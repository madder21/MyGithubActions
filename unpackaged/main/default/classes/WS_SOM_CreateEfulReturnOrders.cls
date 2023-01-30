@RestResource(urlMapping='/CreateEfulReturnOrders/*')
global with sharing class WS_SOM_CreateEfulReturnOrders {

    @HttpPost
    global static List<EfulReturnOrderResponse> createEfulReturnOrder(List<EfulReturnOrderRequest> request){

        List<EfulReturnOrderResponse> efulReturnOrdersResponseList = new List<EfulReturnOrderResponse>();

        try{

            List<String> returnOrderReturnOriginValues            = getPicklistValues('ReturnOrder', 'ReturnOrigin__c');
            List<String> returnOrderItemConditionValues           = getPicklistValues('ReturnOrderLineItem', 'ConditionId__c');
            List<String> returnOrderItemReasonForReturnValues     = getPicklistValues('ReturnOrderLineItem', 'ReasonForReturn');
            List<String> returnOrderItemLineFollowUpValues        = getPicklistValues('ReturnOrderLineItem', 'RepaymentMethod');

            Set<String> locationNames           = new Set<String>();
            Set<String> orderSummariesNumbers   = new Set<String>();
            Set<String> productsSKU             = new Set<String>();

            Map<String, SObject> locationsMap   = new Map<String, SObject>();
            Map<String, OrderSummary> osMap     = new Map<String, OrderSummary>();
            Map<String, Product2> productsMap   = new Map<String, Product2>();

            Map<String, Map<String, OrderItemSummary>> orderNumberSKUItemsMap = new Map<String, Map<String, OrderItemSummary>>();

            Map<Integer, ReturnOrder> roToPersistMap                             = new Map<Integer, ReturnOrder>();
            Map<Integer, Map<Integer, ReturnOrderLineItem>> roliToPersistMap     = new Map<Integer, Map<Integer, ReturnOrderLineItem>>();
            Map<Integer, Map<Integer, ReturnOrderItemTax>> roliTaxToPersistMap   = new Map<Integer, Map<Integer,ReturnOrderItemTax>>();

            for(EfulReturnOrderRequest req : request){
                if(req.roLocation != null) locationNames.add(req.roLocation);
                if(req.orderSummaryNumber != null) orderSummariesNumbers.add(req.orderSummaryNumber);
                for (ReturnOrderItem item : req.items) {
                    if (item.sku != null) productsSKU.add(item.sku);
                }
            }

            //Order summary
            List<OrderSummary> orderSummaries = [SELECT Id, OrderNumber, (SELECT  Id, OrderSummaryId, OrderSummary.OrderNumber, Product2Id, StockKeepingUnit, GrossUnitPrice, UnitPrice, TotalTaxAmount, Quantity FROM OrderItemSummaries) FROM OrderSummary WHERE OrderNumber IN :orderSummariesNumbers];
            System.debug('orderSummaries' + orderSummaries);
            if(orderSummaries != null){
                for(OrderSummary os : orderSummaries){
                    osMap.put(os.OrderNumber, os);
                    if(os.orderItemSummaries != null){
                        System.debug('os.orderItemSummaries' + os.orderItemSummaries);
                    Map<String, OrderItemSummary> skuOisMap = new Map<String, OrderItemSummary>();
                    for (OrderItemSummary oi : os.orderItemSummaries) {
                        skuOisMap.put(oi.StockKeepingUnit, oi);
                    }
                    orderNumberSKUItemsMap.put(os.OrderNumber, skuOisMap);
                    
                }
            }
        }

        System.debug('orderNumberSKUItemsMap' + orderNumberSKUItemsMap);

            //location
            List<SObject> locations = [SELECT ID, Name FROM Location WHERE Name IN :locationNames];
            if (locations != null) {
                for (SObject loc : locations) {
                    locationsMap.put(String.valueOf(loc.get('Name')), loc);
                }
            }

            //products
            Map<Id, Product2> productsByIdMap = new Map<Id, Product2>([SELECT ID, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :productsSKU]);
            for (Id prdId : productsByIdMap.keySet()) {
                productsMap.put(productsByIdMap.get(prdId).StockKeepingUnit, productsByIdMap.get(prdId));
            }


            for (Integer i=0; i < request.size(); i++) {
                EfulReturnOrderRequest efulReturnOrder = request.get(i);
                Boolean isKO = false;
                //check order summary
                if (osMap.get(efulReturnOrder.orderSummaryNumber) == null){
                    EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                    response.roNumber = efulReturnOrder.roDescription;
                    response.status = 'KO';
                    response.errorMessage = 'Order Summary ' + efulReturnOrder.orderSummaryNumber + ' does not exist.';
                    efulReturnOrdersResponseList.add(response);
                    continue;
                }
                
                //check location
                if (locationsMap.get(efulReturnOrder.roLocation) == null){
                    EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                    response.roNumber = efulReturnOrder.roDescription;
                    response.status = 'KO';
                    response.errorMessage = 'Location ' + efulReturnOrder.roLocation + ' does not exist.';
                    efulReturnOrdersResponseList.add(response);
                    continue;
                }

                //Check Return origin picklist
                if(!returnOrderReturnOriginValues.contains(efulReturnOrder.roOrigin)){
                    EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                    response.roNumber = efulReturnOrder.roDescription;
                    response.status = 'KO';
                    response.errorMessage = 'Specified Origin ' + efulReturnOrder.roOrigin + ' does not match any picklist value in SOM.';
                    efulReturnOrdersResponseList.add(response);
                    continue;
                }

                //Construct Return Order
                ReturnOrder ro = new ReturnOrder();
                ro.orderSummaryId   = osMap.get(efulReturnOrder.orderSummaryNumber).Id;
                ro.status           = SOM_Constants.RETURN_ORDER_STATUS_CLOSED;
                ro.Description      = efulReturnOrder.roDescription;
                ro.ReturnDate__c    = SOM_DateTimeHelper.convertISO8601ToDateTime(efulReturnOrder.roDate);
                ro.ReturnOrigin__c  = efulReturnOrder.roOrigin;
                if (locationsMap.get(efulReturnOrder.roLocation) != null) ro.DestinationLocationId = locationsMap.get(efulReturnOrder.roLocation).Id;

                //Construct return order line items
                Map<Integer, ReturnOrderLineItem> roliItemsMap     = new Map<Integer, ReturnOrderLineItem>();
                Map<Integer, ReturnOrderItemTax> roliTaxMap = new Map<Integer, ReturnOrderItemTax>();

                for (Integer j=0 ; j<efulReturnOrder.items.size() ; j++){
                    ReturnOrderItem item = efulReturnOrder.items.get(j); 

                    //Check if Item SKU is linked to OIS
                    if(orderNumberSKUItemsMap.get(efulReturnOrder.orderSummaryNumber).get(item.sku) == null){
                        EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                        response.roNumber = efulReturnOrder.roDescription;
                        response.status = 'KO';
                        response.errorMessage = 'No Product in Order ' + efulReturnOrder.orderSummaryNumber + ' exist with SKU ' + item.sku;
                        efulReturnOrdersResponseList.add(response);
                        isKO = true;
                        break;
                    }

                    //Check Return item condition picklist
                    if(!returnOrderItemConditionValues.contains(item.conditionId)){
                        EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                        response.roNumber = efulReturnOrder.roDescription;
                        response.status = 'KO';
                        response.errorMessage = 'Specified Condition ' + item.conditionId + ' does not match any picklist value in SOM.';
                        efulReturnOrdersResponseList.add(response);
                        isKO = true;
                        break;
                    }

                    //Check Return item reason picklist
                    if(!returnOrderItemReasonForReturnValues.contains(item.reasonCode)){
                        EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                        response.roNumber = efulReturnOrder.roDescription;
                        response.status = 'KO';
                        response.errorMessage = 'Specified Reason Code ' + item.reasonCode + ' does not match any picklist value in SOM.';
                        efulReturnOrdersResponseList.add(response);
                        isKO = true;
                        break;
                    }

                    //Check Return item follow up picklist
                    if(!returnOrderItemLineFollowUpValues.contains(item.lineFollowUp)){
                        EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                        response.roNumber = efulReturnOrder.roDescription;
                        response.status = 'KO';
                        response.errorMessage = 'Specified follow up ' + item.lineFollowUp + ' does not match any picklist value in SOM.';
                        efulReturnOrdersResponseList.add(response);
                        isKO = true;
                        break;
                    }

                    ReturnOrderLineItem roli = new ReturnOrderLineItem();
                    roli.orderItemSummaryId = orderNumberSKUItemsMap.get(efulReturnOrder.orderSummaryNumber).get(item.sku).Id;
                    roli.Product2Id         = productsMap.get(item.sku).Id;
                    roli.reasonForReturn    = item.reasonCode;
                    roli.quantityExpected   = item.quantityExpected;
                    roli.quantityReceived   = item.quantityReceived;
                    roli.quantityReturned   = item.quantityReturned;
                    roli.ConditionId__c       = item.conditionId;
                    roli.ReasonForReturn      = item.reasonCode;
                    roli.RepaymentMethod      = item.lineFollowUp;
                    roli.TotalLineAmount      = orderNumberSKUItemsMap.get(efulReturnOrder.orderSummaryNumber).get(item.sku).UnitPrice * roli.quantityReceived;
                    roli.FollowUpProcessed__c = true;
                    if (item.serialNumbers != null && !item.serialNumbers.isEmpty()) {
                        roli.SerialNumber__c = String.join(item.serialNumbers, ',');
                    }
                    roliItemsMap.put(j, roli);

                    //create Return Order Item Tax
                    ReturnOrderItemTax roliTax = new ReturnOrderItemTax();
                    roliTax.Type                 = SOM_Constants.ORDER_ITEM_TAX_TYPE_ESTIMATED;
                    roliTax.Amount               = (orderNumberSKUItemsMap.get(efulReturnOrder.orderSummaryNumber).get(item.sku).TotalTaxAmount/orderNumberSKUItemsMap.get(efulReturnOrder.orderSummaryNumber).get(item.sku).quantity) * roli.quantityReceived;
                    roliTaxMap.put(j, roliTax);
                }

                if(isKO == false) {
                    roliToPersistMap.put(i, roliItemsMap);
                    roliTaxToPersistMap.put(i,roliTaxMap);
                    roToPersistMap.put(i, ro);
                }

            }

            //persist return orders
            insert roToPersistMap.values();
           
            //persist return order Line items
            PAD.deactivateTrigger(SOM_Constants.RETURN_ORDER_ITEM_TRIGGER_CONDITION_ID);
            List<ReturnOrderLineItem> allRolis = new List<ReturnOrderLineItem>();
            for (Integer idx : roliToPersistMap.keySet()) {
                Map<Integer, ReturnOrderLineItem> roliMap = roliToPersistMap.get(idx);
                for (Integer idx2 : roliMap.keySet()) {
                    ReturnOrderLineItem roli = roliMap.get(idx2);
                    roli.ReturnOrderId   = roToPersistMap.get(idx).Id;              
                }
                allRolis.addAll(roliMap.values());
            }
            insert allRolis;

            //persist return Order item tax
            List<ReturnOrderItemTax> allRoliTax = new List<ReturnOrderItemTax>();
            for (Integer idx : roliTaxToPersistMap.keySet()) {
                Map<Integer, ReturnOrderLineItem> roliMap   = roliToPersistMap.get(idx);
                Map<Integer, ReturnOrderItemTax> roliTaxMap = roliTaxToPersistMap.get(idx);
                for (Integer idx2 : roliMap.keySet()) {
                    ReturnOrderLineItem roli         = roliMap.get(idx2);
                    ReturnOrderItemTax roliTax       = roliTaxMap.get(idx2);
                    roliTax.ReturnOrderLineItemId    = roli.Id;
                    roliTax.ReturnOrderId            = roToPersistMap.get(idx).Id;
                }
                allRoliTax.addAll(roliTaxMap.values());
            }
            insert allRoliTax;
           
            for (ReturnOrder persistedReturnOrder : roToPersistMap.values()) {
                EfulReturnOrderResponse response = new EfulReturnOrderResponse();
                response.status = 'OK';
                response.roNumber = persistedReturnOrder.description;
                efulReturnOrdersResponseList.add(response);            
            }

        } catch(Exception e){
            EfulReturnOrderResponse response = new EfulReturnOrderResponse();
            response.status       = 'KO';
            response.errorMessage = e.getMessage();
            efulReturnOrdersResponseList.add(response);
        }

        return efulReturnOrdersResponseList;

    }


    global static List<String> getPicklistValues(String objectName, String fieldName){
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

    global with sharing class EfulReturnOrderRequest{

        public String roDescription; 
        public String roStatus; 
        public String roLocation; 
        public String roOrigin; 
        public String roDate;
        public String orderSummaryNumber; 
        public List<ReturnOrderItem> items;
        
    }

    global with sharing class ReturnOrderItem{

        public String sku; 
        public String reasonCode; 
        public String lineFollowUp; 
        public Boolean isProcessed; 
        public String conditionId;
        public Decimal quantityExpected; 
        public Decimal quantityReceived;
        public Decimal quantityReturned;
        public List<String> serialNumbers; 
        
    }

    global with sharing class EfulReturnOrderResponse{

        public String roNumber;
        public String errorMessage;
        public String status;

    }

}