/**
 * @author Samodi
 * @date 17/03/2025
 * @Type Apex Class 
 *****************************************************************************************************************************************************************
 * @description This trigger is fired for any event on the Case
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|17032025			|.Asamodi		|.					|.
*/

public with sharing class CaseTriggerHandler implements ITriggerHandler {
	/* 
  	Allows unit tests (or other code) to disable this trigger for the transaction
  	To stop this trigger from firing while in a unit test, I could just add the following code to the test:
  	CaseTriggerHandler.TriggerDisabled = true;
  	*/
  	public static Boolean TriggerDisabled = false;

  	/*
  	Checks to see if the trigger has been disabled. For example, you could check a custom setting here.
  	In this example, a static property is used to disable the trigger.
  	In a unit test, you could use CaseTriggerHandler.TriggerDisabled = true to completely disable the trigger.
  	*/
  	public Boolean IsDisabled() {
        /*Use the option below if you set up Custom Settings to controll Triggers*/
        BypassTrigger__c bypassOrgDef = BypassTrigger__c.getOrgDefaults();
        BypassTrigger__c bypassUser = BypassTrigger__c.getInstance(UserInfo.getUserId());
        /*if(bypassOrgDef.Case__c == true || bypassUser.Case__c == true) {
            TriggerDisabled = true;
        }*/
        return TriggerDisabled;
  	}
    
    public void AfterInsert(Map<Id, SObject> newItems) {}

    public void BeforeInsert(List<SObject> newItems) {

            CaseServices.formulaEval((List<Case>) newItems, true);
    }

    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {

            CaseServices.formulaEval(newItems.values(), false);
    }

    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
  	public void BeforeDelete(Map<Id, SObject> oldItems) {}

  	public void AfterDelete(Map<Id, SObject> oldItems) {}

  	public void AfterUndelete(Map<Id, SObject> oldItems) {}
}