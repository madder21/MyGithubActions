global class DataMigrationSchedule implements Schedulable {
    
   global void execute(SchedulableContext sc) {
       
       
       
       CronTrigger job = [SELECT Id, CronJobDetail.Name, PreviousFireTime,StartTime, CreatedDate 
                          FROM CronTrigger 
                          WHERE Id=:sc.getTriggerID()];
       
      
       // regular run 
       if(job.PreviousFireTime!=null){
           DataMigrationBatch batch = new DataMigrationBatch(false,job.PreviousFireTime);
           Database.executeBatch(batch);
           
       }else{
           
           DataMigrationBatch batch = new DataMigrationBatch(true,null);
           Database.executeBatch(batch);
       }
       
      
       
      
       

      
   }
}