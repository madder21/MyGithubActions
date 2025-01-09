/**************************************************************************************

-- - Author        : Mohamed Amine ANBRI

-- - Description   : An endpoint that creates Return Orders and Return Order Line Items

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 29-03-2022    MAA    1.0          Initial version

***************************************************************************************/
@RestResource(urlMapping='/ReturnOrderEndpoint/*')
global with sharing class WS_SOM_CreateReturnOrderEndpoint {
   
    public static final String CONCAT_CHARACTER               = '_';
    public static final String SERIAL_NUMBER_CONCAT_CHARACTER = ',';
    public static final String SERIAL_NUMBER_SC_CONCAT_CHARACTER = ';';

    /**
     * @description handleReturnOrderCreateUpdateRequest Create Return Orders and Return Order Line Items
     * @param  request request List of Return Orders to create
     * @return         return  response
     */
    @HttpPost
    global static List<ReturnOrderCreateUpdateResponse> handleReturnOrderCreateUpdateRequest(List<ReturnOrderCreateUpdateRequest> request){
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeObject(request);
        List<ReturnOrderCreateUpdateResponse> returnOrderCreateUpdateResponseList = new List<ReturnOrderCreateUpdateResponse>();
        List<String> orderNumbers = new List<String>();
        List<String> locations    = new List<String>();
        try {
            for (ReturnOrderCreateUpdateRequest req:request) {
                if (req.orderSummaryNumber != null && req.orderSummaryNumber.length() > 0)
                    orderNumbers.add(req.orderSummaryNumber);
                if (req.warehouseId != null && req.warehouseId.length() > 0)
                    locations.add(req.warehouseId); 
            }
            
            Map<String, Schema.Location> locationMap              = getLocationMap(locations);
            Map<String, OrderSummary> orderSummaryMap             = getOrderSummaryMap(orderNumbers);
            Map<String, Map<String, OrderShipmentItem>> orderSummaryShipmentsMap = getOrderSummaryShipmentMap(orderNumbers);
            Map<String, Map<String, List<ReturnOrderLineItem>>> orderSummaryReturnOrderLineItemsMap = getOrderSummaryReturnsMap(orderNumbers);
            List<String> returnOrderReturnOriginValues            = getPicklistValues('ReturnOrder', 'ReturnOrigin__c');
            List<String> returnOrderItemConditionValues           = getPicklistValues('ReturnOrderLineItem', 'ConditionId__c');
            List<String> returnOrderItemReasonForReturnValues     = getPicklistValues('ReturnOrderLineItem', 'ReasonForReturn');
            
            Map<Id, ReturnOrderCreateUpdateRequest> returnOrderToUpdateMap                = new Map<Id, ReturnOrderCreateUpdateRequest>();
            Map<Id, Map<String, returnOrderItemCreateUpdate>> returnOrderItemsToUpdateMap = new Map<Id, Map<String, returnOrderItemCreateUpdate>>();
            List<ReturnOrderLineItem> returnOrderLineItemsList = new List<ReturnOrderLineItem>();
            Set<Id> returnOrderIds = new Set<Id>();
            //iterate over return orders
            for (ReturnOrderCreateUpdateRequest req:request) {
                Map<String, returnOrderItemCreateUpdate> returnOrderItemsRequest = new Map<String, returnOrderItemCreateUpdate>();
                String errorMsg = checkReturnOrderRequest(req, orderSummaryMap.get(req.orderSummaryNumber), locationMap.get(req.warehouseId), returnOrderReturnOriginValues);
                if (errorMsg != null) {
                    returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(errorMsg, 'KO', req.orderSummaryNumber, null, null,null));
                    continue;
                }
                //if return request is RMA or no Return found for this order => create new Return
                if (req.type == SOM_Constants.RMA_RETURN_TYPE || !orderSummaryReturnOrderLineItemsMap.containsKey(req.orderSummaryNumber)) {
                    String errorMessage = createReturnOrderWithItems(orderSummaryShipmentsMap, 
                                                req.items, 
                                                req, 
                                                returnOrderItemConditionValues, 
                                                returnOrderItemReasonForReturnValues, 
                                                orderSummaryMap.get(req.orderSummaryNumber), 
                                                returnOrderToUpdateMap, 
                                                returnOrderItemsToUpdateMap); 
                    if (errorMessage != null) {
                        returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(errorMessage, 'KO', req.orderSummaryNumber, null, null,null));
                    }
                    continue;
                }
                List<ReturnOrderLineItem> returnOrderLineItemsWithSameQuantityExpected      = new List<ReturnOrderLineItem>();
                List<ReturnOrderLineItem> returnOrderLineItemsWithDifferentQuantityExpected = new List<ReturnOrderLineItem>();
                String errorMessage = populateReturnOrderLineItemsMapToUpdate(req, 
                                                                            orderSummaryShipmentsMap,
                                                                            orderSummaryReturnOrderLineItemsMap,
                                                                            returnOrderLineItemsWithSameQuantityExpected, 
                                                                            returnOrderLineItemsWithDifferentQuantityExpected, 
                                                                            returnOrderItemConditionValues, 
                                                                            returnOrderItemReasonForReturnValues);
                if (errorMessage != null) {
                    returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(errorMessage, 'KO', req.orderSummaryNumber, null, null,null));
                    continue;
                }
                List<ReturnOrderLineItem> lineItemsToUpdate         = new List<ReturnOrderLineItem>();
                List<ReturnOrderItemCreateUpdate> lineItemsToCreate = new List<ReturnOrderItemCreateUpdate>();
                for(ReturnOrderItemCreateUpdate returnOrderItemCreateUpdate:req.items) {
                    ReturnOrderLineItem roLineItem = foundReturnOrderLineItemToUpdate(returnOrderItemCreateUpdate, 
                                                        returnOrderLineItemsWithSameQuantityExpected, 
                                                        returnOrderLineItemsWithDifferentQuantityExpected);
                    if (roLineItem != null) {
                        if ((roLineItem.QuantityExpected < returnOrderItemCreateUpdate.quantity) && (returnOrderItemCreateUpdate.quantity - roLineItem.QuantityExpected > orderSummaryShipmentsMap.get(req.orderSummaryNumber).get(returnOrderItemCreateUpdate.sku).quantityAvailableToReturn)) {
                            errorMessage = 'The additional return quantity: ' + (returnOrderItemCreateUpdate.quantity - roLineItem.QuantityExpected) + ' is greater than the quantity available to return: ' + orderSummaryShipmentsMap.get(req.orderSummaryNumber).get(returnOrderItemCreateUpdate.sku).quantityAvailableToReturn;
                            break;
                        }    
                        if (roLineItem.QuantityExpected < returnOrderItemCreateUpdate.quantity){
                            ReturnOrderItemCreateUpdate roItemToCreate = new ReturnOrderItemCreateUpdate();
                            roItemToCreate.sku            = returnOrderItemCreateUpdate.sku;
                            roItemToCreate.quantity       = returnOrderItemCreateUpdate.quantity - roLineItem.QuantityExpected;
                            roItemToCreate.conditionId    = returnOrderItemCreateUpdate.conditionId;
                            roItemToCreate.reasonCode     = returnOrderItemCreateUpdate.reasonCode;
                            if (returnOrderItemCreateUpdate.serialNumbers != null  && !returnOrderItemCreateUpdate.serialNumbers.Isempty()){
                                List<String> srlsSlice = new List<String>();
                                List<String> srlsMax   = new List<String>();
                                srlsSlice = returnOrderItemCreateUpdate.serialNumbers.clone();
                                Integer IndexExistSerialNumber = 0;
                                IndexExistSerialNumber = returnOrderItemCreateUpdate.serialNumbers.indexOf(roLineItem.SerialNumber__c);
                                if (IndexExistSerialNumber !=-1){
                                    srlsSlice.remove(IndexExistSerialNumber);
                                }
                               
                                for(Integer q = 0 ; q < roItemToCreate.quantity  ; q++){
                                    srlsMax.add(srlsSlice[q]);
                                }
                                roItemToCreate.serialNumbers  = srlsMax;
                            }
                            roItemToCreate.reasonFreeText = returnOrderItemCreateUpdate.reasonFreeText;
                            lineItemsToCreate.add(roItemToCreate);
                            roLineItem.QuantityReceived = roLineItem.QuantityExpected;
                            //roLineItem.QuantityExpected = returnOrderItemCreateUpdate.quantity; ==> this wil throw an exception
                        }
                        else if(roLineItem.QuantityExpected >= returnOrderItemCreateUpdate.quantity){
                                roLineItem.QuantityReceived = roLineItem.QuantityReceived + returnOrderItemCreateUpdate.quantity; //returnOrderItemCreateUpdate.quantity;
                                //roLineItem.QuantityExpected = roLineItem.QuantityReceived; 
                        }
                        if (returnOrderItemCreateUpdate.reasonCode != null && returnOrderItemCreateUpdate.reasonCode.length() > 0)
                            roLineItem.ReasonForReturn = returnOrderItemCreateUpdate.reasonCode;
                        if (returnOrderItemCreateUpdate.conditionId != null && returnOrderItemCreateUpdate.conditionId.length() > 0)    
                            roLineItem.ConditionId__c   = returnOrderItemCreateUpdate.conditionId;
                        if (returnOrderItemCreateUpdate.reasonFreeText != null && returnOrderItemCreateUpdate.reasonFreeText.length() > 0)    
                            roLineItem.AdditionalReturnReason__c = returnOrderItemCreateUpdate.reasonFreeText;
                        if (returnOrderItemCreateUpdate.sku10Digits != null && returnOrderItemCreateUpdate.sku10Digits.length() > 0)    
                            roLineItem.Sku_10_Digits__c = returnOrderItemCreateUpdate.sku10Digits;
                        if (returnOrderItemCreateUpdate.serialNumbers != null){
                            List<String> srls = new List<String>();
                            for(Integer q = 0 ; q < roLineItem.QuantityExpected ; q++){
                                srls.add(returnOrderItemCreateUpdate.serialNumbers[q]);
                            }
                            if( roLineItem.SerialNumber__c != null){
                            	roLineItem.SerialNumber__c  = roLineItem.SerialNumber__c + ';' +String.join(srls, SERIAL_NUMBER_SC_CONCAT_CHARACTER);
                            } else {
                            	roLineItem.SerialNumber__c  = String.join(srls, SERIAL_NUMBER_SC_CONCAT_CHARACTER);
                            }
                        }
                        lineItemsToUpdate.add(roLineItem);
                        returnOrderIds.add(roLineItem.ReturnOrderId);
                        continue;
                    }
                    //For line items that we didn't find a match
                    lineItemsToCreate.add(returnOrderItemCreateUpdate);
                }
                if (errorMessage != null) {
                    returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(errorMessage, 'KO', req.orderSummaryNumber, null, null,null));
                    continue;
                }
                //Create new return for items that didn't have a correspondant line item
                if (lineItemsToCreate.size() > 0) {
                    errorMessage = createReturnOrderWithItems(orderSummaryShipmentsMap,
                                                lineItemsToCreate,
                                                req,
                                                returnOrderItemConditionValues,
                                                returnOrderItemReasonForReturnValues,
                                                orderSummaryMap.get(req.orderSummaryNumber), 
                                                returnOrderToUpdateMap,
                                                returnOrderItemsToUpdateMap);
                    if (errorMessage != null) {
                        returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(errorMessage, 'KO', req.orderSummaryNumber, null, null,null));
                        continue;
                    }
                }
                for (ReturnOrderLineItem roLineItem:lineItemsToUpdate) {
                    returnOrderToUpdateMap.put(roLineItem.ReturnOrderId, req);
                }
                returnOrderLineItemsList.addAll(lineItemsToUpdate);
            }
            updateReturnOrders(returnOrderToUpdateMap,
                            returnOrderItemsToUpdateMap,
                            locationMap,
                            returnOrderLineItemsList,
                            returnOrderIds,
                            returnOrderCreateUpdateResponseList);
        } catch(Exception ex){
            returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(ex.getMessage(), 'KO', null, null, null,null));
        }

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeObject(returnOrderCreateUpdateResponseList);

        return returnOrderCreateUpdateResponseList;
    }

    /**
     * @description foundReturnOrderLineItemToUpdate found the return line item to update its quantity
     * @param  returnOrderItemCreateUpdate                       returnOrderItemCreateUpdate : return item request
     * @param  returnOrderLineItemsWithSameQuantityExpected      returnOrderLineItemsWithSameQuantityExpected : list of return items with the same quantity expected
     * @param  returnOrderLineItemsWithDifferentQuantityExpected returnOrderLineItemsWithDifferentQuantityExpected : list of return items with the different quantity expected
     * @return                                                   return return order line item
     */
    public static ReturnOrderLineItem foundReturnOrderLineItemToUpdate(ReturnOrderItemCreateUpdate returnOrderItemCreateUpdate,
                                                                    List<ReturnOrderLineItem> returnOrderLineItemsWithSameQuantityExpected,
                                                                    List<ReturnOrderLineItem> returnOrderLineItemsWithDifferentQuantityExpected){
        for (ReturnOrderLineItem roli : returnOrderLineItemsWithSameQuantityExpected) {
            if (roli.Product2.StockKeepingUnit == returnOrderItemCreateUpdate.sku) return roli;
        }
        for (ReturnOrderLineItem roli : returnOrderLineItemsWithDifferentQuantityExpected) {
            if (roli.Product2.StockKeepingUnit == returnOrderItemCreateUpdate.sku) return roli;
        }

        return null;
    }

    /**
     * @description populateReturnOrderLineItemsMapToUpdate populate possible return Line items to update
     * @param  req                                               req : return order request
     * @param  orderSummaryShipmentsMap                          orderSummaryShipmentsMap : already shipped items
     * @param  orderSummaryReturnOrderLineItemsMap               orderSummaryReturnOrderLineItemsMap : returns that are already creaded
     * @param  returnOrderLineItemsWithSameQuantityExpected      returnOrderLineItemsWithSameQuantityExpected : list of return items with the same quantity expected
     * @param  returnOrderLineItemsWithDifferentQuantityExpected returnOrderLineItemsWithDifferentQuantityExpected : list of return items with the different quantity expected
     * @param  returnOrderItemConditionValues                    returnOrderItemConditionValues       : condition values
     * @param  returnOrderItemReasonForReturnValues              returnOrderItemReasonForReturnValues : reason codes
     * @return                                                   return error message
     */
    private static String populateReturnOrderLineItemsMapToUpdate(ReturnOrderCreateUpdateRequest req,
                                                                Map<String, Map<String, OrderShipmentItem>> orderSummaryShipmentsMap,
                                                                Map<String, Map<String, List<ReturnOrderLineItem>>> orderSummaryReturnOrderLineItemsMap,
                                                                List<ReturnOrderLineItem> returnOrderLineItemsWithSameQuantityExpected,
                                                                List<ReturnOrderLineItem> returnOrderLineItemsWithDifferentQuantityExpected,
                                                                List<String> returnOrderItemConditionValues,
                                                                List<String> returnOrderItemReasonForReturnValues){
        for(ReturnOrderItemCreateUpdate returnOrderItemCreateUpdate:req.items) {
            String errorMessage = verifyReturnLineItemIsValid(returnOrderItemCreateUpdate, 
                                                        orderSummaryShipmentsMap.get(req.orderSummaryNumber).get(returnOrderItemCreateUpdate.sku), 
                                                        returnOrderItemConditionValues, 
                                                        returnOrderItemReasonForReturnValues);
            if (errorMessage != null) return errorMessage;
            //returnOrder items in submitted status that have the sku
            List<ReturnOrderLineItem> returnOrderLineItems = orderSummaryReturnOrderLineItemsMap.get(req.orderSummaryNumber).get(returnOrderItemCreateUpdate.sku);
            //No returns have the sku
            if (returnOrderLineItems == null || returnOrderLineItems.isEmpty()) continue;
            for (ReturnOrderLineItem lineItem:returnOrderLineItems) {
                if (lineItem.QuantityExpected == returnOrderItemCreateUpdate.quantity){
                    returnOrderLineItemsWithSameQuantityExpected.add(lineItem);
                    continue;
                }
                returnOrderLineItemsWithDifferentQuantityExpected.add(lineItem);  
            }
        }
        return null;
    }

    /**
     * @description updateReturnOrders description
     * @param  returnOrderToUpdateMap              returnOrderToUpdateMap      : return orders to update
     * @param  returnOrderItemsToUpdateMap         returnOrderItemsToUpdateMap : return items to update
     * @param  locationMap                         locationMap : location map
     * @param  returnOrderLineItemsList            returnOrderLineItemsList : return order items that have values sync with return item request
     * @param  returnOrderIds                      returnOrderIds : return orders that have return items already updated
     * @param  returnOrderCreateUpdateResponseList returnOrderCreateUpdateResponseList : returns' response list
     */
    private static void updateReturnOrders(Map<Id, ReturnOrderCreateUpdateRequest> returnOrderToUpdateMap,
                                        Map<Id, Map<String, returnOrderItemCreateUpdate>> returnOrderItemsToUpdateMap,
                                        //ReturnOrderCreateUpdateRequest req,
                                        Map<String, Schema.location> locationMap, 
                                        List<ReturnOrderLineItem> returnOrderLineItemsList,
                                        Set<Id> returnOrderIds,
                                        List<ReturnOrderCreateUpdateResponse> returnOrderCreateUpdateResponseList){
        List<ReturnOrder> returnOrdersToUpdateList = new List<ReturnOrder>();
        List<ReturnOrderLineItem> returnOrderLineItemsToUpdateList = new List<ReturnOrderLineItem>(returnOrderLineItemsList);                    
        if (returnOrderToUpdateMap.size() > 0) {
            List<ReturnOrder> returnOrders = [SELECT Id, ReturnOrderNumber, ReturnDate__c, ReturnOrigin__c, DestinationLocationId, SourceLocationId, OrderSummary.OrderNumber, (SELECT Id,Sku_10_Digits__c, AdditionalReturnReason__c, ConditionId__c, Product2.StockKeepingUnit FROM ReturnOrderLineItems) FROM ReturnOrder WHERE Id=:returnOrderToUpdateMap.keySet()];
            if (returnOrders != null && !returnOrders.isEmpty()) {
                for(ReturnOrder returnOrderToUpdate:returnOrders) {
                    ReturnOrderCreateUpdateRequest req = returnOrderToUpdateMap.get(returnOrderToUpdate.Id);
                    if (req.returnDate != null) returnOrderToUpdate.ReturnDate__c = SOM_DateTimeHelper.convertISO8601ToDateTime(req.returnDate);
                    returnOrderToUpdate.ReturnOrigin__c = req.returnOrigin;
                    if (locationMap.get(req.warehouseId) != null) returnOrderToUpdate.DestinationLocationId = locationMap.get(req.warehouseId).Id;
                    //return line items already added to the update list
                    if (returnOrderIds.contains(returnOrderToUpdate.Id)) {
                        returnOrdersToUpdateList.add(returnOrderToUpdate);
                        continue;
                    }
                    List<ReturnOrderLineItem> ReturnOrderLineItemList = new List<ReturnOrderLineItem>();
                    Map<String, returnOrderItemCreateUpdate> returnOrderItemsRequest = returnOrderItemsToUpdateMap.get(returnOrderToUpdate.id);
                    if (returnOrderToUpdate.ReturnOrderLineItems != null && !returnOrderToUpdate.ReturnOrderLineItems.isEmpty()) {
                        for(ReturnOrderLineItem lineItem:returnOrderToUpdate.ReturnOrderLineItems) {
                            returnOrderItemCreateUpdate returnOrderItemRequest = returnOrderItemsRequest.get(lineItem.Id);
                            if (returnOrderItemRequest != null) {
                                lineItem.ConditionId__c = returnOrderItemRequest.conditionId;
                                if (returnOrderItemRequest.reasonCode == null || returnOrderItemRequest.reasonCode.length() == 0)
                                    lineItem.ReasonForReturn = SOM_Constants.RETURN_DEFAULT_REASON_CODE;
                                if (returnOrderItemRequest.serialNumbers != null && !returnOrderItemRequest.serialNumbers.isEmpty()) {
                                    lineItem.SerialNumber__c = String.join(returnOrderItemRequest.serialNumbers, SERIAL_NUMBER_CONCAT_CHARACTER);
                                } 
                                lineItem.AdditionalReturnReason__c = returnOrderItemRequest.reasonFreeText;
                                lineItem.Sku_10_Digits__c = returnOrderItemRequest.sku10Digits;
                                returnOrderLineItemsToUpdateList.add(lineItem);
                            }
                            ReturnOrderLineItemList.add(lineItem);
                        }
                    }
                    if (req.type == SOM_Constants.RMA_RETURN_TYPE)
                    returnOrderToUpdate.expectedPackages__c         =  Math.max(1,GetSUMQuantityExpected(ReturnOrderLineItemList));
                    returnOrdersToUpdateList.add(returnOrderToUpdate);
                }
            }
        }

        try {
            PAD.deactivateTrigger(SOM_Constants.RETURN_ORDER_ITEM_TRIGGER_CONDITION_ID);
            if (returnOrdersToUpdateList.size() > 0) update returnOrdersToUpdateList;
            if (returnOrderLineItemsToUpdateList.size() > 0) update returnOrderLineItemsToUpdateList;
            updateReturnOrdersToReceivedQty(returnOrderToUpdateMap);
            updateReturnOrdersToReceived(returnOrderToUpdateMap);
            for (ReturnOrder persistedReturnOrder:returnOrdersToUpdateList) {
                ReturnOrderCreateUpdateRequest req = returnOrderToUpdateMap.get(persistedReturnOrder.Id);
                if (req.type == SOM_Constants.RMA_RETURN_TYPE){
                	returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(null, 'OK', persistedReturnOrder.OrderSummary.OrderNumber, persistedReturnOrder.Id, persistedReturnOrder.ReturnOrderNumber,persistedReturnOrder.expectedPackages__c));
                }else{
                	returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(null, 'OK', persistedReturnOrder.OrderSummary.OrderNumber, persistedReturnOrder.Id, persistedReturnOrder.ReturnOrderNumber,null));
                }
            }
        } catch(Exception ex) {
            returnOrderCreateUpdateResponseList.add(createReturnOrderCreateUpdateResponse(ex.getMessage(), 'KO', null, null, null,null));
        }
    }

        /**
     * @description updateReturnOrdersToReceivedQty update return orders quatities to received
     * @param  returnOrderToUpdateMap returnOrderToUpdateMap return orders to update
     */
    private static void updateReturnOrdersToReceivedQty(Map<Id, ReturnOrderCreateUpdateRequest> returnOrderToUpdateMap){
        if (returnOrderToUpdateMap.size() > 0) {
            List<ReturnOrder> returnOrdersToUpdate = new List<ReturnOrder>();
            List<ReturnOrderLineItem> ReturnOrderLineItemToUpdate = new List<ReturnOrderLineItem>();
            List<ReturnOrder> returnOrders = [SELECT Id, Status, (SELECT Id,RepaymentMethod,Quantity_Previously_Received__c,Quantity_Previously_Returned__c, QuantityExpected, QuantityReceived FROM ReturnOrderLineItems) FROM ReturnOrder WHERE Id=:returnOrderToUpdateMap.keySet()];
            for (ReturnOrder ro:returnOrders) {
                ReturnOrderCreateUpdateRequest req = returnOrderToUpdateMap.get(ro.Id);
                if (req.type == SOM_Constants.WMS_RETURN_TYPE){                
                    for (ReturnOrderLineItem roLineItem:ro.ReturnOrderLineItems) {
                        Decimal QtyRec = roLineItem.QuantityReceived;
                        if( roLineItem.RepaymentMethod == 'Reship' ){
                            roLineItem.QuantityExpected 				= roLineItem.QuantityExpected - QtyRec;
                            roLineItem.Quantity_Previously_Received__c 	= roLineItem.Quantity_Previously_Received__c + QtyRec;
                            roLineItem.Quantity_Previously_Returned__c 	= roLineItem.Quantity_Previously_Returned__c + QtyRec;
                            roLineItem.QuantityReceived 				= 0;
                            ReturnOrderLineItemToUpdate.add(roLineItem);
                        }else{
                            roLineItem.Quantity_Previously_Received__c 	=  QtyRec;
                            roLineItem.Quantity_Previously_Returned__c 	=  QtyRec;
                            ReturnOrderLineItemToUpdate.add(roLineItem);
                        }
                    }
                }
            }


            if (ReturnOrderLineItemToUpdate.size() > 0) update ReturnOrderLineItemToUpdate;
        }
    }

    
    /**
     * @description updateReturnOrdersToReceived update return orders to received
     * @param  returnOrderToUpdateMap returnOrderToUpdateMap return orders to update
     */
    private static void updateReturnOrdersToReceived(Map<Id, ReturnOrderCreateUpdateRequest> returnOrderToUpdateMap){
        if (returnOrderToUpdateMap.size() > 0) {
            List<ReturnOrder> returnOrdersToUpdate = new List<ReturnOrder>();
            List<ReturnOrder> returnOrders = [SELECT Id, Status, (SELECT Id, QuantityExpected, QuantityReceived FROM ReturnOrderLineItems) FROM ReturnOrder WHERE Id=:returnOrderToUpdateMap.keySet()];
            for (ReturnOrder ro:returnOrders) {
                Boolean updateRO = true;
                for (ReturnOrderLineItem roLineItem:ro.ReturnOrderLineItems) {
                    if (roLineItem.QuantityExpected > roLineItem.QuantityReceived) {
                        updateRO = false;
                        break;
                    }
                }
                if (updateRO) {
                    ro.Status = SOM_Constants.RETURN_ORDER_STATUS_RECEIVED;
                    returnOrdersToUpdate.add(ro);
                }
            }

            if (returnOrdersToUpdate.size() > 0) update returnOrdersToUpdate;
        }
    }

    /**
     * @description createReturnOrderWithItems create return order and return order items using standard action
     * @param  orderSummaryShipmentsMap             orderSummaryShipmentsMap : already shipped items
     * @param  returnItems                          returnItems : return items request
     * @param  req                                  req : return request
     * @param  returnOrderItemConditionValues       returnOrderItemConditionValues : condition values
     * @param  returnOrderItemReasonForReturnValues returnOrderItemReasonForReturnValues : reason codes
     * @param  orderSummary                         orderSummary : order summary
     * @param  returnOrderToUpdateMap               returnOrderToUpdateMap  : return orders to update     
     * @param  returnOrderItemsToUpdateMap          returnOrderItemsToUpdateMap : return order items to update
     * @return                                      return error message
     */
    private static String createReturnOrderWithItems(Map<String, Map<String, OrderShipmentItem>> orderSummaryShipmentsMap,
                                            List<ReturnOrderItemCreateUpdate> returnItems,
                                            ReturnOrderCreateUpdateRequest req,
                                            List<String> returnOrderItemConditionValues,
                                            List<String> returnOrderItemReasonForReturnValues,
                                            OrderSummary orderSummary,
                                            Map<Id, ReturnOrderCreateUpdateRequest> returnOrderToUpdateMap,
                                            Map<Id, Map<String, returnOrderItemCreateUpdate>> returnOrderItemsToUpdateMap) {
        List<ConnectApi.ReturnOrderLineItemInputRepresentation> returnOrderLineItemsInputList = new List<ConnectApi.ReturnOrderLineItemInputRepresentation>();
        Map<String, returnOrderItemCreateUpdate> returnOrderItemsRequest = new Map<String, returnOrderItemCreateUpdate>();
        if (!orderSummaryShipmentsMap.containsKey(req.orderSummaryNumber)) 
            return 'No shipments found for this Order Summary.';
        //Iterate over return line items
        for(ReturnOrderItemCreateUpdate returnOrderItemCreateUpdate:returnItems) {
            OrderShipmentItem orderShipmentItem = orderSummaryShipmentsMap.get(req.orderSummaryNumber).get(returnOrderItemCreateUpdate.sku);
            //Check that the line items are shipped, Quantity and the serial number are valid.
            String errorMessage = verifyReturnLineItemIsValid(returnOrderItemCreateUpdate, 
                                                    orderShipmentItem, 
                                                    returnOrderItemConditionValues, 
                                                    returnOrderItemReasonForReturnValues);
            if (errorMessage != null) return errorMessage;
            if (returnOrderItemCreateUpdate.quantity > orderShipmentItem.quantityAvailableToReturn)
                return 'The return quantity: ' + returnOrderItemCreateUpdate.quantity + ' is greater than the quantity available to return: ' + orderShipmentItem.quantityAvailableToReturn;
            ConnectApi.ReturnOrderLineItemInputRepresentation returnOrderLineItemInput = new ConnectApi.ReturnOrderLineItemInputRepresentation();
            returnOrderLineItemInput.canReduceShipping  = false;
            returnOrderLineItemInput.orderItemSummaryId = orderShipmentItem.orderItemSummaryId;
            returnOrderLineItemInput.reasonForReturn    = returnOrderItemCreateUpdate.reasonCode == null || returnOrderItemCreateUpdate.reasonCode.length() == 0 ? SOM_Constants.RETURN_DEFAULT_REASON_CODE : returnOrderItemCreateUpdate.reasonCode;
            returnOrderLineItemInput.quantityExpected   = returnOrderItemCreateUpdate.quantity;
            if (req.type == SOM_Constants.WMS_RETURN_TYPE)
                returnOrderLineItemInput.quantityReceived = returnOrderItemCreateUpdate.quantity;
            
            //reduce quantity to return
            orderShipmentItem.quantityAvailableToReturn -= returnOrderItemCreateUpdate.quantity;
            orderSummaryShipmentsMap.get(req.orderSummaryNumber).put(returnOrderItemCreateUpdate.sku, orderShipmentItem);
            
            returnOrderLineItemsInputList.add(returnOrderLineItemInput);
        }

        /***start metrics****/
        Integer numberOfCallouts     = Limits.getCallouts();
        Integer numberOfDmlRows      = Limits.getDmlRows();
        Integer numberOfDmlStatments = Limits.getDmlStatements();
        Integer numberOfQueries      = Limits.getQueries();
        Integer numberOfQueryRows    = Limits.getQueryRows();
        ConnectApi.ReturnOrderInputRepresentation returnOrderInput = new ConnectApi.ReturnOrderInputRepresentation();
        returnOrderInput.orderSummaryId           = orderSummary.Id;
        returnOrderInput.returnOrderLifeCycleType = SOM_Constants.RETURN_ORDER_LIFE_CYCLE_TYPE;
        returnOrderInput.status                   = req.type == SOM_Constants.RMA_RETURN_TYPE ? SOM_Constants.RETURN_ORDER_STATUS_CREATED : SOM_Constants.RETURN_ORDER_STATUS_RECEIVED;
        returnOrderInput.returnOrderLineItems     = returnOrderLineItemsInputList;
        ConnectApi.ReturnOrderOutputRepresentation returnOrderOutput = ConnectApi.Returnorder.createReturnOrder(returnOrderInput);
        List<ReturnOrderLineItem> createdROLIs = [SELECT Id, reasonForReturn,QuantityExpected, Quantity_Previously_Received__c, Quantity_Previously_Returned__c, QuantityReceived, Product2.StockKeepingUnit, RepaymentMethod FROM ReturnOrderLineItem WHERE ReturnOrderId = :returnOrderOutput.returnOrderId];
        List<ReturnOrderLineItem> roliToUpdateFollowUp = new List<ReturnOrderLineItem>(); 
        for(ReturnOrderItemCreateUpdate reqItem : returnItems){
            for(Integer i=0; i<createdROLIs.size(); i++){
            	ReturnOrderLineItem singleROLI = createdROLIs.get(i);
                //if( singleROLI.Product2.StockKeepingUnit == reqItem.sku && singleROLI.reasonForReturn == reqItem.reasonCode ){
                    // Fill the Map : returnOrderItemsRequest
                    returnOrderItemsRequest.put(singleROLI.Id, reqItem);
                    if(req.type == SOM_Constants.RMA_RETURN_TYPE){ // If req.type = 1 => FollowUp = Refund
                        singleROLI.RepaymentMethod = SOM_Constants.RETURN_LINE_ITEM_FOLLOW_UP_REFUND;
                        roliToUpdateFollowUp.add(singleROLI);
                    }
                    createdROLIs.remove(i);
                    break;
                //}
            }
        }

        if( roliToUpdateFollowUp.size() > 0 ) update roliToUpdateFollowUp;

        /****end metrics****/
        returnOrderToUpdateMap.put(returnOrderOutput.returnOrderId, req);
        returnOrderItemsToUpdateMap.put(returnOrderOutput.returnOrderId, returnOrderItemsRequest);

        return null;
    }
    
    /**
     * @description Get SUM(QuantityExpected) of the return request
     * @param  returnItems                   returnItems : return items request
     * @return                               return Decimal : SUM of QuantityExpected
     */
    //private static Decimal GetSUMQuantityExpected(List<ConnectApi.ReturnOrderLineItemInputRepresentation> returnOrderLineItemsInputList){
    private static Decimal GetSUMQuantityExpected(List<ReturnOrderLineItem> ReturnOrderLineItemList){
        
        List<String> ReturnOrderLineItemListIds = new List<String>();
        Map<String,Decimal> ReturnOrderLineItemMap = new Map<String,Decimal>();
        Decimal SUMQuantityExpected = 0;
        if (ReturnOrderLineItemList.size() > 0) {
                for (ReturnOrderLineItem returnOrderLineItem:ReturnOrderLineItemList) {
                    ReturnOrderLineItemListIds.add(returnOrderLineItem.Id);
                    //orderItemSummaryIdsMap.put(returnOrderLineItem.orderItemSummaryId,returnOrderLineItem.quantityExpected);
                }
        }
        List<ReturnOrderLineItem> ReturnOrderLineItems = [Select Id,QuantityExpected From ReturnOrderLineItem where Id In :ReturnOrderLineItemListIds AND Product2.macrofunction_id__c IN : Getmacrofunction_id()];
        for (ReturnOrderLineItem returnOrderLineItem:ReturnOrderLineItems) {
            SUMQuantityExpected += returnOrderLineItem.QuantityExpected;
                }
        return SUMQuantityExpected;
    }
    
    /**
     * @description Get macrofunction_ids of the Product_Config__mdt
     * @return                               return List<Decimal>
     */
    private static List<Decimal> Getmacrofunction_id(){
        List<Decimal> ListToReturn = new List<Decimal>();
			List<Product_Config__mdt> listMet = [SELECT Macrofunction_id__c, Need_Package__c FROM Product_Config__mdt WHERE Need_Package__c = true ];
        	for (Product_Config__mdt Temp:listMet) {
                    ListToReturn.add(Temp.Macrofunction_id__c);
                }
        	Return ListToReturn;
    }
    
        

    /**
     * @description checkReturnOrderRequest check the validity of the return request
     * @param  req                           req : return request
     * @param  orderSum                      orderSum : order summary
     * @param  loc                           loc : location
     * @param  returnOrderReturnOriginValues returnOrderReturnOriginValues : return origin values
     * @return                               return error message
     */
    private static String checkReturnOrderRequest(ReturnOrderCreateUpdateRequest req, 
                                                OrderSummary orderSum, 
                                                Schema.Location loc,
                                                List<String> returnOrderReturnOriginValues){

        if (orderSum.SalesChannel.ExternalChannelNumber == SOM_Constants.SALES_CHANNEL_CEGID || orderSum.tech_os_store_shipping_method__c != 0)
            return 'This order does not allow return.';                                            
        if (req.items == null || req.items.isEmpty())
            return 'Return order items are empty.';
        if (orderSum == null)
            return 'We cannot find the orderSummary: '+req.orderSummaryNumber+' in SOM.';
        if (loc == null)
            return 'We cannot find the location: '+req.warehouseId+' in SOM.';
        if (req.type == null || (req.type != SOM_Constants.RMA_RETURN_TYPE && req.type != SOM_Constants.WMS_RETURN_TYPE))
            return 'Unknown type number: '+req.type;
        if (req.returnOrigin == null || !returnOrderReturnOriginValues.contains(req.returnOrigin))
            return 'Return Origin: '+req.returnOrigin+' is not valid.';
        
        List<String> concatenateSkuAndConditionIdList = new List<String>();
        for (ReturnOrderItemCreateUpdate returnOrderItemCreateUpdate:req.items) {
            String concatenateSkuAndConditionId = returnOrderItemCreateUpdate.sku+returnOrderItemCreateUpdate.ConditionId;
            if (concatenateSkuAndConditionIdList.contains(concatenateSkuAndConditionId))
                return 'Duplicate items with the same SKU code : '+returnOrderItemCreateUpdate.sku+' and ConditionId : '+returnOrderItemCreateUpdate.ConditionId+'.';
                concatenateSkuAndConditionIdList.add(concatenateSkuAndConditionId);
        } 

        return null;
    }

    /**
     * @description getLocationMap returns map of locations
     * @param  locations locations locations' name
     * @return           return map of locations
     */
    private static Map<String, Schema.Location> getLocationMap(List<String> locations){
        Map<String, Schema.Location> locationMap = new Map<String, Schema.Location>();
        if (locations.size() > 0) {
            List<Schema.Location> locationResult = [SELECT Id, Name FROM Location WHERE Name IN :locations];
            if (locationResult != null) {
                for (Schema.Location loc:locationResult) {
                    locationMap.put(loc.Name, loc);
                }
            }
        }

        return locationMap;
    }

    /**
     * @description getOrderSummaryMap returns map of orders
     * @param  orderNumbers orderNumbers : order numbers
     * @return              return map of orders
     */
    private static Map<String, OrderSummary> getOrderSummaryMap(List<String> orderNumbers){
        Map<String,OrderSummary> orderSummaryMap = new Map<String, OrderSummary>();
        if (orderNumbers.size() > 0) {
            List<OrderSummary> orderSummaryResult = [SELECT Id, AccountId, OrderNumber, SalesChannel.ExternalChannelNumber, tech_os_store_shipping_method__c FROM OrderSummary WHERE OrderNumber IN :orderNumbers];
            if (orderSummaryResult != null) {
                for (OrderSummary ordSummary:orderSummaryResult) {
                    orderSummaryMap.put(ordSummary.OrderNumber, ordSummary);
                }
            }
        }

        return orderSummaryMap;
    }

    /**
     * @description getOrderSummaryShipmentMap returns map of shipped items
     * @param  orderNumbers orderNumbers : order numbers
     * @return              return map of shipped items
     */
    private static Map<String, Map<String, OrderShipmentItem>> getOrderSummaryShipmentMap(List<String> orderNumbers){
        Map<String, Map<String, OrderShipmentItem>> orderSummaryShipmentsMap = new Map<String, Map<String, OrderShipmentItem>>();
        if (orderNumbers.size() > 0) {
            List<Shipment> shipments = [SELECT Id, OrderSummary.OrderNumber, (SELECT Id, OrderItemSummaryId, OrderItemSummary.QuantityAvailableToReturn, Product2.StockKeepingUnit, SerialNumber__c FROM ShipmentItems) FROM Shipment WHERE OrderSummary.OrderNumber IN :orderNumbers AND ReturnOrderId = NULL];
            if (shipments != null) {
                for (Shipment ship:shipments) {
                    if (!orderSummaryShipmentsMap.containsKey(ship.OrderSummary.OrderNumber))
                        orderSummaryShipmentsMap.put(ship.OrderSummary.OrderNumber, new Map<String, OrderShipmentItem>());
                    if (ship.ShipmentItems != null) {
                        for(ShipmentItem shipItem:ship.ShipmentItems) {
                            if (orderSummaryShipmentsMap.get(ship.OrderSummary.OrderNumber).containsKey(shipItem.Product2.StockKeepingUnit)) {
                                if (shipItem.SerialNumber__c != null && shipItem.SerialNumber__c.length() > 0) 
                                    orderSummaryShipmentsMap.get(ship.OrderSummary.OrderNumber).get(shipItem.Product2.StockKeepingUnit).serialNumbers.add(shipItem.SerialNumber__c);
                                continue;
                            }
                            OrderShipmentItem orderShipmentItem         = new OrderShipmentItem();
                            orderShipmentItem.orderItemSummaryId        = shipItem.OrderItemSummaryId;
                            orderShipmentItem.quantityAvailableToReturn = shipItem.OrderItemSummary.QuantityAvailableToReturn;
                            if (shipItem.SerialNumber__c != null && shipItem.SerialNumber__c.length() > 0) {
                                orderShipmentItem.serialNumbers.add(shipItem.SerialNumber__c);
                            }

                            orderSummaryShipmentsMap.get(ship.OrderSummary.OrderNumber).put(shipItem.Product2.StockKeepingUnit, orderShipmentItem);
                        }
                    }
                }
            }
        }

        return orderSummaryShipmentsMap;
    }

    /**
     * @description getOrderSummaryReturnsMap returns map of created returns
     * @param  orderSummaryNumbers orderSummaryNumbers : order numbers
     * @return                     return map created returns
     */
    private static Map<String, Map<String, List<ReturnOrderLineItem>>> getOrderSummaryReturnsMap(List<String> orderSummaryNumbers){
        Map<String, Map<String, List<ReturnOrderLineItem>>> orderSummaryReturnOrderLineItemsMap = new Map<String, Map<String, List<ReturnOrderLineItem>>>();
        if (orderSummaryNumbers.size() > 0) {
            List<ReturnOrder> returnOrders = [SELECT Id, ReturnOrderNumber, Status, OrderSummary.OrderNumber, ReturnDate__c, (SELECT Id, Product2.StockKeepingUnit, ReturnOrderId, QuantityExpected, QuantityReceived, ConditionId__c,SerialNumber__c  FROM ReturnOrderLineItems) FROM ReturnOrder WHERE OrderSummary.OrderNumber IN :orderSummaryNumbers AND Status = :SOM_Constants.RETURN_ORDER_STATUS_SUBMITTED];
            if (returnOrders != null) {
                for (ReturnOrder retOrder:returnOrders) {
                    if (!orderSummaryReturnOrderLineItemsMap.containsKey(retOrder.OrderSummary.OrderNumber)) {
                        orderSummaryReturnOrderLineItemsMap.put(retOrder.OrderSummary.OrderNumber, new Map<String, List<ReturnOrderLineItem>>());
                    }
                    if (retOrder.ReturnOrderLineItems != null) {
                        for (ReturnOrderLineItem retOrderLineItem:retOrder.ReturnOrderLineItems) {
                            if (orderSummaryReturnOrderLineItemsMap.get(retOrder.OrderSummary.OrderNumber).containsKey(retOrderLineItem.Product2.StockKeepingUnit)) {
                                orderSummaryReturnOrderLineItemsMap.get(retOrder.OrderSummary.OrderNumber).get(retOrderLineItem.Product2.StockKeepingUnit).add(retOrderLineItem);
                                continue;
                            }

                            orderSummaryReturnOrderLineItemsMap.get(retOrder.OrderSummary.OrderNumber).put(retOrderLineItem.Product2.StockKeepingUnit, new List<ReturnOrderLineItem>{retOrderLineItem});
                        }
                    }
                }
            }
        }

        return orderSummaryReturnOrderLineItemsMap;
    }

    /**
     * @description createReturnOrderCreateUpdateResponse create return response
     * @param  errorMsg          errorMsg : error message
     * @param  status            status   : OK / KO
     * @param  orderNumber       orderNumber 
     * @param  returnOrderId     returnOrderId 
     * @param  returnOrderNumber returnOrderNumber
     * @return                   return return response
     */
    private static ReturnOrderCreateUpdateResponse createReturnOrderCreateUpdateResponse(String errorMsg, String status, String orderNumber, Id returnOrderId, String returnOrderNumber,Decimal expectedPackages){
        ReturnOrderCreateUpdateResponse response = new ReturnOrderCreateUpdateResponse();
        response.errorMessage       = errorMsg;
        response.orderSummaryNumber = orderNumber;
        response.returnOrderId      = returnOrderId;
        response.returnOrderStatus  = status;
        response.returnOrderNumber  = returnOrderNumber;
        response.expectedPackages   = expectedPackages;

        return response;
    }

    /**
     * @description getPicklistValues get picklist values
     * @param  objectName objectName : object name
     * @param  fieldName  fieldName  : picklist api name
     * @return            return picklist values
     */
    private static List<String> getPicklistValues(String objectName, String fieldName){
        List<String> picklistValues = new List<String>();
        Schema.SObjectType sobjectType                     = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describeSobjectResult = sobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields         = describeSobjectResult.fields.getMap();
        List<Schema.PicklistEntry> pickListValuesList      = mapFields.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry pickEntry : pickListValuesList) {
            if (pickEntry.isActive()) picklistValues.add(pickEntry.getValue());
        }

        return picklistValues;
    }

    /**
     * @description verifyReturnLineItemIsValid verify validity of return line item
     * @param  returnOrderItemCreateUpdate          returnOrderItemCreateUpdate : return line item request
     * @param  orderShipmentItem                    orderShipmentItem           : shipped item
     * @param  returnOrderItemConditionValues       returnOrderItemConditionValues : condition values
     * @param  returnOrderItemReasonForReturnValues returnOrderItemReasonForReturnValues : reason codes
     * @return                                      return  error message
     */
    private static String verifyReturnLineItemIsValid(ReturnOrderItemCreateUpdate returnOrderItemCreateUpdate, 
                                                    OrderShipmentItem orderShipmentItem,
                                                    List<String> returnOrderItemConditionValues,
                                                    List<String> returnOrderItemReasonForReturnValues){

        if (returnOrderItemCreateUpdate.sku == null || returnOrderItemCreateUpdate.sku.length() ==0)
            return 'SKU code must not be empty.';
        if (returnOrderItemCreateUpdate.quantity == null || returnOrderItemCreateUpdate.quantity <=0)
            return 'Return Order Item quantity must be greater than 0.';
        if (returnOrderItemCreateUpdate.conditionId == null || !returnOrderItemConditionValues.contains(returnOrderItemCreateUpdate.conditionId?.toLowercase().capitalize()))
            return 'Return Order Item condition is not valid: ' + returnOrderItemCreateUpdate.conditionId;
		if (returnOrderItemCreateUpdate.sku10Digits != null && !String.isBlank(returnOrderItemCreateUpdate.sku10Digits) && returnOrderItemCreateUpdate.sku10Digits.length() != 10 )
            return 'The field sku10Digits contains more or less than 10 digits.';
        if (returnOrderItemCreateUpdate.reasonCode != null && !returnOrderItemReasonForReturnValues.contains(returnOrderItemCreateUpdate.reasonCode))
            return 'Return Order Item reason code: '+returnOrderItemCreateUpdate.reasonCode+' is not valid.';
        if (orderShipmentItem == null)
            return 'OrderItem: '+returnOrderItemCreateUpdate.sku+' is not shipped';
        //serialNumber sent in the request doesn't exist in the shipped products.
        if (returnOrderItemCreateUpdate.serialNumbers != null && !returnOrderItemCreateUpdate.serialNumbers.isEmpty()) {
            if (returnOrderItemCreateUpdate.serialNumbers.size() != returnOrderItemCreateUpdate.quantity){
                return 'Serial numbers does not match the quantity.';
            }
            for(String serialNumber:returnOrderItemCreateUpdate.serialNumbers) {
                if (!orderShipmentItem.serialNumbers.contains(serialNumber))
                    return 'We cannot find a serial number with the value: ' + serialNumber + ' Shipped.';
            }
        }

        return null;
    }

    global with sharing class ReturnOrderCreateUpdateRequest{
        public Integer                           type; //1: SFCC(Status is Create) -- 2: WMS (Status is Received)
        public String                            orderSummaryNumber;
        public String                            warehouseId;
        public String                            returnOrigin;
        public String                            returnDate;
        public List<ReturnOrderItemCreateUpdate> items;
    }

    global with sharing class ReturnOrderItemCreateUpdate {
        public String       sku;
        public Decimal      quantity;
        public String       conditionId;
        public List<String> serialNumbers;
        public String       reasonCode;
        public String       reasonFreeText; 
        public String 		sku10Digits;
    }

    global with sharing class ReturnOrderCreateUpdateResponse{
        public String   orderSummaryNumber;
        public Id       returnOrderId;
        public String   returnOrderStatus; //OK or KO
        public String   errorMessage;
        public String   returnOrderNumber;
        public Decimal   expectedPackages;
    }

    global with sharing class OrderShipmentItem{
        public Id           orderItemSummaryId;
        public String       sku;
        public List<String> serialNumbers;
        public Decimal      quantityAvailableToReturn;

        public OrderShipmentItem(){
            this.serialNumbers             = new List<String>();
            this.quantityAvailableToReturn = 0;
        }
    }
}
