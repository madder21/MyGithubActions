public with sharing class SOM_callStartFulfillmentProcessBatch {

    @InvocableMethod(label='Start Fulfillment Process' description='This method is called from the Flow "SOM 201", it starts the fulfillment process by calling the batch "SOM_Batch_StartFulfillmentProcess".')
    public static void startFulfillmentProcess(List<String> orderSummaryIds) {
        List<String> orderSummIds = new List<String>();
        orderSummIds = orderSummaryIds;
        Id batchJobId = Database.executeBatch(new SOM_Batch_StartFulfillmentProcess(orderSummIds), 1);
    }
}