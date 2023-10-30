@isTest
public with sharing class SOM_BatchAnonymization_4_Test {
    @isTest(seeAllData=true)
    public static List<OrderPaymentSummary> setUpData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        List<OrderSummary> os = [SELECT Id, OriginalOrderId, Status, AccountId, (SELECT Id, Status FROM OrderItemSummaries) FROM OrderSummary WHERE Id = :los[0].id];
        os[0].Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
        update os[0];
        List<OrderPaymentSummary> ordPaySumm = [SELECT Id, PaymentMethodId, OrderSummary.AccountId FROM OrderPaymentSummary WHERE OrderSummaryId = :los[0].id];
        return ordPaySumm;
    }

    @isTest(seeAllData=true)
    public static void anonymizeTestOK(){
        List<OrderPaymentSummary> paymentMethods = setUpData();
        List<String> cardPayList = new List<String>();
        for(OrderPaymentSummary ordPay : paymentMethods){
            cardPayList.add(ordPay.PaymentMethodId);
        }
        Map<String, String> objectClientId = new Map<String, String>();
        Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
        List<String> cls = new List<String>();
        cls.add(paymentMethods[0].OrderSummary.AccountId);
        Test.startTest();
        SOM_BatchAnonymization_4 nextBatch = new SOM_BatchAnonymization_4(cardPayList, objectClientId, orderSummaryNumbers, cls);
        database.executebatch(nextBatch);
        Test.stopTest();
        List<CardPaymentMethod> cardPays = [SELECT Id, PaymentMethodStreet, Status FROM CardPaymentMethod WHERE Id IN :cardPayList];
        System.assertEquals('InActive', cardPays[0].Status,'Status should be InActive');
    }
}