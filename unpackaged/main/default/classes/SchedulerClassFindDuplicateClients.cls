/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class handles the scheduling of the BatchFindDuplicateClients batch
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/
public class SchedulerClassFindDuplicateClients implements Schedulable {
    public void execute(SchedulableContext context) {
        BatchFindDuplicateClients batchClass = new BatchFindDuplicateClients();
        Database.executeBatch(batchClass, 200); // You can adjust the batch size as per your requirement
    }
}