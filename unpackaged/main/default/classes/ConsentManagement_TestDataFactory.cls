/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is responsible for creating instances of data objects for all test classes, 
 * 				in order to improve readability and reusability of code components 
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/
@isTest
public class ConsentManagement_TestDataFactory {
    
    @TestSetup
    static void setup() {
        //Create CommSubscriptionChannelType
        List<CommSubscriptionChannelType> channelTypeTestDataList = ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
    }
    
    /*
    * @description creates a new record of Account
    * 
    * @param doInsert either create or create and insert
    * @return the created account record
    */
    public static Account createAccount(Boolean doInsert) {
		Account acc = (Account) TestDataFactory.createSObject('Account');
        return acc;
	}
    
    /*
    * @description creates multiple records of Account
    * 
    * @param doInsert either create or create and insert
    * @param numberOfAccount the of the account to be inserted
    * @return the created list of account records
    */
	public static List<Account> createAccounts(Boolean doInsert, Integer numberOfAccount) {
		List<Account> accList = TestDataFactory.createSObjectList('Account', numberOfAccount);
        return accList;
	}
   
    /*
    * @description creates a new record of Individual
    * 
    * @param doInsert either create or create and insert
    * @return the created account Individual
    */
    public static Individual createIndividual(Boolean doInsert){
        Individual indiv = (Individual) TestDataFactory.createSObject('Individual');
        return indiv;
    }
    
    /*
    * @description creates multiple records of Individual
    * 
    * @param doInsert either create or create and insert
    * @param numberOfIndividual the of the Individual to be inserted
    * @return the created list of Individual records
    */
    public static List<Individual> createIndividuals(Boolean doInsert, Integer numberOfIndividual) {
		List<Individual> indivList = TestDataFactory.createSObjectList('Individual', numberOfIndividual);
        return indivList;
	}
    
    /*
    * @description creates a new record of B2CCustomInput
    * 
    * @param doInsert either create or create and insert
    * @param accountId the Id of an account which will be attached to the B2CCustomInput
    * @return the created B2CCustomInput record
    */
    public static B2CCustomInput__c createB2CCustomInput(Boolean doInsert, String accountID){

        B2CCustomInput__c outputRecord = new B2CCustomInput__c(AccountID__c = accountID);
        if(doInsert) insert outputRecord;
        return outputRecord;
    }

    /*
    * @description creates multiple records of B2CCustomInput
    * 
    * @param doInsert either create or create and insert
    * @param accountList list of account records to be attached to the B2CCustomInput 
    * @return the created list of B2CCustomInput records
    */
    public static List<B2CCustomInput__c> createB2CCustomInputs(Boolean doInsert,  List<Account> accountList){
        List<B2CCustomInput__c> outputRecords = new List<B2CCustomInput__c>();
        for(Account aAccount : accountList){
            outputRecords.add(new B2CCustomInput__c(AccountID__c = aAccount.Id));
        }       
        if(doInsert) insert outputRecords;

        return outputRecords;
    }

