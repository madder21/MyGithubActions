@IsTest
global with sharing class WS_SOM_CapturePaymentAction_Test {

    @IsTest (seeAllData=true)
    public static void testCaptureOK(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder foCreated = SOM_testDataFactory.createFO(lOS[0]);
        foCreated.Capture_Status__c = SOM_Constants.ORDER_TO_CAPTURE_STATUS;
        update foCreated;

        List<List<SOM_CapturePaymentActionResponseWrapper>> captureResponse;
        List<SOM_CapturePaymentActionRequestWrapper> requestDataList = new List<SOM_CapturePaymentActionRequestWrapper>();
        SOM_CapturePaymentActionRequestWrapper requestData = new SOM_CapturePaymentActionRequestWrapper();
        
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());

        Test.startTest();
        FulfillmentOrder fo = [SELECT Id FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds AND Capture_Status__c =: SOM_Constants.ORDER_TO_CAPTURE_STATUS  LIMIT 1];
        requestData.fulfillmetOrderId = fo.Id;
        if(requestData.fulfillmetOrderId != null){
            requestDataList.add(requestData);
            captureResponse = WS_SOM_CapturePaymentAction.capturePayment(new List<List<SOM_CapturePaymentActionRequestWrapper>>{requestDataList});
        }
        Test.stopTest();
        System.assertEquals(true, captureResponse[0][0].isSucces); 
        
    }

    @IsTest (seeAllData=true)
    public static void testCaptureKO(){
        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder foCreated = SOM_testDataFactory.createFO(lOS[0]);
        foCreated.Capture_Status__c = SOM_Constants.ORDER_TO_CAPTURE_STATUS;
        update foCreated;

        List<List<SOM_CapturePaymentActionResponseWrapper>> captureResponse;
        List<SOM_CapturePaymentActionRequestWrapper> requestDataList = new List<SOM_CapturePaymentActionRequestWrapper>();
        SOM_CapturePaymentActionRequestWrapper requestData = new SOM_CapturePaymentActionRequestWrapper();
        
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutErrorMock());

        Test.startTest();
        FulfillmentOrder fo = [SELECT Id FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds AND Capture_Status__c =: SOM_Constants.ORDER_TO_CAPTURE_STATUS  LIMIT 1];
        requestData.fulfillmetOrderId = fo.Id;
        if(requestData.fulfillmetOrderId != null){
            requestDataList.add(requestData);
            captureResponse = WS_SOM_CapturePaymentAction.capturePayment(new List<List<SOM_CapturePaymentActionRequestWrapper>>{requestDataList});
        }
        Test.stopTest();
        System.assertEquals(false, captureResponse[0][0].isSucces); 
        
    }

    global class CybersourceCalloutMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(200);
            res.setBody('{}');
            return res;
        }
    }

    global class CybersourceCalloutErrorMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
   
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(401);
            return res;
        }
    }
}