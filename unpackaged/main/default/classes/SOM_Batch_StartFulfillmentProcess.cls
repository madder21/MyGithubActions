global class SOM_Batch_StartFulfillmentProcess implements Database.Batchable<Sobject>, Database.Stateful {

    List<String> orderSummIds = new List<String>();

    public SOM_Batch_StartFulfillmentProcess(List<String> orderSummaryIds) {
        orderSummIds = orderSummaryIds;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id FROM OrderSummary WHERE Id IN :orderSummIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<OrderSummary> orderSummaries){
        for(OrderSummary ordSumm : orderSummaries){
            Map<String, Object> params = new Map<String, Object>();
            params.put('OrderSummaryID',ordSumm.Id);
            if(!Test.isrunningtest()) {
                Flow.Interview.SOM_203_Invokable_FO_Orchestration OrchestrationFlow = new Flow.Interview.SOM_203_Invokable_FO_Orchestration (params);
                OrchestrationFlow.start();
            }
        }
    }

    global void finish(Database.BatchableContext BC){}
}