global class Batch_HandleAsyncRequests implements Database.Batchable<sObject> {

    // instance member to retain state across transactions
    private Integer recordsProcessed = 0;
    //private Map<String,String> mStatusOnScope;
    private String query;
  
  	global Batch_HandleAsyncRequests (String soql){
    	query = soql;
        //mStatusOnScope = new List<String,String> ();
  	}
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('Batch_HandleAsyncRequests - start : ' + query);
    	return Database.getQuerylocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Async_Job_Request__c> scope){
        System.debug('Batch_HandleAsyncRequests - execute : ' + scope);
        // process each batch of records
        //Map<Id,Async_Job_Request__c> mapAsyncRequestForDeduplication = new Map<Id,Async_Job_Request__c> (scope);
        //List<Account> lstAccountFromTheTriggerScope = new List<Account> ();
        
        //Update asyncRequestJob records to be sent in "InProgress" status
        AsyncRequestHandler.UpdateStatusOfAsyncRequest(scope, AsyncRequestHandler.EnumStatus.InProgress);
        
        //Build a set of distinct Accounts records concerned by the DQE mechanism
        Set<Id> setIDfromScope = new Set<Id> ();        
        for (Async_Job_Request__c asyncCurrentItem : scope) {
            setIDfromScope.add(asyncCurrentItem.RecordId__c);
        }
        system.debug('Debuginfo : list Id : '+setIDfromScope);
        
        //retrieve all accounts from this distinct list (issued from the input scope)
        List<Account> lstAccountFromTheTriggerScope = TNP001_DM_Account.getAccountsByIdList(convertSetIdToListId(setIDfromScope));     
        system.debug('Debuginfo : list Accounts : '+ lstAccountFromTheTriggerScope);
        
    	recordsProcessed = lstAccountFromTheTriggerScope?.size();
        system.debug('Debuginfo : Nb Accounts : '+recordsProcessed);
            
        /*Old code
         *          
         * Map<String,Account> mapDistinctAccount = new Map<String,Account> ();
         * List<Account> lstAccountsSubmittedForAsyncRequest = new List<Account> ();
           
        //Create a map with distinct last version of modified accounts
        for (Async_Job_Request__c asyncCurrentItem : scope) {
        	Account accountCurrent = (Account)JSON.deserialize(asyncCurrentItem.SerializedObject__c, Account.class);
            
            // If the current Map does not contain the current Account Id, the add it to the list and increment the counter
            if(!mapDistinctAccount.containsKey(asyncCurrentItem.RecordId__c)) {
                lstAccountsSubmittedForAsyncRequest.add(accountCurrent);
                // increment the instance member counter
                recordsProcessed ++;
            }
            
            //update the map with the most recent version of each "already present" record
            mapDistinctAccount.put(asyncCurrentItem.RecordId__c, accountCurrent);            
        }
		*
		*/
        
        //Enqueue accounts to call to MuleSoft
        System.debug('Batch_HandleAsyncRequests - Execute - Nb of records to process :' + recordsProcessed + ' records processed !');
        System.debug('Batch_HandleAsyncRequests - Execute - List of records to process :' + lstAccountFromTheTriggerScope);
        
        //ID jobID = System.enqueueJob(new TNP_001_QueueableCallOut(lstAccountsSubmittedForAsyncRequest,'',Label.TNP_CL_AfterUpdate));
        
        //enqueue the job only if there are accounts to be handled
        if (recordsProcessed>0){ 
            ID jobID = System.enqueueJob(new TNP_001_QueueableCallOut(lstAccountFromTheTriggerScope,'',Label.TNP_CL_AfterUpdate));
                   
            //update asyncRequestJob records to be sent in "InProgress" status
            AsyncRequestHandler.UpdateAsyncRequestWithJobid(scope, jobID);
        }
    }
    
    /*
    public void execute(Database.BatchableContext bc, List<Async_Job_Request__c> scope){
        // process each batch of records
        //Map<Id,Async_Job_Request__c> mapAsyncRequestForDeduplication = new Map<Id,Async_Job_Request__c> (scope);
        Map<String,Account> mapDistinctAccount = new Map<String,Account> ();
        List<Account> lstAccountsSubmittedForAsyncRequest = new List<Account> ();
        
        //update asyncRequestJob records to be sent in "InProgress" status
        AsyncRequestHandler.UpdateStatusOfAsyncRequest(scope, AsyncRequestHandler.EnumStatus.InProgress);
        
        //Create a map with distinct last version of modified accounts
        for (Async_Job_Request__c asyncCurrentItem : scope) {
        	Account accountCurrent = (Account)JSON.deserialize(asyncCurrentItem.SerializedObject__c, Account.class);
            
            // If the current Map does not contain the current Account Id, the add it to the list and increment the counter
            if(!mapDistinctAccount.containsKey(asyncCurrentItem.RecordId__c)) {
                lstAccountsSubmittedForAsyncRequest.add(accountCurrent);
                // increment the instance member counter
                recordsProcessed ++;
            }
            
            //update the map with the most recent version of each "already present" record
            mapDistinctAccount.put(asyncCurrentItem.RecordId__c, accountCurrent);            
        }
                        
        //Enqueue accounts to call to MuleSoft
        ID jobID = System.enqueueJob(new TNP_001_QueueableCallOut(lstAccountsSubmittedForAsyncRequest,'',Label.TNP_CL_AfterUpdate));
        System.debug('Batch_HandleAsyncRequests - Execute - Nb of records processed :' + recordsProcessed + ' records processed !');
        
        //update asyncRequestJob records to be sent in "InProgress" status
        AsyncRequestHandler.UpdateAsyncRequestWithJobid(scope, jobID);
    }*/

    global void finish(Database.BatchableContext bc){
        System.debug('Batch_HandleAsyncRequests - Finish - Nb of records processed :' + recordsProcessed + ' records processed !');
        
        // call some utility to send email
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug('Batch_HandleAsyncRequests - Finish - Async Job Status ------->:' + job.Status);
        System.debug('Batch_HandleAsyncRequests - Finish - Async Job information -->:' + job);
    }	
    
    public static List<Id> convertSetIdToListId (Set<Id> setID) {
        return (List<Id>)JSON.deserialize(JSON.serialize(setID), List<Id>.class);
    }
}