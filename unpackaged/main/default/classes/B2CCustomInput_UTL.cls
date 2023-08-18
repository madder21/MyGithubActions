/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description 
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12062023			|.UMNN		|.					|.
*/
public without sharing class B2CCustomInput_UTL {
    
    // Attribute definition - START
    public List<Account> accs;
    public List<AuthorizationFormConsent> authFormConsentList;
    public List<Id> individualIdList;
    public List<AuthorizationFormText> authFormTextList;
    public List<AuthorizationForm> authFormList;
    public List<B2CCustomInput__c> b2cCustomInputList;
    public Map<Id, Account> customInputIdAccountMap;
    // Attribute definition - END

    /**
     * @description: Constructor
     * @param: Account - List of Accounts get from Datamigration / SFCC Callout
     * @param: B2CContactProcessCustomInput - Custom Wrapper used to handle consent information
     */
    public B2CCustomInput_UTL(List<B2CCustomInput__c> b2cCustomInputList) {
        this.b2cCustomInputList = b2cCustomInputList;
        this.customInputIdAccountMap = new Map<Id, Account>();
        this.accs = getAccountByCustomInput();
        this.individualIdList = getIndividualIdListFromAccounts();
        this.authFormConsentList = retrievedAuthFormConsent();
        this.authFormTextList = retrievedAuthFormText();
        this.authFormList = retrievedAuthForm();
    }

    public List<Account> getAccountByCustomInput() {
        System.debug('*** B2CCustomInput_UTL - getAccountByCustomInput - START***');
        List<Id> accountListID = new List<Id>();
        List<Account> accountList = new List<Account>();
        for(B2CCustomInput__c customInput : this.b2cCustomInputList) {
            accountListID.add(customInput.AccountId__c);
        }
        List<Account> retrievedAccountList = [SELECT Id, PersonIndividualId, OptinCGI__c FROM Account WHERE Id IN: accountListID];//NOPMD
        for(B2CCustomInput__c customInput : this.b2cCustomInputList) {
            for(Account acc : retrievedAccountList) {
                accountList.add(acc);
                if(customInput.AccountId__c == acc.Id) {
                    System.debug('Madder');
                    this.customInputIdAccountMap.put(customInput.Id, acc);
                } 
            }
        }
        System.debug('*** B2CCustomInput_UTL - getAccountByCustomInput - END - accountList***: '+accountList);
        return accountList;
    }

    public static Map<Id, Individual> getAccIdIndividualId(List<B2CCustomInput__c> b2cCustomInputList) {
        System.debug('*** B2CCustomInput_UTL - getAccIdIndividualId - START***');
        List<Id> accountListID = new List<Id>();
        // Map<Id, Id> accIdIndividualMap = new Map<Id, Id>();
        List<Id> individualId = new List<Id>();
        List<Account> accList = new List<Account>();
        Map<Id, Individual> accIndividualMap = new Map<Id, Individual>();
        for(B2CCustomInput__c customInput : b2cCustomInputList) {
            accountListID.add(customInput.AccountId__c);
        }
        for(Account acc : [SELECT Id, PersonIndividualId, OptinCGI__c, PersonBirthdate, LastName, Salutation FROM Account WHERE Id IN: accountListID]) {//NOPMD
            if(acc.PersonIndividualId != null) {
                // accIdIndividualMap.put(acc.Id, acc.PersonIndividualId);
                individualId.add(acc.PersonIndividualId);
                accList.add(acc);
            }            
        }

        for(Individual ind : [SELECT Id, Salutation, FirstName, LastName FROM Individual WHERE Id IN: individualId]) {//NOPMD
            for(Account acc : accList) {
                if(ind.Id == acc.PersonIndividualId) {
                    accIndividualMap.put(acc.Id, ind);
                }
            }
        }

        return accIndividualMap;
    }

    public static Map<Id, Account> buildCustomInputIdAccountMap(List<B2CCustomInput__c> b2cCustomInputList) {
        Map<Id, Account> customInputIdAccountMap = new Map<Id, Account>();
        List<Id> accountListID = new List<Id>();
        for(B2CCustomInput__c customInput : b2cCustomInputList) {
            accountListID.add(customInput.AccountId__c);
        }
        //Modified by Abdelkhalek SAIDI on 20/05/2023
        //OLD line
        //List<Account> retrievedAccountList = [SELECT Id, PersonIndividualId, OptinCGI__c FROM Account WHERE Id IN: accountListID];//NOPMD
        //New line
        List<Account> retrievedAccountList = [SELECT Id, LastName, Salutation, PersonBirthdate, PersonIndividualId, OptinCGI__c FROM Account WHERE Id IN: accountListID];
        for(B2CCustomInput__c customInput : b2cCustomInputList) {
            for(Account acc : retrievedAccountList) {
                if(customInput.AccountId__c == acc.Id) {
                    customInputIdAccountMap.put(customInput.Id, acc); 
                }
            }
        }

        return customInputIdAccountMap;
    }

    public List<Id> getIndividualIdListFromAccounts() {
        System.debug('*** B2CCustomInput_UTL - getIndividualIdListFromAccounts - START***');
    	List<Id> individualIdList = new List<Id>();
        if(!accs.isEmpty()) {
        	for(Account acc : this.accs) {
             	individualIdList.add(acc.PersonIndividualId);
            }
        }
        System.debug('*** B2CCustomInput_UTL - getIndividualIdListFromAccounts - END - individualIdList***: '+individualIdList);
        return individualIdList;
	}
    
    public List<AuthorizationFormConsent> retrievedAuthFormConsent() {
        System.debug('*** B2CCustomInput_UTL - retrievedAuthFormConsent***');
    	return [SELECT Id, Name, AuthorizationFormTextId, ConsentCapturedDateTime, ConsentCapturedSource, ConsentCapturedSourceType, ConsentGiverId //NOPMD
        		FROM AuthorizationFormConsent 
                WHERE ConsentGiverId IN: this.individualIdList];
    }
    
	public List<AuthorizationFormText> retrievedAuthFormText() {
        System.debug('*** B2CCustomInput_UTL - retrievedAuthFormText***');
    	List<Id> authFormConsentIdList = new List<Id>();
        for(AuthorizationFormConsent authFormConsent : this.authFormConsentList) {
        	authFormConsentIdList.add(authFormConsent.AuthorizationFormTextId);
        }
        return [SELECT Id, Name, AuthorizationFormId, Locale //NOPMD
                FROM AuthorizationFormText 
                WHERE Id IN: authFormConsentIdList];
	}
    
    public List<AuthorizationForm> retrievedAuthForm() {
        System.debug('*** B2CCustomInput_UTL - retrievedAuthForm***');
    	List<Id> authFormIdList = new List<Id>();
        for(AuthorizationFormText authFormText : this.authFormTextList) {
        	authFormIdList.add(authFormText.AuthorizationFormId);
        }
        return [SELECT Id, Name, DefaultAuthFormTextId, EffectiveFromDate, EffectiveToDate //NOPMD
                FROM AuthorizationForm 
                WHERE Id IN: authFormIdList];
	}
    
   	public void createAuthorizationForms(List<Account> accountList) {
        System.debug('*** B2CCustomInput_UTL - createAuthorizationForms - START***');
        ConsentInfo__mdt consentInfo = ConsentInfo__mdt.getInstance('CGIConsent');
        System.debug('*** B2CCustomInput_UTL - createAuthorizationForms - consentInfo***: '+consentInfo);
        List<AuthorizationForm> authFormToBeCreated = new List<AuthorizationForm>();
        Map<Id, List<AuthorizationForm>> accAuthForMap = new Map<Id, List<AuthorizationForm>>();

        for(Account acc : accountList) {
            if(acc.OptinCGI__c) {
                authFormToBeCreated.add(new AuthorizationForm(
                    Name = consentInfo.DeveloperName,
                    EffectiveFromDate = Date.today(),
                    EffectiveToDate = null));
                accAuthForMap.put(acc.Id, authFormToBeCreated);
            }  
        }
        if(!authFormToBeCreated.isEmpty()) {
            System.debug('*** B2CCustomInput_UTL - createAuthorizationForms - authFormToBeCreated***: '+authFormToBeCreated);
            insert authFormToBeCreated;
            createAuthorizationFormText(accAuthForMap);
        }
   	} 
    
    public void createAuthorizationFormText(Map<Id, List<AuthorizationForm>> accAuthForMap) {
        System.debug('*** B2CCustomInput_UTL - createAuthorizationFormText - START***');
    	List<AuthorizationFormText> authFormTextToBeCreated = new List<AuthorizationFormText>();
        Map<Id, List<AuthorizationFormText>> accAuthFormTextMap = new Map<Id, List<AuthorizationFormText>>();
        for(Id accId : accAuthForMap.keySet()) {
            for(AuthorizationForm authForm : accAuthForMap.get(accId)) {
                AuthorizationFormText authFormText = new AuthorizationFormText(
                    Name = authForm.Name,
                    AuthorizationFormId = authForm.Id
                );
                authFormTextToBeCreated.add(authFormText);
                accAuthFormTextMap.put(accId, authFormTextToBeCreated);
            }
        }
        if(!authFormTextToBeCreated.isEmpty()) {
            insert authFormTextToBeCreated;
            System.debug('*** B2CCustomInput_UTL - createAuthorizationFormText - authFormTextToBeCreated***: '+authFormTextToBeCreated);
            buildAuthorizationFormConsent(accAuthFormTextMap);
        }
        System.debug('*** B2CCustomInput_UTL - createAuthorizationFormText - END***: '+authFormTextToBeCreated);
    }
    
    public void buildAuthorizationFormConsent(Map<Id, List<AuthorizationFormText>> accAuthFormTextMap) {
        System.debug('*** B2CCustomInput_UTL - buildAuthorizationFormConsent - START***');
        List<AuthorizationFormConsent> authFormConsentList = new List<AuthorizationFormConsent>();
        for(B2CCustomInput__c customInput : this.b2cCustomInputList) {
            for(AuthorizationFormText authFormText : accAuthFormTextMap.get(customInput.AccountId__c)) {
                if(this.customInputIdAccountMap.containsKey(customInput.Id)) {
                    authFormConsentList.add(new AuthorizationFormConsent(Name = authFormText.Name,
                                                                         AuthorizationFormTextId = authFormText.Id,
                                                                         ConsentCapturedDateTime = System.today(),
                                                                         ConsentCapturedSource = customInput.CaptureSource__c,
                                                                         ConsentGiverId = this.customInputIdAccountMap.get(customInput.Id).PersonIndividualId, 
                                                                         ConsentCapturedSourceType = customInput.CaptureContactPointType__c));
                }
            }
        }

        if(!authFormConsentList.isEmpty()) {
            insert authFormConsentList;
        }
        System.debug('*** B2CCustomInput_UTL - buildAuthorizationFormConsent - END***: '+authFormConsentList);
    }

    /**
     * @description: this method is used in other to update Authorization Form records
     */
    public void updateAuthorizationForm(Map<Id, List<AuthorizationForm>> mapAuthFormToBeUpdated) {
        System.debug('*** B2CCustomInput_UTL updateAuthorizationForm - START ***');
        Map<Id, Account> accountMap = new Map<Id, Account>(this.accs);//Map of Account to be used in the current process
        List<AuthorizationForm> authFormToBeUpdated = new List<AuthorizationForm>();
        for(Id accId: mapAuthFormToBeUpdated.keySet()) {
            for(AuthorizationForm authForm : mapAuthFormToBeUpdated.get(accId)) {
                //check if the current user has already a CGI consent and revert his choice
                if(!accountMap.get(accId).OptinCGI__c && authForm.EffectiveFromDate != null) {
                    authForm.EffectiveToDate = Date.today();
                }
                System.debug('accountMap.get(accId).OptinCGI__c: '+accountMap.get(accId).OptinCGI__c);
                //check if the current user does not have a CGI consent
                if(accountMap.get(accId).OptinCGI__c) {
                    authForm.EffectiveFromDate = Date.today();
                    authForm.EffectiveToDate = null;
                }
                authFormToBeUpdated.add(authForm);
            }
        }
        if(!authFormToBeUpdated.isEmpty()){
            update authFormToBeUpdated;
            updateAuthorizationFormConsent(authFormToBeUpdated);
        }
        System.debug('*** B2CCustomInput_UTL updateAuthorizationForm - END ***');
    }

    public void updateAuthorizationFormConsent(List<AuthorizationForm> authFormToBeUpdated) {
        System.debug('*** B2CCustomInput_UTL updateAuthorizationFormConsent - START ***');
        List<Id> authformIds = new List<Id>();
        for(AuthorizationForm authFormId: authFormToBeUpdated) {
            authformIds.add(authFormId.Id);
        }
        List<AuthorizationFormText> retrievedAuthFormText = [SELECT Id, AuthorizationFormId //NOPMD
                                                             FROM AuthorizationFormText 
                                                             WHERE AuthorizationFormId IN: authformIds];
        List<AuthorizationFormConsent> retrievedAuthFormConsent = [SELECT Id, ConsentCapturedDateTime, ConsentCapturedSource, ConsentGiverId, ConsentCapturedSourceType, AuthorizationFormTextId //NOPMD
                                                                    FROM AuthorizationFormConsent 
                                                                    WHERE AuthorizationFormTextId IN: retrievedAuthFormText];
        for(B2CCustomInput__c customInput : this.b2cCustomInputList) {
            for(AuthorizationFormConsent authFormConsent : retrievedAuthFormConsent) {
                if(this.customInputIdAccountMap.get(customInput.Id).PersonIndividualId == authFormConsent.ConsentGiverId) {
                    authFormConsent.ConsentCapturedDateTime = System.today();
                    authFormConsent.ConsentCapturedSource = customInput.CaptureSource__c;
                    authFormConsent.ConsentCapturedSourceType = customInput.CaptureContactPointType__c;
                }
            }
        }
            
        if(!retrievedAuthFormConsent.isEmpty()) {
            update retrievedAuthFormConsent;
        }
        System.debug('*** B2CCustomInput_UTL updateAuthorizationFormConsent - START ***');        
    }

    /**
     * @description: This method is used to run the process needed to create/update CGI Consent flow
     */
    public void runLegalConsentProcess() {
        System.debug('*** B2CCustomInput_UTL runLegalConsentProcess - START ***');
        List<Account> accWithoutauthForm = new List<Account>();//List of Accounts without any authorization Form
        List<AuthorizationForm> authFormToBeUpdated = new List<AuthorizationForm>();//Authorization Form that need to be updated
        Map<Id, Id> mapAuthFormId = new Map<Id, Id>();//Map of Authorization Form Id and Individual Id
        Map<Id, Id> mapAuthFormTextIdIndividualId = new Map<Id, Id>();//Map of Authorization Form Text Id and Indivi
        Map<Id, List<AuthorizationForm>> mapAuthFormToBeUpdated = new Map<Id, List<AuthorizationForm>>();//Map of account Id and authorization Form List
        
        for(AuthorizationFormConsent authFormConsent : this.authFormConsentList) {
            mapAuthFormTextIdIndividualId.put(authFormConsent.AuthorizationFormTextId, authFormConsent.ConsentGiverId);
        }
        for(AuthorizationFormText authFormText : this.authFormTextList) {
            mapAuthFormId.put(authFormText.AuthorizationFormId, mapAuthFormTextIdIndividualId.get(authFormText.Id));
        }
        for(Account acc : this.accs) {
            //check if authorization form list is not empty
            if(!this.authFormList.isEmpty()) {
                for(AuthorizationForm authForm : this.authFormList) {
                    //check if the current account is already linked to an authorization form
                    if(mapAuthFormId.containsKey(authForm.Id) && acc.PersonIndividualId == mapAuthFormId.get(authForm.Id)){
                        //add the current authorization form through the list of AuthorizationForm that need to be updated
                        authFormToBeUpdated.add(authForm);
                        //build a map of account Id and list of Authorization Form that need to be updated
                        mapAuthFormToBeUpdated.put(acc.Id, authFormToBeUpdated);
                    }else{
                        //if the current account does not link with any authorization form then add the account through the list of account that need an authorization form
                        accWithoutauthForm.add(acc);
                    }
                }
            }else {
                //init case - there is no Authorization Form record on the database
                accWithoutauthForm.add(acc);
            }
        }
        //check the list of account without any Authorization Form is not empty
        if(!accWithoutauthForm.isEmpty()) {
            //Create authorization form
            createAuthorizationForms(accWithoutauthForm);
        }
        //check if there are some authorization form
        if(!authFormToBeUpdated.isEmpty()) {
            updateAuthorizationForm(mapAuthFormToBeUpdated);
        }
        System.debug('*** B2CCustomInput_UTL runLegalConsentProcess - END ***');
    }
}