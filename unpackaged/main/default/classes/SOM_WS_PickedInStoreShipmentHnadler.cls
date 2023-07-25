/**************************************************************************************

-- - Author        : Bader Eddine Elkhal

-- - Description   : An endpoint that create picked In Store shipments and shipment items received from WMS

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 04-18-2022    BEE    1.0          Initial version

***************************************************************************************/
@RestResource(urlMapping='/shipments/orderPickedinStore/*')
global with sharing class SOM_WS_PickedInStoreShipmentHnadler {
    

	/**
	* @description this method used to create shipments, shipment item, call SOM_ClosingFulfillmentOrderAction to close FO
	* @author BADER EDDINE ELKHAL | 04-18-2022 
	* @return Void 
	**/
    @HttpPost
	global static Void createPickedInStoreShipments() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        String RequestBody = request.requestBody.toString() != null ? request.requestBody.toString() : null;


        List<WMS_OrderPickedinStoreRequest> requestData = new List<WMS_OrderPickedinStoreRequest>();
        List<FulfillmentOrder> listfulfillmentOrder = new List<FulfillmentOrder>();
        List<ShipmentItem> listShipmentItemLineToInsert = new List<ShipmentItem>();
        Map <Id, Map<String, FulfillmentOrderLineItem>> listOfLstFOLIWithSkuBFOId = new Map <Id, Map<String, FulfillmentOrderLineItem>>();
        Map<String, List<ShipmentItem>> shipmentItemsToInsertByOsId = new Map<String, List<ShipmentItem>>();
        Map<String, Shipment> shipmentsToInsertByOsNumber = new Map<String, Shipment>();
        Map<String, WMS_OrderPickedinStoreRequest> requestByOSNumber = new Map<String, WMS_OrderPickedinStoreRequest>();
        Map<Id, List<FulfillmentOrder>> listfulfillmentOrderByOsId = new Map<Id, List<FulfillmentOrder>>();
        Map<String, Id> listOSIdByOsNumber = new Map<String, Id>();
        Map<String, Id> listfulfillmentOrderByOrderNumber = new Map<String, Id>();
        Map<String, WMS_OrderPickedinStoreResponse> responseData = new Map<String, WMS_OrderPickedinStoreResponse>();
        Map <Id, Integer> totalExistingShipmentItemsByFoliId = new Map <Id, Integer>();
        Set<Id> setFoliIds = new Set<Id>();
        List<Id> setFoToUpdateStatus = new List<Id>();

        //Save point Start
        Savepoint sp = Database.setSavepoint();
        try {
            // To do ---> Clacultate HeapSize Limits
            requestData = (List<WMS_OrderPickedinStoreRequest>) json.deserialize(RequestBody, List<WMS_OrderPickedinStoreRequest>.class);
            if(requestData.isEmpty()){
                // prepare response to return
                response.statusCode = 400;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String> {
                    'Response' => 'Error Data Request Body Empty'
                }));
                return;
            }
            //prepare request data lines and ordersummNubers in map and set
            for(WMS_OrderPickedinStoreRequest req : requestData){
                requestByOSNumber.put(req.orderSummaryNumber, req);
            }
            listfulfillmentOrder = [SELECT Id, Status, OrderSummaryId, OrderSummary.orderNumber, FulfilledFromLocation.VisitorAddress.city,FulfilledFromLocation.VisitorAddress.Country, 
                                        FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode, FulfilledFromLocation.VisitorAddress.state, 
                                        FulfilledToEmailAddress, FulfilledToPhone, DeliveryMethodId, FulfilledToName, OrderSummary.On_Hold__c, OrderSummary.Status,
                                        (SELECT Id, OrderItemSummaryId, orderItemSummary.listPrice, Product2.StockKeepingUnit,Quantity, Product2Id, OrderItemSummary.isSerialized__c
                                        FROM FulfillmentOrderLineItems 
                                        WHERE Quantity>0 AND Type !=: SOM_Constants.FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE) 
                                    FROM fulfillmentOrder 
                                    WHERE Type =: SOM_Constants.FULFILLMENT_ORDER_FULFILLED_IN_STORE_PICKUP AND OrderSummary.orderNumber IN : requestByOSNumber.keySet() AND
                                    ((orderSummary.Status =: SOM_Constants.ORDER_SUMMARY_VALIDATED AND Status =: SOM_Constants.FULFILLMENT_ORDER_ALLOCATED) OR
                                    (orderSummary.Status =: SOM_Constants.ORDER_SUMMARY_FULFILLING AND Status =: SOM_Constants.FULFILLMENT_ORDER_FULFILLING) OR 
                                    (orderSummary.Status =: SOM_Constants.ORDER_SUMMARY_PARTIALLY_FULFILLED AND Status =: SOM_Constants.FULFILLMENT_ORDER_PARTIALLY_FULFILLED))];
            //Return Error response Data request Empty                        
            if(listfulfillmentOrder.isEmpty()){
                // prepare response to return
                response.statusCode = 400;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                    'Response' => 'Fulfillment Order or Order Summary are not valid or their status should be in : fulfilling, partially fulfilled'
                }));
                return;
            }
            //Loop over
            for(FulfillmentOrder fulfillmentOrder : listfulfillmentOrder){
                //Stack OrderSummary Id by OrderNumber
                listOSIdByOsNumber.put(fulfillmentOrder.orderSummary.orderNumber, fulfillmentOrder.orderSummaryId);
                listfulfillmentOrderByOrderNumber.put(fulfillmentOrder.orderSummary.orderNumber, fulfillmentOrder.Id);
                //Stack fulfillmentOrderLineItem Id 
                if(!fulfillmentOrder.FulfillmentOrderLineItems?.isEmpty()){
                    for(fulfillmentOrderLineItem foli : fulfillmentOrder.FulfillmentOrderLineItems){
                        setFoliIds.add(foli.Id);
                        if(!listOfLstFOLIWithSkuBFOId.containsKey(fulfillmentOrder.Id)){
                            listOfLstFOLIWithSkuBFOId.put(fulfillmentOrder.Id, new Map<String, FulfillmentOrderLineItem>{
                                foli.Product2.StockKeepingUnit => foli
                            }); 
                            continue;
                        } 
                        listOfLstFOLIWithSkuBFOId.get(fulfillmentOrder.Id).put(foli.Product2.StockKeepingUnit,foli);   
                        
                       
                    }
                }
                //Stack fulfillmentOrders by  OrderSummaryId
                if(listfulfillmentOrderByOsId.containsKey(fulfillmentOrder.orderSummaryId)){
                    listfulfillmentOrderByOsId.get(fulfillmentOrder.orderSummaryId).add(fulfillmentOrder);
                    continue;
                }
                listfulfillmentOrderByOsId.put(fulfillmentOrder.orderSummaryId, new List<FulfillmentOrder>{ fulfillmentOrder });
                
            }
            if(!setFoliIds.isEmpty()){
                //Get total Existing Shipment Items for each FulfillmentOrderLineItem
                for(AggregateResult resultFoli : [SELECT  FulfillmentOrderLineItemId FoliId , SUM(Quantity) Quantity  
                                                FROM ShipmentItem 
                                                WHERE FulfillmentOrderLineItemId IN : setFoliIds 
                                                GROUP BY FulfillmentOrderLineItemId]){
                    
                    totalExistingShipmentItemsByFoliId.put((Id) resultFoli.get('FoliId'), Integer.valueOf((Decimal) resultFoli.get('Quantity')));
                }
            }
            for(WMS_OrderPickedinStoreRequest reqLine : requestData){
                //Handle Error no OrderSummary Exist with this OrderNumber
                if(!listOSIdByOsNumber.containsKey(reqLine.orderSummaryNumber)){
                    //handle Error
                    WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                    fulflOrderResponse.isSuccess = false;
                    fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                    fulflOrderResponse.errorMessage = 'Order Summary with number : '+ reqLine.orderSummaryNumber + ' should be in fulling or partially fulfilled status';
                    responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                    continue;
                }
                //Handle Error too long cegidInvoiceNumber
                if(reqLine.cegidInvoiceNumber.length() > 20){
                    //handle Error
                    WMS_OrderPickedinStoreResponse cegidOrdNumberResponse = new WMS_OrderPickedinStoreResponse();
                    cegidOrdNumberResponse.isSuccess = false;
                    cegidOrdNumberResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                    cegidOrdNumberResponse.errorMessage = 'Invoice Number : '+reqLine.cegidInvoiceNumber+' too long, max length is 20';
                    responseData.put(reqLine.orderSummaryNumber, cegidOrdNumberResponse);
                    continue;
                }
                //Handle Error too long deliveryDate
                //valueOf(reqLine.deliveryDate);
                if(listfulfillmentOrderByOsId?.get(listOSIdByOsNumber.get(reqLine.orderSummaryNumber)).size() != 1){
                    //Handle Error no OrderSummary Exist with this OrderNumber
                    WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                    fulflOrderResponse.isSuccess = false;
                    fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                    String errorMsg = 'Error: this order Summary with the number '+ reqLine.orderSummaryNumber ;
                    fulflOrderResponse.errorMessage = listfulfillmentOrderByOsId?.get(listOSIdByOsNumber.get(reqLine.orderSummaryNumber)).size() > 1 ? errorMsg + ' should have only one FulfillmentOrder to ship' : errorMsg + ' not contains any fulfillmentOrder to ship';
                    responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                    continue;
                }
                //Get Current FulfillmentOrder to process from map
                FulfillmentOrder foToProcess = listfulfillmentOrderByOsId.get(listOSIdByOsNumber.get(reqLine.orderSummaryNumber)).get(0);
                if (foToProcess.OrderSummary.On_Hold__c) {
                    WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                    fulflOrderResponse.isSuccess = false;
                    fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                    fulflOrderResponse.errorMessage = 'Order Summary with number : '+ reqLine.orderSummaryNumber + ' is on hold.';
                    responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                    continue;
                }
                Shipment shipment = new Shipment();
                shipment.DeliveryMethodId = foToProcess.DeliveryMethodId;
                shipment.FulfillmentOrderId = foToProcess.Id;
                shipment.OrderSummaryId = foToProcess.OrderSummaryId;
                shipment.ShipToName = foToProcess.FulfilledToName;
                shipment.SourceLocationId = foToProcess.FulfilledFromLocationId;
                shipment.DispatchDate__c = reqLine.deliveryDate;
                Shipment.CegidInvoiceNumber__c = reqLine.cegidInvoiceNumber;
                shipment.Status = SOM_Constants.SHIPMENT_SHIPPED;
                if(foToProcess.FulfilledFromLocation != null){
                    //shipFrom data
                    shipment.ShipFromCity = foToProcess.FulfilledFromLocation.VisitorAddress.City;
                    shipment.ShipFromStreet = foToProcess.FulfilledFromLocation.VisitorAddress.Street;
                    shipment.ShipFromPostalCode = foToProcess.FulfilledFromLocation.VisitorAddress.PostalCode;
                    shipment.ShipFromState = foToProcess.FulfilledFromLocation.VisitorAddress.State;
                    shipment.ShipFromCountry = foToProcess.FulfilledFromLocation.VisitorAddress.Country;
                    //shipTo data
                    shipment.ShipToCity = foToProcess.FulfilledFromLocation.VisitorAddress.City;
                    shipment.ShipToStreet = foToProcess.FulfilledFromLocation.VisitorAddress.Street;
                    shipment.ShipToPostalCode = foToProcess.FulfilledFromLocation.VisitorAddress.PostalCode;
                    shipment.ShipToState = foToProcess.FulfilledFromLocation.VisitorAddress.State;
                    shipment.ShipToCountry = foToProcess.FulfilledFromLocation.VisitorAddress.Country;
                }
                //Check if no Item exist to ship for this Order
                if(reqLine.item?.isEmpty()){
                    //Handle error message no item exist to ship for this order
                    WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                    fulflOrderResponse.isSuccess = false;
                    fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                    fulflOrderResponse.errorMessage = 'Error: list items to ship is empty ';
                    responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                    continue;
                }
                
                for(WMS_Item item : reqLine.item){
                    fulfillmentOrderLineItem foliLine = listOfLstFOLIWithSkuBFOId?.get(listfulfillmentOrderByOrderNumber?.get(reqLine.orderSummaryNumber))?.get(item.sku);
                    if(foliLine == null){
                        //handle error no foli exist with target sku
                        WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                        fulflOrderResponse.isSuccess = false;
                        fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                        fulflOrderResponse.errorMessage = 'Error: no fulfillmentOrderLineItem exist with target SKU '+item.sku;
                        if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)) shipmentItemsToInsertByOsId.remove(reqLine.orderSummaryNumber);
                        if(shipmentsToInsertByOsNumber.containsKey(reqLine.orderSummaryNumber)) shipmentsToInsertByOsNumber.remove(reqLine.orderSummaryNumber);
                        responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                        break;
                    }
                    Integer totalExistingShipmentItems = totalExistingShipmentItemsByFoliId.containsKey(foliLine.Id) ? totalExistingShipmentItemsByFoliId.get(foliLine.Id) + item.qty : item.qty;
                    if(foliLine.Quantity < totalExistingShipmentItems){
                        //handle foli Quantity less than requested quantity to ship
                        WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                        fulflOrderResponse.isSuccess = false;
                        fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                        fulflOrderResponse.errorMessage = 'Error: Quantity requested to ship is greater than Quantity Available for this SKU '+item.sku;
                        responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                        if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)) shipmentItemsToInsertByOsId.remove(reqLine.orderSummaryNumber);
                        if(shipmentsToInsertByOsNumber.containsKey(reqLine.orderSummaryNumber)) shipmentsToInsertByOsNumber.remove(reqLine.orderSummaryNumber);
                        break;
                    }
                    if(item.serialNumber !=null && item.serialNumber?.size() != item.qty){
                        //handle item serialNumber not equal with quantity to ship
                        WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                        fulflOrderResponse.isSuccess = false;
                        fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                        fulflOrderResponse.errorMessage = 'Error: Quantity requested to ship not equal the totale of serialNumbers';
                        if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)) shipmentItemsToInsertByOsId.remove(reqLine.orderSummaryNumber);
                        if(shipmentsToInsertByOsNumber.containsKey(reqLine.orderSummaryNumber)) shipmentsToInsertByOsNumber.remove(reqLine.orderSummaryNumber);
                        responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                        break;
                    }
                    if(foliLine.OrderItemSummary.isSerialized__c && (item.serialNumber == null || item.serialNumber.isEmpty())){
                        //handle item serialNumber not equal with quantity to ship
                        WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                        fulflOrderResponse.isSuccess = false;
                        fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                        fulflOrderResponse.errorMessage = 'Missing serialNumbers for serialized product with this SKU ' + item.sku;
                        if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)) shipmentItemsToInsertByOsId.remove(reqLine.orderSummaryNumber);
                        if(shipmentsToInsertByOsNumber.containsKey(reqLine.orderSummaryNumber)) shipmentsToInsertByOsNumber.remove(reqLine.orderSummaryNumber);
                        responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                        break;
                    }
                    if(!foliLine.OrderItemSummary.isSerialized__c && item.serialNumber !=null){
                        //handle item serialNumber not equal with quantity to ship
                        WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                        fulflOrderResponse.isSuccess = false;
                        fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                        fulflOrderResponse.errorMessage = 'No serialNumber should provided for a non serialized product with this SKU ' + item.sku;
                        if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)) shipmentItemsToInsertByOsId.remove(reqLine.orderSummaryNumber);
                        if(shipmentsToInsertByOsNumber.containsKey(reqLine.orderSummaryNumber)) shipmentsToInsertByOsNumber.remove(reqLine.orderSummaryNumber);
                        responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                        break;
                    }
                    //Update quantity available to ship per foli
                    totalExistingShipmentItemsByFoliId.put(foliLine.Id, totalExistingShipmentItems);
                    //list shipment to insert by the order summary number
                    shipmentsToInsertByOsNumber.put(reqLine.orderSummaryNumber ,shipment);
                    if(item.serialNumber != null){
                        //Loop Over SerialNumbers
                        for(String serialNumber : item.serialNumber){
                            if(serialNumber.length() > 20 ){
                                //handle item's serialNumber too large
                                WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                                fulflOrderResponse.isSuccess = false;
                                fulflOrderResponse.orderSummaryNumber = reqLine.orderSummaryNumber;
                                fulflOrderResponse.errorMessage = 'SerialNumber : '+serialNumber+' too long, max length is 20';
                                if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)) shipmentItemsToInsertByOsId.remove(reqLine.orderSummaryNumber);
                                if(shipmentsToInsertByOsNumber.containsKey(reqLine.orderSummaryNumber)) shipmentsToInsertByOsNumber.remove(reqLine.orderSummaryNumber);
                                responseData.put(reqLine.orderSummaryNumber, fulflOrderResponse);
                                break;
                            }
                            ShipmentItem shipmentLine = new ShipmentItem();
                            shipmentLine.Product2Id = foliLine.Product2Id;
                            shipmentLine.Quantity = 1;
                            shipmentLine.FulfillmentOrderLineItemId = foliLine.Id;
                            shipmentLine.SerialNumber__c = serialNumber;
                            shipmentLine.OrderItemSummaryId = foliLine.OrderItemSummaryId;
                            
                            if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)){
                                shipmentItemsToInsertByOsId.get(reqLine.orderSummaryNumber).add(shipmentLine);
                            }
                            else{
                                shipmentItemsToInsertByOsId.put(reqLine.orderSummaryNumber, new List<ShipmentItem>{shipmentLine});
                            }                                         
                        }
                        continue;                                  
                    }
                    //case if product are not serializable
                    ShipmentItem shipmentLine = new ShipmentItem();
                    shipmentLine.Product2Id = foliLine.Product2Id;
                    shipmentLine.Quantity = item.qty;
                    shipmentLine.FulfillmentOrderLineItemId = foliLine.Id;
                    shipmentLine.OrderItemSummaryId = foliLine.OrderItemSummaryId;

                    if(shipmentItemsToInsertByOsId.containsKey(reqLine.orderSummaryNumber)){
                        shipmentItemsToInsertByOsId.get(reqLine.orderSummaryNumber).add(shipmentLine);
                    }
                    else{
                        shipmentItemsToInsertByOsId.put(reqLine.orderSummaryNumber, new List<ShipmentItem>{shipmentLine});
                    }    
                }
            }
            //insert Shipment
            if(!shipmentsToInsertByOsNumber.values().isEmpty()){
                insert shipmentsToInsertByOsNumber.values();
                //Loop over shipmentItem by OrderNumber to assign shipmentId to shipmentItem
                for(String orderNumber : shipmentsToInsertByOsNumber.keySet()){
                    if(!shipmentItemsToInsertByOsId?.get(orderNumber)?.isEmpty() && shipmentsToInsertByOsNumber?.get(orderNumber).Id != null){
                        Id shipmentId = shipmentsToInsertByOsNumber.get(orderNumber).Id;
                        for(ShipmentItem shipItem : shipmentItemsToInsertByOsId.get(orderNumber)){
                            shipItem.shipmentId = shipmentId;
                            listShipmentItemLineToInsert.add(shipItem);
                        }
                        //Stack Fo Id update
                        setFoToUpdateStatus.add(shipmentsToInsertByOsNumber.get(orderNumber).FulfillmentOrderId);

                    }
                }
                if(!listShipmentItemLineToInsert.isEmpty()) insert listShipmentItemLineToInsert;
                //Update Fo And Os Status
                List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> params = new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs>();
                SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs param = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
                List<Id> fulIds = new List<Id>();
                param.foIds = new List<Id>();
                param.foIds.addAll(setFoToUpdateStatus);
                param.doUpdateOSStatus = true;
                params.add(param);
                List<SOM_CloseFulfillmentOrderResponseWr> listFoIdResponse = SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(params);  
                /*
                    Optimisation du Code
                */
                if(listFoIdResponse == null || !listFoIdResponse[0].isSuccess){
                    //Handle Internal Error
                    Database.rollback(sp);
                    response.statusCode = 403;
                    String errorMsg = listFoIdResponse == null ? 'Internal Error While updating OrderSummaries status Please contact your Salesforce Admin' : 'Error while updating orderSummaries status '+ listFoIdResponse[0].errorMessage;
                    response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                        'Response' => errorMsg
                    
                    }));
                    return;
                }
                for(FulfillmentOrder foItem : [SELECT Id, Status , OrderSummaryId, OrderSummary.OrderNumber, OrderSummary.Status 
                                                FROM FulfillmentOrder 
                                                WHERE Id IN : listFoIdResponse[0].foIds]){
                    
                    WMS_OrderPickedinStoreResponse fulflOrderResponse = new WMS_OrderPickedinStoreResponse();
                    fulflOrderResponse.isSuccess = true;
                    fulflOrderResponse.orderSummaryNumber = foItem.OrderSummary.OrderNumber;
                    fulflOrderResponse.orderSummaryStatus = foItem.OrderSummary.Status;
                    responseData.put(foItem.OrderSummary.OrderNumber, fulflOrderResponse);
                    
                }
            }
            if(responseData.isEmpty()){
                response.statusCode = 403;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                    'Response' => 'Internal Error No shipment was processed'
                    
                }));
            }
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                'Response' => responseData.values()
                
            }));
            
        } catch (Exception exp) {
            Database.rollback(sp);
            response.statusCode = 403;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                'Response' => 'Internal Error Please contact your Salesforce Admin'
            
            }));
            
        }
        
    }

    // data Request wrapper
    public class WMS_OrderPickedinStoreRequest {

        public String orderSummaryNumber;
        
        public String cegidInvoiceNumber;
        
        public Datetime deliveryDate;        
    
        public List<WMS_Item> item;
    }
    public class WMS_Item {

        public String sku;
        
        public Integer qty;
        
        public List<String> serialNumber;
    }
    public class WMS_OrderPickedinStoreResponse {

        public String orderSummaryNumber;
        
        public String orderSummaryStatus;
        
        public Boolean isSuccess;
        
        public String errorMessage;
    }
}
