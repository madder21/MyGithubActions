@isTest
public with sharing class SOM_BatchAnonymization_3_Test {
    @isTest(seeAllData=true)
    public static List<String> setUpData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        List<OrderSummary> os = [SELECT Id, OriginalOrderId, Status, AccountId, (SELECT Id, Status FROM OrderItemSummaries) FROM OrderSummary WHERE Id = :los[0].id];
        os[0].Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
        update os[0];
        List<OrderPaymentSummary> ordPaySumm = [SELECT Id, PaymentMethodId FROM OrderPaymentSummary WHERE OrderSummaryId = :los[0].id];
        List<String> ordPayList = new List<String>();
        ordPayList.add(ordPaySumm[0].Id);
        Payment pay = new Payment(); 
        pay.OrderPaymentSummaryId = ordPaySumm[0].Id;
        pay.Amount                = 900.78;
        pay.Status                = SOM_Constants.ORDER_DRAFT_STATUS;
        pay.Type                  = SOM_Constants.PAYMENT_TYPE_CAPTURE;
        pay.ProcessingMode        = SOM_Constants.PAYMENT_PROCESSING_MODE_EXTERNAL;
        insert pay;
        return ordPayList;
    }

    @isTest(seeAllData=true)
    public static void anonymizeTestOK(){
        List<String> orderPaymentSummaryIds = setUpData();
        List<String> paymentMethodIds = new List<String>();
        Map<String, String> objectClientId = new Map<String, String>();
        Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
        List<String> cls = new List<String>();
        Test.startTest();
        SOM_BatchAnonymization_3 nextBatch = new SOM_BatchAnonymization_3(paymentMethodIds, orderPaymentSummaryIds, objectClientId, orderSummaryNumbers, cls);
        database.executebatch(nextBatch);
        Test.stopTest();
        List<Payment> pays = [SELECT Id, Phone FROM Payment WHERE OrderPaymentSummaryId IN :orderPaymentSummaryIds];
        System.assertEquals(SOM_Constants.STRING_OPERATOR_ANONYMIZATION, pays[0].Phone,'Phone should be anonymized with : XXXXXXXXXX');
    }
}