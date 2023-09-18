@IsTest
global with sharing class SOM_OrderSummaryCapturePaymentActionTest {

    public static List<OrderSummary> listOrderSummary = new List<OrderSummary>();
    
    @testSetup static void setup() {
        OrderSummary orderSumm1 = SOM_testDataFactory.customOrderSummaryCreation('ORD-91001001', SOM_Constants.RI_REPAYMENT_METHOD_C_KLARNA, 'E4C294A4ED2CCF54E053AF598E0A061C', false, false);
        OrderSummary orderSumm2 = SOM_testDataFactory.customOrderSummaryCreation('ORD-91001002', SOM_Constants.RI_REPAYMENT_METHOD_C_CREDIT_CARD, 'E4C294A4ED2CCF54E053AF598E0B172D', false, false);
        //createCybersourceSettings();
    }

    @IsTest
    public static void testCaptureOrderSummary(){

        List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionResponse> captureResponse;
        WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest requestData = new WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest();
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        Test.startTest();
        OrderSummary os = [SELECT Id FROM OrderSummary  WHERE CaptureStatus__c =: SOM_Constants.ORDER_TO_CAPTURE_STATUS  LIMIT 1];
        requestData.orderSummaryId = os.Id;
        if(requestData.orderSummaryId != null){
            
            captureResponse = WS_SOM_OrderSummary_CapturePaymentAction.orderSummaryCapturePayment(new List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest>{requestData});
        }
        Test.stopTest();
     
        System.assertEquals(true, captureResponse[0].isSucces,'OrderSummary has not been captured'); 
    }

    @IsTest
    public static void testMissingOrderSummary(){
        List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionResponse> captureResponse;
        WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest requestData = new WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest();
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        Test.startTest();
        OrderSummary os = [SELECT Id FROM OrderSummary  WHERE OrderNumber = 'ORD-91001002' LIMIT 1];
        requestData.orderSummaryId = os.Id;
        if(requestData.orderSummaryId != null){
            
            captureResponse = WS_SOM_OrderSummary_CapturePaymentAction.orderSummaryCapturePayment(new List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest>{requestData});
        }
        
        Test.stopTest();
        System.assertEquals(false, captureResponse[0].isSucces,'OrderSummary has been captured'); 
    }
    

    @IsTest
    public static void testErrorCapturingOrderSummary(){
        List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionResponse> captureResponse;
        WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest requestData = new WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest();
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutErrorMock());
        Test.startTest();
        OrderSummary os = [SELECT Id FROM OrderSummary  WHERE CaptureStatus__c =: SOM_Constants.ORDER_TO_CAPTURE_STATUS  LIMIT 1];
        requestData.orderSummaryId = os.Id;
        if(requestData.orderSummaryId != null){
            captureResponse = WS_SOM_OrderSummary_CapturePaymentAction.orderSummaryCapturePayment(new List<WS_SOM_OrderSummary_CapturePaymentAction.CapturePaymentActionRequest>{requestData});
        }
        Test.stopTest();
        System.assertEquals(false, captureResponse[0].isSucces,'OrderSummary has been captured'); 
        
    }

   /* public static void createCybersourceSettings(){
        try{
            CybersourceSettings__c cybSettings = SOM_CyberSettingsCredentials.CybSettingsCreds();
            system.debug('cybSettings :'+cybSettings);
            //insert cybSettings;
        }catch(Exception e){system.debug('Error : '+e);}
    }*/
    
    

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
