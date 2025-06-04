/**
 * @author Sarah A.(Balink)
 * @date Mai, 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class handles sending push notifications for various clienteling-related events. It can handle large sets of notifications by utilizing batch processing if necessary.
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modification   |Modified By            |Related Jira Ticket|Description of changes			
 * 0.0		|2024/05/		        |Sarah A.	            |				    |Original version.
 * 1.0		|2024/08/12		        |Sarah AYOUN(Balink)    |RCLIENT-1235	    |Badge count exclude silent notifications				
*/
public with sharing class CLT_SendPushNotifications {
    /**
     * This method sends notifications based on the provided flow inputs. If there are more than 10 inputs, the method utilizes a batch process.
     * @PARAM List<FlowInputs> flowInput: The list of inputs from the flow, each containing information about the notification to be sent.
     * @RETURN: none
     */
    @InvocableMethod
    public static void sendNotifications(List<FlowInputs> flowInput){
        System.debug('**sendNotifications '+ flowInput);
        if(flowInput.size() > 10) {
            CLT_BatchSendPushNotifications b = new CLT_BatchSendPushNotifications(flowInput);
            Database.executeBatch(b, 10);
            return;
        }
        List<String> notificationsIdToUpdate = new List<String>();
        Map<String, Integer> unseenNotifPerUserMap = countUnseenNotificationsPerUser(flowInput);
        Map<String, Boolean> sentNotifMap = getSentNotifMap(flowInput);
        for(FlowInputs fi : flowInput) {
            Set<String> recipientId = new Set<String>{fi.userId};
            
            if(!sentNotifMap.get(fi.id)) {
                Integer unSeenNotif = unseenNotifPerUserMap.get(fi.userId) != null ? unseenNotifPerUserMap.get(fi.userId) : 0;
                unseenNotifPerUserMap.put(fi.userId, unSeenNotif + 1);
            }
            sendPushNotification(recipientId, fi, unseenNotifPerUserMap.get(fi.userId));
            notificationsIdToUpdate.add(fi.id);
        }
        
        if(notificationsIdToUpdate.size() > 0) {
            updateNotificationRecordsAfterPush(notificationsIdToUpdate);
        }
    }

    /**
     * Counts the number of unseen notifications per user within the last 30 days.
     * @PARAM List<FlowInputs> flowInput: The list of inputs from the flow, each containing information about the notification to be sent.
     * @RETURN: Map<String, Integer>: A map where the key is the user ID and the value is the count of unseen notifications.
     */
    private static Map<String, Integer> countUnseenNotificationsPerUser(List<FlowInputs> flowInput) {
        Map<String, Integer> unredNotifPerUserMap = new Map<String, Integer>();
        List<String> userIds = new List<String>();
        for(FlowInputs fi : flowInput) {
            userIds.add(fi.userId);
        }
        for(AggregateResult ar : [SELECT COUNT(Id) countNotif, User__c user
                                FROM Notification__c 
                                WHERE User__c IN :userIds AND Sent__c = TRUE AND Silent__c = FALSE AND Seen__c = FALSE AND SendingTime__c = LAST_N_DAYS:30 AND SendingTime__c <= :DateTime.now()
                                GROUP BY User__c]) {
            unredNotifPerUserMap.put((String)ar.get('user'), (Integer)ar.get('countNotif'));
        }
        return unredNotifPerUserMap;
    }

    /**
     * Retrieves the sent status of notifications for the given flow inputs.
     * @PARAM List<FlowInputs> flowInput: The list of inputs from the flow, each containing information about the notification to be sent.
     * @RETURN: Map<String, Boolean>: A map where the key is the notification ID and the value is a boolean indicating whether the notification has already been sent.
     */
    private static Map<String, Boolean> getSentNotifMap(List<FlowInputs> flowInput) {
        Map<String, Boolean> sentNotifMap = new Map<String, Boolean>();
        List<String> notifIds = new List<String>();
        for(FlowInputs fi : flowInput) {
            notifIds.add(fi.id);
        }

        for(Notification__c notif : [SELECT Id,Sent__c FROM Notification__c WHERE Id IN :notifIds]) {
            sentNotifMap.put(notif.Id, notif.Sent__c);
        }

        return sentNotifMap;
    }

    /**
     * Sends a push notification to the specified recipients based on the flow input data.
     * @PARAM Set<String> recipientIds: The set of user IDs who will receive the notification.
     * @PARAM FlowInputs input: The input data from the flow, containing details of the notification.
     * @PARAM Integer badge: The badge count for the notification, representing the number of unseen notifications.
     * @RETURN: none
     */
    public static void sendPushNotification(Set<String> recipientIds, FlowInputs input, Integer badge){
        Set<String> mutedRecipientIds = new Set<String>();
        if(!String.isEmpty(input.managementId)) {
            for(User u : [SELECT Id,MutedNotifications__c FROM User WHERE Id IN :recipientIds]) {
                if(!String.isEmpty(u.MutedNotifications__c)) {
                    Map<String, Object> userMutedNotifications = (Map<String, Object>)JSON.deserializeUntyped(u.MutedNotifications__c);
                    if(userMutedNotifications.containsKey(input.managementId)) {
                        String endMutedDateStr = (String)userMutedNotifications.get(input.managementId);
                        List<String> mutedDateStringList = (endMutedDateStr).split('-');
                        Date endMutedDate = Date.newInstance(Integer.valueOf(mutedDateStringList[0]), Integer.valueOf(mutedDateStringList[1]), Integer.valueOf(mutedDateStringList[2]));
                        if(Date.today() < endMutedDate) {
                            mutedRecipientIds.add(u.Id);
                            recipientIds.remove(u.Id);
                        }
                    }
                }
            }
        }

        if(recipientIds.size() > 0) {
            System.debug('**badge: '+badge);
            Messaging.PushNotification msg = new Messaging.PushNotification();
            Map<String, String> customPayload = new Map<String, String>{
                'id' => input.id,
                'type' => input.type,
                'subtype' => input.subtype,
                'title' => input.title,
                'body' => input.body,
                'targetId' => input.targetId,
                'targetScreenId' => input.targetScreenId,
                'relatedClientId' => input.relatedClientId,
                'relatedClientName' => input.relatedClientName
            };

            Map<String, Object> payload = Messaging.PushNotificationPayload.apple(input.title + ': ' + input.body, 'default', badge, customPayload);
            msg.setPayload(payload);

            System.debug('**msg: '+msg);
            msg.send('Clienteling_App', recipientIds);
        }
        if(mutedRecipientIds.size() > 0) {
            System.debug('**badge: '+badge);
            Messaging.PushNotification msg = new Messaging.PushNotification();
            Map<String, String> customPayload = new Map<String, String>{
                'id' => input.id,
                'type' => input.type,
                'subtype' => input.subtype
            };

            Map<String, Object> payload = Messaging.PushNotificationPayload.apple('','', badge, customPayload);
            msg.setPayload(payload);

            System.debug('***muted msg: '+msg);
            msg.send('Clienteling_App', mutedRecipientIds);
        }
    }

    /**
     * Updates the notification records after they have been sent by setting the Sent__c field to true.
     * @PARAM List<String> notificationIds: The list of notification record IDs to be updated.
     * @RETURN: none
     */
    private static void updateNotificationRecordsAfterPush(List<String> notificationIds) {
        List<Notification__c> notificationsToUpdate = [SELECT Id,Sent__c FROM Notification__c WHERE Sent__c = false AND Id IN :notificationIds];
        for(Notification__c notif : notificationsToUpdate) {
            notif.Sent__c = true;
        }
        if(notificationsToUpdate.size() > 0) {
            update notificationsToUpdate;
        }
    }

    public class FlowInputs{
        @InvocableVariable
        public Id id;

        @InvocableVariable
        public String userId;

        @InvocableVariable
        public String managementId;
    
        @InvocableVariable
        public String type;

        @InvocableVariable
        public String subtype;
        
        @InvocableVariable
        public String title;

        @InvocableVariable
        public String body;

        @InvocableVariable
        public String targetId;

        @InvocableVariable
        public String targetScreenId;

        @InvocableVariable
        public String relatedClientId;

        @InvocableVariable
        public String relatedClientName;

        public FlowInputs(){}

        public FlowInputs(Id id, String userId, String managementId, String type, String subtype, String title, String body, String targetId, 
                        String targetScreenId, String relatedClientId, String relatedClientName) {
            this.id = id;
            this.userId = userId;
            this.managementId = managementId;
            this.type = type;
            this.subtype = subtype;
            this.title = title;
            this.body = body;
            this.targetId = targetId;
            this.targetScreenId = targetScreenId;
            this.relatedClientId = relatedClientId;
            this.relatedClientName = relatedClientName;
        }
    }
}