    /*
    * @description creates CommSubscriptionChannelType
    * 
    * @return the created list of CommSubscriptionChannelType record
    */
    public static List<CommSubscriptionChannelType> createCommSubscriptionChannelType(){
        List<CommSubscriptionChannelType> listCommSubChannelTypes = new List<CommSubscriptionChannelType>();
        List <CommSubscription> listCommSubscriptions = new List <CommSubscription>();

		//Create Three CommSubscription
        CommSubscription commSub1 = new CommSubscription();
        commSub1.Name = 'Test_CommSubscription1';
        listCommSubscriptions.add(commSub1);
        CommSubscription commSub2 = new CommSubscription();
        commSub2.Name = 'Test_CommSubscription2';
        listCommSubscriptions.add(commSub2);
        CommSubscription commSub3 = new CommSubscription();
        commSub3.Name = 'Test_CommSubscription3';
        listCommSubscriptions.add(commSub3);
        insert listCommSubscriptions;
        System.debug('**listCommSubscriptions Created** - listCommSubscriptions :  ' + listCommSubscriptions);
        
        //Create EngagementChannelType
        EngagementChannelType engChannelType = new EngagementChannelType();
        engChannelType.Name = 'Test EngagementChannelType';
        insert engChannelType;

        //Create Three CommSubscriptionChannelType
        CommSubscriptionChannelType commSubChannelType1 = new CommSubscriptionChannelType();
        commSubChannelType1.Name = 'Newsletter';
        commSubChannelType1.EngagementChannelTypeId = engChannelType.Id;
        commSubChannelType1.CommunicationSubscriptionId = commSub1.Id;
        listCommSubChannelTypes.add(commSubChannelType1);
        CommSubscriptionChannelType commSubChannelType2 = new CommSubscriptionChannelType();
        commSubChannelType2.Name = 'BackInStock';
        commSubChannelType2.EngagementChannelTypeId = engChannelType.Id;
        commSubChannelType2.CommunicationSubscriptionId = commSub2.Id;
        listCommSubChannelTypes.add(commSubChannelType2);
        CommSubscriptionChannelType commSubChannelType3 = new CommSubscriptionChannelType();
        commSubChannelType3.Name = 'SpecialEvent';
        commSubChannelType3.EngagementChannelTypeId = engChannelType.Id;
        commSubChannelType3.CommunicationSubscriptionId = commSub3.Id;
        listCommSubChannelTypes.add(commSubChannelType3);
        insert listCommSubChannelTypes;
        System.debug('**listCommSubChannelTypes Created** - listCommSubChannelTypes :  ' + listCommSubChannelTypes);
        
        return listCommSubChannelTypes;
    }
	
    /*
    * @description updates the fields of accounts and individuals
    * 
    * @return the list of account records which were updated
    */
    public static List<Account> updateAccountAndIndividual() {
        
        //Get All Accounts
        List<Account> accountList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                        PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                        (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r) FROM Account];
        //Get All Individuals
        List<Individual> individualList = [SELECT Id, LastName, Salutation, BirthDate FROM Individual ORDER BY CreatedDate];

        //Update Account & Individual
        for (Integer i=0; i < accountList.size(); i++) {

            Account aAccount = accountList[i];
            Individual indiv = individualList[i];

            //Update Individual data
            indiv.LastName = 'Test ' + i; 
            indiv.Salutation = 'Salutation ' + i; 
            indiv.BirthDate = aAccount.PersonBirthdate;
            
            //Update Account data
            aAccount.OptinEmailing__pc = true;
            aAccount.PersonIndividualId = indiv.Id;
            aAccount.LastName = 'Test ' + i;
            aAccount.Salutation = '1';
            aAccount.Phone = '012345678' + i;
            //aAccount.PersonBirthdate = Datetime.now().date();
            aAccount.PersonEmail = 'test' + i +'@gmail.com';
            aAccount.WebsiteLocale__pc = 'FR';
            aAccount.WebsiteCountry__pc = 'FR';
            aAccount.Country__pc = 'FR';
            accountList[i] = aAccount;

        }
		
        //Update Data in Database
        update accountList;
        update IndividualList;
        

