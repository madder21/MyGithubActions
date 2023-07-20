/**
 * @author Viseo : Bader-Eddine Elkhal
 * @date September, 3rd 2021
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description :
 * This global class implements the `Schedulable` interface and is used to schedule a batch job that migrates data from one object to another.
 * The `execute` method of this class is called each time the scheduled job is executed, and it retrieves the previous scheduled job's execution time
 * from the `PreviousFireTime` field of the corresponding `CronTrigger` record. This value is then passed to an instance of the `DataMigrationBatch` class
 * that is responsible for migrating the data. If the `PreviousFireTime` value is `null`, yesterday's date is used instead.
 *
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|	Date of modication	|	Modified By		|	Related Jira Ticket		|		Description of changes			
 * 0.0		|	2021/09/03			|	.BEE			|	.						|		.original version						
 * 0.1		|	2023/04/24			|	.PLM			|	.						|		.Buffering of the job previousFireTime, to avoid sending the new execution time
 *    		|	          			|	    			|	.						|		 
*/
global class DataMigrationSchedule implements Schedulable {
   global void execute(SchedulableContext sc) {
       
       // Get the CronTrigger record corresponding to the current scheduled job
       // Retrieve the previous execution time from the custom setting
        BatchLastExecutionTime__c batchLastExecutionTime = BatchLastExecutionTime__c.getOrgDefaults();
        Datetime previousExecutionTime = batchLastExecutionTime.DataMigrationLastExecutionDate__c;
        
       
       // Determine the previous scheduled job's execution time, take the previous fire time if exist in crontrigger or fallback to yesterday's date
       Datetime previousFireTime = previousExecutionTime != null ? previousExecutionTime: Datetime.now().addDays(-1).date();
     
       // Create an instance of the DataMigrationBatch class and pass the previousFireTime as a parameter
       DataMigrationBatch batch = new DataMigrationBatch(false,previousFireTime);
       
       // Execute the batch job
       Database.executeBatch(batch);
       
       // Update the previous execution time in the custom setting
       batchLastExecutionTime.DataMigrationLastExecutionDate__c = Datetime.now();
       upsert batchLastExecutionTime;
   }
}