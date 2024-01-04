/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this batch aims to delete all the accounts with no firstname, no lastname and no consent captured
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
 * 0.1		|20122023			|.PLM		|.CI-233			|.Add the exclusion of CSC Integration User
*/
public with sharing class BatchDeleteUncategorizedContact implements Database.Batchable<sObject>, Database.Stateful {
    
    
    public BatchDeleteUncategorizedContact() {
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        string dateQuery = 'LAST_N_WEEKS:2';
        if(Test.isRunningTest()){
            dateQuery = 'TODAY';
        }
        String query =  'SELECT Id, FirstName, LastName, LastModifiedDate, OptinEmailing__pc '
            +'FROM Account WHERE OptinEmailing__pc = false '
            +'AND FirstName = \'no firstname\' AND LastName = \'no lastname\' '
            +'AND LastModifiedDate <= '+ dateQuery +' AND CreatedBy.Name != \'' +  Label.SFSC_Integration_User + '\' ORDER BY LastModifiedDate DESC';
        
        return Database.getQueryLocator(query);
    }
    
	/*
    * @description hard delete all the account records with no firstname, no lastname and no consent captured 
    *
    * @param bc batchContext
    * @param accountToDelete list of account records to be deleted
    */
    public void execute(Database.BatchableContext bc, List<Account> accountToDelete){
        //Delete accounts 
        if (!accountToDelete.isEmpty()) {
            delete accountToDelete;
            Database.emptyRecycleBin(accountToDelete);
        }  
    }

    public void finish(Database.BatchableContext bc){
        /*
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
		*/
    }
    
}