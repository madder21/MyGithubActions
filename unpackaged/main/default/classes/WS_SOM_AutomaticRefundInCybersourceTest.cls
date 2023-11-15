@IsTest
global with sharing class WS_SOM_AutomaticRefundInCybersourceTest {
    public static Boolean attachedToRO = false ;
    public static Boolean discount = false ;

    @IsTest (seeAllData=true)
    public static void testCC_Refund(){
        
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id,FulfillmentOrder> mapFO = new Map<Id,FulfillmentOrder>();
        mapFO.put(fo.Id,fo);
        Map<Id, Shipment> shipmentMap = SOM_testDataFactory.createShipments(mapFO);
        Refund refund = SOM_testDataFactory.createRefundWithCreditMemo(los[0] ,attachedToRO,discount);

        List<WS_SOM_AutomaticRefundInCybersource.AutomaticRefundInCybersourceResponse> Response;
        List<WS_SOM_AutomaticRefundInCybersource.AutomaticRefundInCybersourceRequest> requests = new List<WS_SOM_AutomaticRefundInCybersource.AutomaticRefundInCybersourceRequest>();
        WS_SOM_AutomaticRefundInCybersource.AutomaticRefundInCybersourceRequest requestCC = new WS_SOM_AutomaticRefundInCybersource.AutomaticRefundInCybersourceRequest();
        
        
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());

        Test.startTest();
        		requestCC.url = 'https://ics2wstesta.ic3.com:443/commerce/1.x/transactionProcessor';
                requestCC.merchantId = 'rimowa_ae';
                requestCC.Password = 'gbuM9DtCDyrqzj3JSc1DLxuwrT1jRqBcAFfoNucMeEXTO0X1bk6OH/JNB/G7SCEngAaSblDUZMj2hAZOAxVb2AqKvsUobCfeEbGlilOIfFx6GYwoJlFrCjwUU+GWt9mMrvx014nvFrd/pZDeZA7qDmBrOHZufGfPw3ZltlsZA+y3m95DGf2ou8W6SKT3uktgxMaOKglpQpZPfXPYBHt1DqOkGVpm0vvlR8JR77Lj+EgU4yiY+7tGhmAOxso3Ei7YNU48yNpxyixyhNCrAoNEJgou7czIa3mjaPEnfcl3LBatsZxoK1R8dfzVc9Wft+s/i+75tfTVeLVTL9+tda4quA==';
                requestCC.RefundMethod = 'CC';
                requestCC.merchantReferenceCode = los[0].OrderNumber;
                requestCC.amount_currency = 'AED';
                requestCC.grandTotalAmount = '50';
                requestCC.captureRequestID = '6970407796836626104010';
        		requestCC.RefundId = refund.Id;
        		
        requests.add(requestCC);
            Response = WS_SOM_AutomaticRefundInCybersource.AutomaticRefundInCybersource(requests);
        Test.stopTest();
        
    }


    global class CybersourceCalloutMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
    
            HttpResponse httpRequest = new HttpResponse();
            httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
            httpRequest.setStatusCode(200);
            httpRequest.setBody('{}');
            return httpRequest;
        }
    }

   
}