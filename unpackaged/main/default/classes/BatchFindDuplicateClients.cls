/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this batch aims to identify any duplicate contacts and accounts and update their "lastModifiedDate" fields.
 * 				As a result, RCU will be triggered to merge those duplicates
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/
public with sharing class BatchFindDuplicateClients implements Database.Batchable<sObject>, Database.Stateful {
    
	/*
    * @description get the most recent account or contact among the duplicated ones
    *
    * @param duplicateRecordList list of DuplicateRecordItem records that contains a duplicate contact or account
    * @return Map of DuplicateRecordItem with DuplicateRecordSetId as key
    */
    public Map<Id,DuplicateRecordItem> getTheRecentDuplicates(List<DuplicateRecordItem> duplicateRecordList) {
		
        Id key; 
        Map<Id,DuplicateRecordItem> duplicateRecordMap = new Map<Id,DuplicateRecordItem>();
     
        for (DuplicateRecordItem record : duplicateRecordList) {
            key = record.DuplicateRecordSetId;
            //Record already exists
            if (duplicateRecordMap.containsKey(key) &&
                //Get the recent record
                record.DuplicateRecordSet.LastModifiedDate > duplicateRecordMap.get(key)?.DuplicateRecordSet.LastModifiedDate) {
                    duplicateRecordMap.put(key, record);
            } else { //No records already exist
                duplicateRecordMap.put(key, record);
            } 
        }
        return duplicateRecordMap;
    }
	
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT DuplicateRecordSetId, Record.id, DuplicateRecordSet.LastModifiedDate'
            + ' FROM DuplicateRecordItem WHERE DuplicateRecordSet.DuplicateRuleId != null'
        );
    }
	
    /*
    * @description  update the field B2C_Date_Last_Modified on account or contact with duplicate records
    *
    * @param bc batchContext
    * @param duplicateRecordList contains all duplicate records to be updated
    */
    public void execute(Database.BatchableContext bc, List<DuplicateRecordItem> duplicateRecordList){
        
        Map<Id, DuplicateRecordItem> duplicateRecord = getTheRecentDuplicates(duplicateRecordList);
        List<Contact> conListToBeUpdated  = new List<Contact> ();
        List<Account> accountListToUpdate  = new List<Account> ();

        Id recordId;
        List <Id> recordIds = new List <Id>();
        for (DuplicateRecordItem item : duplicateRecord.values()) {
            recordId = item.Record.id;
            //CONTACT
            if (String.valueOf(recordId).startswith('003') && !recordIds.contains(recordId)) {
                Contact record = new Contact();
                record.id = item.Record.id;
                record.B2C_Date_Last_Modified__c = Date.today();
                // add contact to list to be updated
                conListToBeUpdated.add((Contact)record);
                recordIds.add(recordId);
            }//ACCOUNT
            else if (String.valueOf(recordId).startswith('001') && !recordIds.contains(recordId)) {
                Account record = new Account();
                record.id = item.Record.id;
                record.B2C_Date_Last_Modified__pc = Date.today();
                // add account to list to be updated
                accountListToUpdate.add(record);
                recordIds.add(recordId);
            }
        }
        if(!conListToBeUpdated.isEmpty())update conListToBeUpdated;
        if(!accountListToUpdate.isEmpty())update accountListToUpdate;
        
    }

    public void finish(Database.BatchableContext bc){
        /*
         * AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];*/
    }
    
}