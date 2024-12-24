global class CLT_BatchReattributedClientsNotif implements Database.Batchable<sObject>, Schedulable {
    String query;
    Integer sendingTimeHour;
    String reattributedListId;

    public CLT_BatchReattributedClientsNotif() {
        RClientConfigurations__c rclientConfigurations = RClientConfigurations__c.getOrgDefaults();
        sendingTimeHour = Integer.valueOf(rclientConfigurations.ReattributedNotifSendHour__c);
        reattributedListId = rclientConfigurations.ReattributedClientListId__c;
        query = 'SELECT Id,StoreCode__c FROM User WHERE Id IN ' +
            '(SELECT Local_Main_CA__c FROM Account WHERE IsPersonAccount = TRUE AND Targeted_Customers_CAreattribution_Notif__c = TRUE)';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<User> scope) {
        List<Notification__c> notificationsToInsert = new List<Notification__c>();

        CLT_NotificationManagement__mdt comboNotificationSetting = [SELECT Id,Type__c,Subtype__c,Name__c,Message__c,RedirectionScreen__c 
                                                                    FROM CLT_NotificationManagement__mdt 
                                                                    WHERE Type__c = 'clienteling' AND  Subtype__c = 'reattributed'
                                                                    LIMIT 1];

        Map<String,List<String>> usersToNotify = new Map<String,List<String>>();
        for(User u : scope) {
            String storeCode = !String.isEmpty(u.StoreCode__c) ? u.StoreCode__c : '#NOSTORE';
            if(!usersToNotify.containsKey(storeCode)) {
                usersToNotify.put(storeCode, new List<String>());
            }
            usersToNotify.get(storeCode).add(u.Id);
        }

        Map<String,Integer> userSendingTimeMap = CLT_PushNotification_Utils.getUsersSendingTimeHour(usersToNotify, sendingTimeHour);
        
        for(User u : scope) {
            notificationsToInsert.add(new Notification__c(
                NotificationManagementId__c = comboNotificationSetting.Id,
                Type__c = comboNotificationSetting.Type__c,
                Subtype__c = comboNotificationSetting.Subtype__c,
                Seen__c = false,
                Read__c = false,
                SendingTime__c = DateTime.newInstanceGMT(Date.today().addDays(1), Time.newInstance(userSendingTimeMap.containsKey(u.Id) ? userSendingTimeMap.get(u.Id) : sendingTimeHour, 0, 0, 0)),
                Title__c = comboNotificationSetting.Name__c,
                Body__c = comboNotificationSetting.Message__c,
                RelatedRecordId__c = reattributedListId,
                TargetScreenId__c = comboNotificationSetting.RedirectionScreen__c,
                User__c = u.Id
            ));
        }

        insert notificationsToInsert;

        Set<Id> userIds = (new Map<Id, User>(scope)).keySet();
        List<Account> clientsToUpdate = new List<Account>();
        for(Account client : [SELECT Id,Targeted_Customers_CAreattribution_Notif__c
                            FROM Account
                            WHERE Local_Main_CA__c IN :userIds AND Targeted_Customers_CAreattribution_Notif__c = true]) {
            client.Targeted_Customers_CAreattribution_Notif__c = false;
            clientsToUpdate.add(client);
        }
        update clientsToUpdate;
    }

    global void finish(Database.BatchableContext BC) {
    }

    global void execute(SchedulableContext sc) {
        CLT_BatchReattributedClientsNotif b = new CLT_BatchReattributedClientsNotif();
        Database.executeBatch(b);
    }
}