        return accountList;
    }
	
    /*
    * @description updates the fields of B2CCustomInputs
    * 
    * @return the list of B2CCustomInput records which were updated
    */
    public static List<B2CCustomInput__c> updateB2CCustomInput(String subscriptionName) {

        List<B2CCustomInput__c> customInputMap= new List<B2CCustomInput__c>();
        
        //Get All B2CCustomInputs
        List<B2CCustomInput__c> customInputList = [SELECT AccountId__c, AddressConsent__c, BackInStockSubscriptionSKU__c, 
                                                        CaptureContactPointType__c, CaptureSource__c, Company__c, Warehouse__c,
                                                        contactPointType__c, CurrencyIsoCode, CustomContactPointType__c,
                                                        EmailConsent__c, Name, OptinCGI__c, OptinMessaging__c, OptinPhone__c,
                                                        OptOutContactPointType__c, SaleChannel__c, Store__c, SubscriptionName__c
                                                        FROM B2CCustomInput__c ];

        //Update B2CCustomInput data
        for (Integer i=0; i < customInputList.size(); i++) {

            B2CCustomInput__c customInput = customInputList[i];
            customInput.AddressConsent__c = false;
            customInput.BackInStockSubscriptionSKU__c = 'SKU ' + i;
            customInput.CaptureContactPointType__c = 'Web';
            customInput.CaptureSource__c = 'SFDC Contact Process';
            customInput.Company__c = 'Company ' + i;
            customInput.Warehouse__c = 'Warehouse ' + i;
            customInput.contactPointType__c = null;
            customInput.CustomContactPointType__c = 'SFDC';
            customInput.EmailConsent__c = true;
            customInput.OptinCGI__c = false;
            customInput.OptinMessaging__c = false;
            customInput.OptinPhone__c = false;
            customInput.OptOutContactPointType__c = 'SFDC';
            customInput.SaleChannel__c = 'Sale Channel ' + i;
            customInput.Store__c = 'Store ' + i;
            customInput.SubscriptionName__c = subscriptionName;
            customInputList[i] = customInput;
        }

        
       	//Update Data in Database
       	update customInputList;
        
        

        return customInputList;

    }
	
    /*
    * @description creates multiple B2CCustomInput record for the the same account
    * 
    * @param aAccountId the Id of an account which will be attached to the B2CCustomInput
    * @return the created list of B2CCustomInput record
    */
    public static List<B2CCustomInput__c> createMultipleB2CCustomInputForAccount(Id aAccountId) {

        List<B2CCustomInput__c> customInputList= new List<B2CCustomInput__c>();
        List<String> subscriptionNameList = new List<String>{'Newsletter', 'BackInStock', 'SpecialEvent'};

        //Create B2CCustomInput data
        Integer i=0;
        for (String subscriptionName : subscriptionNameList) {

            B2CCustomInput__c customInput = new B2CCustomInput__c();
            customInput.AddressConsent__c = false;
            customInput.BackInStockSubscriptionSKU__c = 'SKU ' + i;
            customInput.CaptureContactPointType__c = 'Web';
            customInput.CaptureSource__c = 'SFDC Contact Process';
            customInput.Company__c = 'Company ' + i;
            customInput.Warehouse__c = 'Warehouse ' + i;
            customInput.contactPointType__c = null;
            customInput.CustomContactPointType__c = 'SFDC';
            customInput.EmailConsent__c = true;
            customInput.OptinCGI__c = false;
            customInput.OptinMessaging__c = false;
            customInput.OptinPhone__c = false;
            customInput.OptOutContactPointType__c = 'SFDC';
            customInput.SaleChannel__c = 'Sale Channel ' + i;
            customInput.Store__c = 'Store ' + i;
            customInput.SubscriptionName__c = subscriptionName;
            customInputList.add(customInput);
            i++;
        }
		
        //Insert Data in Database
        insert customInputList;
        

        return customInputList;

    }
	
    /*
    * @description creates multiple records of ContactPointEmail
    * 
    * @param accountList list of account records to be attached to the ContactPointEmail 
    * @return the created list of ContactPointEmail records
    */
    public static List<ContactPointEmail> CreateContactPointEmail(List<Account> accountList) {
        
        List<ContactPointEmail> cpEmailList = new List<ContactPointEmail>();

        for (Account aAccount : accountList) {
            
            ContactPointEmail cpEmail = new ContactPointEmail();
            cpEmail.EmailAddress = aAccount.PersonEmail;
            cpEmail.ParentId = aAccount.PersonIndividualId;
            cpEmail.AccountId__c = aAccount.Id;
            cpEmail.ActiveFromDate =  DateTime.now().Date();
            cpEmailList.add(cpEmail);
        }
        
        //Update Data in Database
        insert cpEmailList;
        
        
        
        return cpEmailList;
    }
	
    /*
    * @description creates multiple records of ContactPointTypeConsent
    * 
    * @param accountList list of account records to be attached to the ContactPointTypeConsent 
    * @return the created list of ContactPointTypeConsent records
    */
    public static List<ContactPointTypeConsent> createContactPointTypeConsent(List<Account> accountList) {
        
        List<ContactPointTypeConsent> cptcList = new List<ContactPointTypeConsent>();

        for (Account aAccount : accountList) {
            
            ContactPointTypeConsent cptc = new ContactPointTypeConsent ();
            cptc.AccountId__c = aAccount.Id;
            cptc.PartyId = aAccount.PersonIndividualId;
            cptc.Name = 'Test';
            cptc.PartyId = aAccount.PersonIndividualId;
            cptc.ContactPointType = 'Email';
            cptc.PrivacyConsentStatus = 'Optin';
            cptc.EffectiveFrom = System.now();
            cptc.CaptureDate = System.now();
            cptc.CaptureContactPointType = 'Web';
            cptc.CaptureSource = 'SFDC Contact Process';
            cptc.OptOutContactPointType__c   = 'SFDC';
            cptc.CustomContactPointType__c   = 'SFDC';
            cptcList.add(cptc);
    
        }
        //Update Data in Database
        insert cptcList;
        
        

        return cptcList;

    }
	
    /*
    * @description creates multiple records of ContactPointConsent
    * 
    * @param accountList list of account records to be attached to the ContactPointConsent 
    * @return the created list of ContactPointConsent records
    */
    public static List<ContactPointConsent> createContactPointConsent(List<ContactPointEmail> cpEmailList) {
        
        List<ContactPointConsent> cpcList = new List<ContactPointConsent>();

        for (ContactPointEmail cpEmail : cpEmailList) {
            
            ContactPointConsent cpc = new ContactPointConsent();
            cpc.Name = 'Test 1';
            cpc.ContactPointId  = cpEmail.Id;
            cpc.PrivacyConsentStatus = 'Optin';
            cpc.EffectiveFrom = Datetime.now();
            cpc.CaptureDate  = Datetime.now();
            cpc.CaptureContactPointType  = 'Web';
            cpc.CaptureSource  = 'SFDC Contact Process';
            cpc.OptOutContactPointType__c  = 'SFDC';
            cpc.CustomContactPointType__c  = 'SFDC';
            cpc.DoubleOptInHash__c =  null;
            cpc.AccountId__c = cpEmail.AccountId__c;
            cpcList.add(cpc);
    
        }
        //Update Data in Database
        insert cpcList;
        
        

        return cpcList;
           
    }
	
    /*
    * @description creates multiple records of ConsentWrapper
    * 
    * @param accountList list of account records to be attached to the ConsentWrapper 
    * @param customInputList list of B2CCustomInput records to be attached to the ConsentWrapper
    * @return the created list of ConsentWrapper records
    */
    public static List<ConsentWrapper> createConsent(List<B2CCustomInput__c> customInputList, List<Account> accountList) {
        List<ConsentWrapper> consentList = new List<ConsentWrapper>();
        Set<Id> customInputIdSet = new Set<Id>();
        for (Account aAccount : accountList) {
            for(B2CCustomInput__c customInput : customInputList) {
                if (aAccount.Id == customInput.AccountId__c && !customInputIdSet.contains(customInput.Id)) {
                    ConsentWrapper consent = new ConsentWrapper(customInput, aAccount);
                    consentList.add(consent);
                    customInputIdSet.add(customInput.Id);
                }
            }
        }
        return consentList;
    }
	
    /*
    * @description updates ConsentWrapper with ContactPointConsent
    * 
    * @param consentInputList list of ConsentWrapper to be update throughout this method
    * @param cpConsentList list of ContactPointConsent records which will populate the ConsentWrapper
    * @return the created list of ConsentWrapper records
    */
    public static List<ConsentWrapper> updateConsent(List<ConsentWrapper> consentInputList, List<ContactPointConsent> cpConsentList) {
        List<ConsentWrapper> consentOuputList = new List<ConsentWrapper>();
        for (ConsentWrapper consent : consentInputList) {
            for (ContactPointConsent cpConsent : cpConsentList) {
                if (cpConsent.AccountId__c == consent.client.Id) {
                    consent.cpConsent = cpConsent;
                    break;
                }
            }
            consentOuputList.add(consent);

        }
        return consentOuputList;
    }



    
}