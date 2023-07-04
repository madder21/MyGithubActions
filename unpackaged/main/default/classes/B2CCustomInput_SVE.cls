/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is used in order to run B2CCustomInput Management Process
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12062023			|.UMNN		|.					|.
*/
public without sharing class B2CCustomInput_SVE {

    public static List<ConsentWrapper> redirectLogic(List<B2CCustomInput__c> b2cCustomInputList) {
        System.debug('*** B2CCustomInput_SVE - redirectLogic - START***');
		List<B2CCustomInput__c> inputEmail = new List<B2CCustomInput__c>();
        List<ConsentWrapper> consentList = new List<ConsentWrapper> ();
        ConsentManagementHandler CMH = new ConsentManagementHandler();
        for(B2CCustomInput__c input : b2cCustomInputList){
			System.debug('*** input.SubscriptionName__c ' + input.SubscriptionName__c);
            if(input.SubscriptionName__c == System.Label.LABS_ComSubscriptionChannelType_Newsletter ||
               input.SubscriptionName__c == System.Label.LABS_ComSubscriptionChannelType_BackInStock
               ){
                inputEmail.add(input);
            }
        }
        System.debug('*** B2CCustomInput_SVE - redirectLogic - Custom Input CGI Ok***');
        B2CCustomInput_UTL customInputClass = new B2CCustomInput_UTL(b2cCustomInputList);
        customInputClass.runLegalConsentProcess();
        
        if(!inputEmail.isEmpty()){
            consentList = CMH.emailConsentHandler(inputEmail);
        }
        System.debug('*** B2CCustomInput_SVE - redirectLogic - END***');
        
        return consentList;  //Added by Abdelkhalek SAIDI on 26/06/2023 ---> in order to delete B2CCustomInput after insert
    }

    public static void buildAccountIndividualByCustomInput(List<B2CCustomInput__c> b2cCustomInputList) {
        System.debug('*** B2CCustomInput_SVE - buildAccountIndividualByCustomInput - START***');
        List<Individual> individualToBeUpdated = new List<Individual>();
        List<Account> accountToBeCreated = new List<Account>();
        Map<Id, Individual> acountIndividualMap = new Map<Id, Individual>();
        Map<Id, Individual> accIdIndividualIdMap =  B2CCustomInput_UTL.getAccIdIndividualId(b2cCustomInputList);
        Map<Id, Account> customInputIdAccountMap = B2CCustomInput_UTL.buildCustomInputIdAccountMap(b2cCustomInputList);
        
        for(B2CCustomInput__c customInput : b2cCustomInputList) {
            Account acc = customInputIdAccountMap.get(customInput.Id);
            System.debug('*** B2CCustomInput_SVE - buildAccountIndividualByCustomInput Account :' + acc);
            if(accIdIndividualIdMap.containsKey(acc.Id)) {
                Individual ind = accIdIndividualIdMap.get(acc.Id);
                ind.LastName  = acc.LastName;
                ind.Salutation = acc.Salutation;
                ind.BirthDate = acc.PersonBirthdate;
                individualToBeUpdated.add(ind);
                acountIndividualMap.put(acc.Id, ind);
            }else {
                System.debug('*** B2CCustomInput_SVE - buildAccountIndividualByCustomInput Account Lastname :' + acc.LastName);
                Individual indiv = new Individual(
                    LastName   = acc.LastName,
                    Salutation = acc.Salutation,
                    BirthDate  = acc.PersonBirthdate
                );
                acountIndividualMap.put(acc.Id, indiv);
            }
            
        }

        if(!individualToBeUpdated.isEmpty()) {
            update individualToBeUpdated;
        }

        if(!acountIndividualMap.values().isEmpty()) {
            try{
                insert acountIndividualMap.values();
            }catch(DMLException e) {//NOPMD
                System.debug('insert failed with this error message: '+e.getMessage());
            }finally {
                for(B2CCustomInput__c customInput : b2cCustomInputList) {
                    Account updatedAccount = customInputIdAccountMap.get(customInput.Id);
                    updatedAccount.PersonIndividualId = acountIndividualMap.get(customInput.AccountId__c).Id;
                    updatedAccount.OptinCGI__c = customInput.OptinCGI__c;
                    updatedAccount.OptinMarketingPartner__c = customInput.OptinMarketingPartner__c;
                    updatedAccount.LastUpdateOptinMarketingPartners__c = System.now();
                    updatedAccount.LastUpdateOptinCGI__c = System.now();
                    accountToBeCreated.add(updatedAccount);
                }
                System.debug('*** B2CCustomInput_SVE - buildAccountIndividualByCustomInput - accountToBeCreated *** '+accountToBeCreated);
                update accountToBeCreated;
            }
        }
        System.debug('*** B2CCustomInput_SVE - buildAccountIndividualByCustomInput - END***');
    }
    
}