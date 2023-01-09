global class DataMigrationBatch implements Database.Batchable<sObject> {
    
    Private Boolean isFirstRun;
    Private DateTime lastBatchExecutionDateTime;
    
    public DataMigrationBatch(Boolean isFirstRun, DateTime lastBatchExecutionDateTime){
        this.isFirstRun = isFirstRun;
        this.lastBatchExecutionDateTime = lastBatchExecutionDateTime;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(DataMigrationHelper.buildDataMigrationBatchQuery(isFirstRun, lastBatchExecutionDateTime));
        
    }
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        //DataMigrationHelper.migrateConsents(accountList);
        ConsentManagementHelper.migrateConsentGlobalMethod(accountList,null,true);
    }    
    global void finish(Database.BatchableContext bc){
    }    
}