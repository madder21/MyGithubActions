/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This interface represents a class that manages all the events triggered on an account
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12042023			|.UMNN		|.					|.
*/
public interface ITriggerHandler {
    
	void BeforeInsert(SObject[] newItems);
    
  	void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    
  	void BeforeDelete(Map<Id, SObject> oldItems);
    
  	void AfterInsert(Map<Id, SObject> newItems);
    
    void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems);
    
    void AfterDelete(Map<Id, SObject> oldItems);
    
    void AfterUndelete(Map<Id, SObject> oldItems);
    
    Boolean IsDisabled();
}