@IsTest
public with sharing class SOM_SalesPaymentKRMonthSchedule_Test {
    @IsTest (seeAllData = true)
   static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_SalesPaymentsReportMonthKRSchedule', '0 0 * * * ?', new SOM_SalesPaymentsReportMonthKRSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
}