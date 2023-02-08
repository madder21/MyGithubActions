@isTest
private class SOM_GetAvailabilityBatchTest {

    @isTest (seeAllData=true)
    static void testGetAvailabilityExecute() {
        List<OrderSummary> osList = new List<OrderSummary>();
        osList =  SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,1);
        
        System.debug('osList :::: ' +osList);
        Test.startTest();
        SOM_GetAvailability_BatchSubClass b = new SOM_GetAvailability_BatchSubClass(osList);
        Test.stopTest();
        System.assertNotEquals(null, b.result);

    }
}