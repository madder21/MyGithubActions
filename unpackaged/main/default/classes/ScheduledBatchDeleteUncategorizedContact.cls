/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************

 * ScheduledBatchDeleteUncategorizedContact Class
 *
 * This global class implements the Schedulable interface to enable scheduling
 * the execution of BatchDeleteUncategorizedContact at predefined intervals.
 * The execute method instantiates the BatchDeleteUncategorizedContact batch class
 * and triggers its execution using Database.executeBatch.
 *
 * Scheduling Example:
     *  To schedule this job sunday at midnight every two weeks , use the following Apex code:
 * ```
 * String cronExp = '0 0 0 ? * SUN#2';
 * ScheduledBatchDeleteUncategorizedContact scheduledJob = new ScheduledBatchDeleteUncategorizedContact();
 * System.schedule('Batch Delete Job', cronExp, scheduledJob);
 * ```
 *
 * Note: Adjust the cron expression based on specific scheduling requirements.
 
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|29012024			|.PLM		|.CI-233			|.Add the exclusion of CSC Integration User
*/
global class ScheduledBatchDeleteUncategorizedContact implements Schedulable {

    global void execute(SchedulableContext sc) {
        // Instantiate the batch class
        BatchDeleteUncategorizedContact batchClass = new BatchDeleteUncategorizedContact();

        // Start the batch
        Database.executeBatch(batchClass);
    }
}