/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @Description : Test class for Schedulable Class : ScheduledBatchDeleteUncategorizedContact
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|29012024			|.PLM		|.CI-233			|.Add the exclusion of CSC Integration User
*/
@isTest
private class SchedBatchDeleteUncategorizedContactTest {

    @isTest
    static void testSchedBatchDeleteUncategorizedContact() {
        // Schedule the job to run immediately
        Test.startTest();
        String cronExp = '0 0 0 ? * SUN#2';
        ScheduledBatchDeleteUncategorizedContact scheduledJob = new ScheduledBatchDeleteUncategorizedContact();
        System.schedule('Test Batch Delete Job', cronExp, scheduledJob);
        Test.stopTest();

    }
}