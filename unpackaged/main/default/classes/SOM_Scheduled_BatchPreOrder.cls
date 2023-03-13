public with sharing class SOM_Scheduled_BatchPreOrder implements Schedulable {

    public void execute(SchedulableContext sc)
    {
        SOM_PreOrderBatch batch = new SOM_PreOrderBatch();
        database.executebatch(batch,200); 
    }

}