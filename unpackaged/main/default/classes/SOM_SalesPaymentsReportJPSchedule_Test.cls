@IsTest
public class SOM_SalesPaymentsReportJPSchedule_Test  {
    @IsTest (seeAllData = true)
    static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_SalesAndPaymentsReportJPSchedule', '0 0 * * * ?', new SOM_SalesAndPaymentsReportJPSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
}