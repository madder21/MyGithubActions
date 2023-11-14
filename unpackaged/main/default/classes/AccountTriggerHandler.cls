/**
 * @author: Ulrich M. NDONG NGOMO
 * @description: This class is used to manage consent action needs to be done when an account is created/updated
 * @Created Date: 4/12/2023
 * @LastModifiedDate: 4/12/2023
 * @LastModifiedDate: 9/22/2023 : P.L.M : Before insert and before update trigger modified for SMFC Sync
 * @LastModifiedDate: 02/10/23 : E.B : modification to avoid runtime test error when deploying
 * @LastModifiedDate : 10/10/2023 : U.N.N : Modification for CDP Integration + China customers
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
    
    public Boolean isDisabledForB2CConnector(){
        return BypassTrigger.checkBypassClass(AccountTriggerHandler.class.getName());
    }

  	public void BeforeInsert(List<SObject> newItems) {
        //#CI-202 :22/09/2023: Update the SFMC Synchronisation field for flag a record to be sync in SFMC
        AP3_SFMCSynchronisation.manageSynchronisations((List<Account>)newItems);
    }

  	public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
    	TNP_001_AccountTrigger_SVE.preventClientInfoDeletion(newItems.values(), oldItems);
        //#CI-202 :22/09/2023: Update the SFMC Synchronisation field for flag a record to be sync in SFMC
         AP3_SFMCSynchronisation.manageSynchronisations((List<Account>)newItems.Values());
    }
    
  	public void BeforeDelete(Map<Id, SObject> oldItems) {}

  	public void AfterInsert(Map<Id, SObject> newItems) {
    	System.debug('**** TRIGGER CONTEXT : START AFTER INSERT ****');
        TNP_001_AccountWrapper wrapper = TNP_001_AccountTrigger_SVE.manageAccountEvent(newItems.values());
        System.debug('** wrapper: '+wrapper);
        //TNP_001_AccountTrigger_SVE.createNotificationContent(wrapper.cdpAccountList);
        TNP_001_AccountTrigger_SVE.listAccountAfterInsert(wrapper.otherAccountList);
        TNP_001_AccountTrigger_SVE.manageClientSource(newItems.values());//2023-11-03 by Ulrich
        if(!isDisabledForB2CConnector()) {
            AccountConsent_SVE.createB2CCustomInputForRetail(newItems, new Map<Id, SObject>());
        }
        System.debug('**** TRIGGER CONTEXT : END AFTER INSERT ****'); 
    }

  	public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        System.debug('**** TRIGGER CONTEXT : START AFTER UPDATE ****');
        // Eric-02/10/23 : modification to avoid runtime test error when deploying
        Map<Id,Account> mapOldAccounts = new Map<Id,Account>();
        for (Id idKey : oldItems.keySet()) {
            mapOldAccounts.put(idKey,(Account)oldItems.get(idKey));
        }
        //End Eric
        
        //TNP_001_AccountWrapper wrapper = TNP_001_AccountTrigger_SVE.manageAccountEvent(newItems.values());
        TNP_001_AccountTrigger_SVE.listAccountAfterUpdate(newItems.values(),mapOldAccounts);
        if(!isDisabledForB2CConnector()) {
            AccountConsent_SVE.createB2CCustomInputForRetail(newItems, oldItems);
        }
        System.debug('**** TRIGGER CONTEXT : END AFTER UPDATE ****');
    }

  	public void AfterDelete(Map<Id, SObject> oldItems) {}

  	public void AfterUndelete(Map<Id, SObject> oldItems) {}
}