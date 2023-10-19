@isTest
public with sharing class SOM_callStartFulfillmentProcessBatchTest {
    @isTest(seeAllData=true)
    public static String setUpData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        return los[0].Id;
    }

    @isTest(seeAllData=true)
    public static void startFulfillmentProcessTest(){
        String ordSummId = setUpData();
        List<String> ordSummIds = new List<String>();
        ordSummIds.add(ordSummId);
        Test.startTest();
        SOM_callStartFulfillmentProcessBatch.startFulfillmentProcess(ordSummIds);
        Test.stopTest();
    }
}