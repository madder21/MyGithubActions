global with sharing class SOM_GetAvailability_BatchSubClass {

    global List<OrderSummary> osList ;
    global ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation result {get;set;}


    global SOM_GetAvailability_BatchSubClass(List<OrderSummary> osList){
        this.osList = osList ;  
        getAvailabilityExecute();
    }

    global void getAvailabilityExecute() {
        Set<String> osIds           = new Set<String>();
        Set<String> oisIds          = new Set<String>();
        Set<String> skus            = new Set<String>();
        Set<String> locationIds     = new Set<String>();
        Set<String> locationExtRef  = new Set<String>();

        Map<String, SObject> locationsMap  = new Map<String, SObject>();

        for(OrderSummary os : this.osList){
            osIds.add(os.Id);
        }

        List<OrderItemSummary> ois = [SELECT ID, OriginalOrderItem.ReservedAtLocationId, ReservedAtLocationId, TYPEOF ReservedAtLocation WHEN Location THEN ExternalReference END, StockKeepingUnit, OrderSummary.SalesChannel.SalesChannelName, Quantity FROM OrderItemSummary WHERE orderSummaryId IN :osIds AND Type =: SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT AND Status =: SOM_Constants.Status_Ordered AND ( IsPreOrder__c =: false OR (IsPreOrder__c =: true AND DeliveryStartDate__c <=: system.now()))];
        for (OrderItemSummary orderItemSum : ois) {
            orderItemSum.ReservedAtLocationId = orderItemSum.OriginalOrderItem.ReservedAtLocationId;
            oisIds.add(orderItemSum.Id);
            skus.add(orderItemSum.StockKeepingUnit);
            locationIds.add(orderItemSum.OriginalOrderItem.ReservedAtLocationId);
        }
        
        if(skus != null && !skus.isEmpty()){
            List<SObject> locations = [SELECT ID, ExternalReference FROM Location WHERE Id IN :locationIds];
            for (SObject loc : locations) {
                locationsMap.put(String.valueOf(loc.get('ExternalReference')), loc);
            }
    
            ConnectApi.OCIGetInventoryAvailabilityInputRepresentation ociInputRep = new ConnectApi.OCIGetInventoryAvailabilityInputRepresentation();
            ociInputRep.locationIdentifiers = new List<String>(locationsMap.keySet());
            ociInputRep.stockKeepingUnits   = new List<String>(skus);
            ociInputRep.useCache            = false;
            
            if(!Test.isRunningTest()){
                ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation ociOutputRep = ConnectApi.OmnichannelInventoryService.getInventoryAvailability(ociInputRep);  
                this.result = ociOutputRep;
                SOM_Retry_Allocation.retryAlloc(ois, ociOutputRep);   
            }
            else {
                ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation ociOutputRep = new ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation();
                List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locationsOutTest = new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
                ConnectApi.OCILocationAvailabilityOutputRepresentation locationOutTest = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
                List<ConnectApi.OCIInventoryRecordOutputRepresentation> inventsTest = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
                ConnectApi.OCIInventoryRecordOutputRepresentation inventTest = new ConnectApi.OCIInventoryRecordOutputRepresentation();
                
                inventTest.onHand = 1000;
                inventTest.stockKeepingUnit = 'sku10001';
                inventsTest.add(inventTest);
    
                locationOutTest.locationIdentifier  = 'rimowa-inventory-ae';
                locationOutTest.inventoryRecords    = inventsTest;
                locationsOutTest.add(locationOutTest);
    
                ociOutputRep.locations = locationsOutTest;
                this.result = ociOutputRep;
                SOM_Retry_Allocation.retryAlloc(ois, ociOutputRep);   
            }
        }        
    }
}