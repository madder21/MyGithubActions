@IsTest
public with sharing class SOM_SalesPaymentAUMonthSchedule_Test {
    @IsTest (seeAllData = true)
   static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_SalesPaymentsReportMonthAUSchedule', '0 0 * * * ?', new SOM_SalesPaymentsReportMonthAUSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
}