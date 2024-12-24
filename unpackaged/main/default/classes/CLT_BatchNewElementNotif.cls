global class CLT_BatchNewElementNotif implements Database.Batchable<sObject>, Schedulable {
    DateTime lastRunning;
    DateTime currentRunningStart;
    String query;

    Map<String, String> countryStoreCodeMap = new Map<String, String>();
    Map<String, String> regionStoreCodeMap = new Map<String, String>();
    Map<String, CLT_NotificationManagement__mdt> notificationManagementMap = new Map<String, CLT_NotificationManagement__mdt>();

    Map<String,List<Event__c>> countriesEventsMap = new Map<String,List<Event__c>>();
    Map<String,List<Event__c>> regionsEventsMap = new Map<String,List<Event__c>>();
    List<Event__c> newEvents = new List<Event__c>();
    Map<String,List<Gift__c>> countriesGiftsMap = new Map<String,List<Gift__c>>();
    Map<String,List<Gift__c>> regionsGiftsMap = new Map<String,List<Gift__c>>();
    List<Gift__c> newGifts = new List<Gift__c>();
    List<Catalog_Product__c> newCatalogProducts;
    Map<String,List<CLT_Email_Template__c>> newEmailTemplatesMap = new Map<String,List<CLT_Email_Template__c>>();

    Integer newProductSendingTimeHour;
    Integer newEventSendingTimeHour ;
    Integer newGiftSendingTimeHour;
    Integer newEmailTemplateSendingTimeHour;

    public CLT_BatchNewElementNotif() {
        RClientConfigurations__c rclientConfigurations = RClientConfigurations__c.getOrgDefaults();
        newProductSendingTimeHour = Integer.valueOf(rclientConfigurations.NewProductNotifSendHour__c);
        newEventSendingTimeHour = Integer.valueOf(rclientConfigurations.NewEventNotifSendHour__c);
        newGiftSendingTimeHour = Integer.valueOf(rclientConfigurations.NewGiftNotifSendHour__c);
        newEmailTemplateSendingTimeHour = Integer.valueOf(rclientConfigurations.NewEmailTemplateNotifSendHour__c);
        lastRunning = rclientConfigurations.NewElementNotifBatchLastRun__c != null ? rclientConfigurations.NewElementNotifBatchLastRun__c : DateTime.now().addDays(-1);
        currentRunningStart = DateTime.now();
        System.debug('CLT_BatchNewElementNotif lastRunning--> ' + lastRunning);
        System.debug('CLT_BatchNewElementNotif currentRunningStart--> ' + currentRunningStart);
        setStoresMaps(countryStoreCodeMap, regionStoreCodeMap);

        for(CLT_NotificationManagement__mdt notifMgmnt : [SELECT Id,Type__c,Subtype__c,Name__c,Message__c,RedirectionScreen__c FROM CLT_NotificationManagement__mdt]) {
            notificationManagementMap.put(notifMgmnt.Type__c + '_' + notifMgmnt.Subtype__c, notifMgmnt);
        }

        setEventMapsAndList(lastRunning, currentRunningStart, countriesEventsMap, regionsEventsMap, newEvents);
        setGiftMapsAndList(lastRunning, currentRunningStart, countriesGiftsMap, regionsGiftsMap, newGifts);
        newCatalogProducts = [SELECT Id FROM Catalog_Product__c WHERE CreatedDate > :lastRunning AND CreatedDate < :currentRunningStart LIMIT 2];
        setEmailTemplatesMap(lastRunning, currentRunningStart, newEmailTemplatesMap);

        query = 'SELECT Id,StoreCode__c,Email_templates__c FROM User WHERE ';
        if(countriesEventsMap.keySet().size() > 0 || regionsEventsMap.keySet().size() > 0 || newEvents.size() > 0 || 
            countriesGiftsMap.keySet().size() > 0 || regionsGiftsMap.keySet().size() > 0 || newGifts.size() > 0 ||
            newCatalogProducts.size() > 0 || newEmailTemplatesMap.keySet().size() > 0) {
            query += 'IsActive = true AND (Profile.Name = \'' + System.Label.profileName_StoreUser + '\' OR Profile.Name = \'' + System.Label.profileName_SystemAdministrator + '\')';
        }
        else {
            query += 'Id = NULL';
        }
        if(Test.isRunningTest()) {
            String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

            User sa = [SELECT Id,StoreCode__c FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
            query +=  ' AND Id = \'' + sa.Id + '\'';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('query--> ' + query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope) {
        Map<String, List<String>> usersToNotify = new Map<String, List<String>>();
        for(User u : scope) {
            String storeCode = !String.isEmpty(u.StoreCode__c) ? u.StoreCode__c : '#NOSTORE';
            if(!usersToNotify.containsKey(storeCode)) {
                usersToNotify.put(storeCode, new List<String>());
            }
            usersToNotify.get(storeCode).add(u.Id);
        }

        Map<String,Integer> newProductUserSendingTimeMap = CLT_PushNotification_Utils.getUsersSendingTimeHour(new Map<String, List<String>>(usersToNotify), newProductSendingTimeHour);
        Map<String,Integer> newEventUserSendingTimeMap = CLT_PushNotification_Utils.getUsersSendingTimeHour(new Map<String, List<String>>(usersToNotify), newEventSendingTimeHour);
        Map<String,Integer> newGiftUserSendingTimeMap = CLT_PushNotification_Utils.getUsersSendingTimeHour(new Map<String, List<String>>(usersToNotify), newGiftSendingTimeHour);
        Map<String,Integer> newEmailTemplateUserSendingTimeMap = CLT_PushNotification_Utils.getUsersSendingTimeHour(new Map<String, List<String>>(usersToNotify), newEmailTemplateSendingTimeHour);

        List<Notification__c> notificationsToInsert = new List<Notification__c>();

        for(User u : scope) {
            if(newCatalogProducts.size() > 0) {
                if(newCatalogProducts.size() == 1) {
                    notificationsToInsert.add(createNotificationToInsert(notificationManagementMap.get('product_new'), newProductUserSendingTimeMap.containsKey(u.Id) ? newProductUserSendingTimeMap.get(u.Id) : newProductSendingTimeHour, newCatalogProducts[0].Id, null, u.Id));
                }
                else {
                    notificationsToInsert.add(createNotificationToInsert(notificationManagementMap.get('product_new'),  newProductUserSendingTimeMap.containsKey(u.Id) ? newProductUserSendingTimeMap.get(u.Id) : newProductSendingTimeHour, null, null, u.Id));
                }
            }
            if(newEvents.size() > 0 || (countriesEventsMap.keySet().size() > 0 && countriesEventsMap.containsKey(countryStoreCodeMap.get(u.StoreCode__c))) 
                || (regionsEventsMap.keySet().size() > 0 && regionsEventsMap.containsKey(regionStoreCodeMap.get(u.StoreCode__c)))) {
                notificationsToInsert.add(createNotificationToInsert(notificationManagementMap.get('clienteling_event'),  newEventUserSendingTimeMap.containsKey(u.Id) ? newEventUserSendingTimeMap.get(u.Id) : newEventSendingTimeHour, null, null, u.Id));
            }
            if(newGifts.size() > 0 || (countriesGiftsMap.keySet().size() > 0 && countriesGiftsMap.containsKey(countryStoreCodeMap.get(u.StoreCode__c))) 
                || (regionsGiftsMap.keySet().size() > 0 && regionsGiftsMap.containsKey(regionStoreCodeMap.get(u.StoreCode__c)))) {
                notificationsToInsert.add(createNotificationToInsert(notificationManagementMap.get('clienteling_gift'),  newGiftUserSendingTimeMap.containsKey(u.Id) ? newGiftUserSendingTimeMap.get(u.Id) : newGiftSendingTimeHour, null, null, u.Id));
            }
            if(newEmailTemplatesMap.keySet().size() > 0) {
                Boolean userLaguageAdded = false;
                if(newEmailTemplatesMap.containsKey('EN')) {
                    userLaguageAdded = true;
                }
                else if(!String.isEmpty(u.Email_templates__c)) { 
                    for(String uLang : u.Email_templates__c.split('\\;')) {
                        if(newEmailTemplatesMap.containsKey(uLang)) {
                            userLaguageAdded = true;
                        }
                    }
                }

                if(userLaguageAdded) {
                    notificationsToInsert.add(createNotificationToInsert(notificationManagementMap.get('clienteling_template'),  newEmailTemplateUserSendingTimeMap.containsKey(u.Id) ? newEmailTemplateUserSendingTimeMap.get(u.Id) : newEmailTemplateSendingTimeHour, null, null, u.Id));
                }
            }
        }

        insert notificationsToInsert;
        
    }

    global void finish(Database.BatchableContext BC) {
        RClientConfigurations__c rclientConfigurations = RClientConfigurations__c.getOrgDefaults();
        rclientConfigurations.NewElementNotifBatchLastRun__c = currentRunningStart;
        update rclientConfigurations;
    }

    global void execute(SchedulableContext sc) {
        CLT_BatchNewElementNotif b = new CLT_BatchNewElementNotif();
        Database.executeBatch(b);
    }

    private static void setStoresMaps(Map<String, String> countryStoreCodeMap, Map<String, String> regionStoreCodeMap) {
        for (Store__c store : [SELECT SourceStoreId__c,Country__c,Region__c FROM Store__c]) {
            if(store.Country__c != null) {
                countryStoreCodeMap.put(store.SourceStoreId__c, store.Country__c);
            }
            if(store.Region__c != null) {
                regionStoreCodeMap.put(store.SourceStoreId__c, store.Region__c);
            }
        }
    }

    private static Notification__c createNotificationToInsert(CLT_NotificationManagement__mdt comboNotificationSetting, Integer sendingTimeHour, String relatedRecordId, String clientId, String userId) {
        return new Notification__c(
            NotificationManagementId__c = comboNotificationSetting.Id,
            Type__c = comboNotificationSetting.Type__c,
            Subtype__c = comboNotificationSetting.Subtype__c,
            Seen__c = false,
            Read__c = false,
            SendingTime__c = DateTime.newInstanceGMT(Date.today().addDays(1), Time.newInstance(sendingTimeHour, 0, 0, 0)),
            Title__c = comboNotificationSetting.Name__c,
            Body__c = comboNotificationSetting.Message__c,
            TargetScreenId__c = comboNotificationSetting.RedirectionScreen__c,
            RelatedRecordId__c = relatedRecordId,
            Client__c = clientId,
            User__c = userId
        );
    }

    private static void setEventMapsAndList(Datetime lastRunning, Datetime currentRunningStart, Map<String,List<Event__c>> countriesEventsMap, Map<String, List<Event__c>> regionsEventsMap, List<Event__c> newEvents) {
        for(Event__c evnt : [SELECT Id,Countries__c,Region__c
                            FROM Event__c 
                            WHERE (ActiveFrom__c != NULL AND ActiveFrom__c > :lastRunning.date() AND ActiveFrom__c >= TODAY) OR 
                                (ActiveFrom__c = NULL AND CreatedDate > :lastRunning AND CreatedDate < :currentRunningStart) OR
                                (ActiveFrom__c != NULL AND ActiveFrom__c = :lastRunning.date() AND CreatedDate > :lastRunning)]) {
            if(evnt.Countries__c != null) {
                for(String country : evnt.Countries__c.split(';')) {
                    if(!countriesEventsMap.containsKey(country)) {
                        countriesEventsMap.put(country, new List<Event__c>());
                    }
                    countriesEventsMap.get(country).add(evnt);
                }
            }
            else if(evnt.Region__c != null) {
                if(!regionsEventsMap.containsKey(evnt.Region__c)) {
                    regionsEventsMap.put(evnt.Region__c, new List<Event__c>());
                }
                regionsEventsMap.get(evnt.Region__c).add(evnt);
            }
            else {
                newEvents.add(evnt);
            }
        }
    }

    private static void setGiftMapsAndList(Datetime lastRunning, Datetime currentRunningStart, Map<String,List<Gift__c>> countriesGiftsMap, Map<String, List<Gift__c>> regionsGiftsMap, List<Gift__c> newGifts) {
        for(Gift__c gift : [SELECT Id,Countries__c,Region__c
                            FROM Gift__c 
                            WHERE (ActiveFrom__c != NULL AND ActiveFrom__c > :lastRunning.date() AND ActiveFrom__c >= TODAY) OR 
                                (ActiveFrom__c = NULL AND CreatedDate > :lastRunning AND CreatedDate < :currentRunningStart) OR
                                (ActiveFrom__c != NULL AND ActiveFrom__c = :lastRunning.date() AND CreatedDate > :lastRunning)]) {
            if(gift.Countries__c != null) {
                for(String country : gift.Countries__c.split(';')) {
                    if(!countriesGiftsMap.containsKey(country)) {
                        countriesGiftsMap.put(country, new List<Gift__c>());
                    }
                    countriesGiftsMap.get(country).add(gift);
                }
            }
            else if(gift.Region__c != null) {
                if(!regionsGiftsMap.containsKey(gift.Region__c)) {
                    regionsGiftsMap.put(gift.Region__c, new List<Gift__c>());
                }
                regionsGiftsMap.get(gift.Region__c).add(gift);
            }
            else {
                newGifts.add(gift);
            }
        }
    }

    private static void setEmailTemplatesMap(Datetime lastRunning, Datetime currentRunningStart, Map<String, List<CLT_Email_Template__c>> newEmailTemplatesMap) {
        Map<String, String> etLanguageMap = new Map<String, String>();
        for(Folder f : [SELECT Name,DeveloperName FROM Folder WHERE Type = 'Email' AND Name != 'Sharing Templates']) {
            etLanguageMap.put(f.DeveloperName,f.Name.substringBefore(' '));
        }

        for(CLT_Email_Template__c et : [SELECT Id,JSON__c
                                        FROM CLT_Email_Template__c 
                                        WHERE Is_Active__c = TRUE AND PersonalizedTemplate__c = FALSE AND CreatedDate > :lastRunning AND CreatedDate < :currentRunningStart]) {
            String etLang = etLanguageMap.get((String)(((Map<String, Object>)JSON.deserializeUntyped(et.JSON__c)).get('developerName')));
            if(!newEmailTemplatesMap.containsKey(etLang)) {
                newEmailTemplatesMap.put(etLang, new List<CLT_Email_Template__c>());
            }
            newEmailTemplatesMap.get(etLang).add(et);
        }
    }
}