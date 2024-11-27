/**
 * @author Sarah AYOUN (Balink)
 * @date August,10 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is handling the push of silent notifications
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|2024/08/10 		|.Sarah A	|RCLIENT-1235		|.original version to send silent notifications to R-Client App						
*/
public with sharing class CLT_SendSilentPushNotifications {

    public static String SILENT_AGENDA_TYPE = 'silent-agenda';
    public static String SILENT_AGENDA_DELTA_SUBTYPE = 'agenda-delta';
    public static String SILENT_AGENDA_DELETE_SUBTYPE = 'agenda-delete';

    /*
     * @METHOD 	: sendSilentNotifications
     * @DESC 	: Sends silent push notifications to users. If the number of users exceeds 10, the notifications are sent in batches.
     * @PARAM 	: userIds : Set<String> : The set of user IDs to send notifications to, type : String : The type of notification to send, subtype : String : The subtype of notification to send.
     * @RETURN 	: void
     */
    public static void sendSilentNotifications(Set<String> userIds, String type, String subtype){
        if(userIds.size() > 10) {
            CLT_BatchSendSilentPushNotif b = new CLT_BatchSendSilentPushNotif(userIds, type, subtype);
            Database.executeBatch(b, 10);
            return;
        }

        Map<String, Integer> unseenNotifPerUserMap = countUnseenNotificationsPerUser(userIds);
        for(String userId : userIds) {
            Set<String> recipientId = new Set<String>{userId};
            
            Integer unSeenNotif = unseenNotifPerUserMap.containsKey(userId) ? unseenNotifPerUserMap.get(userId) : 0;
            
            sendPushNotification(recipientId, new List<String>(), type, subtype, unSeenNotif);
        }
    }

    /*
     * @METHOD 	: sendSilentNotifications
     * @DESC 	: Sends silent push notifications based on a map of user IDs and associated deleted records. If the number of users exceeds 10, the notifications are sent in batches.
     * @PARAM 	: userDeleteRecordsNotifMap : Map<String, List<String>> : Map of user IDs to lists of deleted record IDs, type : String : The type of notification to send, subtype : String : The subtype of notification to send.
     * @RETURN 	: void
     */
    public static void sendSilentNotifications(Map<String, List<String>> userDeleteRecordsNotifMap, String type, String subtype){
        if(userDeleteRecordsNotifMap.keySet().size() > 10) {
            CLT_BatchSendSilentPushNotif b = new CLT_BatchSendSilentPushNotif(userDeleteRecordsNotifMap, type, subtype);
            Database.executeBatch(b, 10);
            return;
        }

        List<Notification__c> notificationToInsert = new List<Notification__c>();
        Map<String, Integer> unseenNotifPerUserMap = countUnseenNotificationsPerUser(userDeleteRecordsNotifMap.keySet());
        for(String userId : userDeleteRecordsNotifMap.keySet()) {
            Set<String> recipientId = new Set<String>{userId};
            Integer unSeenNotif = unseenNotifPerUserMap.containsKey(userId) ? unseenNotifPerUserMap.get(userId) : 0;
            sendPushNotification(recipientId, userDeleteRecordsNotifMap.get(userId), type, subtype, unSeenNotif);
            for(String delRecordId : userDeleteRecordsNotifMap.get(userId)) {
                notificationToInsert.add(new Notification__c(
                    User__c = userId,
                    SendingTime__c = Datetime.now(),
                    Type__c = type,
                    Subtype__c = subtype,
                    Sent__c = true,
                    Silent__c = true,
                    RelatedRecordId__c = delRecordId
                ));
            }
        }

        insert notificationToInsert;
    }

    /*
     * @METHOD 	: countUnseenNotificationsPerUser
     * @DESC 	: Counts the number of unseen notifications per user in the last 30 days.
     * @PARAM 	: userIds : Set<String> : The set of user IDs to count unseen notifications for.
     * @RETURN 	: Map<String, Integer> : A map of user IDs to the count of unseen notifications.
     */
    private static Map<String, Integer> countUnseenNotificationsPerUser(Set<String> userIds) {
        Map<String, Integer> unredNotifPerUserMap = new Map<String, Integer>();
        for(AggregateResult ar : [SELECT COUNT(Id) countNotif, User__c user
                                FROM Notification__c 
                                WHERE User__c IN :userIds AND Sent__c = TRUE AND Silent__c = FALSE AND Seen__c = FALSE AND SendingTime__c = LAST_N_DAYS:30 AND SendingTime__c <= :DateTime.now()
                                GROUP BY User__c]) {
            unredNotifPerUserMap.put((String)ar.get('user'), (Integer)ar.get('countNotif'));
        }
        return unredNotifPerUserMap;
    }

    /*
     * @METHOD 	: sendPushNotification
     * @DESC 	: Sends a push notification to the specified recipients with the given payload.
     * @PARAM 	: recipientIds : Set<String> : The set of recipient IDs to send the notification to,  deletedRecords : List<String> : List of deleted record IDs to include in the notification,
     *           type : String : The type of notification to send, subtype : String : The subtype of notification to send, badge : Integer : The badge count for the notification.
     * @RETURN 	: void
     */
    public static void sendPushNotification(Set<String> recipientIds, List<String> deletedRecords, String type, String subtype, Integer badge){
        Messaging.PushNotification msg = new Messaging.PushNotification();
        Map<String, Object> customPayload = new Map<String, Object>{
            'deletedRecords' => deletedRecords,
            'type' => type,
            'subtype' => subtype
        };
        
        Map<String, Object> payload = Messaging.PushNotificationPayload.apple('','', badge, customPayload);
        msg.setPayload(payload);
        
        msg.send('Clienteling_App', recipientIds);
    }
}