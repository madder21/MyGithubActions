/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
@RestResource(urlMapping='/OrderSummary/pickupCancel/*')
global with sharing class SOM_OrderSummaryCancelationHandler {

	/**
	* @description 
	* @author BADER EDDINE ELKHAL | 04-17-2022 
	* @return Void 
	**/
    @HttpPost
	global static Void cancelPickup() {
        System.debug('$$$ SOM_OrderSummaryCancelationHandler Start  createShipments Method :');

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        List<PickupCancelRequest> listOrderNumberRequest = new List<PickupCancelRequest>();
        Set<String> initialOsNumber = new Set<String>();
        List<OrderSummary> listOfOrderSummary = new List<OrderSummary>();
        Map<String, Id> OrderSummaryIdByNumber = new Map<String, Id>();
        Map<Id, OrderSummary> orderSummariesById = new Map<Id, OrderSummary>();
        Map<Id, List<FulfillmentOrder>> fulfillmentOrdersByOSId = new Map<Id, List<FulfillmentOrder>>();
        Map<Id, FulfillmentOrder> listFulfillmentOrderById = new  Map<Id, FulfillmentOrder>();
        Map<Id, List<FulfillmentOrderLineItem>> folisByFOId = new Map<Id, List<FulfillmentOrderLineItem>>();
        List<PickupCancelResponse> listPickUpResponse = new List<PickupCancelResponse>();
        Map<Id, FulfillmentOrder> mapFOByIdToUpdate = new Map<Id, FulfillmentOrder>();
        Set<Id> setOrderSummaryds = new Set<Id>();
        List<Id> seOfFulfillmentOrderIds = new List<Id>();
        Map<Id, Refund> refundToPrepareByOsId = new Map<Id, Refund>();
        Map<Id, OrderSummary> listosToUpdate = new Map<Id, OrderSummary>();
        


        //Get request data
        String RequestBody = request.requestBody.toString() != null ? request.requestBody.toString() : null;
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('$$$ SOM_OrderSummaryCancelationHandler Enter Try block : ');
            // Parse Json Input data to PickupCancelRequest List
            
            listOrderNumberRequest = (List<PickupCancelRequest>) json.deserialize(RequestBody, List<PickupCancelRequest>.class);
            System.debug('$$$ SOM_OrderSummaryCancelationHandler -- listOrderNumberRequest  : ' + listOrderNumberRequest);
            if(!listOrderNumberRequest.isEmpty() && listOrderNumberRequest.size()<31){
                for(PickupCancelRequest osNumberLine : listOrderNumberRequest){
                    initialOsNumber.add(osNumberLine.orderSummaryNumber);
                }
                System.debug('°°°°°°°° initialOsNumber '+initialOsNumber);
                //Query On target OrderSummaries with related FulfillmentOrders
                for(FulfillmentOrder fulmntOrder : [SELECT Id, Status, OrderSummaryId, OrderSummary.orderNumber, (SELECT Id, OrderItemSummaryId, Quantity , orderItemSummary.listPrice 
                    FROM FulfillmentOrderLineItems WHERE Quantity>0 AND Type != 'Delivery Charge') FROM fulfillmentOrder WHERE Type = 'Store' AND	OrderSummary.OrderNumber IN : initialOsNumber AND 
                    ((orderSummary.Status = 'Validated' AND Status = 'Allocated') OR (orderSummary.Status = 'Fulfilling' AND Status = 'Fulfilling'))]){
                    System.debug('fooo'+fulmntOrder);
                    //Stack OrderSummaries
                    //orderSummariesByNumber.put(orderSumm.OrderNumber, orderSumm);
                    //orderSummariesById.put(orderSumm.Id, orderSumm);
                    if(!OrderSummaryIdByNumber.containsKey(fulmntOrder.OrderSummary.orderNumber)) OrderSummaryIdByNumber.put(fulmntOrder.OrderSummary.OrderNumber, fulmntOrder.OrderSummaryId);
                    listFulfillmentOrderById.put(fulmntOrder.Id, fulmntOrder);

                    if(fulfillmentOrdersByOSId.containsKey(fulmntOrder.OrderSummaryId)){
                        fulfillmentOrdersByOSId.get(fulmntOrder.OrderSummaryId).add(fulmntOrder);
                    }
                    else{
                        fulfillmentOrdersByOSId.put(fulmntOrder.OrderSummaryId, new List<FulfillmentOrder> {fulmntOrder});
                    }
                    if(!fulmntOrder.FulfillmentOrderLineItems?.isEmpty()){
                        for(FulfillmentOrderLineItem foliLineItem : fulmntOrder.FulfillmentOrderLineItems){
                            if(folisByFOId.containsKey(fulmntOrder.Id)){
                                folisByFOId.get(fulmntOrder.Id).add(foliLineItem);
                            }
                            else{
                                folisByFOId.put(fulmntOrder.Id, new List<FulfillmentOrderLineItem> {foliLineItem});
                            }
                            
                            
                        }
                    }      
                    
                }
                System.debug('$$$ SOM_OrderSummaryCancelationHandler -- fulfillmentOrdersByOSId  : ' + fulfillmentOrdersByOSId);
                System.debug('$$$ SOM_OrderSummaryCancelationHandler -- folisByFOId  : ' + folisByFOId);
                for(String orderSummNumber : initialOsNumber){
                    if(OrderSummaryIdByNumber.containsKey(orderSummNumber)){
                        Id ordersummId = OrderSummaryIdByNumber.get(orderSummNumber);
                        //Cancel Folis
                        if(!fulfillmentOrdersByOSId.get(ordersummId)?.isEmpty()){
                            Decimal refundAmount = 0.0;
                            List<ConnectApi.ChangeItemInputRepresentation> listOisItemsTocancel = new List<ConnectApi.ChangeItemInputRepresentation>();
                            List<WR_fulfillmentOrderOutput> listFoOutPutData = new List<WR_fulfillmentOrderOutput>();
                            Boolean processOISCancelation = true;
                            for(FulfillmentOrder fo : fulfillmentOrdersByOSId.get(orderSummId)){
                                if(folisByFOId.containsKey(fo.Id)){
                                    
                                    ConnectAPI.FulfillmentOrderLineItemsToCancelInputRepresentation input = new ConnectAPI.FulfillmentOrderLineItemsToCancelInputRepresentation();        
                                    List<ConnectApi.FulfillmentOrderLineItemInputRepresentation> folisToCancel = new List<ConnectApi.FulfillmentOrderLineItemInputRepresentation>();
                                    WR_fulfillmentOrderOutput foOutPutData = new WR_fulfillmentOrderOutput();
                                    for(FulfillmentOrderLineItem foli : folisByFOId.get(fo.Id)){
                                        
                                        ConnectApi.FulfillmentOrderLineItemInputRepresentation FoliInputToCancel = new ConnectApi.FulfillmentOrderLineItemInputRepresentation();
                                        ConnectApi.ChangeItemInputRepresentation oisInputToCancel = new ConnectApi.ChangeItemInputRepresentation();

                                        //Prepare Foli To Cancel
                                        FoliInputToCancel.fulfillmentOrderLineItemId = foli.Id;
                                        FoliInputToCancel.quantity = foli.Quantity;
                                        folisToCancel.add(FoliInputToCancel);

                                        //Calculate Refund Amount to edite later
                                        //refundAmount = refundAmount + (foli.Quantity * foli.orderItemSummary.listPrice);
                                        //Prepare OIS To Cancel
                                        oisInputToCancel.orderItemSummaryId = foli.orderItemSummaryId;
                                        oisInputToCancel.quantity = foli.Quantity;
                                        oisInputToCancel.reason = 'RE03';
                                        oisInputToCancel.shippingReductionFlag = false;
                                        listOisItemsTocancel.add(oisInputToCancel);
                                    }
                                    //Cancel FOLI
                                    input.fulfillmentOrderLineItemsToCancel = folisToCancel;
                                    System.debug('$$$ SOM_OrderSummaryCancelationHandler -- folisToCancel  : ' + folisToCancel);      
                                    ConnectAPI.FulfillmentOrderCancelLineItemsOutputRepresentation foCancelResult = ConnectAPI.FulfillmentOrder.cancelFulfillmentOrderLineItems(fo.Id, input);
                                    System.debug('$$$ SOM_OrderSummaryCancelationHandler -- foCancelResult  : ' + foCancelResult);
                                    if(foCancelResult.success){
                                        //fo.Status = 'Canceled';
                                        if(!mapFOByIdToUpdate.containsKey(fo.Id)) mapFOByIdToUpdate.put(fo.Id,fo);
                                        seOfFulfillmentOrderIds.add(fo.Id);
                                        //Calculate Refund Amount
                                        //refundAmount = refundAmount + (foli.Quantity * foli.orderItemSummary.listPrice);

                                    }
                                    else{
                                        processOISCancelation = false;
                                    }
                                                            
                                }
                                else{
                                    //Hnadle Error
                                    processOISCancelation = false;
                                    PickupCancelResponse pickUpLine = new PickupCancelResponse();
                                    WR_fulfillmentOrderOutput wrFOOutput = new WR_fulfillmentOrderOutput();
                                    wrFOOutput.errorMessage = 'This Fulfillment Order not contains any FulfillmentOrderLineItem';
                                    wrFOOutput.FulfillmentOrderId = fo.Id;
                                    wrFOOutput.isSuccess = false;
                                    if(pickUpLine.fulfillmentOrdersOuputs?.size()>0){
                                        pickUpLine.fulfillmentOrdersOuputs.add(wrFOOutput);
                                    }
                                    else{
                                        pickUpLine.fulfillmentOrdersOuputs = new List<WR_fulfillmentOrderOutput>{wrFOOutput};
                                    }
                                    pickUpLine.orderSummaryNumber = orderSummNumber;
                                    
                                    listPickUpResponse.add(pickUpLine);
                                }
                            }
                            if(processOISCancelation){
                                //Cancel OIS
                                ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
                                changeInput.changeItems = listOisItemsTocancel;
                                System.debug('$$$ SOM_OrderSummaryCancelationHandler -- changeInput  : ' + changeInput); 
                                ConnectApi.SubmitCancelOutputRepresentation osCancelResult = ConnectAPI.OrderSummary.submitCancel(orderSummId, changeInput);
                                System.debug('$$$ SOM_OrderSummaryCancelationHandler -- osCancelResult  : ' + osCancelResult);
                                if(osCancelResult.success){
                                    Refund refundItem = new Refund();
                                    refundItem.Amount = osCancelResult.changeBalances.totalAdjProductAmtWithTax;
                                    refundItem.ProcessingMode = 'External';
                                    refundItem.Status = 'Draft';
                                    refundItem.Type = 'Referenced';
                                    refundItem.Date = System.now();
                                    refundItem.EffectiveDate = System.now();
                                    refundToPrepareByOsId.put(ordersummId,refundItem);
                                    setOrderSummaryds.add(ordersummId);
                                }
                                
                            }
                            else{
                                //To verify
                            }

                        }
                        else{
                            //Error Message to handle
                            /*System.debug('$$$ SOM_OrderSummaryCancelationHandler -- Error fulfillmentOrdersByOSId empty  : ');
                            PickupCancelResponse pickUpLine = new PickupCancelResponse();
                            pickUpLine.errorMessage = 'This OrderSummary not contains Any fulfillmentOrder to cancel';
                            listPickUpResponse.add(pickUpLine);*/
                        }
                    }
                    else{
                        //No ordersummary exist
                        PickupCancelResponse pickUpLine = new PickupCancelResponse();
                        pickUpLine.errorMessage = 'No OrderSummary Exist with this OrderNumber : ' + orderSummNumber;
                        pickUpLine.orderSummaryNumber = orderSummNumber;
                        System.debug('ffffffffffffffffffffffff pick' + pickUpLine);
                        listPickUpResponse.add(pickUpLine);
                    }

                    

                }


               
                //for tomorrow start 2022-04-21T16:22:00 -------------

                if(!listPickUpResponse.isEmpty() && mapFOByIdToUpdate.values()?.isEmpty()){
                    Database.rollback(sp);
                    response.statusCode = 200;
                    response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                        'Response' => listPickUpResponse
                    
                    }));
                    return;
                }
                //if(!listosToUpdate?.isEmpty()) update listosToUpdate.values();
                List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> params = new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs>();
                SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs param = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
                List<Id> fulIds = new List<Id>();
                param.foIds = new List<Id>();
                param.foIds.addAll(seOfFulfillmentOrderIds);
                param.doUpdateOSStatus = true;
                params.add(param);
                List<SOM_CloseFulfillmentOrderResponseWr> listFoIdResponse = SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(params);  
                
                if(listFoIdResponse == null ){
                    //Handle Internal Error
                    Database.rollback(sp);
                    response.statusCode = 403;
                    response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                        'Response' => 'Internal Error While updating OrderSummaries status Please contact your Salesforce Admin'
                    
                    }));
                    return;
                }
                SOM_CloseFulfillmentOrderResponseWr foResponse = listFoIdResponse[0];
                if(!foResponse.isSuccess){
                    //handle error while updating fo and os
                    Database.rollback(sp);
                    response.statusCode = 403;
                    response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                        'Response' => 'Error while updating orderSummaries status '+ foResponse.errorMessage
                    
                    }));
                    return;
                }
                if(foResponse.foIds?.size() != seOfFulfillmentOrderIds?.size()){
                    //handle error while updating fo and os
                    Database.rollback(sp);
                    response.statusCode = 403;
                    response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                        'Response' => 'Error while updating orderSummaries status please contact your salesforce Admin for more details'
                    
                    }));
                    return;
                }
                /*if(refundToPrepareByOsId.values()?.isEmpty()){
                    Database.rollback(sp);
                    response.statusCode = 500;
                    response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                        'Response' => 'Error while Creating refunds please contact your salesforce Admin for more details'
                    
                    }));
                    return;
                }
                for(OrderSummary osLine : [SELECT  Id, AccountId, CurrencyIsoCode, OrderNumber, (SELECT Id, PaymentMethodId FROM OrderPaymentSummaries ) FROM OrderSummary WHERE Id IN : refundToPrepareByOsId.keySet()]){
                    if(!osLine.OrderPaymentSummaries?.isEmpty()){
                        refundToPrepareByOsId.get(osLine.Id).AccountId = osLine.AccountId;
                        refundToPrepareByOsId.get(osLine.Id).CurrencyIsoCode = osLine.CurrencyIsoCode;
                        refundToPrepareByOsId.get(osLine.Id).OrderPaymentSummaryId = osLine.OrderPaymentSummaries[0].Id;
                        refundToPrepareByOsId.get(osLine.Id).PaymentMethodId = osLine.OrderPaymentSummaries[0].PaymentMethodId;
                    }
                }
                //Process the creation of refunds
                
                //insert Refunds
                insert refundToPrepareByOsId.values();
                */
                //Prepare Response 
                for(FulfillmentOrder foItem : [SELECT Id, Status , OrderSummaryId, OrderSummary.OrderNumber, OrderSummary.Status 
                                                FROM FulfillmentOrder 
                                                WHERE Id IN : foResponse.foIds]){

                    PickupCancelResponse pickUpLine = new PickupCancelResponse();
                    WR_fulfillmentOrderOutput wrFOOutput = new WR_fulfillmentOrderOutput();
                    wrFOOutput.FulfillmentOrderId = foItem.Id;
                    wrFOOutput.FulfillmentOrderStatus = foItem.status;
                    wrFOOutput.isSuccess = true;
                    pickUpLine.orderSummaryNumber = foItem.OrderSummary.OrderNumber;
                    pickUpLine.orderSummaryStatus = foItem.OrderSummary.Status;
                    if(pickUpLine.fulfillmentOrdersOuputs?.size()>0){
                        pickUpLine.fulfillmentOrdersOuputs.add(wrFOOutput);
                    }
                    else{
                        pickUpLine.fulfillmentOrdersOuputs = new List<WR_fulfillmentOrderOutput>{wrFOOutput};
                    }
                    listPickUpResponse.add(pickUpLine);
                    
                }
                /*for(FulfillmentOrder fo : mapFOByIdToUpdate.values()){
                    if(listosToUpdate.containsKey(fo.OrderSummaryId)){
                        PickupCancelResponse pickUpLine = new PickupCancelResponse();
                        WR_fulfillmentOrderOutput wrFOOutput = new WR_fulfillmentOrderOutput();
                        wrFOOutput.FulfillmentOrderId = fo.Id;
                        wrFOOutput.FulfillmentOrderStatus = fo.status;
                        wrFOOutput.isSuccess = true;
                        pickUpLine.orderSummaryNumber = fo.OrderSummary.OrderNumber;
                        pickUpLine.orderSummaryStatus = listosToUpdate.get(fo.OrderSummaryId).status;
                        if(pickUpLine.fulfillmentOrdersOuputs?.size()>0){
                            pickUpLine.fulfillmentOrdersOuputs.add(wrFOOutput);
                        }
                        else{
                            pickUpLine.fulfillmentOrdersOuputs = new List<WR_fulfillmentOrderOutput>{wrFOOutput};
                        }
                        listPickUpResponse.add(pickUpLine);
                        


                    }
                }*/
                System.debug('$$$ SOM_OrderSummaryCancelationHandler :::: go to ok response : ' + listPickUpResponse);
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                    'Response' => listPickUpResponse
                //'Response' => outPutResponseByFOId.values()
                //'data' => 'ok'
                }));
                System.debug('$$$ SOM_OrderSummaryCancelationHandler End Try block With Success : ');

                
            }
            else{
                String errorMessage = listOrderNumberRequest?.size()>30 ? 'Request Error : Number of orderNumbers per Request should be less or equals 30 lines' : 'List of OrderNumbers Is Empty, Please check your Data!';
                response.statusCode = 403;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String> {
                    'Response' => errorMessage
                //'Response' => outPutResponseByFOId.values()
                //'data' => 'ok'
                }));
                System.debug('$$$ SOM_OrderSummaryCancelationHandler End Try block With Error : ');
            }
        }
        catch(Exception exp){
            Database.rollback(sp);
            System.debug('$$$ SOM_OrderSummaryCancelationHandler Catch Bolck :: Error : '+ exp.getMessage());
                response.statusCode = 403;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                    'Response' => 'Internal Error Please contact your Salesforce Admin'
                
                }));
                System.debug('$$$ SOM_OrderSummaryCancelationHandler End Catch Block : ');

        }
    }


    
    public class PickupCancelRequest{

        public String orderSummaryNumber;
    }
    
    public class PickupCancelResponse {

        
        public String orderSummaryNumber;

        public List<WR_fulfillmentOrderOutput> fulfillmentOrdersOuputs;

        public String orderSummaryStatus;

        public String errorMessage;
    }
    public class WR_fulfillmentOrderOutput {

        public String FulfillmentOrderId;

        public String FulfillmentOrderStatus;

        public String errorMessage;
        
        public Boolean isSuccess;
    }

    
    
}