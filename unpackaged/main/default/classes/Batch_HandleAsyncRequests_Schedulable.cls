global class Batch_HandleAsyncRequests_Schedulable implements Schedulable {
    
	global void execute(SchedulableContext sc) {
       
    	String soql = 	'SELECT Id, Name, TriggeringObject__c, RecordId__c, SerializedObject__c, Status__c, RunningJobId__c, ContextInformation__c, '+
            			'createddate, lastmodifieddate, SystemModstamp '+
            			'FROM Async_Job_Request__c '+
						'WHERE Status__c = \'NewLog\' '+
						'ORDER BY SystemModstamp ASC';
                         
		Batch_HandleAsyncRequests b = new Batch_HandleAsyncRequests(soql);
      	Database.executeBatch(b,200);
	}
}