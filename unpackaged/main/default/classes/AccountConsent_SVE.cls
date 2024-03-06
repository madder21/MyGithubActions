/**
 * @author Paul Louis MONY
 * @date 07-JUNE-2023
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is used to manage consent action needs to be done when an account is created/updated
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|07062023			|.PLM		|.					|.
 * 0.1		|01032024			|.PLM		|.CI-303			|.Creation of 2 new methods: rejectOptinWithoutEmail(List<Account>)  
 * 			|					|			|					|							 rejectOptinWithoutEmail((Map<Id,sObject> newAccounts, Map<Id,sObject> oldAccounts))
*/

public without sharing class AccountConsent_SVE {
    
    /*
    * @param newAccounts : New account from trigger.New
    * @param oldAccounts : Existing account from trigger.Update
    * @return void
    */
    
    public static void checkKPIFieldsValues(List<Account> newAccounts, Map<id, Account> oldAccounts) {
        
        for(Account acc: newAccounts) {
            Account oldAcc = oldAccounts.get(acc.Id);
            acc.ClientAdvisor__pc = (acc.ClientAdvisor__pc == null) ? oldAcc.ClientAdvisor__pc : null;
            acc.MainStore__pc = (acc.MainStore__pc == null) ? oldAcc.MainStore__pc : null; 
        } 
        System.debug('*** newAccounts ***: '+newAccounts);
    }
    
   
    
    
    /*
    * @description Create B2CCustomInput For Retail trouchpoints (DDC & CEGID)
    *
    * @param newAccounts : New account from trigger.New
    * @param oldAccounts : Existing account from trigger.Update
    * @return void
    */
    public static void createB2CCustomInputForRetail(Map<id, sObject> newAccounts, Map<id, sObject> oldAccounts) {
        System.debug('PLM TRACK : I m here createB2CCustomInputForRetail');
        Boolean isNew = oldAccounts?.isEmpty()? true : false;
        List<B2CCustomInput__c> customInputs= new List<B2CCustomInput__c> ();
        List<Account> accounts = new List<Account>();
		
        //if we are in Trigger context New : just take in consideration newAccounts Map, if we are in Update context check if there are changes in the Accounts 
        accounts = isNew? (List<Account>)newAccounts.Values() : filterOnUpdatedAccount(newAccounts, oldAccounts);        
        
        ConsentSource__mdt consentSource = ConsentSource__mdt.getInstance(System.Label.LABS_ConsentSourceName_Retail);
        
        if(consentSource!=null){
            for(Account acc : accounts){
                if((isNew && isThereAtLeastOneOptin(acc)) || !isNew){
                    customInputs.add(createB2CCustomInput(acc, consentSource));
                }
            }
            if (!customInputs.isEmpty()) {
                System.debug('PLM TRACK : Cust input to create : ' + customInputs);
               insert customInputs; 
            }
        }
    }
    
    
    /*
    * @description Create a B2CCustomInput record for a given account
    *
    * @param client is an account that is linked to the B2CCustomInput record
    * @param consentSource custom meta data contains data to create B2CCustomInput record from a specific source
    * @return B2CCustomInput record that was created
    */
    private static B2CCustomInput__c createB2CCustomInput(Account client, ConsentSource__mdt consentSource){
        B2CCustomInput__c customInput = new B2CCustomInput__c();
        if(consentSource!=null){
            customInput.AccountId__c = client.Id;
            customInput.CaptureContactPointType__c = consentSource.capturePointType__c;
            customInput.CaptureSource__c = consentSource.captureSource__c;
            customInput.CustomContactPointType__c = consentSource.TypeSource__c;
            customInput.EmailConsent__c = client.OptinEmailing__pc;
            customInput.OptinCGI__c = client.OptinCGI__c;
            customInput.OptinMessaging__c = client.OptinInstantMessaging__pc;
            customInput.OptinPhone__c = client.OptinCalling__pc;
            customInput.OptOutContactPointType__c = consentSource.OptoutPointType__c;
            
            if ((!client?.OptinEmailing__pc && client?.LastUpdateOptinEmailing__pc != null) || client?.OptinEmailing__pc) {
                customInput.SubscriptionName__c = consentSource.SubscriptionName__c;
            }            
            return customInput;
        }
        return null;
    }
    
    /*
    * @description This method compares old and new optin values, adding accounts to a list if any optin has changed
    *
    * @param newAccounts map of all new accounts
    * @param oldAccounts map of all old accounts
    * @return list of accounts which have at least one optin changed
    */
    private static List<Account> filterOnUpdatedAccount(Map<id, sObject> newAccounts, Map<id, sObject> oldAccounts){
         List<Account> accountUpdated = new  List<Account>();
        for (sObject obj : newAccounts.values()) {
            Account newAccount = (Account) obj;
            Account oldAccount = (Account) oldAccounts.get(newAccount.Id);
            if (
                (newAccount.OptinEmailing__pc != oldAccount.OptinEmailing__pc && 
                ((newAccount.OptinEmailing__pc && String.isNotBlank(newAccount.PersonEmail)) || !newAccount.OptinEmailing__pc))|| 
                newAccount.OptinMailing__pc != oldAccount.OptinMailing__pc   ||  
                newAccount.OptinCalling__pc != oldAccount.OptinCalling__pc   || 
                newAccount.OptinCGI__c != oldAccount.OptinCGI__c             ||  
                newAccount.OptinInstantMessaging__pc != oldAccount.OptinInstantMessaging__pc  || 
                newAccount.OptinMarketingPartner__c != oldAccount.OptinMarketingPartner__c
            	) {
               accountUpdated.add(newAccount);
            }
        }
        return accountUpdated;
    }
    
    /*
    * @description for an account given check if at least has one active optin
    *
    * @param client, is an account to be checked
    * @return ture if the account has at least one active optin
    */
    private static boolean isThereAtLeastOneOptin(Account client){
        boolean status = false;
        status = (client.OptinEmailing__pc && String.isNotBlank(client.personEmail)) || 
                client.OptinMailing__pc ||  
                (client.OptinCalling__pc && String.isNotBlank(client.Phone)) || 
                client.OptinCGI__c ||  
                (client.OptinInstantMessaging__pc && (String.isNotBlank(client.Phone) ||  String.isNotBlank(client.WeChat__pc))) || 
                client.OptinMarketingPartner__c;
        return status;
    }
    
    /**
     * @description This method iterates over a list of accounts and sets the OptinEmailing__pc field to false
     * for accounts that do not have a personEmail value.
     * @param accountList List of Account records to process.
     * @return the accountList in the trigger context
     */
    public static void rejectOptinWithoutEmail(List<Account> accountList) {
        for(Account acc : accountList) {
            if(String.isBlank(acc.personEmail)) {
                acc.OptinEmailing__pc = false;
            }
        }
    }
    
    /**
     * This method compares new and old account records to determine if the opt-in status has changed
     * and if the email address is missing. If the opt-in status has changed and there is no email address,
     * it updates the opt-in status to false and records the timestamp of the update.
     * @param newAccounts Map containing new Account records, where the key is the account ID.
     * @param oldAccounts Map containing old Account records, where the key is the account ID.
     * @return the accounts into the map in the trigger context
     */
    public static void rejectOptinWithoutEmail(Map<Id, sObject> newAccounts, Map<Id, sObject> oldAccounts) {
        for (sObject obj : newAccounts.values()) {
            Account newAccount = (Account)obj;
            Account oldAccount = (Account)oldAccounts.get(newAccount.Id);
            
            Boolean contactIsOptin = newAccount.optinEmailing__pc;
            Boolean optinEmailingHasChanged = newAccount.optinEmailing__pc != oldAccount.optinEmailing__pc;
            Boolean emailIsExist = String.isNotBlank(newAccount.personEmail);
            
            if (contactIsOptin && !emailIsExist) {
                if (optinEmailingHasChanged) {
                    newAccount.optinEmailing__pc = false;
                    newAccount.lastUpdateOptinEmailing__pc = System.now();
                } else {
                    newAccount.optinEmailing__pc = false;
                }
            }
        }
    }

}