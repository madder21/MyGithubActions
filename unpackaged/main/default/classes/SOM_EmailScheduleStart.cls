public class SOM_EmailScheduleStart implements Schedulable{
    public void execute(SchedulableContext ctx) {
        System.schedule('Scheduled Job', '0 0 0,3,6,9,12,15 ? * MON-FRI', new SOM_AutomatedEmailWithProcessEXBatch() );  
    }
}