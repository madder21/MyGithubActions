@IsTest
public with sharing class SOM_USReportMonthSchedule_Test {
    @IsTest (seeAllData = true)
    static void test() {
    Test.startTest();
        String chron = '0 0 * * * ?';        
        String jobid = System.schedule('SOM_USReportMonthSchedule', '0 0 * * * ?', new SOM_USReportMonthSchedule() );
        CronTrigger ct = [SELECT id , CronExpression FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(chron,ct.CronExpression); 
    Test.stopTest();
   }
}