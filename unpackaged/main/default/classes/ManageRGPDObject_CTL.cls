public class ManageRGPDObject_CTL implements Queueable{
    
    private List<sObject> objList;
    
    public ManageRGPDObject_CTL(List<sObject> objList) {
        this.objList = objList;
    }
    
    public void execute(QueueableContext context) {
        delete this.objList;
    }

}