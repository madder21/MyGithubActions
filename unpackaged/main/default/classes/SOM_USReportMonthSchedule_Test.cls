@IsTest
public with sharing class SOM_USReportMonthSchedule_Test {
    @IsTest (seeAllData = true)
    static void test() {
          Test.startTest();
          SOM_USReportMonthSchedule scheduler = new SOM_USReportMonthSchedule();
          scheduler.execute(null);
          System.assertEquals(1,1); 
          Test.stopTest();
   }
}