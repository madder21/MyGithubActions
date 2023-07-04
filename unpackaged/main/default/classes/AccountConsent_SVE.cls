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
*/

public without sharing class AccountConsent_SVE {
    
    /*
    * @description Create B2CCustomInput For Retail trouchpoints (DDC & CEGID)
    *
    * @param newAccounts : New account from trigger.New
    * @param oldAccounts : Existing account from trigger.Update
    * @return void
    */
    public static void createB2CCustomInputForRetail(Map<id, sObject> newAccounts, Map<id, sObject> oldAccounts) {
        Boolean isNew = oldAccounts?.isEmpty()? true : false;
        List<B2CCustomInput__c> customInputs= new List<B2CCustomInput__c> ();
        List<Account> accounts = new List<Account>();
		
        //if we are in Trigger context New : just take in consideration newAccounts Map, if we are in Update context check if there are changes in the Accounts
        accounts = isNew? (List<Account>)newAccounts.Values() : filterOnUpdatedAccount(newAccounts,oldAccounts);        
        
        ConsentSource__mdt consentSource = ConsentSource__mdt.getInstance(System.Label.LABS_ConsentSourceName_Retail);
        
        if(consentSource!=null){
            for(Account acc : accounts){
                if((isNew && isThereAtLeastOneOptin(acc)) || !isNew){
                    customInputs.add(createB2CCustomInput(acc, consentSource));
                }
            }
            if (!customInputs.isEmpty()) {
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
            customInput.CaptureContactPointType__c = consentSource.capturePointType__c; //TODO => EMAIL
            customInput.CaptureSource__c = consentSource.captureSource__c;
            customInput.contactPointType__c = null;
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
         List<Account> accountToUpdate = new  List<Account>();
        //TO DO Compare optin old VS optin New, if at least one optin changed add the new account in the list to return
        for (sObject obj : newAccounts.values()) {
            Account newAccount = (Account) obj;
            Account oldAccount = (Account) oldAccounts.get(newAccount.Id);
            if (
                (newAccount.OptinEmailing__pc != oldAccount.OptinEmailing__pc) || 
                (newAccount.OptinMailing__pc != oldAccount.OptinMailing__pc)   ||  
                (newAccount.OptinCalling__pc != oldAccount.OptinCalling__pc)   || 
                (newAccount.OptinCGI__c != oldAccount.OptinCGI__c )            ||  
                (newAccount.OptinInstantMessaging__pc != oldAccount.OptinInstantMessaging__pc ) || 
                (newAccount.OptinMarketingPartner__c != oldAccount.OptinMarketingPartner__c)
            	) {
               accountToUpdate.add(newAccount);     
            }
        }
        return accountToUpdate;
    }
    
    /*
    * @description for an account given check if at least has one active optin
    *
    * @param client, is an account to be checked
    * @return ture if the account has at least one active optin
    */
    private static boolean isThereAtLeastOneOptin(Account client){
        boolean status = false;
        status = client.OptinEmailing__pc || 
                client.OptinMailing__pc ||  
                client.OptinCalling__pc || 
                client.OptinCGI__c ||  
                client.OptinInstantMessaging__pc || 
                client.OptinMarketingPartner__c;
        return status;
    }
}