@isTest
public with sharing class SOM_BatchAnonymization_5_Test {
    @isTest(seeAllData=true)
    public static OrderSummary setUpData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        List<OrderSummary> os = [SELECT Id, OriginalOrderId, Status, AccountId, (SELECT Id, Status FROM OrderItemSummaries) FROM OrderSummary WHERE Id = :los[0].id];
        os[0].Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
        update os[0];
        DigitalWallet digitWall = new DigitalWallet();
        digitWall.Status         = 'Active';
        digitWall.ProcessingMode = 'External';
        digitWall.AccountId      = los[0].AccountId;
        insert digitWall;
        return los[0]; 
    }

    @isTest(seeAllData=true)
    public static void anonymizeTestOK(){
        OrderSummary orderSu = setUpData();
        String accId = orderSu.AccountId;
        List<String> paymentMethodIds = new List<String>();
        Map<String, String> objectClientId = new Map<String, String>();
        Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
        List<String> ordNum = new List<String>();
        ordNum.add(orderSu.OrderNumber);
        orderSummaryNumbers.put(accId, ordNum);
        List<String> cls = new List<String>();
        cls.add(accId);
        List<String> OrdersId = new List<String>();
        OrdersId.add(orderSu.OriginalOrderId);
        Test.startTest();
        SOM_BatchAnonymization_5 nextBatch = new SOM_BatchAnonymization_5(OrdersId,paymentMethodIds, objectClientId, orderSummaryNumbers, cls);
        database.executebatch(nextBatch);
        Test.stopTest();
    }
}
