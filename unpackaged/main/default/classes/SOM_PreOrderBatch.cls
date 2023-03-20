global with sharing class SOM_PreOrderBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {             
        String query = 'SELECT id,OrderSummaryId,IsPreOrder__c,DeliveryStartDate__c,CreatedDate FROM OrderItemSummary  WHERE IsPreOrder__c =true AND DeliveryStartDate__c <=Today AND Status =\'ORDERED\'';
        return Database.getQueryLocator(query);
    }
         
    global void execute(Database.BatchableContext BC, List<OrderItemSummary> OiList) {
        try {
            Map<String,List<OrderItemSummary>> OiMap = new Map<String, List<OrderItemSummary>>();
            OiMap.put('NewOrderProductSum',OiList);
            Flow.Interview.SOM_250_FulfillmentOrderBatchHelper_FO_On_PreOrder flow1 = new 			    Flow.Interview.SOM_250_FulfillmentOrderBatchHelper_FO_On_PreOrder(OiMap);
            flow1.start();
             
        } catch(Exception e) {
            System.debug(e);
        }
             
    }   
         
    global void finish(Database.BatchableContext BC) {
        System.debug('**********SOM_PreOrderBatch FINISHED**********');
    }

}