@IsTest
public class SOM_SalesPaymentsReportEUSchedule_Test  {
    @IsTest (seeAllData = true)
    static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_SalesAndPaymentsReportEUSchedule', '0 0 * * * ?', new SOM_SalesAndPaymentsReportEUSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
}