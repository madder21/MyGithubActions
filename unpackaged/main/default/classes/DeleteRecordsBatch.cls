global class DeleteRecordsBatch implements Database.Batchable<sObject> {
    
    Map<Integer, String> objMap;
    
    String query;
    String objectName;
    Integer i;
    
    
    public DeleteRecordsBatch(String objName) {
        i = 0;
        objectName = objName;
        System.debug('objectName ' + objectName);
       
        query = 'SELECT Id FROM ' + objectName;
    }
    
    public DeleteRecordsBatch(Integer objNum) {
        i = objNum;
        
        objMap = new Map<Integer, String> ();
       /* objMap.put(1,'Task');
        objMap.put(2, 'Event');
        objMap.put(3, 'ClientAddress__c');
        objMap.put(4, 'ClientSource__c');
        objMap.put(5, 'due__Diduenjoy_Answer__c');
        objMap.put(6, 'due__Diduenjoy_Feedback__c');
        objMap.put(7, 'Case');
        objMap.put(8, 'TransactionPayment__c');
        objMap.put(9, 'TransactionItem__c');
        objMap.put(10, 'Transaction__c');
        objMap.put(11, 'ClientProduct__c');
        objMap.put(12, 'Note__c');
        objMap.put(13, 'Contact');
        objMap.put(14, 'Account');
        objMap.put(15, 'Product2');*/
        objMap.put(1,'Task');
        objMap.put(2, 'due__Diduenjoy_Answer__c');
        objMap.put(3, 'due__Diduenjoy_Feedback__c');
        objMap.put(4, 'Note__c');

        objectName = objMap.get(i);
        
        System.debug('objectName ' + objectName);
        
        query = 'SELECT Id FROM ' + objectName;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Database.delete(scope, false);
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug(objectName + ' deleted!!!!!');
       // if(i > 0 && i < 15) {
        if(i > 0 && i < 4) {
            i++;
            DeleteRecordsBatch b = new DeleteRecordsBatch(i);
			Database.executeBatch(b,2000);
        }

    }
}