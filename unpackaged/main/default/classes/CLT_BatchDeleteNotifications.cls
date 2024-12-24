/**
 * @author Sarah AYOUN(Balink)
 * @date August,19 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is an Apex Batch (+ it's scheduler) to be run every day to delete notifications from more than 30 days 
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|2024/08/19			|.Sarah A	|RCLIENT-976		|.Original version						
*/
global class CLT_BatchDeleteNotifications implements Database.Batchable<sObject>, Schedulable  {
    String query;

    /*
     * @METHOD 	: CLT_BatchDeleteNotifications
     * @DESC 	: Constractor to define which notifications are to be deleted
     * @PARAM 	: none
     * @RETURN 	: build the new Batch with the correct query to run
     */
    public CLT_BatchDeleteNotifications() {
        //silent notifications that are older than 2 days ago, non silent notifications that are older than 40 days ago
        query = 'SELECT Id FROM Notification__c WHERE ((Silent__c = FALSE AND SendingTime__c < LAST_N_DAYS:30) OR (Silent__c = TRUE AND SendingTime__c < LAST_N_DAYS:2))';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    /*
     * @METHOD 	: execute
     * @DESC 	: delete the queried notifications
     * @PARAM 	: List<Notification__c> list of 10000 notifications to delete in each iteration
     * @RETURN 	: none
     */
    global void execute(Database.BatchableContext BC, List<Notification__c> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {

    }

    /*
     * @METHOD 	: execute (Apex Schedular)
     * @DESC 	: schedule the job with chuncks of 10000
     * @PARAM 	: schedulable context
     * @RETURN 	: none
     */
    global void execute(SchedulableContext sc) {
        CLT_BatchDeleteNotifications b = new CLT_BatchDeleteNotifications();
        Database.executeBatch(b, 10000);
    }
}