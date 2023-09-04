/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This trigger is fired for any event on the B2CCustomInput__c
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12042023			|.UMNN		|.					|.
*/
trigger B2CCustomInputTrigger on B2CCustomInput__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	TriggerDispatcher.run(new B2CCustomInputTriggerHandler(), Trigger.operationType);
}