/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This trigger is fired for any event on the account
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12042023			|.UMNN		|.					|.
*/
trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.run(new AccountTriggerHandler(), Trigger.operationType);
}