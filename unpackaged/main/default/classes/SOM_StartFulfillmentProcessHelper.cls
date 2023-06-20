public class SOM_StartFulfillmentProcessHelper {
    public static void startFulfillmentProcess( List<Start_Fulfillment_Process__e> FulfillmentEventList) {
        for ( Start_Fulfillment_Process__e FulfillmentEvent : FulfillmentEventList){
            if(!Test.isrunningtest()) {
                Map<String, Object> params = new Map<String, Object>();
                params.put('OrderSummaryID',FulfillmentEvent.OrderSummaryID__c);
                Flow.Interview.SOM_203_Invokable_FO_Orchestration OrchestrationFlow = new Flow.Interview.SOM_203_Invokable_FO_Orchestration (params);
                OrchestrationFlow.start();
            }
        }
    }
}