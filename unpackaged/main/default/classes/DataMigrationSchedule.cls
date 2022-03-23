global class DataMigrationSchedule implements Schedulable {
    
   global void execute(SchedulableContext sc) {
       
       
       
       CronTrigger job = [SELECT Id, CronJobDetail.Name, PreviousFireTime,StartTime, CreatedDate 
                          FROM CronTrigger 
                          WHERE Id=:sc.getTriggerID()];
       
      
       // regular run 
       if(job.PreviousFireTime!=null){
           DataMigrationBatch batch = new DataMigrationBatch(false,job.PreviousFireTime,null);
           Database.executeBatch(batch);
           
       }else{
           
           DataMigrationBatch batch = new DataMigrationBatch(true,null,null);
           Database.executeBatch(batch);
       }
       
      
       
      
       

      
   }
}