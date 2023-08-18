/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is used in order to handle context on the B2CCustomInputTrigger trigger
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12062023			|.UMNN		|.					|.
*/
public without sharing class B2CCustomInputTriggerHandler implements ITriggerHandler {

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
            /**
             * Use the option below if you set up Custom Settings to controll Triggers
             */
            //Récupération du Bypass de l'Org (default) et le bypass du User
            TriggerSettings__c bypassOrgDef = TriggerSettings__c.getOrgDefaults();
            TriggerSettings__c bypassUser = TriggerSettings__c.getInstance(UserInfo.getUserId());
            
            system.debug('*** bypassUser object ' + bypassUser);
            system.debug('*** bypassUser object B2CCustomInput ' + bypassUser.B2CCustomInput__c);
            system.debug('*** bypassOrgDef object ' + bypassOrgDef);
            system.debug('*** bypassOrgDef object B2CCustomInput ' + bypassOrgDef.B2CCustomInput__c);

            if(bypassOrgDef.B2CCustomInput__c == true || bypassUser.B2CCustomInput__c == true) {
                  TriggerDisabled = true;
            }
            return TriggerDisabled;
  	}

  	public void BeforeInsert(List<SObject> newItems) {}

  	public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    
  	public void BeforeDelete(Map<Id, SObject> oldItems) {}

  	public void AfterInsert(Map<Id, SObject> newItems) {
            System.debug('**** TRIGGER CONTEXT : B2CCustomInputTriggerHandler START AFTER INSERT ****');
            B2CCustomInput_SVE.buildAccountIndividualByCustomInput(newItems.values());
            B2CCustomInput_SVE.redirectLogic(newItems.values());
            System.debug('**** TRIGGER CONTEXT : B2CCustomInputTriggerHandler END AFTER INSERT ****'); 
      }

  	public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
            System.debug('**** TRIGGER CONTEXT : START AFTER UPDATE ****');
            //AccountConsent_SVE.updateContactPointPhoneRecords(newItems.values(), (Map<Id, Account>)oldItems);
            System.debug('**** TRIGGER CONTEXT : END AFTER UPDATE ****');
      }

  	public void AfterDelete(Map<Id, SObject> oldItems) {}

  	public void AfterUndelete(Map<Id, SObject> oldItems) {}
}