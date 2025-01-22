global class CLT_BatchComboChallengeNotif implements Database.Batchable<sObject>, Schedulable {
    String query;
    Date dateOfPurchase;
    Integer nbOfDaysAfterPurchase;
    Integer sendingTimeHour;

    public CLT_BatchComboChallengeNotif() {
        RClientConfigurations__c rclientConfigurations = RClientConfigurations__c.getOrgDefaults();
        nbOfDaysAfterPurchase = Integer.valueOf(rclientConfigurations.ComboChallengeNotificationAfter__c);
        sendingTimeHour = Integer.valueOf(rclientConfigurations.ComboChallengeNotifSendHour__c);
        dateOfPurchase = Date.today().addDays(-nbOfDaysAfterPurchase);
        query = 'SELECT Id,Last_Transaction_SA__pc,Last_Transaction_SA__pr.StoreCode__c,LastPurchaseDate__pc,FirstPurchaseDate__pc, ' + 
                    '(SELECT TransactionDate__c, LocalOrTourist__c ' +
                    'FROM Transactions__r ' +
                    'WHERE TransactionDate__c = :dateOfPurchase ORDER BY CreatedDate DESC LIMIT 1),' +
                    '(SELECT ReviewedInformation__c FROM Client_Insights__r WHERE LastReviewDate__c >= :dateOfPurchase),' +
                    '(SELECT Id,Outreach_Type__c,OwnerId FROM Tasks ' +
                    'WHERE CreatedDate >= LAST_N_DAYS:' + nbOfDaysAfterPurchase + ' AND (Outreach_Type__c = NULL OR (Outreach_Type__c != NULL AND Outreach_Type__c NOT IN (\'Gift\',\'Event\',\'Wishlist\'))))' +
                'FROM Account ' +
                'WHERE LastPurchaseDate__pc = :dateOfPurchase AND Id NOT IN ' +
                    '(SELECT Client__c FROM ClientSource__c WHERE (SourceCode__c LIKE \'____\'  OR SourceCode__c LIKE \'%000000\'))';
                System.debug(query);
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Notification__c> notificationsToInsert = new List<Notification__c>();

        CLT_NotificationManagement__mdt comboNotificationSetting = [SELECT Id,Type__c,Subtype__c,Name__c,Message__c,RedirectionScreen__c 
                                                                    FROM CLT_NotificationManagement__mdt 
                                                                    WHERE Type__c = 'general' AND  Subtype__c = 'combo'
                                                                    LIMIT 1];

        List<Account> clientsToNotify = getClientsToNotifyList(scope);
        Map<String, List<String>> usersToNotify = new Map<String, List<String>>();
        for(Account client : clientsToNotify) {
            String storeCode = !String.isEmpty(client.Last_Transaction_SA__pr.StoreCode__c) ? client.Last_Transaction_SA__pr.StoreCode__c : '#NOSTORE';
            if(!usersToNotify.containsKey(storeCode)) {
                usersToNotify.put(storeCode, new List<String>());
            }
            usersToNotify.get(storeCode).add(client.Last_Transaction_SA__pc);
        }

        Map<String,Integer> userSendingTimeMap = CLT_PushNotification_Utils.getUsersSendingTimeHour(usersToNotify, sendingTimeHour);

        for(Account client : clientsToNotify) {
            notificationsToInsert.add(new Notification__c(
                NotificationManagementId__c = comboNotificationSetting.Id,
                Type__c = comboNotificationSetting.Type__c,
                Subtype__c = comboNotificationSetting.Subtype__c,
                Seen__c = false,
                Read__c = false,
                SendingTime__c = DateTime.newInstanceGMT(Date.today().addDays(1), Time.newInstance(userSendingTimeMap.containsKey(client.Last_Transaction_SA__pc) ? userSendingTimeMap.get(client.Last_Transaction_SA__pc) : sendingTimeHour, 0, 0, 0)),
                Title__c = comboNotificationSetting.Name__c,
                Body__c = comboNotificationSetting.Message__c,
                TargetScreenId__c = comboNotificationSetting.RedirectionScreen__c,
                Client__c = client.Id,
                User__c = client.Last_Transaction_SA__pc
            ));
        }

        insert notificationsToInsert;
    }

    global void finish(Database.BatchableContext BC) {
    }

    global void execute(SchedulableContext sc) {
         

    }

    public List<Account> getClientsToNotifyList(List<Account> scope) {
        Map<String,Account> challengeClientsMap = getChallengeClientsMap(scope);
        List<Account> clientToNotify = new List<Account>();

        if(challengeClientsMap.keySet().size() > 0) {
            Map<String, List<String>> clientNotesMap = getClientNotesMap(challengeClientsMap.keySet());
        
            for(Account client : challengeClientsMap.values()) {
                Boolean isFirstPurchase = client.FirstPurchaseDate__pc == client.LastPurchaseDate__pc ? true : false;
                Integer doneCombo = 0;
                Boolean isTourist = getIsTouristTransaction(client);
                Boolean isReviewedInsights = getIsReviewedInsights(client);

                if(isReviewedInsights) {
                    doneCombo ++;
                }

                if(!isReviewedInsights && clientNotesMap.containsKey(client.Id) && ((isFirstPurchase && clientNotesMap.get(client.Id).size() >= 5) || (!isFirstPurchase && clientNotesMap.get(client.Id).size() >= 1))) {
                    doneCombo ++;
                }

                Boolean taskDone = false;
                Boolean outrechDone = false;
                for(Task currentTask : client.Tasks) {
                    if(currentTask.OwnerId == client.Last_Transaction_SA__pc) {
                        if(!isTourist && String.isEmpty(currentTask.Outreach_Type__c)) {
                            taskDone = true;
                        }
                        else if(!String.isEmpty(currentTask.Outreach_Type__c)) {
                            outrechDone = true;
                        }
                    }
                }
                if(taskDone) {
                    doneCombo ++;
                }
                if(outrechDone) {
                    doneCombo ++;
                }

                if((!isTourist && doneCombo < 3) || doneCombo < 2) {
                    clientToNotify.add(client);
                }
            }
        }
        return clientToNotify;
    }

    public Map<String,Account> getChallengeClientsMap(List<Account> scope) {
        Map<Id,Account> clientsMap = new Map<Id,Account>(scope);
        Map<String,Account> challengeClientsMap = new Map<String,Account>();
        for(Transaction__c t : [SELECT Client__c,
                                    (SELECT Id 
                                    FROM Transaction_Items__r 
                                    WHERE (NOT Product__r.StockKeepingUnit LIKE '2%') AND Product__r.macrofunction__c != 'REPARATION' 
                                        AND Type__c = 'Sale' AND ExclTaxAmount__c > 0)
                                FROM Transaction__c 
                                WHERE TransactionDate__c = :dateOfPurchase AND Client__c IN :clientsMap.keySet()]) {
            if(t.Transaction_Items__r.size() > 0) {
                Account client = clientsMap.get(t.Client__c);
                challengeClientsMap.put(client.Id, client);
            }
        }
        return challengeClientsMap;
    }

    public Map<String, List<String>> getClientNotesMap(Set<String> challengeClientIds) {
        Map<String, List<String>> clientNotesMap = new Map<String, List<String>>();
        for(Client_Insight_History__c cih : [SELECT ModifiedField__c,ClientInsight__r.Client__c,ClientInsight__r.Client__r.Last_Transaction_SA__pc,ModifiedAt__c,ModifiedBy__c
                                            FROM Client_Insight_History__c
                                            WHERE ClientInsight__r.Client__c IN :challengeClientIds AND ModifiedAt__c >= :dateOfPurchase]) {
            if(cih.ClientInsight__r.Client__r.Last_Transaction_SA__pc == cih.ModifiedBy__c) {
                if(!clientNotesMap.containsKey(cih.ClientInsight__r.Client__c)) {
                    clientNotesMap.put(cih.ClientInsight__r.Client__c, new List<String>());
                }
                if(!clientNotesMap.get(cih.ClientInsight__r.Client__c).contains(cih.ModifiedField__c)) {
                    clientNotesMap.get(cih.ClientInsight__r.Client__c).add(cih.ModifiedField__c);
                }
            }
            
        }

        for(Note_History__c noteH : [SELECT Note__r.Client__c,Note__r.Client__r.Last_Transaction_SA__pc,ModifiedAt__c,ModifiedBy__c
                                    FROM Note_History__c
                                    WHERE Note__r.Client__c IN :challengeClientIds AND ModifiedAt__c >= :dateOfPurchase]) {
            if(noteH.Note__r.Client__r.Last_Transaction_SA__pc == noteH.ModifiedBy__c) {
                if(!clientNotesMap.containsKey(noteH.Note__r.Client__c)) {
                    clientNotesMap.put(noteH.Note__r.Client__c, new List<String>());
                }
                if(!clientNotesMap.get(noteH.Note__r.Client__c).contains('note-comment')) {
                    clientNotesMap.get(noteH.Note__r.Client__c).add('note-comment');
                }
            }
        }

        return clientNotesMap;
    }

    public Boolean getIsTouristTransaction(Account client) {
        Boolean isTourist = false;

        for(Transaction__c currentTransaction : client.Transactions__r) {
            isTourist = currentTransaction.LocalOrTourist__c == 'Tourist' ? true : false; 
        }

        return isTourist;
    }

    public Boolean getIsReviewedInsights(Account client) {
        Boolean isReviewedInsights = false;

        for(Client_Insight__c ci : client.Client_Insights__r) {
            Map<String, Object> reviewedInformationMap = !String.isEmpty(ci.ReviewedInformation__c) ? (Map<String, Object>)JSON.deserializeUntyped(ci.ReviewedInformation__c) : new Map<String, Object>();
            if(reviewedInformationMap.containsKey(client.Last_Transaction_SA__pc)) {
                List<String> userReviewedDateList = ((String)reviewedInformationMap.get(client.Last_Transaction_SA__pc)).split('-');
                Date userReviewedDate = userReviewedDateList.size() == 3 ? Date.newInstance(Integer.valueOf(userReviewedDateList[2]), Integer.valueOf(userReviewedDateList[1]), Integer.valueOf(userReviewedDateList[0])) : Date.newInstance(2000, 1, 1);
                if(userReviewedDate >= dateOfPurchase) {
                    isReviewedInsights = true;
                }
            }
        }

        return isReviewedInsights;
    }
}