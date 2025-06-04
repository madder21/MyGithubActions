public with sharing class CLT_BatchSendPushNotifications implements Database.Batchable<sObject> {
    String query;
    List<String> notificationsIds = new List<String>();

    public CLT_BatchSendPushNotifications(List<CLT_SendPushNotifications.FlowInputs> flowInput) {
        for(CLT_SendPushNotifications.FlowInputs fi : flowInput) {
            if(!String.isEmpty(fi.id))
            notificationsIds.add(fi.id);
        }

        query = 'SELECT Id,User__c,NotificationManagementId__c,Type__c,Subtype__c,Seen__c,Read__c,SendingTime__c,Title__c,Body__c,RelatedRecordId__c,TargetScreenId__c,Client__c,Client__r.Name ' + 
                ' FROM Notification__c ' + 
                ' WHERE Id '+ (notificationsIds.size() > 0 ? ' IN :notificationsIds' : ' = NULL');
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Notification__c> scope) {
        List<CLT_SendPushNotifications.FlowInputs> flowInputToPush = new List<CLT_SendPushNotifications.FlowInputs>();
        for(Notification__c notif : scope) {
            flowInputToPush.add(new CLT_SendPushNotifications.FlowInputs(notif.Id, notif.User__c, notif.NotificationManagementId__c, notif.Type__c,
                notif.Subtype__c, notif.Title__c, notif.Body__c, notif.RelatedRecordId__c, notif.TargetScreenId__c, notif.Client__c, (notif.Client__c != null ? notif.Client__r.Name : ''))
            );
        }
        
        CLT_SendPushNotifications.sendNotifications(flowInputToPush);
    }

    public void finish(Database.BatchableContext BC) {
    }
}