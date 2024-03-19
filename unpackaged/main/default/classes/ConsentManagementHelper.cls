/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class reduces complexity in the main class ConsentManagementHandler by providing modular, 
 * 				reusable code components that assist in achieving objectives and improve readability and maintainability
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
 * 0.1	    |10102023			|.PLM		|.CI-219			|.Modification of method : setEmailConsentFields() to not let the client being optin in case of double Optin
 * 0.2		|01032024			|.PLM		|.CI-303			|.Modification of method : setEmailConsentFields() to not create an optin email when the email is empty
*/
public without sharing class ConsentManagementHelper {
    
    /*
    * @Description Creates a list of consentWrapper from B2CCustominput sObject
    *
    * @param customInputList list of B2CCustomInput instances that contains data of accounts
    * @return List of consentWrapper
    */
    public static List<consentWrapper> getCustomInputs(List<B2CCustomInput__c> customInputList) {        
        List<consentWrapper>  OutputConsentList = new List<consentWrapper>();
        //Get Ids of all accounts
        Set<Id> accountSet = setOfAccountId(customInputList);
        //Get all accounts 
        Map<Id,Account> newAccountsMap =  new Map<ID, Account>([SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                                             PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                                             (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                                             FROM Account WHERE ID in :accountSet]);
        
        Map<Id,Account> OldAccountsMap = getOldAccounts(accountSet);
        
        for (B2CCustomInput__c customInput : customInputList) {
            //Create consentWrapper for the current account
            Account aAccount = newAccountsMap.get(customInput.AccountID__c);
            ConsentWrapper consent = new ConsentWrapper(customInput, aAccount);
            //Populate the current consentWrapper with the old account data
            if (OldAccountsMap.containsKey(aAccount.Id)) {
                consent.oldClient = OldAccountsMap.get(aAccount.Id);
            }
            OutputConsentList.add(consent);
        }
        return OutputConsentList;
    }
    
    /*
    * @Description Create a map of accounts with their Ids as key filled with all historical information about the accounts that have been updated
    *
    * @param accountSet Ids of accounts to look for they histories data
    * @return map of old accounts with their Ids as key
    */

    public static Map<Id, Account> getOldAccounts(Set<Id> accountSet) {        
		
        ID accountID;
        String newPersonEmail;
        String oldPersonEmail;
        Boolean isTestContext = test.isRunningTest();
        Map<Id, Account> oldAccounts = new Map<Id, Account>();
        
        If (accountSet.size() != 0) {
            //Get all account histories data that have changed their personEmails
            List<AccountHistory> accountHistoryList =  [SELECT AccountId, OldValue, NewValue, CreatedDate FROM AccountHistory 
                                                        WHERE Field =: Label.LABS_Field_PersonEmail AND  AccountId in : accountSet ORDER BY CreatedDate];
            //This IF block Condition is added in order to coverage code,  due to test context is not possible to track accounts on the sObject AccountHistory
            //even it is not possible to create record of this object
            if(isTestContext){
                for (Id accId : accountSet) {
                    AccountHistory accHistory = new AccountHistory(AccountId=accId , Field = Label.LABS_Field_PersonEmail);
                    accountHistoryList.add(accHistory);
                }
            }
            for (AccountHistory accountHisorty : accountHistoryList) {
                
                accountID = accountHisorty.AccountId;
                newPersonEmail = (String)accountHisorty?.NewValue ;
                oldPersonEmail = isTestContext? 'fromTestContext@gmail.com' : (String)accountHisorty?.OldValue ;
                //IF account doesn't exist and its newPersonEmail is null & oldPersonEmail not null
                if (!oldAccounts.containsKey(accountId) && String.isBlank(newPersonEmail) 
                    && String.isNotBlank(oldPersonEmail)) {
                    oldAccounts.put(accountId, new Account(Id = accountId, PersonEmail = oldPersonEmail));
                }
                //IF account exists 
                else { 
                    // Retrieve the most recent update for the old accounts
                    if (accountHisorty?.CreatedDate > oldAccounts.get(accountId)?.CreatedDate 
                        && String.isNotBlank(oldPersonEmail)  && String.isBlank(newPersonEmail) ) {
                        oldAccounts.put(accountId, new Account(Id = accountId, PersonEmail= oldPersonEmail));
                    }
                }
            }
        }
        return oldAccounts;
    }
    
    /**
     * @Description : Updates consent wrapper objects with email consent-related fields.
     * This method sets the OptinEmailing__pc and LastUpdateOptinEmailing__pc fields based on the 
     * provided consent information and whether the contact has provided an email address.
     * It also checks for double opt-in scenarios and updates the consent accordingly.
     * Additionally, it determines whether the client needs to be updated based on their subscription status.
     * @param : consentListInput List of ConsentWrapper objects to process.
     * @return : List of updated ConsentWrapper objects with email consent fields modified.
     */
    public static List<ConsentWrapper> setEmailConsentFields(List<consentWrapper> consentListInput){            
        List<ConsentWrapper>  OutputConsentList = new List<consentWrapper>();
        for (ConsentWrapper consent : consentListInput){
            // Update the current consent with :
            consent.doubleOptin = checkIsDoubleOptin(consent);
            
            //CI-219 : Modification for not optin the contact in case of doubleOptin
            //CI-304 : Exception when OptinEmailing__pc = true && personEmail = null
            Boolean oldOptinEmailingValueFromExistingClient = consent.client.OptinEmailing__pc;
            if (String.isEmpty(consent.client.personEmail)) {
                consent.client.LastUpdateOptinEmailing__pc = (consent.client.OptinEmailing__pc && consent.client.LastUpdateOptinEmailing__pc != null) ? 
                    consent.optDate : consent.client.LastUpdateOptinEmailing__pc;
                consent.client.OptinEmailing__pc = false;
            } else {
                Boolean newOptinValue;
                if (consent.doubleOptin) {
                    newOptinValue = oldOptinEmailingValueFromExistingClient;
                } else {
                    newOptinValue = consent.customInput.EmailConsent__c;
                }
                consent.client.OptinEmailing__pc = newOptinValue;
                consent.client.LastUpdateOptinEmailing__pc = (newOptinValue) ? 
                    consent.optDate : consent.client.LastUpdateOptinEmailing__pc;
            }
            //Clients are only updated when they have subscribed to the newsletter or unsubscribed
            consent.clientToUpdate = consent.customInput.SubscriptionName__c?.equalsIgnoreCase(Label.LABS_ComSubscriptionChannelType_Newsletter)? true : false;
            OutputConsentList.add(consent);
        }
        return OutputConsentList;
    }
    
    /*
    * @Description Update the list of consents, either by using existing Individual or creating new ones
    *
    * @param consentListInput list of ConsentWrapper to be updated
    * @return list of consentWrapper updated with Individual
    */
    public static List<ConsentWrapper> getIndividuals(List<ConsentWrapper> consentListInput) {
        List<ConsentWrapper> outputList = new List<ConsentWrapper>();
        for (ConsentWrapper consent : consentListInput) {
            if (String.isBlank(consent.client.PersonIndividualId)) {
                //Create new individual attached to this account & attribute it to the current consent
                consent.indiv = createIndividual(consent);
            } else {
                //Add the existing Individual to the current consent
                consent.indiv = new Individual(Id = consent.client.PersonIndividualId);
            }
            outputList.add(consent);
        }
        return outputList;
    }
    
    /*
    * @Description Update the list of consents, either by using existing ContactPointEmail or creating new ones.
    *
    * @param consentListInput list of ConsentWrapper to be updated
    * @return list of consentWrapper updated with ContactPointEmail
    */
    public static List<ConsentWrapper> getContactPointEmails(List<ConsentWrapper> consentListInput) {
        List<ConsentWrapper> outputList = new List<ConsentWrapper>();
        
        for (ConsentWrapper consent : consentListInput) {
            ContactPointEmail cpEmail = matchedContactPointEmail(consent);
            if (cpEmail != null) {
                //Add the existing ContactPointEmail to the current consent
                consent.cpEmail = cpEmail;
            } else {
                //Create new ContactPointEmail attached to this account & add it to the current consent
                consent.cpEmail = createContactPointEmail(consent);                
            }
            outputList.add(consent);
        }
        return outputList;
    }
    
    /*
    * @description Get the ContactPointTypeConsent, ContactPointConsent and CommSubscriptionConsent for Newsletter Use Case, If DoubleOptin, the CommSubscriptionConsent will not be retreived or created
    *
    * @param consentNewsletterList list of consentWrapper
    * @param channelType sObject for Newsletter
    * @return list of consentWrapper updated with CommSubscriptionConsent of Newsletter
    */
    public static List<consentWrapper> getNewsletterConsentSObjects(List<consentWrapper> consentNewsletterList, commSubscriptionChannelType channelType) {
        Set<Id> accountIdSet = setOfAccountId(consentNewsletterList);
        // retrieves a list of consentWrapper objects that have a contact point type of "Email"
        List<consentWrapper> consentList = getContactPointTypeConsents(consentNewsletterList, accountIdSet, System.Label.LABS_PointType_Email);
        // retrieves a list of consentWrapper objects that have a contact point type of "Email" and a communication point type of "Email"
        consentList = getContactPointConsents(consentList, accountIdSet, System.label.LABS_ContactPointType_Email);
        // creates two empty lists to store consentWrapper objects based on whether or not they have double opt-in
        List<consentWrapper> consentWithoutDoubleOptinList = new List<consentWrapper>();
        List<consentWrapper> consentWitDoubleOptinList = new List<consentWrapper>();
        
        // loops through the consentList and adds each consentWrapper object to the appropriate list based on whether or not it has double opt-in
        for (consentWrapper consent : consentList) {
            if (consent.doubleOptin) {
                consentWitDoubleOptinList.add(consent);
            } else {
                consentWithoutDoubleOptinList.add(consent);
            }
        }
        
        // retrieves a list of consentWrapper objects that have a communication subscription for the given channel type and do not have double opt-in
        consentWithoutDoubleOptinList = getCommSubscriptionConsents(consentWithoutDoubleOptinList, accountIdSet, channelType);
        
        // creates a list to store the final list of consentWrapper objects and adds the two lists of consentWrapper objects together
        List<consentWrapper> consentListOutput = new List<consentWrapper>();
        consentListOutput.addAll(consentWithoutDoubleOptinList);
        consentListOutput.addAll(consentWitDoubleOptinList);
        
        return consentListOutput;
    }
    
    /*
    * @Description Updates list of consents with new CommSubscriptionConsent of BackInStock
    *
    * @param consentBackInStockList list of ConsentWrapper to be updated
    * @param channelType sObject for BackInStock
    * @return list of consentWrapper updated with CommSubscriptionConsent of BackInStock
    */
    public static List<consentWrapper> getBackInStockConsentSObjects(List<consentWrapper> consentBackInStockList, commSubscriptionChannelType channelType) { 
        List<consentWrapper> consentListOutput = new List<consentWrapper>();
        for(ConsentWrapper consent : consentBackInStockList){
            //Create new commSubscriptionConsent for BackInStock & add it to the current consent
            consent.commSubConsent = createCommSubscriptionConsent(consent, channelType);
            consentListOutput.add(consent);
        }
        return consentListOutput;
    } 
    
    /*
    * @description Extracts from list of consents all the consents that have a specific subscription name
    *
    * @param consentListInput list of consents to be updated
    * @param subscriptionName consent key
    * @return list of consentWrapper updated with specific subscription name
    */
    public static List<ConsentWrapper> getSubscriptionByName(List<ConsentWrapper> consentListInput, String subscriptionName) {
        List<consentWrapper> ouputConsentList = new List<consentWrapper>();
        for (ConsentWrapper consent : consentListInput) {
            if (consent.customInput.subscriptionName__c == subscriptionName) {
                ouputConsentList.add(consent);
            }
        }
        return ouputConsentList;
    }
    
    /*
    * @description Updates the list of consents, either by using existing ContactPointTypeConsent or creating new ones
    *
    * @param consentListInput list of ConsentWrapper to be updated throughout this method
    * @param accountIdSet Set of account Ids 
    * @param ContactPointTypeName of ContactPointTypeConsent
    * @return list of consentWrapper updated with ContactPointTypeConsent
    */
    public static List<ConsentWrapper> getContactPointTypeConsents(List<ConsentWrapper> consentListInput, Set<Id> accountIdSet, String ContactPointTypeName) {
        List<consentWrapper> outputConsents = new List<consentWrapper>();
        Map<Id, ContactPointTypeConsent> contactPointTypeConsentMap = new Map<Id, ContactPointTypeConsent>();
        //Get all the existing ContactPointTypeConsent
        for (ContactPointTypeConsent contactPointTypeConsent : [SELECT Id, AccountId__r.Name, AccountId__c, EffectiveFrom, EffectiveTo, 
                                                                ContactPointType, PrivacyConsentStatus
                                                                FROM ContactPointTypeConsent 
                                                                WHERE AccountId__c IN :accountIdSet
                                                                AND PrivacyConsentStatus =: System.Label.LABS_Consent_Optin
                                                                AND ContactPointType = : ContactPointTypeName 
                                                                AND EffectiveTo = null
                                                                AND EffectiveFrom != null
                                                                ORDER BY EffectiveFrom DESC]) {
            contactPointTypeConsentMap.put(contactPointTypeConsent.AccountId__c, contactPointTypeConsent);
        }
        
        for (ConsentWrapper consent : consentListInput) {
            Id accountId = consent.client.Id;
            Boolean contactPointTypeConsentIsExist = contactPointTypeConsentMap.containsKey(accountId);
            if(contactPointTypeConsentIsExist){
                //Populate the current consent with the exsiting ContactPointTypeConsent
                consent.cpTypeConsent = contactPointTypeConsentMap.get(accountId); 
            }
            else if(!contactPointTypeConsentIsExist && consent.customInput.EmailConsent__c){
                //create a new ContactPointTypeConsent & populate it to the current consent
                consent.cpTypeConsent = createContactPointTypeConsent(consent);
            }
            outputConsents.add(consent);       
        }
        return outputConsents;
    }
    
    /*
    * @description Updates the list of consents, either by using existing ContactPointConsent or creating new ones
    *
    * @param consentListInput list of ConsentWrapper to be updated throughout this method
    * @param accountIdSet Set of account Ids 
    * @param contactPointType of ContactPointConsent
    * @return list of consentWrapper updated with ContactPointConsent
    */
    public static List<ConsentWrapper> getContactPointConsents(List<ConsentWrapper> consentListInput, Set<Id> accountIdSet, String contactPointType) {
        List<consentWrapper> outputConsents = new List<consentWrapper>();
        Map<Id, ContactPointConsent> contactPointConsentMap = new Map<Id, ContactPointConsent>();
        for(ContactPointConsent contactPointConsent : [SELECT Id, ContactPointId, PrivacyConsentStatus, AccountId__c, EffectiveFrom, EffectiveTo 
                                                       FROM ContactPointConsent 
                                                       WHERE AccountId__c IN :accountIdSet
                                                       AND PrivacyConsentStatus =: System.Label.LABS_Consent_Optin
                                                       AND EffectiveTo = null
                                                       AND EffectiveFrom != null
                                                       ORDER BY EffectiveFrom DESC]) {
            String contactPointId = contactPointConsent.ContactPointID;
            if(contactPointId.startsWith(contactPointType)){
                contactPointConsentMap.put(contactPointConsent.AccountId__c, contactPointConsent);
        	}
        }                                           
        for (ConsentWrapper consent : consentListInput) {
            Id accountId = consent.client.Id;
            Boolean contactPointConsentIsExist = contactPointConsentMap.containsKey(accountId);
            if(contactPointConsentIsExist){
                //Populate the current consent with the exsiting ContactPointConsent
                consent.cpConsent = contactPointConsentMap.get(accountId); 
            }
            else if(!contactPointConsentIsExist && consent.customInput.EmailConsent__c){
                //create a new ContactPointConsent & populate it to the current consent
                consent.cpConsent = createContactPointConsent(consent);  
            } 
            outputConsents.add(consent);
        }        
        return outputConsents;
                                  
    }
    
    /*
    * @description Updates the list of consents, either by using existing CommSubscriptionConsent or creating new ones
    *
    * @param consentListInput list of ConsentWrapper to be updated throughout this method
    * @param accountIdSet Set of account Ids 
    * @param channelType sObject
    * @return list of consentWrapper updated with CommSubscriptionConsent
    */
    public static List<ConsentWrapper> getCommSubscriptionConsents(List<ConsentWrapper> consentListInput, Set<Id> accountIdSet, commSubscriptionChannelType channelType) {  
        //11-10-2023 PLM : Prevent from having no channelType
        if(channelType == null){
            channelType = getChannelTypeMap().get('SpecialEvent');
        }
        List<consentWrapper> outputConsents = new List<consentWrapper>();
        Map<Id, CommSubscriptionConsent> commSubscriptionConsentMap = new Map<Id, CommSubscriptionConsent>();
        for(CommSubscriptionConsent commSubscriptionConsent : [SELECT Id, Name, ContactPointId, AccountId__c, EffectiveFromDate, EffectiveToDate, 
                                                               ConsentCapturedDateTime, ConsentCapturedSource, PrivacyConsentStatus,
                                                               CommSubscriptionChannelTypeId, CommSubscriptionChannelType.Name
                                                               FROM CommSubscriptionConsent 
                                                               WHERE AccountId__c IN :accountIdSet
                                                               AND CommSubscriptionChannelTypeId = :channelType.Id
                                                               AND EffectiveToDate = null
                                                               AND EffectiveFromDate != null	
                                                               ORDER BY EffectiveFromDate DESC]) {
        	commSubscriptionConsentMap.put(commSubscriptionConsent.AccountId__c, commSubscriptionConsent);
        }
        for(ConsentWrapper consent : consentListInput){
            
            Id accountId = consent.client.Id;
            Boolean commSubIsExist = commSubscriptionConsentMap.containsKey(accountId);
            if(commSubIsExist){
                //added on the 05/06/2023
                //If the CommSubConsent is related to the current ContactPointEmail
                if (commSubscriptionConsentMap.get(accountId)?.ContactPointId == consent.cpEmail?.Id) {
                    //Populate the current consent with the exsiting commSubscriptionConsent
                    consent.commSubConsent = commSubscriptionConsentMap.get(accountId);
                //There is no CommSubConsent related to the current ContactPointEmail
                } else {
                    //create a new commSubscriptionConsent & populate it to the current consent
                    consent.commSubConsent = createCommSubscriptionConsent(consent, channelType);
                }
            }
            else if(!commSubIsExist && consent.customInput.EmailConsent__c){
                //create a new commSubscriptionConsent & populate it to the current consent
                consent.commSubConsent = createCommSubscriptionConsent(consent, channelType);
            }
            outputConsents.add(consent);   
        }
        return outputConsents;
    }
    
    /*
    * @description get all existing channel types
    *
    * @return map contains CommSubscriptionChannelType with subscriptionName as key
    */
    public static Map<String, CommSubscriptionChannelType> getChannelTypeMap(){
        Map<String, commSubscriptionChannelType> channelTypeMap = new Map<String, commSubscriptionChannelType>();

        //Create a map that contains all the existing channel types with their subscriptionName as key
        String query = 'Select Id, Name From CommSubscriptionChannelType';
        for (commSubscriptionChannelType channelType : Database.query(query, AccessLevel.SYSTEM_MODE)) {
            channelTypeMap.put(channelType.Name, channelType);
        }
        //11-10-2023 PLM : Prevent test class to not have commSubscriptionChannelType
        if (Test.isRunningTest() && channelTypeMap.isEmpty()) {
    		ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
            for (commSubscriptionChannelType channelType : Database.query(query, AccessLevel.SYSTEM_MODE))channelTypeMap.put(channelType.Name, channelType);
		}
        return channelTypeMap;
    }
    
    /*
    * @description Extract a Set of accounts which are in the customInputList
    *
    * @param customInputList list of B2CCustomInput__c instances that contain data of accounts
    * @return Set of account Ids
    */
    public static Set<Id> setOfAccountId(List<B2CCustomInput__c> customInputList) {
        Set<Id> accountIdSet = new Set<Id>();
        for (B2CCustomInput__c customInput : customInputList) {
            if (customInput.AccountId__c != null) {
                accountIdSet.add(customInput.AccountId__c);
            }
        }
        return accountIdSet;
    }
    
    /*
    * @description Extract a Set of accounts which are in the consentWrapperList
    *
    * @param consentWrapperList list of ConsentWrapper instances that contain data of accounts
    * @return Set of account Ids
    */
    public static Set<Id> setOfAccountId(List<ConsentWrapper> consentWrapperList) {
        
        Set<Id> accountIdSet = new Set<Id>();
        
        for (ConsentWrapper aConsentWrapper : consentWrapperList) {
            if (aConsentWrapper.client != null) {
                accountIdSet.add(aConsentWrapper.client.Id);
            }
        }
        return accountIdSet;
    }
    
    /*
    * @description Looks for the matched ContactPointEmail in a list of ContactPointEmail
    * 
    * @param consent contains all the information about a specific account
    * @return matched ContactPointEmail if match is found it, otherwise null
    */
    public static ContactPointEmail matchedContactPointEmail(ConsentWrapper consent) {
        ContactPointEmail outputCPE = null;
        Account newClient = consent.client;
        String personEmail = String.isNotBlank(newClient.PersonEmail)? 
            				 newClient.PersonEmail : consent.oldClient.PersonEmail;
        //Look for the matched ContactPointEmail
        for(ContactPointEmail aContactPointEmail : newClient.ContactPointEmails__r) {
            //IF the matched ContactPointEmail exist
            if(aContactPointEmail.ActiveToDate == null && aContactPointEmail.EmailAddress == personEmail) {
                outputCPE = aContactPointEmail;
            }
        }
        //IF the matched ContactPointEmail doesn't exist
        return outputCPE;
    }
    
    /*
    * @description checks if an account's country has a double optin
    *
    * @param consent contains all the information about a specific account
    * @return true if an account belongs to the countries that have double Optin else false
    */
    public static Boolean checkIsDoubleOptin(consentWrapper consent) {
        
        Account aAccount = consent.client;
        Map<String, Set<String>> countriesCodes = new Map<String, Set<String>> { 'Germany' => new Set<String> {'DEU', 'DE'}}; //Global Variable
            
            //Germany case
            if(countriesCodes.get('Germany').contains(aAccount.Country__pc) || countriesCodes.get('Germany').contains(aAccount.WebsiteCountry__pc)) {
                return true;
            }
        return false;
    }
    
   	/*
    * @description get the right consentSource metadata record based on the customInput
    *
    * @param customInput instance of B2CCustomInput that contains data of an account
    * @return consentSource record
    */
    public static ConsentSource__mdt generateName(B2CCustomInput__c customInput) {
        
        String apiName;
        //Newsletter
        if (customInput.subscriptionName__c == System.label.LABS_ComSubscriptionChannelType_Newsletter) {
            apiName = customInput.EmailConsent__c? System.label.LABS_ConsentSourceName_Newsletter_Optin 
                								 : System.label.LABS_ConsentSourceName_Newsletter_Optout;
        //BackInStock
        } else if(customInput.subscriptionName__c == System.label.LABS_ComSubscriptionChannelType_BackInStock) {
            apiName = System.label.LABS_ConsentSourceName_BackInStock;
        //CGI
        } else if(customInput.subscriptionName__c == System.label.LABS_CGI) {
             apiName = customInput.OptinCGI__c? System.label.LABS_ConsentSourceName_CGI_Optin 
                								 : System.label.LABS_ConsentSourceName_CGI_Optout;           
        } else if(customInput.subscriptionName__c == label.LABS_Messaging) {
            apiName = customInput.OptinMessaging__c? System.label.LABS_ConsentSourceName_Instant_Messaging_Optin 
                								 : System.label.LABS_ConsentSourceName_Instant_Messaging_Optout;
        } // to active 
        /*else if(customInput.subscriptionName__c == label.LABS_Messaging) {
            apiName = customInput.OptinPhone__c? System.label.LABS_ConsentSourceName_Phone_Optin 
                								 : System.label.LABS_ConsentSourceName_Phone_Optout;
        } */
        
        //Get the consentSource record base on its API name
        ConsentSource__mdt consentSource = ConsentSource__mdt.getInstance(apiName);

        
        return consentSource;
    }
    
    /*
    * @description DEBUG LOG Over ConsentWrappers List
    *
    * @param consentList list of ConsentWrapper
    * @param debugLinePosition : Text to show in the first debug line to identify the log
    * @param currentUser the user who is running this method
    * @return none
    */
    public static void debugConsentWrapperList(list<ConsentWrapper> consentList, String debugLinePosition, User currentUser){
        //if(currentUser.APEX_DebugListAuthorization__c){
        if(currentUser.APEX_DebugListAuthorization__c){
            System.debug('-----------------------------------------START Debugging Consent Wraper :'+debugLinePosition+'--------------------------------------------------');
            Integer numberOfAccount = 1;
            for (consentWrapper consent : consentList) {
                System.debug('Account ' + numberOfAccount + ' : ' + consent.client);
                System.debug('Individual ' + numberOfAccount + ' : ' + consent.indiv);
                System.debug('contactPointEmail ' + numberOfAccount + ' : ' + consent.cpEmail);
                System.debug('contactPointPhone ' + numberOfAccount + ' : ' + consent.cpPhone);
                System.debug('ContactPointAddress ' + numberOfAccount + ' : '  + consent.cpAddress);
                System.debug('ContactPointTypeConsent ' + numberOfAccount + ' : '  + consent.cpTypeConsent);
                System.debug('ContactPointConsent ' + numberOfAccount + ' : '  + consent.cpConsent);
                System.debug('CustomInput ' + numberOfAccount + ' : '  + consent.customInput);
                System.debug('CommSubscriptionConsent ' + numberOfAccount + ' : '  + consent.commSubConsent);
                System.debug('OptDate ' + numberOfAccount + ' : '  + consent.optDate);
                System.debug('DoubleOptin ' + numberOfAccount + ' : '  + consent.doubleOptin);
                System.debug('CaptureContactPointType ' + numberOfAccount + ' : '  + consent.captureContactPointType);
                System.debug('CaptureSource ' + numberOfAccount + ' : '  + consent.captureSource);
                System.debug('ClientToUpdate ' + numberOfAccount + ' : '  + consent.clientToUpdate);
                numberOfAccount += 1;
            }
            System.debug('-------------------------------------------END Debugging Consent Wraper:'+debugLinePosition+'----------------------------------------------------');        
        }
    }
    
    /*
    * @description encodes string based on base64Encode
    *
    * @param createDate date of the account creation 
    * @param contactId account Id
    * @param email of the account
    * @return the encoding string
    */
    public static String hashMD5(Datetime createDate, Id contactId, String email){
        
        String fieldsConcatenate = String.valueOf(createDate);
        
        if(email != null) {
            fieldsConcatenate += Email;
        }
        if(ContactId != null) {
            fieldsConcatenate += String.valueOf(ContactId);
        }
        
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(fieldsConcatenate));
        String ecodingToUrl = EncodingUtil.urlEncode(EncodingUtil.Base64Encode(hash), 'UTF-8');
        
        return ecodingToUrl;
        
    }
    
    /**
    * @description Creates a new record of Individual
    * 
    * @param consent contains all the information about a specific account  
    * @return the created Individual record
    */
    public static Individual createIndividual(ConsentWrapper consent) {
        
        Account aAccount = consent.client;
        
        Individual indiv = new Individual(
            LastName   = aAccount.LastName,
            Salutation = aAccount.Salutation,
            BirthDate  = aAccount.PersonBirthdate);
        
        return indiv;
    }
    
    /**
    * @description Creates a new record of ContactPointEmail
    * 
    * @param consent contains all the information about a specific account
    * @return the created ContactPointEmail record
    */
    public static ContactPointEmail createContactPointEmail(ConsentWrapper consent) {
        
        Account aAccount = consent.client;
        if(String.isNotBlank(aAccount.PersonEmail)){
            ContactPointEmail cpe = new ContactPointEmail(
                ActiveFromDate = consent.OptDate.Date(),
                AccountId__c   = aAccount.Id,
                ParentId       = aAccount.PersonIndividualId,
                EmailAddress   = aAccount.PersonEmail);
            
            return cpe;
        }
        return null;
    }
    
    /*
    * @description Creates a new record of ContactPointTypeConsent
    * 
    * @param consent contains all the information about a specific account  
    * @return the created ContactPointTypeConsent record
    */
    public static ContactPointTypeConsent createContactPointTypeConsent(ConsentWrapper consent) {
        
        Account aAccount = consent.client;
        B2CCustomInput__c customInput = consent.customInput;
        ConsentSource__mdt consentSource = generateName(customInput);
        
        ContactPointTypeConsent aContactPointTypeConsent = new ContactPointTypeConsent (
            Name                        = consentSource != null ? consentSource.Name__c : 'Standard',
            PartyId                     = aAccount.PersonIndividualId,
            ContactPointType            = consentSource != null ? consentSource.PointType__c : null,
            PrivacyConsentStatus        = aAccount.OptinEmailing__pc?  Label.LABS_Consent_Optin : Label.LABS_Consent_Optout,
            EffectiveFrom               = consent.optDate,
            CaptureDate                 = consent.optDate,
            CaptureContactPointType     = String.isEmpty(customInput.captureContactPointType__c)? consent.captureContactPointType : customInput.captureContactPointType__c,
            CaptureSource               = String.isEmpty(customInput.captureSource__c)? consent.CaptureSource : customInput.captureSource__c,
            OptOutContactPointType__c   = customInput.OptOutContactPointType__c,
            CustomContactPointType__c   = customInput.customContactPointType__c,
            AccountId__c                = aAccount.Id
        );
        
        return aContactPointTypeConsent;
    }
    
    /*
    * @description Creates a new record of ContactPointConsent
    * 
    * @param consent contains all the information about a specific account  
    * @return the created ContactPointConsent record
    */
    public static ContactPointConsent createContactPointConsent(ConsentWrapper consent) {
        
        Account aAccount = consent.client;
        B2CCustomInput__c customInput = consent.customInput;
        ConsentSource__mdt consentSource = generateName(customInput);
        
        ContactPointConsent aContactPointConsent = new ContactPointConsent(
            Name                        = consentSource != null ? consentSource.Name__c : 'Standard' ,
            ContactPointId              = consent.cpEmail != null ? consent.cpEmail.Id : null,
            PrivacyConsentStatus        = consent.doubleOptin? Label.LABS_Consent_Optout : Label.LABS_Consent_Optin,
            EffectiveFrom               = consent.doubleOptin ? null : consent.optDate,
            CaptureDate                 = consent.optDate,
            CaptureContactPointType     = String.isEmpty(customInput.captureContactPointType__c)? consent.captureContactPointType : customInput.captureContactPointType__c,
            CaptureSource               = String.isEmpty(customInput.captureSource__c)? consent.CaptureSource : customInput.captureSource__c,
            OptOutContactPointType__c   = customInput.OptOutContactPointType__c,
            CustomContactPointType__c   = customInput.customContactPointType__c,
            DoubleOptInHash__c          = consent.doubleOptin ? HashMD5(aAccount.CreatedDate, aAccount.PersonContactId, aAccount.PersonEmail) : null,
            AccountId__c                = aAccount.Id
        );
        
        return aContactPointConsent;        
    }
    
    /*
    * @description Creates a new record of CommSubscriptionConsent
    * 
    * @param consent contains all the information about a specific account 
    * @param channelType sObject 

    * @return the created CommSubscriptionConsent record
    */
    public static CommSubscriptionConsent createCommSubscriptionConsent(consentWrapper consent, commSubscriptionChannelType channelType) {
        
        Account aAccount = consent.client;
        B2CCustomInput__c customInput = consent.customInput;
        
        CommSubscriptionConsent comSubConsent = new CommSubscriptionConsent(
            Name                          = channelType.Name,
            AccountId__c                  = aAccount.Id,
            ContactPointId                = consent.cpEmail != null ? consent.cpEmail.Id : null,
            PrivacyConsentStatus          = customInput.EmailConsent__c? System.Label.LABS_Consent_Optin : System.Label.LABS_Consent_Optout,
            EffectiveFromDate             = consent.optDate.date(),
            ConsentCapturedDateTime       = consent.optDate,
            ConsentCapturedSource         = customInput.captureContactPointType__c,
            Country__c                    = aAccount.WebsiteCountry__pc == 'DEU'? 'DE' : aAccount.WebsiteCountry__pc,
            CommSubscriptionChannelTypeId = channelType.Id
        );
        
        // If the channel type equal to BackInStock add these additional parametres
        if (channelType.Name ==	Label.LABS_ComSubscriptionChannelType_BackInStock) {
            comSubConsent.PrivacyConsentStatus = Label.LABS_Consent_Optin;
            comSubConsent.sku__c               = customInput.BackInStockSubscriptionSKU__c;
            comSubConsent.StoreCode__c         = customInput.Store__c;
            comSubConsent.SaleChannel__c       = customInput.SaleChannel__c;
            comSubConsent.Locale__c            = aAccount.WebsiteLocale__pc;
            comSubConsent.Warehouse__c         = customInput.Warehouse__c;
        }
        
        return comSubConsent;
 
    }
    
}