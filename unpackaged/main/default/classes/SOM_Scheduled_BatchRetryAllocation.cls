public with sharing class SOM_Scheduled_BatchRetryAllocation implements Schedulable {

        public void execute(SchedulableContext sc){
        SOM_Batch_RetryAllocation batch = new SOM_Batch_RetryAllocation();
        database.executebatch(batch,200); 
        
    }

}