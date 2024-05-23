@IsTest
public class SOM_SalesPaymentJPMonthSchedule_Test {
    @IsTest (seeAllData = true)
   static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_SalesPaymentsReportMonthJPSchedule', '0 0 * * * ?', new SOM_SalesPaymentsReportMonthJPSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
}