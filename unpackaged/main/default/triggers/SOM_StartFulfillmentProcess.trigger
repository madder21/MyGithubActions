trigger SOM_StartFulfillmentProcess on Start_Fulfillment_Process__e (after insert) {

for ( Start_Fulfillment_Process__e FulfillmentEvent : trigger.new){
if(!Test.isrunningtest()) {

Map<String, Object> params = new Map<String, Object>();
params.put('OrderSummaryID',FulfillmentEvent.OrderSummaryID__c);
Flow.Interview.SOM_203_Invokable_FO_Orchestration OrchestrationFlow = new Flow.Interview.SOM_203_Invokable_FO_Orchestration (params);
OrchestrationFlow.start();
}
}}