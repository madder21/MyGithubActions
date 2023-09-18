/**************************************************************************************

-- - Author        : Bader Eddine Elkhal

-- - Description   : An endpoint that create shipments and shipment items received from WMS

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 16-03-2022    BEE    1.0          Initial version

***************************************************************************************/
@RestResource(urlMapping='/shipments/insertShipments/*')
global with sharing class SOM_WS_ShipmentHandler {

    public static final Integer STATUS_CODE_403       = 403;
    public static final Integer STATUS_CODE_200       = 200;
    public static final String STATUS_OK              = 'OK';
    public static final String STATUS_ERROR           = 'ERROR';
    public static final String  SHIPMENT_ITEM_TRIGGER = 'ShipmentItemTrigger';

    /**
     * @description createShipments create shipments, shipment item, 
     *                              call SOM_ClosingFulfillmentOrderAction to close FO and generate shipments
     *                              transactional emails
     */
    @HttpPost
    global static Void createShipments() {
        RestRequest request   = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type', 'application/json');
        String RequestBody = request.requestBody.toString() != null ? request.requestBody.toString() : null;
        Map<Id, WMS_OutPutFulfillment> outPutResponseByFOId  = new Map<Id, WMS_OutPutFulfillment>();
        
        Savepoint sp = Database.setSavepoint();
        try {
            List<ShipmentDataRquest> shipmentDataRquestInputs = (List<ShipmentDataRquest>) json.deserialize(RequestBody, List<ShipmentDataRquest>.class);
            if (shipmentDataRquestInputs.isEmpty()) {
                response.statusCode   = STATUS_CODE_403;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                    'Response' => 'Shipment records are empty.'
                }));
                return;
            }

            Map<String, List<WMS_ShipmentData>> listShipmentsDataWithFoNumber = getShipmentDataByFulfillmentOrderMap(shipmentDataRquestInputs);
            //Get Fulfillment Orders
            List<FulfillmentOrder>  fulfillmentOrders = [SELECT Id, FulfillmentOrderNumber, AccountId, DeliveryMethodId, FulfilledFromLocationId, 
                FulfilledToName, FulfilledToStreet, FulfilledToCity, FulfilledToState, FulfilledToPostalCode, 
                FulfilledToCountry, FulfilledToLatitude, FulfilledToLongitude, FulfilledToGeocodeAccuracy, 
                FulfilledToAddress, FulfilledToEmailAddress, FulfilledToPhone, ItemCount, Status, StatusCategory, 
                Type, TypeCategory , OrderSummaryId, OrderSummary.Status, OrderSummary.On_Hold__c, DeliveryMethod.Carrier, DeliveryMethod.ReferenceNumber,
                (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, OrderItemId, Product2.StockKeepingUnit, OrderItemSummaryId, Description, Quantity, 
                Type, TypeCode, UnitPrice, ServiceDate, EndDate, Product2Id, OrderItemSummary.isSerialized__c
                FROM FulfillmentOrderLineItems WHERE Quantity > 0 AND Type != :SOM_Constants.FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE) FROM FulfillmentOrder
                WHERE FulfillmentOrderNumber IN :listShipmentsDataWithFoNumber.keySet()];
            
            Map<Id, FulfillmentOrder> listFulfillementOrderById                      = new Map<Id, FulfillmentOrder>();
            Set<Id> locationIds                                                      = new Set<Id>();
            Set<Id> setFoliToGetQuantity                                             = new Set<Id>();
            Map<Id, Map<String, List<FulfillmentOrderLineItem>>> folisBySkuByFoId    = new Map<Id, Map<String, List<FulfillmentOrderLineItem>>>();
            List<WMS_ShipmentData> listWmsShimpentDataToProcess                      = new List<WMS_ShipmentData>();
            if(!fulfillmentOrders?.isEmpty()){
                for(FulfillmentOrder fo  : fulfillmentOrders){
                    listFulfillementOrderById.put(fo.Id, fo);
                    locationIds.add(fo.FulfilledFromLocationId);
                    for(FulfillmentOrderLineItem foliLine : fo.FulfillmentOrderLineItems){
                        setFoliToGetQuantity.add(foliLine.Id);
                        if(folisBySkuByFoId.containsKey(foliLine.FulfillmentOrderId)){
                            if(folisBySkuByFoId.get(foliLine.FulfillmentOrderId).containsKey(foliLine.Product2.StockKeepingUnit)){
                                folisBySkuByFoId.get(foliLine.FulfillmentOrderId).get(foliLine.Product2.StockKeepingUnit).add(foliLine);
                            }else{
                                folisBySkuByFoId.get(foliLine.FulfillmentOrderId).put(foliLine.Product2.StockKeepingUnit, new List<FulfillmentOrderLineItem>{foliLine});
                            }
                        } else{
                            folisBySkuByFoId.put(foliLine.FulfillmentOrderId, new Map<String, List<FulfillmentOrderLineItem>>{
                                foliLine.Product2.StockKeepingUnit => new List<FulfillmentOrderLineItem>{foliLine}
                            });
                        }   
                        
                    }
                }
            }
            
            //Get Visitor Adresses by location from FO
            Map<Id, Schema.Location> listLocationById = new Map <Id, Schema.Location>([SELECT Id, LocationType, VisitorAddressId, VisitorAddress.Name, VisitorAddress.Street,
                    VisitorAddress.City, VisitorAddress.State, VisitorAddress.PostalCode, VisitorAddress.Country
                    FROM Location WHERE Id IN : locationIds]);
            Map<String, Id> foIdByExternalShipmentId        = new Map<String, Id>();
            Map<String, Shipment> shipmentsByWmsExternalId  = new Map<String, Shipment>();
            //Iterate over retrieved fulfillment orders         
            for(FulfillmentOrder flmntOrder : listFulfillementOrderById.values()){
                String errorMsg = checkFulfillmentOrder(flmntOrder);
                if (errorMsg != null) {
                    outPutResponseByFOId.put(flmntOrder.Id, createWMSOutputFulfillmentResponse(STATUS_ERROR, errorMsg, flmntOrder.Id, null, null));
                    continue;
                }
                if(!listShipmentsDataWithFoNumber.get(flmntOrder.FulfillmentOrderNumber)?.isEmpty()){
                    //Iterate over shipment requests of FO
                    for(WMS_ShipmentData shipmentDataLine : listShipmentsDataWithFoNumber.get(flmntOrder.FulfillmentOrderNumber)){
                        if (shipmentDataLine.articles?.isEmpty() || shipmentsByWmsExternalId.containsKey(shipmentDataLine.WMSshipmentId)) {
                            outPutResponseByFOId.put(flmntOrder.Id, createWMSOutputFulfillmentResponse(STATUS_ERROR, shipmentDataLine.articles?.isEmpty() ? 'Shipment should contain at least one article to ship' : 'Duplicated value '+ shipmentDataLine.WMSshipmentId +' of WMSshipmentId', flmntOrder.Id, null, null));
                            break;
                        }
                        Shipment shipment = createShipmentRecord(flmntOrder, shipmentDataLine, listLocationById);
                        listWmsShimpentDataToProcess.add(shipmentDataLine);
                        foIdByExternalShipmentId.put(shipmentDataLine.WMSshipmentId, flmntOrder.Id);
                        shipmentsByWmsExternalId.put(shipmentDataLine.WMSshipmentId, shipment);
                    }
                }
            }

            Map<String, List<ShipmentItem>> listShipItemToInsertByWmsExtrId     = new Map<String, List<ShipmentItem>>();
            Map<String, Shipment> shipmentToInsertBySpExternalId                = new Map<String, Shipment>();
            Map<Id, Integer> totalExistingShipmentItemsByFoliId             = getShippedQuantityByFOLI(setFoliToGetQuantity);
            Map<Id, Map<String,Integer>> totalExistingShippedQuantityBySkuByFO  = getShippedQuantityBySkuByFO(setFoliToGetQuantity);
            Set<Id> fulfillmentOrdersToRemoveFromCreationProcessSet             = new Set<Id>();
            //Loop over wmsShipmentData
            for(WMS_ShipmentData wmsShipmentLine : listWmsShimpentDataToProcess){
                //Loop Over Articles
                for(WMS_Article wmsArticle : wmsShipmentLine.articles){
                    List<fulfillmentOrderLineItem> foliLines = folisBySkuByFoId.get(foIdByExternalShipmentId.get(wmsShipmentLine.WMSshipmentId))?.get(wmsArticle.productSKU);
                    String errorMessage = verifyShipmentLineItem(
                                            totalExistingShippedQuantityBySkuByFO.get(foIdByExternalShipmentId.get(wmsShipmentLine.WMSshipmentId)), 
                                            foliLines, 
                                            wmsArticle, 
                                            wmsShipmentLine
                                        );
                    if (errorMessage != null) {
                        outPutResponseByFOId.put(foIdByExternalShipmentId.get(wmsShipmentLine.WMSshipmentId), createWMSOutputFulfillmentResponse(STATUS_ERROR, errorMessage, foIdByExternalShipmentId.get(wmsShipmentLine.WMSshipmentId), null, null));
                        fulfillmentOrdersToRemoveFromCreationProcessSet.add(foIdByExternalShipmentId.get(wmsShipmentLine.WMSshipmentId));
                        break;
                    }
                    if(wmsArticle.serialNumber != null){
                        //Loop over serial Numbers
                        for(String serialNumber : wmsArticle.serialNumber){
                            createShipmentItemAndPopulateMap(wmsShipmentLine, foliLines, totalExistingShipmentItemsByFoliId ,Integer.valueOf(wmsArticle.qty/wmsArticle.serialNumber.size()), serialNumber, listShipItemToInsertByWmsExtrId);         
                        }
                        continue;                                  
                    }
                    createShipmentItemAndPopulateMap(wmsShipmentLine, foliLines, totalExistingShipmentItemsByFoliId ,wmsArticle.qty, null, listShipItemToInsertByWmsExtrId); 
                }
                //populate shipments to insert
                shipmentToInsertBySpExternalId.put(wmsShipmentLine.WMSshipmentId, shipmentsByWmsExternalId.get(wmsShipmentLine.WMSshipmentId));
            }       
            removeFulfillmentOrdersWithError(fulfillmentOrdersToRemoveFromCreationProcessSet, listFulfillementOrderById, listShipmentsDataWithFoNumber, listShipItemToInsertByWmsExtrId, shipmentToInsertBySpExternalId);
            Set<Id> foIdsToUpdate = new Set<Id>();
            if(!listShipItemToInsertByWmsExtrId.values().isEmpty() && !shipmentToInsertBySpExternalId.values().isEmpty()){
                //insert shipments
                insert shipmentToInsertBySpExternalId.values();
                List<ShipmentItem> listShipmentItemToInsert = new List<ShipmentItem>();
                for(Shipment shipment : shipmentToInsertBySpExternalId.values()){
                    if(listShipItemToInsertByWmsExtrId.containsKey(shipment.WMSShipmentId__c) && !listShipItemToInsertByWmsExtrId.get(shipment.WMSShipmentId__c)?.isEmpty()){
                        WMS_OutPutshipmentData shipmentOutPut = new WMS_OutPutshipmentData();
                        for(ShipmentItem shipmentLine : listShipItemToInsertByWmsExtrId.get(shipment.WMSShipmentId__c)){
                            shipmentLine.shipmentId = shipment.Id;
                            listShipmentItemToInsert.add(shipmentLine);
                        }
                        shipmentOutPut.shipmentExternalId = shipment.WMSShipmentId__c;
                        shipmentOutPut.shipmentId = shipment.Id;
                        foIdsToUpdate.add(foIdByExternalShipmentId.get(shipment.WMSShipmentId__c));
                    }
                }
                if(!listShipmentItemToInsert.isEmpty()) insert listShipmentItemToInsert;
            }

            if(foIdsToUpdate.isEmpty()){
                Database.rollback(sp);
                response.statusCode   = STATUS_CODE_403;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                    'Response' => outPutResponseByFOId.values()
                
                }));
                return;
            }

            List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> params = new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs>();
            SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs param = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
            List<Id> fulIds = new List<Id>();
            param.foIds = new List<Id>();
            param.foIds.addAll(foIdsToUpdate);
            param.doUpdateOSStatus = true;
            params.add(param);
            List<SOM_CloseFulfillmentOrderResponseWr> listFoIdResponse = SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(params);  
            string errorMsg = checkClosingFulfillmentOrderResponse(listFoIdResponse, foIdsToUpdate);
            if (errorMsg != null) {
                Database.rollback(sp);
                response.statusCode   = STATUS_CODE_403;
                response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                    'Response' => errorMsg
                
                }));
                return;
            }

            //Call transactional email handler to create shipment email records
            List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> transactionalEmails = populateShipmentTransactionalEmailAndOutputResponse(shipmentToInsertBySpExternalId, 
                            listFoIdResponse, 
                            foIdByExternalShipmentId, 
                            listFulfillementOrderById, 
                            outPutResponseByFOId);
            SOM_TransactionalEmailHandler.generateTransactionalEmail(transactionalEmails);
            
            response.statusCode   = STATUS_CODE_200;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                'Response' => outPutResponseByFOId.values()
            }));
        } catch(Exception ex){
            Database.rollback(sp);
            List<WMS_OutPutFulfillment> foOutPutResponseData = new List<WMS_OutPutFulfillment>();
            response.statusCode = STATUS_CODE_403;
            response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
                'Response' => outPutResponseByFOId.values(),
                'Error'    => getErrorMessageForResponse(ex.getMessage())
            }));
        }
    }

    /**
     * @description checkFulfillmentOrder check FO
     * @param  fulfillmentOrder fulfillmentOrder Fulfillment Order to check
     * @return                  return error message
     */
    private static String checkFulfillmentOrder(FulfillmentOrder fulfillmentOrder){
        if (fulfillmentOrder.OrderSummary.Status == SOM_Constants.ORDER_SUMMARY_CANCELED) 
            return 'You cannot create shipments for this Order because It is canceled';
        if (fulfillmentOrder.OrderSummary.On_Hold__c)
            return 'You cannot create shipments for this Order because It is on hold';
        if(fulfillmentOrder.Status == SOM_Constants.FULFILLMENT_ORDER_FULFILLED)
            return 'The Fulfillment Order is already Fulfilled';
        if(fulfillmentOrder.Status != SOM_Constants.FULFILLMENT_ORDER_ALLOCATED && 
            fulfillmentOrder.Status != SOM_Constants.FULFILLMENT_ORDER_FULFILLING && 
            fulfillmentOrder.Status != SOM_Constants.FULFILLMENT_ORDER_PARTIALLY_FULFILLED)
            return 'The Fulfillment Order status is invalid, expected status: Fulfilling or Partially Fulfilled';
          
        return null;
    }

    /**
     * @description populateShipmentTransactionalEmailAndOutputResponse Create response by FO and generate shipment transactional emails
     * @param  shipmentToInsertBySpExternalId shipmentToInsertBySpExternalId : shipment by external Id
     * @param  listFoIdResponse               listFoIdResponse          : response of closing FO call
     * @param  foIdByExternalShipmentId       foIdByExternalShipmentId  : Fulfillment Orders by External shipment Id
     * @param  listFulfillementOrderById      listFulfillementOrderById : Fulfillment Orders by Id
     * @param  outPutResponseByFOId           outPutResponseByFOId      : response by FO Id
     * @return                                return Shipment transacational emails
     */
    private static List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> populateShipmentTransactionalEmailAndOutputResponse(Map<String, Shipment> shipmentToInsertBySpExternalId,
                            List<SOM_CloseFulfillmentOrderResponseWr> listFoIdResponse,
                            Map<String, Id> foIdByExternalShipmentId,
                            Map<Id, FulfillmentOrder> listFulfillementOrderById,
                            Map<Id, WMS_OutPutFulfillment> outPutResponseByFOId){
        List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> generateTransactionalEmailInputsList = new List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput>();
        for(Shipment shipment : shipmentToInsertBySpExternalId.values()){
            if(!listFoIdResponse.get(0).foIds.contains(shipment.FulfillmentOrderId)) continue;
            //Create Transactional Email Input
            SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput generateTransactionalEmailInput = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
            generateTransactionalEmailInput.templateName = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION;
            generateTransactionalEmailInput.recordId     = shipment.Id;
            generateTransactionalEmailInputsList.add(generateTransactionalEmailInput);

            WMS_OutPutshipmentData shipmentOutPut = new WMS_OutPutshipmentData();
            shipmentOutPut.shipmentExternalId     = shipment.WMSShipmentId__c;
            shipmentOutPut.shipmentId             = shipment.Id;
            //Prepare Out Put Data 
            if(outPutResponseByFOId.containsKey(foIdByExternalShipmentId.get(shipment.WMSShipmentId__c))){
                outPutResponseByFOId.get(foIdByExternalShipmentId.get(shipment.WMSShipmentId__c))?.shipments.add(shipmentOutPut);
                continue;
            }

            FulfillmentOrder fullOrder = listFulfillementOrderById.get(foIdByExternalShipmentId.get(shipment.WMSShipmentId__c));
            outPutResponseByFOId.put(foIdByExternalShipmentId.get(shipment.WMSShipmentId__c), 
                            createWMSOutputFulfillmentResponse(STATUS_OK, null, 
                            foIdByExternalShipmentId.get(shipment.WMSShipmentId__c), 
                            fullOrder != null ? fullOrder.FulfillmentOrderNumber : null,
                            new List<WMS_OutPutshipmentData>{shipmentOutPut}));
        }

        return generateTransactionalEmailInputsList;
    }
    
    /**
     * @description getErrorMessageForResponse error message to return in the catch bloc
     * @param  exMsg exMsg  : exception message
     * @return       return : error message
     */
    private static String getErrorMessageForResponse(String exMsg){
        if(exMsg.contains(SHIPMENT_ITEM_TRIGGER))
            return 'Cannot Create Shipments : Error while Updating Fulfillment Orders Status contact your SOM Admin for Additional Details';
        
        return 'Cannot Create Shipments : Error While Processing request please verify your data';
    }

    /**
     * @description checkClosingFulfillmentOrderResponse checking closing FO response
     * @param  listFoIdResponse listFoIdResponse : Closing FO response
     * @param  foIdsToUpdate    foIdsToUpdate    : Fulfillment Order Ids
     * @return                  return           : error message
     */
    private static String checkClosingFulfillmentOrderResponse(List<SOM_CloseFulfillmentOrderResponseWr> listFoIdResponse, Set<Id> foIdsToUpdate){
        if (listFoIdResponse ==null || listFoIdResponse.isEmpty()) return 'Internal error while updating Order Summary status. Please contact your Salesforce Admin.';
        if (!listFoIdResponse.get(0).isSuccess) return 'Error while updating orderSummaries status '+ listFoIdResponse.get(0).errorMessage;
        if (new Set<Id>(listFoIdResponse.get(0).foIds).size() != foIdsToUpdate.size()) return 'Error while updating Order Summary status. Please contact your salesforce Admin for more details.';
        
        return null;
    }

    /**
     * @description verifyShipmentLineItem Verify Shipment line before insert
     * @param  totalExistingShippedQuantityBySku  totalExistingShippedQuantityBySku Quantity already shipped by SKU
     * @param  foLineItems                        foLineItem      : Fulfillment Order Line Items
     * @param  wmsArticle                         wmsArticle      : WMS shipment line
     * @param  wmsShipmentLine                    wmsShipmentLine : WMS shipment request
     * @return                                    return          : error message
     */
    private static String verifyShipmentLineItem(Map<String,Integer> totalExistingShippedQuantityBySku, 
                                        List<FulfillmentOrderLineItem> foLineItems,
                                        WMS_Article wmsArticle,
                                        WMS_ShipmentData wmsShipmentLine){
        if (foLineItems == null || foLineItems.isEmpty()) return 'Error on shipment with WMSshipmentId : ' + wmsShipmentLine.WMSshipmentId + ' No product exist target SKU ' + wmsArticle.productSKU;
        if (foLineItems[0].OrderItemSummary.isSerialized__c && (wmsArticle.serialNumber == null || wmsArticle.serialNumber.isEmpty())) return 'Error on shipment with WMSshipmentId : ' + wmsShipmentLine.WMSshipmentId + 'Missing serialNumbers for serialized product with this SKU ' + wmsArticle.productSKU; 
        if (!foLineItems[0].OrderItemSummary.isSerialized__c && wmsArticle.serialNumber != null) return 'Error on shipment with WMSshipmentId : ' + wmsShipmentLine.WMSshipmentId + 'No serialNumber should provided for a non serialized product with this SKU ' + wmsArticle.productSKU;
        Integer totalExistingShipmentItems = (
                                                totalExistingShippedQuantityBySku != null
                                                && totalExistingShippedQuantityBySku.containsKey(wmsArticle.productSKU) 
                                            )
                                            ? totalExistingShippedQuantityBySku.get(wmsArticle.productSKU) + wmsArticle.qty 
                                            : wmsArticle.qty;
        Integer orderedQuantity = 0;
        for(FulfillmentOrderLineItem foli: foLineItems){
            orderedQuantity = orderedQuantity + Integer.valueOf(foli.Quantity);
        }
        if (orderedQuantity < totalExistingShipmentItems) return 'Error on shipment with WMSshipmentId : ' + wmsShipmentLine.WMSshipmentId + ' we cannot create shipment Items more than quantity ordered';
        if (wmsArticle.serialNumber !=null && wmsArticle.serialNumber?.size() != wmsArticle.qty) return 'The shipment with WMSshipmentId :' + wmsShipmentLine.WMSshipmentId + ' have a number of articles not equals with serial Numbers';
        
        return null;
    }

    /**
     * @description getShippedQuantityByFOLI Calculate already shipped quantity
     * @param  foLineItemsIds foLineItemsIds : Fulfillment Order Line Item Ids
     * @return                return         : Already shipped quantity by Fulfillment Order Line Item Id
     */
    private static Map<Id, Integer> getShippedQuantityByFOLI(Set<Id> foLineItemsIds){
        Map<Id, Integer> totalExistingShipmentItemsByFoliId = new Map<Id, Integer>();
        for(AggregateResult resultFoli : [SELECT  FulfillmentOrderLineItemId FoliId , SUM(Quantity) Quantity  
                                                FROM ShipmentItem 
                                                WHERE FulfillmentOrderLineItemId IN : foLineItemsIds 
                                                GROUP BY FulfillmentOrderLineItemId]){
            totalExistingShipmentItemsByFoliId.put((Id) resultFoli.get('FoliId'), Integer.valueOf((Decimal) resultFoli.get('Quantity')));
        }

        return totalExistingShipmentItemsByFoliId;
    }

    /**
     * @description getShippedQuantityBySkuByFO Calculate already shipped quantity
     * @param  foLineItemsIds foLineItemsIds : Fulfillment Order Line Item Ids
     * @return                return         : Already shipped quantity by SKU by Fulfillment Order Id
     */
    private static Map<Id, Map<String,Integer>> getShippedQuantityBySkuByFO(Set<Id> foLineItemsIds){
        Map<Id, Map<String,Integer>> totalExistingShippedQuantityBySkuByFO = new Map<Id, Map<String,Integer>>();
        for(ShipmentItem shipmentItem : [SELECT     FulfillmentOrderLineItemId , 
                                                    FulfillmentOrderLineItem.Product2.StockKeepingUnit ,
                                                    FulfillmentOrderLineItem.FulfillmentOrderId , 
                                                    Quantity  
                                            FROM ShipmentItem 
                                            WHERE FulfillmentOrderLineItemId IN : foLineItemsIds]){
            if(totalExistingShippedQuantityBySkuByFO.containsKey(shipmentItem.FulfillmentOrderLineItem.FulfillmentOrderId)){
                if(
                    totalExistingShippedQuantityBySkuByFO
                    .get(shipmentItem.FulfillmentOrderLineItem.FulfillmentOrderId)
                    .containsKey(shipmentItem.FulfillmentOrderLineItem.Product2.StockKeepingUnit)){
                        totalExistingShippedQuantityBySkuByFO
                            .get(shipmentItem.FulfillmentOrderLineItem.FulfillmentOrderId)
                            .put(
                                shipmentItem.FulfillmentOrderLineItem.Product2.StockKeepingUnit,
                                Integer.valueOf(
                                    totalExistingShippedQuantityBySkuByFO
                                        .get(shipmentItem.FulfillmentOrderLineItem.FulfillmentOrderId)
                                        .get(shipmentItem.FulfillmentOrderLineItem.Product2.StockKeepingUnit) + shipmentItem.Quantity)
                                );
                }else{
                    totalExistingShippedQuantityBySkuByFO
                        .get(shipmentItem.FulfillmentOrderLineItem.FulfillmentOrderId)
                        .put(
                            shipmentItem.FulfillmentOrderLineItem.Product2.StockKeepingUnit,
                            Integer.valueOf(shipmentItem.Quantity)
                            );
                }
                
            }else{
                totalExistingShippedQuantityBySkuByFO.put(
                    shipmentItem.FulfillmentOrderLineItem.FulfillmentOrderId,
                    new Map<String, Integer> {
                        shipmentItem.FulfillmentOrderLineItem.Product2.StockKeepingUnit => Integer.valueOf(shipmentItem.Quantity)
                    }
                );

            }
        }

        return totalExistingShippedQuantityBySkuByFO;
    }

    /**
     * @description createShipmentRecord Create Shipment
     * @param  flmntOrder       flmntOrder       : Fulfillment Order
     * @param  shipmentDataLine shipmentDataLine : WMS Shipment Data request
     * @param  listLocationById listLocationById : Locations by Id
     * @return                  return           : Created Shipment
     */
    private static Shipment createShipmentRecord(FulfillmentOrder flmntOrder, 
                                        WMS_ShipmentData shipmentDataLine,
                                        Map<Id, Schema.Location> listLocationById) {
        //Create shiipment object
        Shipment shipment           = new Shipment();
        shipment.DeliveryMethodId   = flmntOrder.DeliveryMethodId;
        shipment.FulfillmentOrderId = flmntOrder.Id;
        shipment.OrderSummaryId     = flmntOrder.OrderSummaryId;
        shipment.ShipToName         = flmntOrder.FulfilledToName;
        shipment.SourceLocationId   = flmntOrder.FulfilledFromLocationId;
        shipment.DispatchDate__c    = shipmentDataLine.dispatchDate;
        shipment.WMSShipmentId__c   = shipmentDataLine.WMSshipmentId;
        shipment.TrackingNumber     = shipmentDataLine.trackingNumber;
        shipment.Carrier__c         = shipmentDataLine.carrier != null ? shipmentDataLine.carrier : flmntOrder.DeliveryMethod.Carrier;
        shipment.ShippingService__c = shipmentDataLine.shippingService != null ? shipmentDataLine.shippingService : flmntOrder.DeliveryMethod.ReferenceNumber;
        shipment.Status             = SOM_Constants.SHIPMENT_SHIPPED;
        if(listLocationById.containsKey(flmntOrder.FulfilledFromLocationId)){
            shipment.ShipFromCity       = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.City;
            shipment.ShipFromStreet     = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.Street;
            shipment.ShipFromPostalCode = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.PostalCode;
            shipment.ShipFromState      = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.State;
            shipment.ShipFromCountry    = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.Country;
        }
        if(flmntOrder.type.equalsIgnoreCase(SOM_Constants.FULFILLMENT_ORDER_FULFILLED_IN_STORE_PICKUP)){
            shipment.ShipToCity       = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.City;
            shipment.ShipToStreet     = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.Street;
            shipment.ShipToPostalCode = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.PostalCode;
            shipment.ShipToState      = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.State;
            shipment.ShipToCountry    = listLocationById.get(flmntOrder.FulfilledFromLocationId)?.VisitorAddress.Country;
        } else if(flmntOrder.type.equalsIgnoreCase(SOM_Constants.WAREHOUSE)){
            shipment.ShipToCity       = flmntOrder.FulfilledToCity;
            shipment.ShipToStreet     = flmntOrder.FulfilledToStreet;
            shipment.ShipToPostalCode = flmntOrder.FulfilledToPostalCode;
            shipment.ShipToState      = flmntOrder.FulfilledToState;
            shipment.ShipToCountry    = flmntOrder.FulfilledToCountry;
        }

        return shipment;
    }

    /**
     * @description removeFulfillmentOrdersWithError remove fulfillment orders that have error in shipment data
     * @param  fulfillmentOrdersToRemoveFromCreationProcessSet fulfillmentOrdersToRemoveFromCreationProcessSet : FO Ids to Remove
     * @param  listFulfillementOrderById                       listFulfillementOrderById       : FO by Id
     * @param  listShipmentsDataWithFoNumber                   listShipmentsDataWithFoNumber   : wms shipment data by FO number
     * @param  listShipItemToInsertByWmsExtrId                 listShipItemToInsertByWmsExtrId : shipment items to insert
     * @param  shipmentToInsertBySpExternalId                  shipmentToInsertBySpExternalId  : shipments to insert
     */
    private static void removeFulfillmentOrdersWithError(Set<Id> fulfillmentOrdersToRemoveFromCreationProcessSet,
                                                        Map<Id, FulfillmentOrder> listFulfillementOrderById,
                                                        Map<String, List<WMS_ShipmentData>> listShipmentsDataWithFoNumber,
                                                        Map<String, List<ShipmentItem>> listShipItemToInsertByWmsExtrId,
                                                        Map<String, Shipment> shipmentToInsertBySpExternalId){
        for (Id foId:fulfillmentOrdersToRemoveFromCreationProcessSet) {
            FulfillmentOrder fulfillmentOrder = listFulfillementOrderById.get(foId);
            if (fulfillmentOrder != null) {
                for(WMS_ShipmentData wmsShipment : listShipmentsDataWithFoNumber.get(fulfillmentOrder.FulfillmentOrderNumber)){
                    shipmentToInsertBySpExternalId.remove(wmsShipment.WMSshipmentId);
                    listShipItemToInsertByWmsExtrId.remove(wmsShipment.WMSshipmentId);
                }
            } 
        }
    }

    /**
     * @description createShipmentItemAndPopulateMap Create shipment items and populate listShipItemToInsertByWmsExtrId map
     * @param  wmsShipmentLine                      wmsShipmentLine                     : WMS Shipment Line request
     * @param  foliLine                             foliLine                            : Fulfillment Order Line Item
     * @param  totalExistingShipmentItemsByFoliId   totalExistingShipmentItemsByFoliId  :total shipped qties By FoliId
     * @param  quantity                             quantity                            : quantity shipped
     * @param  serialNumber                         serialNumber                        : serial number attached to the shipped item
     * @param  listShipItemToInsertByWmsExtrId      listShipItemToInsertByWmsExtrId     : shipment items by WMS shipment id
     */
    private static void createShipmentItemAndPopulateMap(WMS_ShipmentData wmsShipmentLine, 
                                                List<FulfillmentOrderLineItem> foliLines,
                                                Map<Id, Integer> totalExistingShipmentItemsByFoliId, 
                                                Integer quantity, 
                                                String serialNumber,
                                                Map<String, List<ShipmentItem>> listShipItemToInsertByWmsExtrId){
        Integer quantityToProcess = quantity;
        List<ShipmentItem> shipmentLines = new List<ShipmentItem>();
        for(FulfillmentOrderLineItem foliLine: foliLines){
            if(quantityToProcess > 0){
                Integer totalExistingShipmentQty = (
                                                totalExistingShipmentItemsByFoliId != null
                                                && totalExistingShipmentItemsByFoliId.containskey(foliLine.Id)
                                                )
                                                ?totalExistingShipmentItemsByFoliId.get(foliLine.Id)
                                                :0;
                Integer shipmentLineQty = (quantityToProcess > Integer.valueOf(foliLine.quantity - totalExistingShipmentQty) )
                                            ? Integer.valueOf(foliLine.quantity - totalExistingShipmentQty)
                                            :quantityToProcess;
                if(shipmentLineQty > 0){
                    shipmentLines.add(createShipmentItemRecord(foliLine, shipmentLineQty, serialNumber));
                    quantityToProcess = quantityToProcess - shipmentLineQty;
                    if(totalExistingShipmentItemsByFoliId.containskey(foliLine.Id)){
                        totalExistingShipmentItemsByFoliId.put(
                            foliLine.Id,
                            totalExistingShipmentItemsByFoliId.get(foliLine.Id)+ shipmentLineQty
                        );
                    }else{
                        totalExistingShipmentItemsByFoliId.put(
                            foliLine.Id,
                            shipmentLineQty
                        );
                    }
                }
            }else{
                break;
            }
        }
        if(listShipItemToInsertByWmsExtrId.containsKey(wmsShipmentLine.WMSshipmentId)){
            listShipItemToInsertByWmsExtrId.get(wmsShipmentLine.WMSshipmentId).addAll(shipmentLines);
        } else{
            listShipItemToInsertByWmsExtrId.put(wmsShipmentLine.WMSshipmentId, shipmentLines);
        } 
    }

    /**
     * @description createShipmentItemRecord Creates Shipment Item
     * @param  foliLine     foliLine         : Fulfillment Order Line Item
     * @param  quantity     quantity         : quantity shipped
     * @param  serialNumber serialNumber     : serial number attached to shipment item
     * @return              return           : shipment item
     */
    private static ShipmentItem createShipmentItemRecord(FulfillmentOrderLineItem foliLine, Integer quantity, String serialNumber){
        ShipmentItem shipmentLine               = new ShipmentItem();
        shipmentLine.Product2Id                 = foliLine.Product2Id;
        shipmentLine.Quantity                   = quantity;
        shipmentLine.FulfillmentOrderLineItemId = foliLine.Id;
        shipmentLine.SerialNumber__c            = serialNumber;
        shipmentLine.OrderItemSummaryId         = foliLine.OrderItemSummaryId;

        return shipmentLine;
    }

    /**
     * @description createWMSOutputFulfillmentResponse Creates response entry for the Fulfillment Order
     * @param  status       status       : OK or ERROR
     * @param  errorMessage errorMessage : error message
     * @param  foId         foId         : Fulfillment Order Id
     * @param  foNumber     foNumber     : Fulfillment Order Number
     * @param  shipments    shipments    : shipments that were inserted
     * @return              return       : created response for the FO
     */
    private static WMS_OutPutFulfillment createWMSOutputFulfillmentResponse(String status, 
                                                                    String errorMessage, 
                                                                    Id foId,
                                                                    String foNumber,
                                                                    List<WMS_OutPutshipmentData> shipments){
        WMS_OutPutFulfillment foItemOutput  = new WMS_OutPutFulfillment();
        foItemOutput.fulfillmentId          = foId;
        foItemOutput.fulfillmentOrderNumber = foNumber;
        foItemOutput.fulfillmentStatus      = status;
        foItemOutput.errorMessage           = errorMessage;
        foItemOutput.shipments              = shipments;

        return foItemOutput;
    }

    /**
     * @description getShipmentDataByFulfillmentOrderMap shipments by Fulfillment Order number in map
     * @param  shipmentDataRequests : shipmentDataRequests WMS request data
     * @return                      return shipments by Fulfillment Order number
     */
    private static Map<String, List<WMS_ShipmentData>> getShipmentDataByFulfillmentOrderMap(List<ShipmentDataRquest> shipmentDataRequests){
        Map<String, List<WMS_ShipmentData>> listShipmentsDataWithFoNumber = new Map<String, List<WMS_ShipmentData>>();
        for(ShipmentDataRquest shipmentRequestItem : shipmentDataRequests){
            listShipmentsDataWithFoNumber.put(shipmentRequestItem.fulfillmentOrderNumber, shipmentRequestItem.shipments);
        }

        return listShipmentsDataWithFoNumber;
    }
    
    public class ShipmentDataRquest {
        public String fulfillmentOrderNumber;
        public List<WMS_ShipmentData> shipments;
    }

    // To do -----------> Delete Aura Enabled Annotation
    public class WMS_ShipmentData {
        public String WMSshipmentId;
        public Datetime dispatchDate;
        public String carrier;
        public String shippingService;
        public String trackingNumber;
        public List<WMS_Article> articles;
    }

    public class WMS_Article {
        public String productSKU;
        public Integer qty;
        public List<String> serialNumber;
    }

    public class WMS_OutPutFulfillment {
        public String fulfillmentOrderNumber;
        public String fulfillmentId;
        public String fulfillmentStatus;
        public List<WMS_OutPutshipmentData> shipments;
        public String errorMessage;
    }
    
    public class WMS_OutPutshipmentData {
        public String shipmentId;
        public String shipmentExternalId;
    }
}