global class LogCleanScheduler implements Schedulable{

    public Void execute(System.SchedulableContext context) {
        Database.executeBatch(new LogCleanBatch(),1000);
    }
   
}