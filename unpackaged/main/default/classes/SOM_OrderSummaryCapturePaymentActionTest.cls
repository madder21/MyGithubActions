@IsTest
global with sharing class SOM_OrderSummaryCapturePaymentActionTest {

    public static List<OrderSummary> listOrderSummary = new List<OrderSummary>();
    @testSetup static void setup() {
        OrderSummary orderSumm1 = SOM_testDataFactory.customOrderSummaryCreation('ORD-91001001', SOM_Constants.RI_REPAYMENT_METHOD_C_KLARNA, 'E4C294A4ED2CCF54E053AF598E0A061C', false, false);
        //listOrderSummary.add(orderSumm1);
        OrderSummary orderSumm2 = SOM_testDataFactory.customOrderSummaryCreation('ORD-91001002', SOM_Constants.RI_REPAYMENT_METHOD_C_CREDIT_CARD, 'E4C294A4ED2CCF54E053AF598E0B172D', false, false);
        //listOrderSummary.add(orderSumm2);
        createCybersourceSettings();
        
        
    }

    @IsTest
    public static void testCaptureOrderSummary(){
        List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionResponse> captureResponse;
        WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest requestData = new WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest();
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        Test.startTest();
        OrderSummary os = [SELECT Id FROM OrderSummary  WHERE CaptureStatus__c =: SOM_Constants.ORDER_TO_CAPTURE_STATUS  LIMIT 1];
        System.debug('---------- os: ' + os);
        requestData.orderSummaryId = os.Id;
        if(requestData.orderSummaryId != null){
            
            captureResponse = WS_SOM_OrderSummary_CapturePaymentAction.orderSummaryCapturePayment(new List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest>{requestData});
            System.debug('---------- captureResponse : ' + captureResponse);
        }
        Test.stopTest();
        System.assertEquals(true, captureResponse[0].isSucces); 
        
    }

    @IsTest
    public static void testMissingOrderSummary(){
        List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionResponse> captureResponse;
        WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest requestData = new WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest();
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        Test.startTest();
        OrderSummary os = [SELECT Id FROM OrderSummary  WHERE OrderNumber = 'ORD-91001002' LIMIT 1];
        System.debug('---------- os: ' + os);
        requestData.orderSummaryId = os.Id;
        if(requestData.orderSummaryId != null){
            
            captureResponse = WS_SOM_OrderSummary_CapturePaymentAction.orderSummaryCapturePayment(new List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest>{requestData});
            System.debug('---------- captureResponse : ' + captureResponse);
        }
        
        Test.stopTest();
        System.assertEquals(false, captureResponse[0].isSucces); 
    }
    

    @IsTest
    public static void testErrorCapturingOrderSummary(){
        List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionResponse> captureResponse;
        WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest requestData = new WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest();
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutErrorMock());
        Test.startTest();
        OrderSummary os = [SELECT Id FROM OrderSummary  WHERE CaptureStatus__c =: SOM_Constants.ORDER_TO_CAPTURE_STATUS  LIMIT 1];
        System.debug('---------- os: ' + os);
        requestData.orderSummaryId = os.Id;
        if(requestData.orderSummaryId != null){
            captureResponse = WS_SOM_OrderSummary_CapturePaymentAction.orderSummaryCapturePayment(new List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest>{requestData});
            System.debug('---------- capture Error Response : ' + captureResponse);
        }
        Test.stopTest();
        System.assertEquals(false, captureResponse[0].isSucces); 
        
    }

    public static void createCybersourceSettings(){
        CybersourceSettings__c cybSettings = new CybersourceSettings__c();
        cybSettings.Host__c              = 'apitest.cybersource.com';
        cybSettings.MerchantId__c        = 'rimowa_eu';
        cybSettings.MerchantKeyId__c     = 'eec3d419-e07d-4cc0-8b0c-dbb5fdcc27eb';
        cybSettings.MerchantSecretKey__c = 'DgMctxVdd7QpPDXDPfsu0OxwYn5MBXjnK/LT+gASClY=';

        insert cybSettings;
    }

   

    global class CybersourceCalloutMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(200);
            res.setBody('{}');
            return res;
        }
    }

    global class CybersourceCalloutErrorMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(401);
            return res;
        }
    }
    
}