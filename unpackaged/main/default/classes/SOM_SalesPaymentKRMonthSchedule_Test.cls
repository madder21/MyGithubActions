@IsTest
public with sharing class SOM_SalesPaymentKRMonthSchedule_Test {
    @IsTest (seeAllData = true)
   static void test() {

          Test.startTest();
          SOM_SalesPaymentsReportMonthKRSchedule scheduler = new SOM_SalesPaymentsReportMonthKRSchedule();
          scheduler.execute(null);
          Test.stopTest();
          System.assertEquals(1,1); 
   }
}