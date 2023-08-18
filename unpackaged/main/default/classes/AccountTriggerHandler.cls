/**
 * @author: Ulrich M. NDONG NGOMO
 * @description: This class is used to manage consent action needs to be done when an account is created/updated
 * @Created Date: 4/12/2023
 * @LastModifiedDate: 4/12/2023
 * 
 */
public class AccountTriggerHandler implements ITriggerHandler {
	/* 
  	Allows unit tests (or other code) to disable this trigger for the transaction
  	To stop this trigger from firing while in a unit test, I could just add the following code to the test:
  	AccountTriggerHandler.TriggerDisabled = true;
  	*/
  	public static Boolean TriggerDisabled = false;

  	/*
  	Checks to see if the trigger has been disabled. For example, you could check a custom setting here.
  	In this example, a static property is used to disable the trigger.
  	In a unit test, you could use AccountTriggerHandler.TriggerDisabled = true to completely disable the trigger.
  	*/
  	public Boolean IsDisabled() {
        /*Use the option below if you set up Custom Settings to controll Triggers*/
        //return TriggerSettings__c.AccountTriggerDisabled__c ?true : TriggerDisabled;
        return TriggerDisabled;
  	}

  	public void BeforeInsert(List<SObject> newItems) {
    }

  	public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
  	public void BeforeDelete(Map<Id, SObject> oldItems) {}

  	public void AfterInsert(Map<Id, SObject> newItems) {
            System.debug('**** TRIGGER CONTEXT : START AFTER INSERT ****');
            TNP_001_AccountTrigger_SVE.listAccountAfterInsert(newItems.values());
            System.debug('**** TRIGGER CONTEXT : END AFTER INSERT ****'); 
    }

  	public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug('**** TRIGGER CONTEXT : START AFTER UPDATE ****');
        TNP_001_AccountTrigger_SVE.listAccountAfterUpdate(newItems.values(),(Map<Id, Account>)oldItems);
        System.debug('**** TRIGGER CONTEXT : END AFTER UPDATE ****');
    }

  	public void AfterDelete(Map<Id, SObject> oldItems) {}

  	public void AfterUndelete(Map<Id, SObject> oldItems) {}
}