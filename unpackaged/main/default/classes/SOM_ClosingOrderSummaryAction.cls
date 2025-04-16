global with sharing class SOM_ClosingOrderSummaryAction {
    @InvocableMethod(label='Update Order Summary' description='Update Order Summary status.')
    global static List<SOM_CloseFulfillmentOrderResponseWr> UpdateOrderSummaryStatus(List<SOM_CloseFulfillmentOrderResponseWr> responseFromFo){

        List<SOM_CloseFulfillmentOrderResponseWr> responseWr = new List<SOM_CloseFulfillmentOrderResponseWr>();
        SOM_CloseFulfillmentOrderResponseWr response = new SOM_CloseFulfillmentOrderResponseWr();
        List<OrderSummary> osToUpdateList = new List<OrderSummary>();
        Map<Id, OrderSummaryStatus> orderSummaryStatusMap   = new Map<Id, OrderSummaryStatus>();

        Map<Id, OrderSummary> foOSMap = new Map<Id, OrderSummary>();
        try {
        if(responseFromFo[0].isSuccess == false){
            response.isSuccess = false;
            responseWr.add(response);
            return responseWr;
        }
        

        List<FulfillmentOrder> firstFosFromIds = [SELECT Id, OrderSummaryId, Status FROM FulfillmentOrder WHERE Id IN: responseFromFo[0].foIds];
        Set<Id> osIds = new Set<Id>();
        for(FulfillmentOrder fo : firstFosFromIds){
            osIds.add(fo.OrderSummaryId);
        }

        List<FulfillmentOrder> fosFromIds = [SELECT Id, OrderSummaryId, Status FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds];

        Map<Id, OrderSummary> osMap = new Map<Id, OrderSummary>([SELECT Id, Status FROM OrderSummary WHERE Id IN: osIds]);

        for(FulfillmentOrder fo : fosFromIds){
            foOSMap.put(fo.Id, osMap.get(fo.OrderSummaryId));
        }




        List<OrderItemSummary> ois = [SELECT Id, OrderSummaryId, quantityAvailabletofulfill FROM OrderItemSummary WHERE Status =: 'Ordered' AND Type != 'Delivery Charge' AND quantityAvailabletofulfill > 0 AND OrderSummaryId IN: osIds];

        Map<Id, Integer> orderedItems = new Map<Id, Integer>();

        if(!ois.isEmpty()){
            for(OrderItemSummary oi : ois){
                if(orderedItems.containsKey(oi.OrderSummaryId)){
                    orderedItems.put(oi.OrderSummaryId,orderedItems.get(oi.OrderSummaryId)+1);
                }
                else{
    
                    orderedItems.put(oi.OrderSummaryId,1);
    
                }
            }
        }
        
        for (FulfillmentOrder fo : fosFromIds) {

            //order summary status
            OrderSummaryStatus orderSummaryStatus = orderSummaryStatusMap.get(fo.OrderSummaryId);
            if (orderSummaryStatus == null) {
                orderSummaryStatus = new OrderSummaryStatus();
                orderSummaryStatus.orderSummary = foOSMap.get(fo.Id);
                orderSummaryStatusMap.put(fo.OrderSummaryId, orderSummaryStatus);
            }

            if(orderedItems.get(orderSummaryStatus.orderSummary.Id) != null){
                orderSummaryStatus.numberOfOrderedItems = orderedItems.get(orderSummaryStatus.orderSummary.Id);
            }
            
            orderSummaryStatus.numberOfFO += 1;
            if (fo.Status == SOM_Constants.FULFILLMENT_ORDER_CANCELED) {
                //fo status is canceled
                orderSummaryStatus.numberOfCanceledFO += 1;
                continue;
            }
            if (fo.Status == SOM_Constants.FULFILLMENT_ORDER_FULFILLED) {
                //fo status is fulfilled
                orderSummaryStatus.numberOfFulfilledFO += 1;
                continue;
            }
            if (fo.Status == SOM_Constants.FULFILLMENT_ORDER_PARTIALLY_FULFILLED) {
                //fo status is partially fulfilled
                orderSummaryStatus.numberOfPartiallyFulfilledFO += 1;
                continue;
            }

            orderSummaryStatus.numberOfFulfillingFO += 1;
        }

        for (Id orderId:orderSummaryStatusMap.keySet()) {
            OrderSummaryStatus orderSummaryStatus = orderSummaryStatusMap.get(orderId);
            osToUpdateList.add(orderSummaryStatus.orderSummary);

            if (orderSummaryStatus.numberOfCanceledFO == orderSummaryStatus.numberOfFO) {
                //canceled
                orderSummaryStatus.orderSummary.Status = SOM_Constants.ORDER_SUMMARY_CANCELED;
                continue;
            }
            else if ((orderSummaryStatus.numberOfOrderedItems == 0) && ((orderSummaryStatus.numberOfFulfilledFO == orderSummaryStatus.numberOfFO) || (orderSummaryStatus.numberOfFulfilledFO+orderSummaryStatus.numberOfCanceledFO == orderSummaryStatus.numberOfFO))) {
                //Fulfilled
                orderSummaryStatus.orderSummary.Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
                continue;
            }
            else if ((orderSummaryStatus.numberOfOrderedItems > 0 && 
            (orderSummaryStatus.numberOfPartiallyFulfilledFO > 0 || orderSummaryStatus.numberOfFulfilledFO > 0)) 
            || (orderSummaryStatus.numberOfPartiallyFulfilledFO > 0) || (orderSummaryStatus.numberOfFulfilledFO > 0 && orderSummaryStatus.numberOfFulfillingFO > 0)) {
                //Partially fulfilled
                orderSummaryStatus.orderSummary.Status = SOM_Constants.ORDER_SUMMARY_PARTIALLY_FULFILLED;
                continue;
            }
            else{
                orderSummaryStatus.orderSummary.Status = SOM_Constants.ORDER_SUMMARY_FULFILLING;
                continue;
            }
        }

            if (osToUpdateList.size() > 0) update osToUpdateList;
            List<Id> osIdList = new List<Id>();
            for (OrderSummary os:osToUpdateList) {
                osIdList.add(os.Id);
            }
            response.foIds     = responseFromFo[0].foIds;
            response.osIds     = osIdList;
            response.isSuccess = true;
			Logs.debug('Closing Order Summary Action', 'SOM_ClosingOrderSummaryAction', 'UpdateOrderSummaryStatus','','',responseFromFo[0].foIds[0]);
			Logs.info('Closing Order Summary Action', 'SOM_ClosingOrderSummaryAction', 'UpdateOrderSummaryStatus','','',responseFromFo[0].foIds[0]);            
        } catch(DmlException ex) { 
            response.isSuccess = false;
            response.errorMessage = ex.getMessage();
            Logs.error(ex, 'Closing Order Summary Action', 'SOM_ClosingOrderSummaryAction', '','',responseFromFo[0].foIds[0]);
        }
        responseWr.add(response);

        return responseWr;
    }



    global with sharing class OrderSummaryStatus{
        //FO
        public Integer      numberOfCanceledFO;
        public Integer      numberOfFulfilledFO;
        public Integer      numberOfPartiallyFulfilledFO;
        public Integer      numberOfFulfillingFO;
        public Integer      numberOfFO;
        public Integer      numberOfOrderedItems;
        public OrderSummary orderSummary;

        public OrderSummaryStatus(){
            this.numberOfCanceledFO           = 0;
            this.numberOfFulfilledFO          = 0;
            this.numberOfPartiallyFulfilledFO = 0;
            this.numberOfFulfillingFO         = 0;
            this.numberOfFO                   = 0;
            this.numberOfOrderedItems         = 0;
        }
    }

}