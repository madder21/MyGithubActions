/**************************************************************************************

-- - Author        : Bader Eddine Elkhal

-- - Description   : A Controller for the LWC SomLwcDisplayOrderItems to perform data preparation and oci calls

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 02-08-2022    MAA    1.0          Initial version

***************************************************************************************/
public with sharing class SOM_LWC_DisplayOrderItems_Controller {
    
    /**
    * @description Method return List of lines to exchange based on runing context of the flow
    * @author BADER EDDINE ELKHAL | 08-09-2022 
    * @param orderSumId   : Represent the OrderSummary Id should be provided in case of Manual orderSummary Context
    * @param returnOrdId  : Represent the ReturnOrder Id should be provided in case of Exchange Return Context
    * @param isFromRo     : Flag to provid to define the runing context of flow (return/orderSummary)
    * @return String 
    **/
    @AuraEnabled 
    public static String getListLineItems(String orderSumId, String returnOrdId, Boolean isFromRo){
        List<SOM_Wr_DisplayLineItem> listLinesToReturn = new List<SOM_Wr_DisplayLineItem>();
        Map<String, SOM_Wr_DisplayLineItem> itemsToProcess = new Map<String, SOM_Wr_DisplayLineItem>();
        List<Wr_InventoryDataRequest> listLocationsBySku = new List<Wr_InventoryDataRequest>();
        
        if(isFromRo && (returnOrdId == null || returnOrdId == '')){
            return null;
        }
        if(!isFromRo && (orderSumId == null || orderSumId == '')){
            return null;
        }
        
        //case when component is running in OrderSummary context
        if(isFromRo){
            for(ReturnOrderLineItem roli : [SELECT Id, Product2.StockKeepingUnit, QuantityReceived, Product2.Name, Product2.Family,Product2.function__c, Product2Id, 
                                            OrderItemSummary.ReservedAtLocationId, OrderItemSummary.PricebookEntryId, OrderItemSummary.LineNumber,
                                            TYPEOF OrderItemSummary.ReservedAtLocation WHEN Location THEN ExternalReference END 
                                            FROM ReturnOrderLineItem 
                                            WHERE OrderItemSummary.Type =:SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT 
                                            AND ReturnOrderId =:returnOrdId AND RepaymentMethod =: SOM_Constants.EXCHANGE AND FollowUpProcessed__c =: false AND QuantityReceived > 0]){
                
                
                SOM_Wr_DisplayLineItem lineItem = new SOM_Wr_DisplayLineItem();
                
                lineItem.sku = roli.Product2.StockKeepingUnit;
                lineItem.pbEntryId = roli.OrderItemSummary.PricebookEntryId;
                lineItem.lineNumber = roli.OrderItemSummary.LineNumber;
                lineItem.description = roli.Product2.Name;
                lineItem.function = roli.Product2.function__c;
                lineItem.family = roli.Product2.Family;
                lineItem.roliID = roli.Id;
                lineItem.taxType = true;
                lineItem.amountId = roli.Product2.StockKeepingUnit + '001';
                lineItem.percentId = roli.Product2.StockKeepingUnit + '002';
                lineItem.unitPrice = 0;
                lineItem.taxValue = 0;
                lineItem.lineTotal = 0;
                lineItem.taxRate = 0;
                lineItem.quantity = Integer.valueOf(roli.QuantityReceived);
                lineItem.originalQuantity = Integer.valueOf(roli.QuantityReceived);
                if (roli.OrderItemSummary.ReservedAtLocation instanceof Schema.Location) {
                    Schema.Location location = (Schema.Location) roli.OrderItemSummary.ReservedAtLocation;
                    lineItem.location = location.ExternalReference;
                }
                itemsToProcess.put(roli.Product2.StockKeepingUnit, lineItem);
                listLocationsBySku.add(
                    new Wr_InventoryDataRequest(roli.Product2.StockKeepingUnit,
                    lineItem.location
                    ));

            }
        }
        //case when component is running in ReturnOrder context
        if(!isFromRo){
            for(OrderItemSummary orderItemSumm : [SELECT Id, Product2.StockKeepingUnit, Quantity,Product2.Family,Product2.function__c ,Product2.Name, ReservedAtLocationId, Product2Id, 
                                                LineNumber, PricebookEntryId, TYPEOF ReservedAtLocation WHEN Location THEN ExternalReference END
                                                FROM OrderItemSummary 
                                                WHERE Type =:SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT AND OrderSummaryId =:orderSumId]){

                
                SOM_Wr_DisplayLineItem lineItem = new SOM_Wr_DisplayLineItem();
                lineItem.sku = orderItemSumm.Product2.StockKeepingUnit;
                lineItem.pbEntryId = orderItemSumm.PricebookEntryId;
                lineItem.lineNumber = orderItemSumm.LineNumber;
                lineItem.description = orderItemSumm.Product2.Name;
                lineItem.function = orderItemSumm.Product2.function__c;
                lineItem.family = orderItemSumm.Product2.Family;
                lineItem.quantity = Integer.valueOf(orderItemSumm.Quantity);
                lineItem.taxType = true;
                lineItem.originalQuantity = Integer.valueOf(orderItemSumm.Quantity);
                if (orderItemSumm.ReservedAtLocation instanceof Schema.Location) {
                    Schema.Location location = (Schema.Location) orderItemSumm.ReservedAtLocation;
                    lineItem.location = location.ExternalReference;
                }
                itemsToProcess.put(orderItemSumm.Product2.StockKeepingUnit, lineItem);
                listLocationsBySku.add(
                    new Wr_InventoryDataRequest(orderItemSumm.Product2.StockKeepingUnit,
                    lineItem.location
                    ));
            }
        }
        if(listLocationsBySku.isEmpty()){
            return null;
        }
        String productAtsResult = getProductAts(JSON.serialize(listLocationsBySku));
        List<Wr_InventoryRecordResponse> listnventoryRecordResponse = (List<Wr_InventoryRecordResponse>) JSON.deserialize(productAtsResult, List<Wr_InventoryRecordResponse>.class);
        if(listnventoryRecordResponse?.isEmpty()){
            return null;
        }
        for(Wr_InventoryRecordResponse inventoryLine : listnventoryRecordResponse){
            if(!itemsToProcess.containsKey(inventoryLine.sku)){
                continue;
            }
            itemsToProcess.get(inventoryLine.sku).ats = inventoryLine.ats;
        }
        return JSON.serialize(itemsToProcess.values()) ;
    }

    @AuraEnabled 
    public static Decimal getTotalLinesRO(String returnOrdId, Boolean isFromRo){
        Decimal linesTotalRO = 0;
        if(isFromRo){
            for(ReturnOrderLineItem roli : [SELECT Id, ReturnOrder.GrandTotalAmount, TotalAmount
                                            FROM ReturnOrderLineItem 
                                            WHERE OrderItemSummary.Type =:SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT 
                                            AND ReturnOrderId =:returnOrdId AND RepaymentMethod =: SOM_Constants.EXCHANGE AND FollowUpProcessed__c =: false AND QuantityReceived > 0]){
                    linesTotalRO += roli.TotalAmount;
            }     
        }
        return linesTotalRO;
    }

    @AuraEnabled 
    public static String getCurrency(String orderSumId){
        OrderSummary os = [SELECT Id, CurrencyIsoCode FROM OrderSummary 
                                         WHERE Id =:orderSumId];
        
        return os.CurrencyIsoCode;

    }

    

    /**
    * @description 
    * @author BADER EDDINE ELKHAL | 08-09-2022 
    * @param countryCode 
    * @return List<Wr_PicklistValue> 
    **/
    @AuraEnabled (cacheable=true)
    public static List<Wr_PicklistValue> getLocations(String countryCode){

        List<Wr_PicklistValue> listPicklistValues = new List<Wr_PicklistValue>();
        if(countryCode == null || countryCode == ''){
            //return null
            return listPicklistValues;
        }
        List<Schema.Location> listLocation = [SELECT Id, Name, CustomCountry__c, LocationType, ExternalReference 
                                                FROM Location 
                                                WHERE CustomCountry__c INCLUDES (:countryCode)
                                                AND LocationType =: SOM_Constants.WAREHOUSE 
                                            ];
        if(listLocation?.isEmpty()){
            return listPicklistValues;
        }
        for(Schema.Location location : listLocation){

            listPicklistValues.add(
                    new Wr_PicklistValue(location.Name,
                    location.ExternalReference)
                );
        }         
                
        return listPicklistValues;
    }

    /**
    * @description 
    * @author BADER EDDINE ELKHAL | 08-09-2022 
    * @param productLine 
    * @param currencyCode 
    * @param priceBookId 
    * @return String 
    **/
     @AuraEnabled
    public static String getProductDetails(String productLine, String currencyCode, String priceBookId){
        SOM_Wr_DisplayLineItem productLineOutput;

        if(productLine == null || productLine == ''){
            return null;
        }
        if(currencyCode == null || currencyCode == ''){
            return null;
        }
        if(priceBookId == null || priceBookId == ''){
            return null;
        }
        SOM_Wr_DisplayLineItem productInput = (SOM_Wr_DisplayLineItem) JSON.deserialize(productLine, SOM_Wr_DisplayLineItem.class);
        List<PricebookEntry> pbEntries = [SELECT Id, Name, Pricebook2Id, Product2Id, Product2.Family,Product2.function__c, Product2.StockKeepingUnit ,Product2.Name
                                                FROM PricebookEntry
                                                WHERE Pricebook2Id =: priceBookId AND CurrencyIsoCode =: currencyCode AND Product2Id =: productInput.productId
                                                LIMIT 1
                                            ];
        if(pbEntries?.isEmpty()){
            return null;
        }
        PricebookEntry pbEntry = pbEntries[0];
        List<Wr_InventoryDataRequest> listLocationsBySku = new List<Wr_InventoryDataRequest>{
            new Wr_InventoryDataRequest(pbEntry.Product2.StockKeepingUnit,
                productInput.location
            )};
        String productAtsResult = getProductAts(JSON.serialize(listLocationsBySku));
        List<Wr_InventoryRecordResponse> listnventoryRecordResponse = (List<Wr_InventoryRecordResponse>) JSON.deserialize(productAtsResult, List<Wr_InventoryRecordResponse>.class);
        if(listnventoryRecordResponse?.isEmpty()){
            return null;
        }
        for(Wr_InventoryRecordResponse inventoryLine : listnventoryRecordResponse){
            if(inventoryLine.sku == pbEntry.Product2.StockKeepingUnit){
                productLineOutput = new SOM_Wr_DisplayLineItem();
                productLineOutput.productId = pbEntry.Product2Id;
                productLineOutput.pbEntryId = pbEntry.Id;
                productLineOutput.ats = inventoryLine.ats;
                productLineOutput.location = inventoryLine.location;
                productLineOutput.description = pbEntry.Product2.Name;
                productLineOutput.skuExchange = pbEntry.Product2.stockKeepingUnit;
                productLineOutput.function = pbEntry.Product2.function__c;
                productLineOutput.family = pbEntry.Product2.Family;
            }
        }
        if(productLineOutput == null){
            return null;
        }
        return JSON.serialize(productLineOutput);
    }

    /**
    * @description 
    * @author BADER EDDINE ELKHAL | 08-09-2022 
    * @param locationBySku 
    * @return String 
    **/
    //@future(callout=true)
    @AuraEnabled
    public static String getProductAts(String locationBySku){
        
        List<Wr_InventoryRecordResponse> listnventoryRecordResponse = new List<Wr_InventoryRecordResponse>();
        if(locationBySku == null || locationBySku == ''){
            return JSON.serialize(listnventoryRecordResponse);
        }
        if(!Test.isRunningTest()) { 
        List<Wr_InventoryDataRequest> listLocationsBySku = (List<Wr_InventoryDataRequest>) JSON.deserialize(locationBySku, List<Wr_InventoryDataRequest>.class);
        ConnectApi.OCIGetInventoryAvailabilityInputRepresentation inventoryAvailabilityInput = new ConnectApi.OCIGetInventoryAvailabilityInputRepresentation();
        inventoryAvailabilityInput.stockKeepingUnits = new List<String>();
        inventoryAvailabilityInput.locationIdentifiers = new List<String>();
        for(Wr_InventoryDataRequest requestLine : listLocationsBySku){
            inventoryAvailabilityInput.stockKeepingUnits.add(requestLine.key);
            inventoryAvailabilityInput.locationIdentifiers.add(requestLine.value);
        }
        ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation inventoryAvailabilityOutput = ConnectApi.OmnichannelInventoryService.getInventoryAvailability(inventoryAvailabilityInput);
        if(inventoryAvailabilityOutput.locations?.isEmpty()){
            return JSON.serialize(listnventoryRecordResponse);
        }
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locationAvailabilityOutput = inventoryAvailabilityOutput.locations;
        if(locationAvailabilityOutput[0].inventoryRecords?.isEmpty()){
            return JSON.serialize(listnventoryRecordResponse);
        }
        for(ConnectApi.OCIInventoryRecordOutputRepresentation inventoryRecordOutput : locationAvailabilityOutput[0].inventoryRecords){
            listnventoryRecordResponse.add(
                new Wr_InventoryRecordResponse(inventoryRecordOutput.stockKeepingUnit,
                                            inventoryRecordOutput.availableToOrder,
                                            locationAvailabilityOutput[0].locationIdentifier)
                );
        }
        }
        return JSON.serialize(listnventoryRecordResponse);
    }
 
    /**
    * @description 
    * @author FATIMA-EZZAHRA LAFTOUMI | 02-09-2022 
    * @return Set<String>
    **/
    @AuraEnabled
    public static List<String> getSKUsDelivery(){
        List<OrderItemSummary> skus = new List<OrderItemSummary>([SELECT Product2.StockKeepingUnit FROM OrderItemSummary WHERE Type  =: SOM_Constants.DELIVERY_CHARGE ]);
        Set<String> setSkus         = new Set<String>();
        for(OrderItemSummary sku : skus){
            setSkus.add(sku.Product2.StockKeepingUnit);
        }         
        List<String> listSkus = new List<String>(setSkus);
        return listSkus;
    }


    public class Wr_PicklistValue{

        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public Wr_PicklistValue(String labelVal, String valueVal){
            this.label = labelVal;
            this.value = valueVal;
        }
        
    }

    public class Wr_InventoryDataRequest{

        @AuraEnabled public String key;
        @AuraEnabled public String value;

        public Wr_InventoryDataRequest(String key, String value){
            this.key = key;
            this.value = value;
        }
        
    }
    public class Wr_InventoryRecordResponse{

        @AuraEnabled public String sku;
        @AuraEnabled public Double ats;
        @AuraEnabled public String location;

        public Wr_InventoryRecordResponse(String sku, Double ats, String location){
            this.sku = sku;
            this.ats = ats;
            this.location = location;
        }
        
    }

    
}