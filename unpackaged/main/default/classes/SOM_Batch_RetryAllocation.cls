global class SOM_Batch_RetryAllocation implements Database.Batchable<sObject>, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id FROM OrderSummary WHERE tech_PE_Fulfillment_Count__c > 0 AND On_Hold__c = false Order by CreatedDate desc';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<OrderSummary> scope){
        SOM_GetAvailability_BatchSubClass sub = new SOM_GetAvailability_BatchSubClass(scope);
    } 

    global void finish(Database.BatchableContext BC){

    }
}