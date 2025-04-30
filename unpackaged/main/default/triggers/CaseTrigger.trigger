/**
 * @author Samodi
 * @date 17/03/2025
 * @Type Apex Trigger
 *****************************************************************************************************************************************************************
 * @description This trigger is fired for any event on the Case
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|17032025			|.Asamodi		|.					|.
*/
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.run(new CaseTriggerHandler(), Trigger.operationType);
}