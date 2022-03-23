global class DataMigrationBatch implements Database.Batchable<sObject> {
    
    Private Boolean isFirstRun;
    Private DateTime lastBatchExecutionDateTime;
    Private DateTime maxDate;
    
    public DataMigrationBatch(Boolean isFirstRun, DateTime lastBatchExecutionDateTime, DateTime maxDate){
        this.isFirstRun = isFirstRun;
        this.lastBatchExecutionDateTime = lastBatchExecutionDateTime;
        this.maxDate = maxDate;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(DataMigrationHelper.buildDataMigrationBatchQuery(isFirstRun, lastBatchExecutionDateTime,maxDate));
    }
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        DataMigrationHelper.migrateConsents(accountList);
    }    
    global void finish(Database.BatchableContext bc){
    }    
}