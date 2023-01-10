global with sharing class SOM_ClosingFulfillmentOrderAction {

    @InvocableMethod(label='Update Fulfillment Order' description='Update Fulfillment Order status.')
    global static List<SOM_CloseFulfillmentOrderResponseWr> UpdateFulfillmentOrderStatus(List<UpdateFulfillmentOrderArgs> argWr){

        List<SOM_CloseFulfillmentOrderResponseWr> responseWrapper = new List<SOM_CloseFulfillmentOrderResponseWr>();
        SOM_CloseFulfillmentOrderResponseWr response = new SOM_CloseFulfillmentOrderResponseWr();
        List<Id> foIds = new List<Id>();
        foIds.addAll(argWr[0].foIds);

        List<FulfillmentOrderLineItem> fulfillmentOrderLineItems = [SELECT Id, Quantity, OriginalQuantity, Type, FulfillmentOrderId, FulfillmentOrder.Status, FulfillmentOrder.OrderSummaryId, FulfillmentOrder.OrderSummary.status, (SELECT Id, Quantity FROM ShipmentItems) FROM FulfillmentOrderLineItem WHERE FulfillmentOrderId IN :foIds AND Type != :SOM_Constants.FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE];
        if (fulfillmentOrderLineItems == null || fulfillmentOrderLineItems.isEmpty()) {
            System.debug('FOLI list is empty.');
            response.isSuccess = false;
            response.errorMessage = 'The Query returns an empty result.';
            responseWrapper.add(response);

            return responseWrapper;
        }
        List<FulfillmentOrder> foToUpdateList = new List<FulfillmentOrder>();

        //construct map
        Map<Id, List<FulfillmentOrderLineItem>> fulfillmentOrderMap = new Map<Id, List<FulfillmentOrderLineItem>>();
        for (FulfillmentOrderLineItem foItem:fulfillmentOrderLineItems) {
            if (!fulfillmentOrderMap.containsKey(foItem.FulfillmentOrderId)) {
                fulfillmentOrderMap.put(foItem.FulfillmentOrderId, new List<FulfillmentOrderLineItem>());
            }
            fulfillmentOrderMap.get(foItem.FulfillmentOrderId).add(foItem);       
        }
        
        for (Id foId:fulfillmentOrderMap.keySet()) {
            FulfillmentOrderStatus fulfillmentOrderStatus = new FulfillmentOrderStatus();
            for(FulfillmentOrderLineItem foItem:fulfillmentOrderMap.get(foId)) {
                //calculate quantity fulfilled
                List<ShipmentItem> shipmentItemsList = foItem.ShipmentItems;
                Decimal quantityFulfilled = 0;
                for(ShipmentItem shipItem:shipmentItemsList) {
                    quantityFulfilled += shipItem.Quantity;
                }
                fulfillmentOrderStatus.orderSummary     = foItem.FulfillmentOrder.OrderSummary;
                fulfillmentOrderStatus.FulfillmentOrder = foItem.FulfillmentOrder;
                if (foItem.Quantity == 0) {
                    //foli is canceled
                    fulfillmentOrderStatus.numberOfCanceledFOLI += 1;
                    continue;
                }
                if (quantityFulfilled > 0 && quantityFulfilled < foItem.Quantity) {
                    //foli is partially fulfilled
                    fulfillmentOrderStatus.numberOfPartiallyFulfilledFOLI += 1;
                    continue;
                }
                if (quantityFulfilled > 0 && quantityFulfilled == foItem.Quantity) {
                    //foli is fulfilled
                    fulfillmentOrderStatus.numberOfFulfilledFOLI += 1;
                    continue;
                }
                if (quantityFulfilled == 0) {
                    //foli is fulfilling
                    fulfillmentOrderStatus.numberOfFulfillingFOLI += 1;
                    continue;
                }
            }

            System.debug('fulfillmentOrderStatus :::::::::: ' +fulfillmentOrderStatus);
            foToUpdateList.add(fulfillmentOrderStatus.fulfillmentOrder);
            Integer numberOfFOLI = fulfillmentOrderMap.get(foId).size();
            System.debug('numberOfFOLI ::::::::::: ' + numberOfFOLI);
            if (fulfillmentOrderStatus.numberOfCanceledFOLI == numberOfFOLI) {
                //fo status is canceled
                fulfillmentOrderStatus.fulfillmentOrder.Status = SOM_Constants.FULFILLMENT_ORDER_CANCELED;
                continue;
            }
            if ((fulfillmentOrderStatus.numberOfFulfilledFOLI == numberOfFOLI) || ((fulfillmentOrderStatus.numberOfCanceledFOLI+fulfillmentOrderStatus.numberOfFulfilledFOLI) == numberOfFOLI)) {
                //fo status is fulfilled
                fulfillmentOrderStatus.fulfillmentOrder.Status = SOM_Constants.FULFILLMENT_ORDER_FULFILLED;
                continue;
            }
            if ((fulfillmentOrderStatus.numberOfPartiallyFulfilledFOLI > 0) || (fulfillmentOrderStatus.numberOfFulfilledFOLI > 0 && fulfillmentOrderStatus.numberOfFulfillingFOLI > 0)) {
                //fo status is partially fulfilled
                fulfillmentOrderStatus.fulfillmentOrder.Status = SOM_Constants.FULFILLMENT_ORDER_PARTIALLY_FULFILLED;
                continue;
            }
            

        }
        System.debug('foToUpdateList ::::::::::: ' + foToUpdateList);

        try {
            if (foToUpdateList.size() > 0) update foToUpdateList;
            List<Id> foIdList = new List<Id>();
            for (FulfillmentOrder fo:foToUpdateList) {
                foIdList.add(fo.Id);
            }
            response.foIds     = foIdList;
            response.isSuccess = true;
        } catch(DmlException ex) { 
            System.debug(ex.getMessage());
            response.isSuccess = false;
            response.errorMessage = ex.getMessage();
        }
        responseWrapper.add(response);

        if(argWr[0].doUpdateOSStatus == true){
           responseWrapper = SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(responseWrapper);
        }
        return responseWrapper;
    }

    global with sharing class FulfillmentOrderStatus{
        public FulfillmentOrder fulfillmentOrder;
        public OrderSummary     orderSummary;
        //FOLI
        public Integer numberOfCanceledFOLI;
        public Integer numberOfFulfilledFOLI;
        public Integer numberOfPartiallyFulfilledFOLI;
        public Integer numberOfFulfillingFOLI;

        public FulfillmentOrderStatus(){
            this.numberOfCanceledFOLI           = 0;
            this.numberOfFulfilledFOLI          = 0;
            this.numberOfPartiallyFulfilledFOLI = 0;
            this.numberOfFulfillingFOLI         = 0;
        }
    }

    global with sharing class UpdateFulfillmentOrderArgs{
        @InvocableVariable
        global List<Id> foIds;
        @InvocableVariable
        global Boolean doUpdateOSStatus;
    }
    
}