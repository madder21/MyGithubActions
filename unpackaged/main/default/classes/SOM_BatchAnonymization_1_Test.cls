@isTest
public with sharing class SOM_BatchAnonymization_1_Test {
    @isTest(seeAllData=true)
    public static String setUpData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        List<OrderSummary> os = [SELECT Id, Status, AccountId, (SELECT Id, Status FROM OrderItemSummaries) FROM OrderSummary WHERE Id = :los[0].id];
        os[0].Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
        update os[0];
        return os[0].AccountId;
    }

    @isTest(seeAllData=true)
    public static void anonymizeTestOK(){
        String cl = setUpData();
        List<String> cls = new List<String>();
        cls.add(cl);
        Test.startTest();
        SOM_BatchAnonymization_1.callBatchAnonymization(cls);
        Test.stopTest();
        List<OrderSummary> ordSumms = [SELECT Id, BillingPostalCode, AccountId FROM OrderSummary WHERE AccountId = :cl];
        System.assertEquals(SOM_Constants.STRING_OPERATOR_ANONYMIZATION, ordSumms[0].BillingPostalCode,'BillingPostalCode should be anonymized with : XXXXXXXXXX');
    }
}