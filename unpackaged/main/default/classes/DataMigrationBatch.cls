/**
 * @description       : CatchUp of Consent
 * @author            : ?
 * @group             : 
 * @last modified on  : 20-02-2023
 * @last modified by  : Paul Louis MONY
 * @last modification : OverLoad the Constructor and class to allow Custom Query + API VERSION Upgrade to 57
 * 
**/
global class DataMigrationBatch implements Database.Batchable<sObject>{
    
    Private Boolean isFirstRun;
    Private DateTime lastBatchExecutionDateTime;
    Private String dataMigrationQuery;
    //Constructor for first Run and scheduler
    public DataMigrationBatch(Boolean isFirstRun, DateTime lastBatchExecutionDateTime){
        this.isFirstRun = isFirstRun;
        this.lastBatchExecutionDateTime = lastBatchExecutionDateTime;
        dataMigrationQuery = DataMigrationHelper.buildDataMigrationBatchQuery(isFirstRun, lastBatchExecutionDateTime);
        System.debug(dataMigrationQuery);
    }
    //Constructor for Custom Query
    public DataMigrationBatch(String query){
        dataMigrationQuery = query; 
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(dataMigrationQuery);
        
    }
    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        //EBU 2023July24th  -  Retro compatibility ONLY for deploy
        //ConsentManagementHelper.migrateConsentGlobalMethod(accountList,null,true);
    }    
    global void finish(Database.BatchableContext bc){
    }    
}