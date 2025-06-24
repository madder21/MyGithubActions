/**************************************************************************************

-- - Author        : Fatima-Ezzahra LAFTOUMI

-- - Description   : Test class for 'SOM_OrderSummaryCancelationHandler' Class

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 22-07-2022    FEL    1.0          Initial version

***************************************************************************************/
@isTest
public with sharing class SOM_OrderSummaryCancelationHandler_Test {

    /**
     * @description testCancelPickup : Testing Scenario of canceling pickup order with no errors
     * SeeAllData=true for allowing ConnectAPI.FulfillmentOrder.cancelFulfillmentOrderLineItems Action purpose only.
     * NB: The actual data is from the Test Data Factory not from the ORG
     */
    @IsTest(SeeAllData=true)
    public static void testCancelPickup() {
     
        List<OrderSummary> os = SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,1);
        SOM_testDataFactory.createFO(os[0]);
        //SOM_testDataFactory.createFO(os[1]);
        Set<Id> Ids = (new Map<Id,OrderSummary>(os)).keySet();
        os = [SELECT Id, OrderNumber FROM OrderSummary WHERE Id IN: Ids];
        
        List<FulfillmentOrder> fo = [SELECT Id, Status, OrderSummaryId, OrderSummary.orderNumber FROM fulfillmentOrder WHERE OrderSummaryId IN: Ids];

        List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest> listOrderNumberRequest = new List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest>();
        SOM_OrderSummaryCancelationHandler.PickupCancelRequest req1 = new SOM_OrderSummaryCancelationHandler.PickupCancelRequest();
        req1.orderSummaryNumber = os.get(0).OrderNumber;
        SOM_OrderSummaryCancelationHandler.PickupCancelRequest req2 = new SOM_OrderSummaryCancelationHandler.PickupCancelRequest();
        //req2.orderSummaryNumber = os.get(1).OrderNumber;
        listOrderNumberRequest.add(req1);
        //listOrderNumberRequest.add(req2);
        RestResponse res = setReqRes(listOrderNumberRequest);

        Test.startTest();
        SOM_OrderSummaryCancelationHandler.cancelPickup();
        Test.stopTest();
        
        Map<String, Object> mapResults = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        List<Object> responseBdy = (List<Object>) mapResults.get('Response');
        String justifiedResponseBdy = JSON.serialize(responseBdy[0]);
        Map<String, Object> mapResponseBdy = (Map<String, Object>) JSON.deserializeUntyped(justifiedResponseBdy);
        Errors err = new Errors();
        err.errorMessage = (String) mapResponseBdy.get('errorMessage');
        
        System.assert(err.errorMessage == null, 'No Error Massage was returned while canceling Pickup');

    }


   
    /**
     * @description testCaseNoOSExist : Testing canceling pickup order where the Order Summary Name Does not Exist Case Scenario.
     */
    @IsTest
    static void testCaseNoOSExist(){
        
        List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest> listOrderNumberRequest = new List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest>();
        SOM_OrderSummaryCancelationHandler.PickupCancelRequest req1 = new SOM_OrderSummaryCancelationHandler.PickupCancelRequest();
        req1.orderSummaryNumber = 'Test OS does not exist';
        listOrderNumberRequest.add(req1);
        RestResponse res = setReqRes(listOrderNumberRequest);

        test.startTest();
        SOM_OrderSummaryCancelationHandler.cancelPickup();
        test.stopTest();

        Map<String, Object> mapResults = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        List<Object> responseBdy = (List<Object>) mapResults.get('Response');
        String justifiedResponseBdy = JSON.serialize(responseBdy[0]);
        Map<String, Object> mapResponseBdy = (Map<String, Object>) JSON.deserializeUntyped(justifiedResponseBdy);
        Errors err = new Errors();
        err.errorMessage = (String) mapResponseBdy.get('errorMessage');
        System.assert(err.errorMessage.contains('No OrderSummary Exist with this OrderNumber'), 'Returned Error : No OrderSummary Exist with this OrderNumber');
    }
    

    /**
     * @description testExceptionThrown : Testing canceling pickup order when Exception is Thrown Case Scenario.
     */
    @IsTest
    static void testExceptionThrown(){
        
        List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest> listOrderNumberRequest = null;
        RestResponse res = setReqRes(listOrderNumberRequest);

        test.startTest();
        SOM_OrderSummaryCancelationHandler.cancelPickup();
        test.stopTest();

        Map<String, Object> mapResults = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        String responseBdy = (String) mapResults.get('Response');
        System.assert(responseBdy.contains('Internal Error'), 'Returned Error : Internal Error' );
    }

    /**
     * @description testElseEmpty : Testing canceling pickup order when the list of Order Summaries size is 0.
     */
    @IsTest
    static void testElseEmpty(){

        List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest> listOrderNumberRequest = new List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest>();
        RestResponse res = setReqRes(listOrderNumberRequest);

        test.startTest();
        SOM_OrderSummaryCancelationHandler.cancelPickup();
        test.stopTest();

        Map<String, Object> mapResults = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        String responseBdy = (String) mapResults.get('Response');
        System.assert(responseBdy.contains('List of OrderNumbers Is Empty'), 'Returned Error : List of OrderNumbers Is Empty');

    }

    /**
     * @description setReqRes : http callout to be used in above testing scenarios
     * @param listOrderNumberRequest : List contains Order Summaries Numbers to concel to be set in the request body
     * @return RestResponse          : Represent the REST response instance that will contain the response from the testing scenarios
     */    
    static RestResponse setReqRes(List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest> listOrderNumberRequest){
        RestRequest req  = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/OrderSummary/pickupCancel'; 
        req.httpMethod = 'Post';
        req.addHeader('Content-Type', 'application/json'); 
        req.requestBody = Blob.valueOf(JSON.serialize(listOrderNumberRequest));
        RestContext.request  = req; 
        RestContext.response = res;
        return res;
        
    } 

    public class Errors{
        string code;
        string errorMessage;
    }


}
