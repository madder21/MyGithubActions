@isTest
public with sharing class SOM_BatchAnonymization_2_Test {
    @isTest(seeAllData=true)
    public static List<String> setUpData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        List<OrderSummary> os = [SELECT Id, OriginalOrderId, Status, AccountId, (SELECT Id, Status FROM OrderItemSummaries) FROM OrderSummary WHERE Id = :los[0].id];
        os[0].Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
        update os[0];
        List<String> originalOrderIdList = new List<String>();
        originalOrderIdList.add(os[0].OriginalOrderId);
        return originalOrderIdList;
    }

    @isTest(seeAllData=true)
    public static void anonymizeTestOK(){
        List<String> ordList = setUpData();
        List<String> paymentMethodIds = new List<String>();
        List<String> orderPaymentSummaryIds = new List<String>();
        Map<String, String> objectClientId = new Map<String, String>();
        Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
        List<String> cls = new List<String>();
        Test.startTest();
        SOM_BatchAnonymization_2 nextBatch = new SOM_BatchAnonymization_2(ordList, paymentMethodIds, orderPaymentSummaryIds, objectClientId, orderSummaryNumbers, cls);
        database.executebatch(nextBatch);
        Test.stopTest();
        List<Order> ords = [SELECT Id, BillingPostalCode, AccountId FROM Order WHERE Id = :ordList];
        System.assertEquals(SOM_Constants.STRING_OPERATOR_ANONYMIZATION, ords[0].BillingPostalCode,'BillingPostalCode should be anonymized with : XXXXXXXXXX');
    }
}