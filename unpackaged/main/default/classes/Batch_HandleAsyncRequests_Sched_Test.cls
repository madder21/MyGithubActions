@isTest 
public class Batch_HandleAsyncRequests_Sched_Test {
	
    @isTest 
    static void testScheduledJob() { 
        // Execute the scheduled job in test context => Launch the job
        Test.startTest();
        
        // Create an account for reference
        Account accountForTesting = new Account(FirstName = 'Chloé', LastName = 'Burté', PersonEmail = 'chloe.burte.test@gmail.com');
        insert accountForTesting;
                
        // Create test accounts to be updated
        List<Async_Job_Request__c> lNewAsyncRequests = new List<Async_Job_Request__c> ();
		For (Integer i=0; i<100; i++) {
            Async_Job_Request__c currentAsyncRequest = new Async_Job_Request__c (TriggeringObject__c='Account',Status__c='NewLog', recordId__c = accountForTesting.Id, ContextInformation__c = 'TEST');
            lNewAsyncRequests.add(currentAsyncRequest);
        }
        For (Integer j=0; j<25; j++) {
            Async_Job_Request__c currentAsyncRequest = new Async_Job_Request__c (TriggeringObject__c='Account',Status__c='InProgress', recordId__c = accountForTesting.Id, ContextInformation__c = 'TEST');
            lNewAsyncRequests.add(currentAsyncRequest);
        }
        For (Integer k=0; k<25; k++) {
            Async_Job_Request__c currentAsyncRequest = new Async_Job_Request__c (TriggeringObject__c='Undefined', Status__c='InProgress', recordId__c = accountForTesting.Id, ContextInformation__c = 'TEST');
            lNewAsyncRequests.add(currentAsyncRequest);
        }
        insert lNewAsyncRequests;
        
        
        Batch_HandleAsyncRequests_Schedulable job = new Batch_HandleAsyncRequests_Schedulable(); 
        String jobId = System.schedule('Test Class - Test Batch_HandleAsyncRequests_Schedulable', '0 0 * * * ?', job);
        job.execute(null); 
                         
                
        // Verify that the job was scheduled 
        CronTrigger ct = [SELECT Id, CronExpression FROM CronTrigger WHERE Id = :jobId]; 
        System.assertNotEquals(null, ct, 'Test Class - Test Batch_HandleAsyncRequests_Schedulable - CronTrigger should not be null'); 

        // Verify that the data was processed 
        List<Async_Job_Request__c> lTestAsyncRequests = [SELECT Id, Name, TriggeringObject__c, RecordId__c, SerializedObject__c, Status__c, RunningJobId__c,
                                                         		ContextInformation__c, Createddate, lastmodifieddate, SystemModstamp
                                                                FROM Async_Job_Request__c
																WHERE Status__c = 'NewLog' AND ContextInformation__c = 'TEST'
																ORDER BY SystemModstamp ASC]; 
        System.assertEquals(100, lTestAsyncRequests.size(), 'Batch_HandleAsyncRequests_Sched_Test - testScheduledJob() - the list size is incorrect'); 
        
        Test.stopTest(); 

    } 
}