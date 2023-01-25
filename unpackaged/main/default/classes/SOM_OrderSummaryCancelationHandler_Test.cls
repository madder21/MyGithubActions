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
     
        List<OrderSummary> os = SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,2);
        SOM_testDataFactory.createFO(os[0]);
        SOM_testDataFactory.createFO(os[1]);
        Set<Id> Ids = (new Map<Id,OrderSummary>(os)).keySet();
        os = [SELECT Id, OrderNumber FROM OrderSummary WHERE Id IN: Ids];
        System.debug('°°°°°°°° Order Summary :::: ' + os + os.size());
        System.debug('°°°°°°°° size os :::: ' + os.size());
        System.debug('°°°°°°°° ids os :::: ' + Ids);
        
        List<FulfillmentOrder> fo = [SELECT Id, Status, OrderSummaryId, OrderSummary.orderNumber FROM fulfillmentOrder WHERE OrderSummaryId IN: Ids];
        System.debug('°°°°°°°° FO :::: ' + fo );
        System.debug('°°°°°°°° size FO :::: ' + fo.size());

        List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest> listOrderNumberRequest = new List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest>();
        SOM_OrderSummaryCancelationHandler.PickupCancelRequest req1 = new SOM_OrderSummaryCancelationHandler.PickupCancelRequest();
        req1.orderSummaryNumber = os.get(0).OrderNumber;
        SOM_OrderSummaryCancelationHandler.PickupCancelRequest req2 = new SOM_OrderSummaryCancelationHandler.PickupCancelRequest();
        req2.orderSummaryNumber = os.get(1).OrderNumber;
        listOrderNumberRequest.add(req1);
        listOrderNumberRequest.add(req2);
        RestResponse res = setReqRes(listOrderNumberRequest);

        Test.startTest();
        SOM_OrderSummaryCancelationHandler.cancelPickup();
        Test.stopTest();
        
        Map<String, Object> mapResults = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        List<Object> responseBdy = (List<Object>) mapResults.get('Response');
        System.debug('response Body' + responseBdy);
        String justifiedResponseBdy = JSON.serialize(responseBdy[0]);
        Map<String, Object> mapResponseBdy = (Map<String, Object>) JSON.deserializeUntyped(justifiedResponseBdy);
        System.debug('mapResponseBdy ' + mapResponseBdy);
        Errors err = new Errors();
        err.errorMessage = (String) mapResponseBdy.get('errorMessage');
        System.debug('eeerrr ' + err.errorMessage);
        
        System.assert(err.errorMessage == null);

    }


    // @IsTest
    // public static void testCaseNoFO() {
        
    //     /***
    //      * for creating FO without FOLI
    //      */
    //     Id pricebookId = Test.getStandardPricebookId();
    //         Pricebook2 standardPricebook = new Pricebook2(
    //             Id = pricebookId,
    //             IsActive = true
    //         );
    //         update standardPricebook;


    //         List<Product2> prodList = new List<Product2>();
    //         List<PricebookEntry> priceEntries = new List<PricebookEntry>();
    //         Product2 prod1 = SOM_testDataFactory.createProduct('Prod1', 'Code1','SKU00001');
    //         Product2 prod2 = SOM_testDataFactory.createProduct('Prod2', 'Code2','SKU00002');
    //         Product2 prod3 = SOM_testDataFactory.createProduct('Prod3', 'Code3','SKU00003');
    //         prodList.add(prod1);
    //         prodList.add(prod2);
    //         prodList.add(prod3);
    //         insert prodList;
    //         PricebookEntry entry1 = SOM_testDataFactory.createPricebookEntry(870, prod1.Id, Test.getStandardPricebookId());
    //         PricebookEntry entry2 = SOM_testDataFactory.createPricebookEntry(855, prod2.Id, Test.getStandardPricebookId());
    //         PricebookEntry entry3 = SOM_testDataFactory.createPricebookEntry(800, prod3.Id, Test.getStandardPricebookId());
    //         priceEntries.add(entry1);
    //         priceEntries.add(entry2);
    //         priceEntries.add(entry3);
    //         insert priceEntries;
    //         SalesChannel saleschannel = SOM_testDataFactory.createSaleschannel('SOM','Rimowa');
    //         insert saleschannel;
    //         OrderDeliveryMethod odm = SOM_testDataFactory.createOrderDeliveryMethod('standard_GB', prod1.Id, 'standard_GB');
    //         insert odm;
    //         Schema.Location loc = SOM_testDataFactory.createLocation('WH_GB','rimowa-inventory-uk', true, 'Warehouse');
    //         insert loc;
    //         Account acc = SOM_testDataFactory.createAccount('test.user@rimowa.com');
    //         Order ord = SOM_testDataFactory.createOrder(acc.Id,'Fatima ezzahra Laftoumi',saleschannel.Id,'Ref001100011',standardPricebook.Id, true,false);
    //         insert ord;
    //         OrderDeliveryGroup odg = SOM_testDataFactory.createOrderDeliveryGroup(ord.Id,odm.Id);

    //         insert odg;
    //         List<OrderItem> listOrderItems =new List<OrderItem>();
            
    //         OrderItem orderItem2 = SOM_testDataFactory.createOrderItem(prodList[1].Id, ord.Id, 1, 855, 855, odg.Id, SOM_Constants.DELIVERY_CHARGE, priceEntries[1].Id, loc.Id, false,false,null);
    //         listOrderItems.add(orderItem2);
    //        /* OrderItem orderItem3 = SOM_testDataFactory.createOrderItem(prodList[2].Id, ord.Id, 0, 800, 800, odg.Id, SOM_Constants.ORDER_PRODUCT,priceEntries[2].Id, loc.Id, false,false,null);
    //         listOrderItems.add(orderItem3);*/
    //         insert listOrderItems;
        
    //         ord.Status = SOM_Constants.ORDER_ACTIVATED_STATUS;
    //         update ord;
    //     /***
    //      * ///////END
    //      * for creating FO without FOLI 
    //      */

        
    //     Set<Id> Ids = (new Map<Id,OrderSummary>(os)).keySet();
    //     os = [SELECT Id, OrderNumber FROM OrderSummary WHERE Id IN: Ids];
    //     System.debug('°°°°°°°° Order Summary :::: ' + os + os.size());
    //     System.debug('°°°°°°°° size os :::: ' + os.size());
    //     System.debug('°°°°°°°° ids os :::: ' + Ids);
        
    //     List<FulfillmentOrder> fo = [SELECT Id, Status, OrderSummaryId, OrderSummary.orderNumber FROM fulfillmentOrder WHERE OrderSummaryId IN: Ids];
    //     System.debug('°°°°°°°° FO :::: ' + fo );
    //     System.debug('°°°°°°°° size FO :::: ' + fo.size());

    //     List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest> listOrderNumberRequest = new List<SOM_OrderSummaryCancelationHandler.PickupCancelRequest>();
    //     SOM_OrderSummaryCancelationHandler.PickupCancelRequest req1 = new SOM_OrderSummaryCancelationHandler.PickupCancelRequest();
    //     req1.orderSummaryNumber = os.get(0).OrderNumber;
    //     listOrderNumberRequest.add(req1);
    //     //String JsonMsg = '[{"orderSummaryNumber": "' + os.get(0).OrderNumber + '"},{"orderSummaryNumber": "'+ os.get(1).OrderNumber +'"},{"orderSummaryNumber": "'+ os.get(2).OrderNumber +'"},{"orderSummaryNumber": "testnoOrderSummary"}]';
    //     setReqRes(listOrderNumberRequest);    

    //     Test.startTest();
    //     SOM_OrderSummaryCancelationHandler.cancelPickup();
    //     Test.stopTest();
    //     List<FulfillmentOrder> foCanceled = [SELECT Id, Status, OrderSummaryId, OrderSummary.orderNumber FROM fulfillmentOrder WHERE Status = 'Canceled' AND OrderSummaryId IN: Ids];
    //     System.assertEquals(2,foCanceled.size());

    // }




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
        System.debug('response Body' + responseBdy);
        String justifiedResponseBdy = JSON.serialize(responseBdy[0]);
        Map<String, Object> mapResponseBdy = (Map<String, Object>) JSON.deserializeUntyped(justifiedResponseBdy);
        System.debug('mapResponseBdy ' + mapResponseBdy);
        Errors err = new Errors();
        err.errorMessage = (String) mapResponseBdy.get('errorMessage');
        System.debug('eeerrr ' + err.errorMessage);
        System.assert(err.errorMessage.contains('No OrderSummary Exist with this OrderNumber'));
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
        System.debug('response Body' + responseBdy);
        System.assert(responseBdy.contains('Internal Error'));
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
        System.debug('response Body' + responseBdy);
        System.assert(responseBdy.contains('List of OrderNumbers Is Empty'));

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