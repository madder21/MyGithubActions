@isTest
public with sharing class SOM_Batch_StartFulfillmentProcess_Test {
    @isTest(seeAllData=true)
    public static String setUpData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        return los[0].Id;
    }

    @isTest(seeAllData=true)
    public static void batchTest(){
        String ordSummId = setUpData();
        List<String> ordSummIds = new List<String>();
        ordSummIds.add(ordSummId);
        Test.startTest();
        Id jobId = Database.executeBatch(new SOM_Batch_StartFulfillmentProcess(ordSummIds));
        Test.stopTest();
    }
}