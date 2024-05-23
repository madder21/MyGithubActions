public class SOM_StartFulfillmentProcessHelper {
    public static void startFulfillmentProcess( List<Start_Fulfillment_Process__e> FulfillmentEventList) {
        List<String> orderSummIds = new List<String>();
        for ( Start_Fulfillment_Process__e FulfillmentEvent : FulfillmentEventList){
            if(!Test.isrunningtest()) {
               
                orderSummIds.add(FulfillmentEvent.OrderSummaryID__c);
                               
            }
                        
        }
        
        Id batchJobId = Database.executeBatch(new SOM_Batch_StartFulfillmentProcess(orderSummIds), 1);
    }
}