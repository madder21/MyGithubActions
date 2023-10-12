@IsTest
public with sharing class SOM_SalesPaymentUKMonthSchedule_Test {
    @IsTest (seeAllData = true)
   static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_SalesPaymentsReportUKMonthSchedule', '0 0 * * * ?', new SOM_SalesPaymentsReportUKMonthSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
}