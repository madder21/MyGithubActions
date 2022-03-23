global class LogCleanBatch implements Database.Batchable<sObject>{
    
    global database.querylocator start(Database.BatchableContext CD){ 
        string strQuery = 'select immediate_log__C,Is_LogActive__c,LogHistoryDays__c from Clienteling_App_Setting__mdt limit 1';
        list<sObject> sObjects = database.query(strQuery);
        sObject settings = sObjects.size() > 0 ? sObjects[0] : null;
        Integer defaultValueDays = 7;
        Integer days = (settings == null) ? defaultValueDays :  Integer.valueOf(settings.get('LogHistoryDays__c'));
        days = 0 - days;
        string Date2Removefrom = DateTime.Now().addDays(days).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
        string query  = 'select id, Has_Error__c from Log__c where createdDate < ' + Date2Removefrom;
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, list<Log__c> logRecords){
       delete logRecords;
    }
    
    global void finish(Database.BatchableContext CD){}

}