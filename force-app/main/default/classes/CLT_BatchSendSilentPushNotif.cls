/**
 * @author Sarah AYOUN(Balink)
 * @date August, 12 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class handles the batch processing of silent push notifications for user tasks. It processes either a set of user IDs or a map of user IDs with corresponding deleted records, sending notifications accordingly.
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modification   |Modified By            |Related Jira Ticket|Description of changes			
 * 1.0		|2024/08/12		        |.Sarah AYOUN(Balink)   |RCLIENT-1235	    |Original version. send silent notification in chuncks of 10				
*/
public with sharing class CLT_BatchSendSilentPushNotif implements Database.Batchable<SObject>, Database.Stateful {

    private Set<String> userIds;
    private Map<String, List<String>> userDeleteRecordsNotifMap;
    private String type;
    private String subtype;

    /**
     * Constructor that initializes the batch job with a set of user IDs.
     * @PARAM: Set<String> userIds: The set of user IDs for which notifications will be sent, String type: The type of notification to be sent, String subtype: The subtype of notification to be sent.
     * @return : none
     */
    public CLT_BatchSendSilentPushNotif(Set<String> userIds, String type, String subtype) {
        this.userDeleteRecordsNotifMap = new Map<String, List<String>>();
        this.userIds = userIds;
        this.type = type;
        this.subtype = subtype;
    }

    /**
     * Constructor that initializes the batch job with a map of user IDs and their corresponding deleted records.
     * @PARAM: Map<String, List<String>> userDeleteRecordsNotifMap: A map containing user IDs and a list of deleted record IDs for each user, String type: The type of notification to be sent,
     *         String subtype: The subtype of notification to be sent.
     * @return : none
     */
    public CLT_BatchSendSilentPushNotif(Map<String, List<String>> userDeleteRecordsNotifMap, String type, String subtype) {
        this.userDeleteRecordsNotifMap = userDeleteRecordsNotifMap;
        this.userIds = new Set<String>();
        this.type = type;
        this.subtype = subtype;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        if(userDeleteRecordsNotifMap.keySet().size() > 0) {
            return Database.getQueryLocator([SELECT Id FROM User WHERE Id IN :userDeleteRecordsNotifMap.keySet()]);
        }
        else {
            return Database.getQueryLocator([SELECT Id FROM User WHERE Id IN :userIds]);
        }
        
    }

    /**
     * This method processes each batch of records and sends silent notifications.
     * @PARAM: List<SObject> scope: List of user records to process in the current batch
     * @return : none
     */
    public void execute(Database.BatchableContext BC, List<SObject> scope) {
        if(userDeleteRecordsNotifMap.keySet().size() > 0) {
            Map<String, List<String>> batchUserDeleteRecordsNotifMap = new Map<String, List<String>>();

            for (SObject sObj : scope) {
                String userId = (String)sObj.get('Id');
                batchUserDeleteRecordsNotifMap.put(userId, userDeleteRecordsNotifMap.get(userId));
            }

            // Call the sendSilentNotifications method for each batch
            CLT_SendSilentPushNotifications.sendSilentNotifications(userDeleteRecordsNotifMap, type, subtype);
        }
        else {
            Set<String> batchUserIds = new Set<String>();

            for (SObject sObj : scope) {
                batchUserIds.add((String)sObj.get('Id'));
            }
    
            // Call the sendSilentNotifications method for each batch
            CLT_SendSilentPushNotifications.sendSilentNotifications(batchUserIds, type, subtype);
        }
    }

    public void finish(Database.BatchableContext BC) {
    }
}