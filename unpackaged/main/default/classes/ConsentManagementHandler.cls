/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class is designed to effectively handle data and generate relevant objects pertaining to Salesforce's consent management process
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		  |25052023			|.PLM		|.					|.
 * 0.1		  |10102023			|.PLM		|.CI-219 		|.Modification of checkFullConsent(), when a client is DoubleOptin, the status should be Opt-out
*/

public with sharing class ConsentManagementHandler {
	
    Public static User currentUser = new User();
    
    public ConsentManagementHandler() {
        currentUser = [Select id, APEX_DebugListAuthorization__c from User where id = :UserInfo.getUserId()][0];
    }
    /*
    * @description handle consent for email based on customInput 
    *
    * @param customInputList list of B2CCustomInput instances that contains data of accounts
    * @return list of consentWrapper
    */
    public List<consentWrapper> emailConsentHandler(List<B2CCustomInput__c> customInputList) {
        
        Map<Id, contactPointTypeConsent> contactPointTypeConsentMap  = new Map<Id, contactPointTypeConsent>();
        Map<Id, contactPointConsent>     contactPointConsentMap      = new Map<Id, contactPointConsent>();
        Map<Id, CommSubscriptionConsent> commSubscriptionConsentMap  = new Map<Id, CommSubscriptionConsent>(); 
        List<ContactPointEmail> cpEmailOptoutList = new List<ContactPointEmail>();
        
        Map<Id, Account> accountToUpdate = new Map<Id, Account>();    
        
        List<consentWrapper>  consentList = new List<consentWrapper>();
        
        String newsLetter = System.label.LABS_ComSubscriptionChannelType_Newsletter;
        String backInStock = System.label.LABS_ComSubscriptionChannelType_BackInStock;
        
        //------------------------------------------------------------------START Data Preparation----------------------------------------------------------------
        //Create ConsentWrapper instances for each customInput in order to update it throughout this method
        consentList = ConsentManagementHelper.getCustomInputs(customInputList);
        //Update consentWrapper  
        consentList = ConsentManagementHelper.setEmailConsentFields(consentList);
        //------------------------------------------------------------------END Data Preparation------------------------------------------------------------------
        
        //Debug Lines
        ConsentManagementHelper.debugConsentWrapperList(consentList,'ConsentManagement.logic() END Data Preparation', currentUser);
        
        //------------------------------------------------------------------START SECTION 1 : Handle individual and Contact Point Email---------------------------
        //Creates individuals & contactPointConsent in consent
        List<ConsentWrapper> consentsWithIndividuals = ConsentManagementHelper.getIndividuals(consentList);
        List<ConsentWrapper> consentsWithIndividualsAndCPEmail = ConsentManagementHelper.getContactPointEmails(consentsWithIndividuals);
        
        //Debug Lines
        ConsentManagementHelper.debugConsentWrapperList(consentList,'ConsentManagement.logic() Create Indiv + CPE ', currentUser);
        
        //Insert Individual
        consentList = insertIndividuals(consentsWithIndividualsAndCPEmail);
        //Insert ContactPointEmail
        consentList = insertContactPointEmail(consentList);
        //------------------------------------------------------------------END SECTION 1------------------------------------------------------------------
        
        //Debug Lines
        ConsentManagementHelper.debugConsentWrapperList(consentList,'ConsentManagement.logic() END SECTION 1 : Handle individual and Contact Point Email', currentUser);
        
        //------------------------------------------------------------------START SECTION 2 : create consent Object for Email------------------------------
        //If NewsLetter : Creates or updates ContactPointTypeConsents & contactPointConsents in consent
        List<ConsentWrapper> consentNewsletterList = ConsentManagementHelper.getSubscriptionByName(consentList, newsletter);
        List<ConsentWrapper> consentBackInStockList = ConsentManagementHelper.getSubscriptionByName(consentList, backInStock);
        
        Map<String, commSubscriptionChannelType> channelTypeMap = ConsentManagementHelper.getChannelTypeMap();
        
        if(!consentNewsletterList.isEmpty()){
            //OverWrite consentList with only Newsletter consents
            consentList = ConsentManagementHelper.getNewsletterConsentSObjects(consentNewsletterList, channelTypeMap.get(newsLetter)); 
        }else{
            //Clear consentList
            consentList = new List<ConsentWrapper>();
        }

        if(!consentBackInStockList.isEmpty()){
            //Add All BackInStock Consent in the consentList
            consentBackInStockList = ConsentManagementHelper.getBackInStockConsentSObjects(consentBackInStockList, channelTypeMap.get(backInStock));
            consentList.addAll(consentBackInStockList);
        }
        //------------------------------------------------------------------END SECTION 2------------------------------------------------------------------
        
        //Debug Lines
        ConsentManagementHelper.debugConsentWrapperList(consentList,'ConsentManagement.logic() END SECTION 2 : create consent Object for Email',currentUser);
        
        //------------------------------------------------------------------START SECTION 3 : Inserting & Updating-----------------------------------------
        for (ConsentWrapper consent : consentList) {
            if(consent.clientToUpdate) accountToUpdate.put(consent.client.id,consent.client);
            
            //Update the status of ContactPointEmail to optout only in case of a newsletter
            if(consent.cpEmail != null){
                if(!consent.customInput.EmailConsent__c && 
                   consent.customInput.SubscriptionName__c?.equalsIgnoreCase(Label.LABS_ComSubscriptionChannelType_Newsletter)){
                    consent.cpEmail = contactPointEmailOptoutHandler(consent.cpEmail, consent.optDate);
                    cpEmailOptoutList.add(consent.cpEmail);
                }
            }
            //Get all contactPointTypeConsent and put them in Map
            if (consent.cpTypeConsent != null) {
                if(!consent.customInput.EmailConsent__c){
                    consent.cpTypeConsent = contactPointTypeConsentOptoutHandler(consent.cpTypeConsent, consent.optDate);
                }
                contactPointTypeConsentMap.put(consent.client.Id, consent.cpTypeConsent);
            }  
            //Get all contactPointConsent and put them in Map 
            if (consent.cpConsent != null) {
                if(!consent.customInput.EmailConsent__c){
                    consent.cpConsent = contactPointConsentOptoutHandler(consent.cpConsent, consent.optDate);
                }
                contactPointConsentMap.put(consent.client.Id, consent.cpConsent);
            }
            //Get all CommSubscriptionConsent and put them in Map
            if (consent.commSubConsent != null) {
                if(!consent.customInput.EmailConsent__c && consent.customInput.subscriptionName__c == newsLetter){
                    consent.commSubConsent = commSubscriptionConsentOptoutHandler(consent.commSubConsent, consent.optDate.date());
                }
                commSubscriptionConsentMap.put(consent.customInput.Id, consent.commSubConsent);
            }
        }
        //update ContactPointEmail in case of Optout
        if(!cpEmailOptoutList.isEmpty()){
            Database.Update(cpEmailOptoutList, AccessLevel.SYSTEM_MODE);
        }
        //Insert or update contactPointTypeConsents
        if (!contactPointTypeConsentMap.isEmpty()) {
            Database.upsert(contactPointTypeConsentMap.values(), AccessLevel.SYSTEM_MODE);
        }
        //Insert or update contactPointConsents
        if (!contactPointConsentMap.isEmpty()) {
            Database.upsert(contactPointConsentMap.values(), AccessLevel.SYSTEM_MODE);
        }
        //Insert or update commSubscriptionConsent
        if (!commSubscriptionConsentMap.isEmpty()) {
            List<CommSubscriptionConsent> test = new List<CommSubscriptionConsent>();//Ulrich and Eric quick fix to be really fix after
            for(CommSubscriptionConsent com : commSubscriptionConsentMap.values()) {//27/01/2023 
                if(com.CommSubscriptionChannelTypeId!= null) {
					test.add(com);                    
                }
            }
            Database.upsert(test, AccessLevel.SYSTEM_MODE);
        }
        //Update Account
        if(!accountToUpdate.isEmpty()){
            Database.update(accountToUpdate.values(), AccessLevel.SYSTEM_MODE);
        }
        //Update consent with ContactPointTypeConsent
        consentList = updateConsentSOjectID(consentList, contactPointTypeConsentMap);
        //Update consent with contactPointConsent
        consentList = updateConsentSOjectID(consentList, contactPointConsentMap);
        //Update consent with CommSubscriptionConsents
        consentList = updateConsentSOjectID(consentList, commSubscriptionConsentMap);
        //------------------------------------------------------------------END SECTION 3 :END Inserting & Updating-------------------------------------------------------
        
        //Debug Lines
        ConsentManagementHelper.debugConsentWrapperList(consentList,'ConsentManagement END SECTION 3', currentUser); 
        
        //List of all the consents that have been successfully created
     	consentList = checkFullConsent(consentList, currentUser);
        callEventDeleteB2CCustomInput(consentList);
        
        return consentList;
    }
    
    /*
    * @description delete B2CCustomInput records that have been successfuly created all the consent for all account 
    *
    * @param consentListInput list of ConsentWrapper that contain B2CCustomInput records to be deleted
    */
    @TestVisible
    private static void callEventDeleteB2CCustomInput(List<ConsentWrapper> consentList) {
        
        List<Delete_B2CCustomInput_record__e> newsEventList = new List<Delete_B2CCustomInput_record__e>();
        List<Database.SaveResult> sr = new List<Database.SaveResult>();
            
        for (ConsentWrapper consent : consentList) {
            Id customInputID = consent.customInput.Id;
            if (String.isNotBlank(customInputID)) {
                Delete_B2CCustomInput_record__e newsEvent = new Delete_B2CCustomInput_record__e(recordID__c = customInputID);
        		newsEventList.add(newsEvent);
            } 
        }
       
        // Call method to publish events
        if (!newsEventList.isEmpty()) {
            sr = EventBus.publish(newsEventList);
        }
    }

    /*
    * @description Check if the consent has been successfully created
    *
    * @param consentListInput list of ConsentWrapper to be checked
    * @return List of consentWrapper that contains only the consents that were checked
    */
    @TestVisible 
    private static List<consentWrapper> checkFullConsent(List<ConsentWrapper> consentListInput, User currentUser) {
        
        Boolean isDoubleOptin;
        Boolean flag;
        Boolean flagCpTypeConsent;
        Boolean flagCpConsent;
        Boolean flagComSubConsent;
        Boolean flagFullConsent;
        String subscription;
        String status;
        List<consentWrapper> fullConsentList  = new List<consentWrapper>();
        
        for (ConsentWrapper consent : consentListInput) {
            
            if (String.isNotBlank(consent.client.PersonEmail)) {
                //Double Optin check
                isDoubleOptin = ConsentManagementHelper.checkIsDoubleOptin(consent);
                //Check if the current account has consented
                flag = consent.customInput?.EmailConsent__c ? true : false;
                //Subscription name
                subscription = consent.customInput?.subscriptionName__c;
                //the current consent can be either optin or optout
                //CI-219 :the status should be Optout if isDoubleOptin is true
                status = flag && !isDoubleOptin ? Label.LABS_Consent_Optin : Label.LABS_Consent_Optout;
                
                //Check if the current consent has an account and an individual
                Boolean flagClientIndiv = String.isNotBlank(consent.client?.Id) 
                    && String.isNotBlank(consent.indiv?.Id);
                
                //Check if the current consent has contactPointEmail with the correct status
                Date activeToDate = consent.cpEmail?.ActiveToDate;
                Boolean flagCpEmail = (flag && String.isBlank(String.valueOf(activeToDate))) || 
                    (!flag && String.isNotBlank(String.valueOf(activeToDate)))? true : false;
                
                if (!isDoubleOptin) {
                    //Check if the current consent has contactPointTypeConsent with the correct status
                    flagCpTypeConsent = subscription.equals(label.LABS_ComSubscriptionChannelType_BackInStock) ? 
                        true : status.equals(consent.cpTypeConsent?.PrivacyConsentStatus) ? 
                            true : false;
                    //Check if the current consent has contactPointConsent with the correct status
                    flagCpConsent = subscription.equals(label.LABS_ComSubscriptionChannelType_BackInStock) ? 
                        true : status.equals(consent.cpConsent?.PrivacyConsentStatus) ? 
                            true : false;
                    //Check if the current consent has commSubscriptionConsent
                    flagComSubConsent = String.isNotBlank(consent.commSubConsent?.Id);
                    
                }else {
                    
                    //Check if the current consent has contactPointTypeConsent with the correct status
                    flagCpTypeConsent = (flag && status.equals(consent.cpTypeConsent?.PrivacyConsentStatus)) ||
                        (!flag && consent.cpTypeConsent == null) ? true  : false;
                    //In this case always the current consent hasn't ContactPointConsent
                    flagCpConsent = true;
                    //Check if the current consent has commSubscriptionConsent
                    flagComSubConsent = subscription.equals(label.LABS_ComSubscriptionChannelType_BackInStock) 
                        && String.isNotBlank(consent.commSubConsent?.Id) ? true : 
                    !(subscription.equals(label.LABS_ComSubscriptionChannelType_BackInStock)) ? true : false;
                }
                //CI-219 : add a debug Line 
                System.debug('**checkFullConsent : flagClientIndiv : ' + flagClientIndiv + 
                             '* flagCpEmail : '+ flagCpEmail+ 
                             '* flagCpTypeConsent: '+flagCpTypeConsent +
                             '* flagCpConsent: '+flagCpConsent+ 
                             '* flagComSubConsent: '+flagComSubConsent);
                //CreationFlag is the result of the two flags above
                flagFullConsent = flagClientIndiv && flagCpEmail && flagCpTypeConsent && flagCpConsent && flagComSubConsent;
                
                if (flagFullConsent) {
                    fullConsentList.add(consent);
                }  else {
                    //Debug Lines
                    System.debug('An error occurred when trying to create the consents for this account');
                    ConsentManagementHelper.debugConsentWrapperList(new list<ConsentWrapper>{consent},'Check ', currentUser);
                }
                
            } else {
                fullConsentList.add(consent);
            }
        }
        return fullConsentList;
    }
    
    /*
    * @description insert Individuals and update it within the consents
    *
    * @param consentListInput list of ConsentWrapper to be updated
    * @return list of consentWrapper updated with Individuals
    */
    @TestVisible 
    private static List<consentWrapper> insertIndividuals(List<consentWrapper> consentListInput) {
        Map<Id, Individual> individualToInsertMap = new Map<Id, Individual>();
        List<consentWrapper> ouputConsents = new List<consentWrapper>();

        //Get all individuals and put them in map
        for (ConsentWrapper consent : consentListInput) {
            //If the individual is not yet created
            if (consent.indiv.id == null) {
                individualToInsertMap.put(consent.client.Id, consent.indiv);
            } 
        }
        //Insert individuals
        if (!individualToInsertMap.isEmpty()) {
            Database.insert(individualToInsertMap.values(), AccessLevel.SYSTEM_MODE); 
        }

        for (ConsentWrapper consent : consentListInput) {    
            //In the current consent update, with the inserted Individual  & client with individualId
            if (individualToInsertMap.containsKey(consent.client.Id)) {
                //The individual attached to the current consent
                Individual individual = individualToInsertMap.get(consent.client.Id);
                consent.indiv = individual;
                consent.client.PersonIndividualId = individual.Id;
                consent.clientToUpdate = true;
            }
            ouputConsents.add(consent);
        }
        return ouputConsents;   
    }
    
    /**
    * @description Insert contactPointEmail and update it within the consents
    *
    * @param consentList list of ConsentWrapper to be updated
    * @return List of all consent which was updated with contactPointEmail
    */
    @TestVisible 
    private static List<consentWrapper> insertContactPointEmail(List<consentWrapper> consentList){  
        Map<Id, ContactPointEmail> contactPointEmailMap = new Map<Id, ContactPointEmail>();
        List<consentWrapper> consentListOuput = new List<consentWrapper>();

        //Get all contactPointEmails and put them in Map 
        for (ConsentWrapper consent : consentList) {
            //If the cpEmail is not yet created
            if (consent.cpEmail != null && consent.cpEmail.id == null) {
                consent.cpEmail.ParentId = consent.indiv.Id;
                contactPointEmailMap.put(consent.client.Id , consent.cpEmail);
            }
        }
        //Insert or update contactPointEmails
        if (!contactPointEmailMap.isEmpty()) {
            Database.insert(contactPointEmailMap.values(), AccessLevel.SYSTEM_MODE);
        }

        for (ConsentWrapper consent : consentList) {
            //In the current consent update Cpe 
            if (contactPointEmailMap.containsKey(consent.client.Id)) {
                consent.cpEmail = contactPointEmailMap.get(consent.client.Id);
            }
            consentListOuput.add(consent);
        }
        return consentListOuput; 
    }
    
    /*
    * @description update the consents with sObject
    *
    * @param consentListInput list of ConsentWrapper to be updated 
    * @param untypedMap map of sObject which will be updated in the consents 
    * @return list of consentWrapper updated with sObject
    */
    public static List<consentWrapper> updateConsentSOjectID(List<consentWrapper> consentListInput, Map<Id,SObject> untypedMap) {
         
        //Create a new map in order to update it throughout this method
        List<consentWrapper> consentListOutput = new List<consentWrapper>();
		
        for (consentWrapper consent : consentListInput) {
            Id accountId = consent.client.Id;
            //In the current consent update check if the map Contains the AccountID 
            if (untypedMap.containsKey(accountId)) {
                //Assing the record untyped from the Map for the current AccountID
                sObject untypedObject = untypedMap.get(accountId);
                //Check the sObjectType and Attribute the value of the ID to the relevant SObject
                switch on String.valueOf(untypedObject.getsObjectType()) {
                    when 'ContactPointTypeConsent' {		
                        consent.cpTypeConsent = (ContactPointTypeConsent)untypedObject;
                    }	
                    when 'ContactPointConsent' {
                        consent.cpConsent = (ContactPointConsent)untypedObject;
                    }
                }
            //CommSubscriptionConsent    
            } else if (untypedMap.containskey(consent.customInput.Id)) {
                sObject untypedObject = untypedMap.get(consent.customInput.Id);
                consent.commSubConsent = (CommSubscriptionConsent)untypedObject;
            }
            consentListOutput.add(consent);
        }
        return consentListOutput; 
    }
	
    /*
    * @description update contactPointEmail fields in the case optOut
    *
    * @param cpEmail which will be updated 
    * @param optoutDate date of the update day
    * @return contactPointTypeConsent updated
    */
    @TestVisible 
    private static contactPointEmail contactPointEmailOptoutHandler(contactPointEmail cpEmail, DateTime optoutDate){
        contactPointEmail outputCpEmail =  cpEmail;
        outputCpEmail.ActiveToDate = optoutDate.date();
        return outputCpEmail;
    }
    
    /*
    * @description update contactPointTypeConsent fields in the case optOut
    *
    * @param cpTypeConsent which will be updated 
    * @param optoutDate date of the update day
    * @return contactPointTypeConsent updated
    */
    @TestVisible 
    private static contactPointTypeConsent contactPointTypeConsentOptoutHandler(contactPointTypeConsent cpTypeConsent, DateTime optoutDate){
        contactPointTypeConsent outputCpTypeConsent =  cpTypeConsent;
        outputCpTypeConsent.PrivacyConsentStatus = System.Label.LABS_Consent_Optout;
        outputCpTypeConsent.EffectiveTo = optoutDate;
        return outputCpTypeConsent;
    }
	
    /*
    * @description update contactPointConsent fields in the case optOut
    *
    * @param contactPointConsent which will be updated 
    * @param optoutDate date of the update day
    * @return contactPointConsent updated
    */
    @TestVisible 
    private static contactPointConsent contactPointConsentOptoutHandler(contactPointConsent cpConsent, DateTime optoutDate){
        contactPointConsent outputCpConsent =  cpConsent;
        outputCpConsent.PrivacyConsentStatus = System.Label.LABS_Consent_Optout;
        outputCpConsent.EffectiveTo = optoutDate;
        return outputCpConsent;
    }
	
    /*
    * @description update CommSubscriptionConsent fields in the case optOut
    *
    * @param CommSubscriptionConsent which will be updated 
    * @param optoutDate date of the update day
    * @return CommSubscriptionConsent updated
    */
    @TestVisible 
    private static CommSubscriptionConsent commSubscriptionConsentOptoutHandler(CommSubscriptionConsent commSubConsent, Date optoutDate){
        CommSubscriptionConsent outputCommSubConsent =  commSubConsent;
        outputCommSubConsent.PrivacyConsentStatus = System.Label.LABS_Consent_Optout;
        outputCommSubConsent.EffectiveToDate = optoutDate;
        return outputCommSubConsent;
    }
}