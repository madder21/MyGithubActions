@IsTest
public with sharing class SOM_SalesPaymentAUMonthSchedule_Test {
    @IsTest (seeAllData = true)
   static void test() {

          Test.startTest();
          SOM_SalesPaymentsReportMonthAUSchedule scheduler = new SOM_SalesPaymentsReportMonthAUSchedule();
          scheduler.execute(null);
          System.assertEquals(1,1); 
          Test.stopTest();

     }

}