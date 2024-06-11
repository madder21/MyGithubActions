public class SFAnonymizationProcessJob implements Queueable {
    
    private List<sObject> objList;
    
    public SFAnonymizationProcessJob(List<sObject> objList) {
        this.objList = objList;
    }
    
    public void execute(QueueableContext context) {
		update this.objList;
    }
}