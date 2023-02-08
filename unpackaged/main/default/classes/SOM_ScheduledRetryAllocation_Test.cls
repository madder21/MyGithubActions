@isTest
public class SOM_ScheduledRetryAllocation_Test {
    @IsTest
    public static void testScheduleRetryAlloc() {
        Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_Scheduled_BatchRetryAllocation', '0 0 * * * ?', new SOM_Scheduled_BatchRetryAllocation() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
        Test.stopTest();

    }
}