public class AsyncRequestHandler {
    
    public enum EnumStatus {NewLog, InProgress, OK, KO}
	public enum EnumObjectType {Account, Undefined}
	
    public static void RecordAsyncRequest (string sContextInfo, string sObjectType, sObject sRecord) {
        Async_Job_Request__c asyncRequest = new Async_Job_Request__c( RecordId__c = sRecord.Id,
                                                                      Status__c = EnumStatus.NewLog.name(),
                                                                      TriggeringObject__c = sObjectType,
                                                                      ContextInformation__c = sContextInfo,
                                                                      SerializedObject__c = JSON.serialize(sRecord)
                                                                    );
        
        Insert asyncRequest;
    }
    
    public static void RecordMultipleAsyncRequest (string sContextInfo, string sObjectType, List<sObject> sRecords) {
        List <Async_Job_Request__c> lstAsyncRequests = new List<Async_Job_Request__c> ();
     
        for (sObject sCurrentObject : sRecords ) {
            Async_Job_Request__c asyncRequestLoopItem = new Async_Job_Request__c( RecordId__c = sCurrentObject.Id,
                                                                                  Status__c = EnumStatus.NewLog.name(),
                                                                                  TriggeringObject__c = sObjectType,
                                                                                  ContextInformation__c = sContextInfo,
                                                                                  SerializedObject__c = JSON.serialize(sCurrentObject)
                                                                                );
            lstAsyncRequests.add(asyncRequestLoopItem);            
        }        
      	Insert lstAsyncRequests;
    }
        
	public static void UpdateStatusOfAsyncRequest (List<Async_Job_Request__c> sRequest, EnumStatus enumStatusNewValue) {
        For (Async_Job_Request__c asjCurrent : sRequest) {
            asjCurrent.Status__c = EnumStatus.InProgress.name();
        }
        update sRequest;
    }
    
    public static void UpdateAsyncRequestWithJobid (List<Async_Job_Request__c> sRequest, ID jobID) {
        For (Async_Job_Request__c asjCurrent : sRequest) {
            asjCurrent.RunningJobId__c = jobID;
        }
        update sRequest;
    }
}