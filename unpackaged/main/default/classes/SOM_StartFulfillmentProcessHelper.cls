public class SOM_StartFulfillmentProcessHelper {
    public static void startFulfillmentProcess( List<Start_Fulfillment_Process__e> FulfillmentEventList) {
        try{
            List<String> orderSummIds = new List<String>();
            for ( Start_Fulfillment_Process__e FulfillmentEvent : FulfillmentEventList){
                if(!Test.isrunningtest()) {
                    orderSummIds.add(FulfillmentEvent.OrderSummaryID__c);
                }
            }
            
            Id batchJobId = Database.executeBatch(new SOM_Batch_StartFulfillmentProcess(orderSummIds), 1);

            Logs.debug('Start Fulfillment Process','SOM_StartFulfillmentProcessHelper','startFulfillmentProcess','','', FulfillmentEventList[0].OrderSummaryID__c); 
            Logs.info('Start Fulfillment Process','SOM_StartFulfillmentProcessHelper','startFulfillmentProcess','','', FulfillmentEventList[0].OrderSummaryID__c);
        } catch(Exception e){
            Logs.error(e,'SOM_StartFulfillmentProcessHelper','startFulfillmentProcess','','', FulfillmentEventList[0].OrderSummaryID__c);   
        }
        
    }
}