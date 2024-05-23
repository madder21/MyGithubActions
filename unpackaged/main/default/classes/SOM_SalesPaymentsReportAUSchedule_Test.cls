@IsTest
public with sharing class SOM_SalesPaymentsReportAUSchedule_Test {

    @IsTest (seeAllData = true)
   static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_SalesAndPaymentsReportAUSchedule', '0 0 * * * ?', new SOM_SalesAndPaymentsReportAUSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
    
}