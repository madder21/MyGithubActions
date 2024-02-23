public with sharing class SOM_Retry_Allocation{
    
    public static void retryAlloc(List<OrderItemSummary> orderItemSummaries, ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation inventRep) {
        Map<Id, List<OrderItemSummary>> mapItemsWithOsId = new Map<Id, List<OrderItemSummary>>();
        Map<String, Decimal> locationSKUwithOnHands      = new Map<String, Decimal>();
        Map<String, Decimal> allocatedItemsMap           = new Map<String, Decimal>();
        Map<Id, ProcessException> oisProcessException    = new Map<Id, ProcessException>();
        
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> ociLocations = inventRep.locations;
        List<ProcessException> peToUpdateList = new List<ProcessException>();
        List<ProcessException> peToCreateList = new List<ProcessException>();
        List<OrderSummary> osToUpdateList     = new List<OrderSummary>();
        
        List<ProcessException> processExceptions = [SELECT Id, Status ,Description, Category, AttachedToId, OrderSummaryId FROM ProcessException WHERE Status =: SOM_Constants.PE_NEW AND Category =: SOM_Constants.FULFILLMENT];
        if(!processExceptions.isEmpty() && processExceptions != null){
            for(ProcessException pe : processExceptions){
                oisProcessException.put(pe.AttachedToId, pe);
            }
        }

        List<Schema.Location> allLocations = [SELECT Id, ExternalReference FROM Location];
        Map<Id, Schema.Location> allLocationsMap = new Map<Id, Schema.Location>(allLocations);
        
        List<OrderItemSummary> oisAllocated = [SELECT Id, stockKeepingUnit, OriginalOrderItem.ReservedAtLocationId, TYPEOF ReservedAtLocation WHEN Location THEN ExternalReference END, QuantityAllocated FROM OrderItemSummary WHERE Status =: SOM_Constants.ALLOCATED];
        if(!oisAllocated.isEmpty() && oisAllocated != null){
            for(OrderItemSummary ois : oisAllocated){
                Decimal qtyAllocated = ois.QuantityAllocated;
                if (ois.ReservedAtLocation instanceof Schema.Location) {
                    Schema.Location location = (Schema.Location) ois.ReservedAtLocation;
                    if(allocatedItemsMap.containsKey(location.ExternalReference + ois.stockKeepingUnit)){
                        allocatedItemsMap.put(location.ExternalReference + ois.stockKeepingUnit,allocatedItemsMap.get(location.ExternalReference + ois.stockKeepingUnit) + qtyAllocated);
                    }
                    else{
                        allocatedItemsMap.put(location.ExternalReference + ois.stockKeepingUnit, qtyAllocated);
                    }
                    
                }
            }
        }
        
        for(ConnectApi.OCILocationAvailabilityOutputRepresentation ociLoc : ociLocations){
            List<ConnectApi.OCIInventoryRecordOutputRepresentation> records = ociLoc.inventoryRecords;
            for(ConnectApi.OCIInventoryRecordOutputRepresentation rec : records){
                locationSKUwithOnHands.put(ociLoc.locationIdentifier + rec.stockKeepingUnit, rec.onHand);
            }   
        }
        
        for(OrderItemSummary ois : orderItemSummaries){
            if(mapItemsWithOsId.containsKey(ois.orderSummaryId)){
                mapItemsWithOsId.get(ois.orderSummaryId).add(ois);
            }
            else{
                mapItemsWithOsId.put(ois.orderSummaryId, new List<OrderItemSummary>{ois});
            }
        }
        
        
        
        
        Map<Id, OrderSummary> mapIdOs = new Map<Id, OrderSummary>([SELECT Id, SalesChannel.SalesChannelName, OrderNumber, Status, CreateFulfillmentOrderImmediatly__c, RetryAllocationProcessed__c FROM OrderSummary WHERE ID IN: mapItemsWithOsId.keySet()]);
        
        for(Id osId : mapItemsWithOsId.keySet()){
            Boolean stockOk = true;
            List<OrderItemSummary> oisList = mapItemsWithOsId.get(osId);
            
            Boolean isSTWorManual = mapIdOs.get(osId).SalesChannel.SalesChannelName == SOM_Constants.SALES_CHANNEL_RIMOWA ? false : true;
            
            ConnectApi.OCICreateReservationInputRepresentation reservInputRep = new ConnectApi.OCICreateReservationInputRepresentation();
            List<ConnectApi.OCICreateReservationSingleInputRepresentation> reservRecords = new List<ConnectApi.OCICreateReservationSingleInputRepresentation>();
            List<ConnectApi.OCICreateReservationSingleInputRepresentation> reservRecordsTemp = new List<ConnectApi.OCICreateReservationSingleInputRepresentation>();
            
            for(OrderItemSummary ois : oisList){
                ProcessException pe = oisProcessException.get(ois.Id);
                //Schema.Location location = (Schema.Location) ois.ReservedAtLocation;
                Schema.Location location = (Schema.Location) allLocationsMap.get(ois.ReservedAtLocationId);
                if(allocatedItemsMap.get(location.ExternalReference + ois.stockKeepingUnit) == null) {
                    allocatedItemsMap.put(location.ExternalReference + ois.stockKeepingUnit, 0);
                }
                ConnectApi.OCICreateReservationSingleInputRepresentation resSingleRec = new ConnectApi.OCICreateReservationSingleInputRepresentation();
                if(locationSKUwithOnHands.get(location.ExternalReference + ois.stockKeepingUnit) >= (ois.Quantity + allocatedItemsMap.get(location.ExternalReference + ois.stockKeepingUnit)) && pe!=null){
                    locationSKUwithOnHands.put(location.ExternalReference + ois.stockKeepingUnit, locationSKUwithOnHands.get(location.ExternalReference + ois.stockKeepingUnit) - ois.Quantity);
                    
                    pe.Status = 'Resolved';
                    peToUpdateList.add(pe);
                    
                    if(isSTWorManual == true){
                        resSingleRec.quantity           = ois.quantity;
                        resSingleRec.locationIdentifier = location.ExternalReference;
                        resSingleRec.stockKeepingUnit   = ois.stockKeepingUnit;
                        reservRecordsTemp.add(resSingleRec);
                        
                    }
                    
                }
                else if(locationSKUwithOnHands.get(location.ExternalReference + ois.stockKeepingUnit) >= (ois.Quantity + allocatedItemsMap.get(location.ExternalReference + ois.stockKeepingUnit)) && pe==null){
                    locationSKUwithOnHands.put(location.ExternalReference + ois.stockKeepingUnit, locationSKUwithOnHands.get(location.ExternalReference + ois.stockKeepingUnit) - ois.Quantity);
                    if(isSTWorManual == true){
                        resSingleRec.quantity           = ois.quantity;
                        resSingleRec.locationIdentifier = location.ExternalReference;
                        resSingleRec.stockKeepingUnit   = ois.stockKeepingUnit;
                        reservRecordsTemp.add(resSingleRec);
                    }
                    
                    
                }
                else if(locationSKUwithOnHands.get(location.ExternalReference + ois.stockKeepingUnit) < (ois.Quantity + allocatedItemsMap.get(location.ExternalReference + ois.stockKeepingUnit)) && pe!=null){
                    stockOk = false;
                }
                else if(locationSKUwithOnHands.get(location.ExternalReference + ois.stockKeepingUnit) < (ois.Quantity + allocatedItemsMap.get(location.ExternalReference + ois.stockKeepingUnit)) && pe == null){
                    ProcessException peToCreate = new ProcessException();
                    peToCreate.Category         = 'Fulfillment';
                    peToCreate.Status           = 'New';
                    peToCreate.Severity         = 'High';
                    peToCreate.Message          = 'Insufficient Stock';
                    peToCreate.Priority         = 'High';
                    peToCreate.AttachedToId     = ois.Id;
                    peToCreate.OrderSummaryId   = osId;
                    peToCreate.Description      = 'SKU : ' + ois.stockKeepingUnit + ' Quantity: ' + ois.Quantity;
                    peToCreateList.add(peToCreate);
                    stockOk = false;
                }
                
            }
            if(stockOk == true){
                OrderSummary osToUpdate = mapIdOs.get(osId);
                osToUpdate.Status = 'Validated';
                osToUpdate.RetryAllocationProcessed__c = true;
                osToUpdate.CreateFulfillmentOrderImmediatly__c = false;
                osToUpdateList.add(osToUpdate);
                
                if(isSTWorManual == true){
                    
                    reservRecords.addAll(reservRecordsTemp);
                    String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
                    String uuidGen = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
                    reservInputRep.createRecords            = reservRecords;
                    reservInputRep.actionRequestId          = uuidGen;
                    reservInputRep.externalRefId            = osToUpdate.OrderNumber;
                    reservInputRep.allowPartialReservations = false;
                    
                    ConnectApi.OmnichannelInventoryService.createReservation(reservInputRep);
                    
                }
            }
        }
        
        if(!peToUpdateList.isEmpty()){
            update peToUpdateList;
        }
        
        if(!peToCreateList.isEmpty()){
            insert peToCreateList;
        }
        
        if(!osToUpdateList.isEmpty()){
            update osToUpdateList;
        }
        
    }
}