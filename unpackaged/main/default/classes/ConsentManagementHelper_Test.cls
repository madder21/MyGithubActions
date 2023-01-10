//the name of this class should be replaced -this is for custom input logic test

 
@IsTest
private class ConsentManagementHelper_Test {
    Static List <ConsentManagementFlowInputs> listCustomInputs1 = new List<ConsentManagementFlowInputs>();
    Static List <ConsentManagementFlowInputs> listCustomInputs2 = new List <ConsentManagementFlowInputs>();
    Static List <ConsentManagementFlowInputs> listCustomInputs3 = new List <ConsentManagementFlowInputs>();
    Static List <ConsentManagementFlowInputs> listCustomInputs4 = new List <ConsentManagementFlowInputs>();
    Static List <Account> staticAccountsList = new List <Account>();
    //@testSetup
    @IsTest
    static void setup() {
        
        List<CommSubscriptionChannelType> listCommSubChannelTypes = new List<CommSubscriptionChannelType>();
        List <CommSubscription> listCommSubscriptions = new List <CommSubscription>();
        List <Account> accounts = new List <Account>();
        Map <Id,Contact> contactsByAccountId = new Map <Id,Contact>();
        List <Individual> individuals = new List <Individual>();
        List <ContactPointEmail> listContactPointEmail = new List <ContactPointEmail>();
        List <ContactPointTypeConsent> listConPointTypeCons = new List <ContactPointTypeConsent>();
        List <ContactPointConsent> listConPointCons = new List <ContactPointConsent>();
        
        Individual individual = new Individual();
        individual.LastName='individual Test';
        individuals.add(individual);
        Individual individual2 = new Individual();
        individual2.LastName='individual Test22';
        individuals.add(individual2);
        insert individuals;
        //return recordtypeId personAccount
        RecordType personAccount = [Select Id, Name from recordType where IsPersonType = true limit 1];
        //Account for Test personAccount logic
        Account account =  new Account();
        account.LastName='Account1';
		account.PersonEmail = 'Account.test@gmail.com';
        account.B2C_Customer_ID__pc = 'abKveEa2SaQRM0000';
		account.B2C_Customer_No__pc = '000170000';
        account.Country__pc = 'DE';
        account.LastUpdateOptinEmailing__pc = System.now();
        account.RecordTypeId  = personAccount.Id;
        account.OptinEmailing__pc = true;
        account.PersonIndividualId = individual.Id;
        accounts.add(account);
        //Account 2
        Account account2 =  new Account();
        account2.LastName='Account2';
		account2.PersonEmail = 'Account.test2@gmail.com';
        account2.B2C_Customer_ID__pc = 'abKveEa2SaQRM0054s00';
		account2.B2C_Customer_No__pc = '000170sdsd000';
        account2.LastUpdateOptinEmailing__pc = System.now();
        account2.RecordTypeId  = personAccount.Id;
        accounts.add(account2);
        //Account 3 
        Account account3 =  new Account();
        account3.LastName='Account3';
		account3.PersonEmail = 'Account.test3@gmail.com';
        account3.B2C_Customer_ID__pc = 'abKveEa2dsfdsnfksd4s00';
		account3.B2C_Customer_No__pc = '000175465456d000';
        account3.RecordTypeId  = personAccount.Id;
        account3.LastUpdateOptinEmailing__pc = System.now();
        accounts.add(account3);
        //Account 4
        Account account4 =  new Account();
        account4.LastName='Account4';
		account4.PersonEmail = 'Account.test4@gmail.com';
        account4.B2C_Customer_ID__pc = 'abKveEa2SaQRM0004';
		account4.B2C_Customer_No__pc = '000170004';
        account4.Country__pc = 'FR';
        account4.LastUpdateOptinEmailing__pc = System.now();
        account4.RecordTypeId  = personAccount.Id;
        account4.OptinEmailing__pc = true;
        accounts.add(account4);
        insert accounts;
        ConsentManagementHelper_Test.staticAccountsList.addAll(accounts);
        System.debug('**Inserted Accounts '+accounts);
        //System.debug('**Inserted Account It is a person account '+account.IsPersonAccount);
        List <Contact> contacts = [Select Id,AccountId , Name , Email,B2C_Customer_ID__c,B2C_Customer_No__c from Contact];
        System.debug('&&&&& Contacts Creared from Accounts : &&&&& '+contacts);

        for(Contact con : contacts){
            contactsByAccountId.put(con.AccountId,con);
        }
        //~~~~~~~~~~~~~~customInput1
        ConsentManagementFlowInputs customInput = new ConsentManagementFlowInputs();
        //Add contact record to flowInput
        customInput.contactRecord = contactsByAccountId.get(accounts[0].Id);
        //Create Custom input instance
        B2CContactProcessCustomInput customInputObj = new B2CContactProcessCustomInput();
		customInputObj.SubscriptionName = 'Newsletter;other;BackInStock';
        customInputObj.CaptureContactPointType = 'Email';
        customInputObj.CustomContactPointType = 'Email';
        customInputObj.Store = 'StoreTest';
        customInputObj.SaleChannel = 'SalesChanelTest';
        customInputObj.Warehouse = 'Wahrehouse Test';
        customInputObj.Company = 'Company Test';
        customInputObj.backInStockSubscriptionSKU = 'Sku00646501';
        customInputObj.EmailConsent = true;
        customInput.customInputRecord = customInputObj;
        
        //Add row to CustomInputsList
        ConsentManagementHelper_Test.listCustomInputs1.add(customInput);
        
        //~~~~~~~~~~~~~~customInput2
        ConsentManagementFlowInputs customInput2 = new ConsentManagementFlowInputs();
        //Add contact record to flowInput
        customInput2.contactRecord = contactsByAccountId.get(accounts[1].Id);
        //Create Custom input instance
        B2CContactProcessCustomInput customInputObj2 = new B2CContactProcessCustomInput();
		customInputObj2.SubscriptionName = 'Newsletter;other';
        customInputObj2.CaptureContactPointType = 'Email';
        customInputObj2.CustomContactPointType = 'Email';
        customInputObj2.EmailConsent = true;
        customInput2.customInputRecord = customInputObj2;
       
        ConsentManagementHelper_Test.ListCustomInputs2.add(customInput2);

         //~~~~~~~~~~~~~~customInput3
         ConsentManagementFlowInputs customInput3 = new ConsentManagementFlowInputs();
         //Add contact record to flowInput
         customInput3.contactRecord = contactsByAccountId.get(accounts[2].Id);
         //Create Custom input instance
         B2CContactProcessCustomInput customInputObj3 = new B2CContactProcessCustomInput();
         customInputObj3.SubscriptionName = 'SpecialEvent';
         customInputObj3.CaptureContactPointType = 'Email';
         customInputObj3.CustomContactPointType = 'Email';
         customInputObj3.EmailConsent = true;
         customInput3.customInputRecord = customInputObj3;
         ConsentManagementHelper_Test.ListCustomInputs3.add(customInput3);

         //Custom 4 
         ConsentManagementFlowInputs customInput4 = new ConsentManagementFlowInputs();
         //Add contact record to flowInput
         customInput4.contactRecord = contactsByAccountId.get(accounts[3].Id);
         //Create Custom input instance 4
         B2CContactProcessCustomInput customInputObj4 = new B2CContactProcessCustomInput();
         customInputObj4.SubscriptionName = 'BackInStock';
         customInputObj4.CaptureContactPointType = 'Email';
         customInputObj4.CustomContactPointType = 'Email';
         customInputObj4.Store = 'StoreTest';
         customInputObj4.SaleChannel = 'SalesChanelTest';
         customInputObj4.Warehouse = 'Wahrehouse Test';
         customInputObj4.Company = 'Company Test';
         customInputObj4.backInStockSubscriptionSKU = 'Sku00646501';
         customInputObj4.EmailConsent = false;
         customInput4.customInputRecord = customInputObj4;
         ConsentManagementHelper_Test.ListCustomInputs4.add(customInput4);

        //Create New ContactPointEmail for contact 1 
        ContactPointEmail contactPointEmail = new ContactPointEmail();
        contactPointEmail.ActiveFromDate =System.today().addDays(-3);
        contactPointEmail.AccountId__c=accounts[0].Id;
        contactPointEmail.ParentId=individuals[0].Id;
        contactPointEmail.EmailAddress = accounts[0].PersonEmail;
        listContactPointEmail.add(contactPointEmail);
        //Create New ContactPointEmail for contact 2 
        ContactPointEmail contactPointEmail2 = new ContactPointEmail();
        contactPointEmail2.ActiveFromDate =System.today().addDays(-3);
        contactPointEmail2.ActiveToDate =System.today().addDays(+60);
        contactPointEmail2.AccountId__c=accounts[1].Id;
        contactPointEmail2.ParentId=individuals[1].Id;
        contactPointEmail2.EmailAddress = accounts[1].PersonEmail;
        listContactPointEmail.add(contactPointEmail2);

        //insert listContactPointEmail
        insert listContactPointEmail;

        //Create New ContactPointTypeConsent
        ContactPointTypeConsent conpointtypecons1 = new ContactPointTypeConsent();
        conpointtypecons1.Name = 'EmailConsent test';
        conpointtypecons1.PartyId = individuals[0].Id;
        conpointtypecons1.ContactPointType = 'Email';
        conpointtypecons1.PrivacyConsentStatus = 'OptIn';
        conpointtypecons1.EffectiveFrom = System.now().addDays(-10);
        conpointtypecons1.EffectiveTo = null;
        conpointtypecons1.CaptureDate = System.now().addDays(-10);
        conpointtypecons1.CaptureContactPointType = 'Web';
        conpointtypecons1.CaptureSource = 'Test source';
        conpointtypecons1.DoubleConsentCaptureDate = null;
        conpointtypecons1.AccountId__c = accounts[0].Id;
        listConPointTypeCons.add(conpointtypecons1);

        //Create New ContactPointConsent
        ContactPointConsent conPointCons = new ContactPointConsent();
        conPointCons.Name = 'EmailConsent test';
        conPointCons.ContactPointId = listContactPointEmail[0].Id;
        conPointCons.PrivacyConsentStatus = 'OptIn';
        conPointCons.EffectiveFrom = System.now().addDays(-10);
        conPointCons.EffectiveTo = null;
        conPointCons.CaptureDate = System.now().addDays(-10);
        conPointCons.CaptureContactPointType = 'Web';
        conPointCons.CaptureSource = 'Test source';
        conPointCons.DoubleConsentCaptureDate = null;
        conPointCons.OptOutContactPointType__c = 'SFDC';
        conPointCons.CustomContactPointType__c = 'SFDC'; 
        conPointCons.AccountId__c = accounts[0].Id;
        listConPointCons.add(conPointCons);

        //Create New ContactPointTypeConsent
        ContactPointTypeConsent conpointtypecons2 = new ContactPointTypeConsent();
        conpointtypecons2.Name = 'EmailConsent test22';
        conpointtypecons2.PartyId = individuals[1].Id;
        conpointtypecons2.ContactPointType = 'Email';
        conpointtypecons2.PrivacyConsentStatus = 'OptIn';
        conpointtypecons2.EffectiveFrom = System.now().addDays(-10);
        conpointtypecons2.EffectiveTo = null;
        conpointtypecons2.CaptureDate = System.now().addDays(-10);
        conpointtypecons2.CaptureContactPointType = 'Web';
        conpointtypecons2.CaptureSource = 'Test source';
        conpointtypecons2.DoubleConsentCaptureDate = null;
        conpointtypecons2.AccountId__c = accounts[1].Id;
        listConPointTypeCons.add(conpointtypecons2);
        insert listConPointTypeCons;

        //Create New ContactPointConsent
        ContactPointConsent conPointCons2 = new ContactPointConsent();
        conPointCons2.Name = 'EmailConsent test22';
        conPointCons2.ContactPointId = listContactPointEmail[1].Id;
        conPointCons2.PrivacyConsentStatus = 'OptIn';
        conPointCons2.EffectiveFrom = System.now().addDays(-10);
        conPointCons2.EffectiveTo = null;
        conPointCons2.CaptureDate = System.now().addDays(-10);
        conPointCons2.CaptureContactPointType = 'Web';
        conPointCons2.CaptureSource = 'Test source';
        conPointCons2.DoubleConsentCaptureDate = null;
        conPointCons2.OptOutContactPointType__c = 'SFDC';
        conPointCons2.CustomContactPointType__c = 'SFDC'; 
        conPointCons2.AccountId__c = accounts[1].Id;
        listConPointCons.add(conPointCons2);
        insert listConPointCons;
        
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
        System.debug('**listCommSubscriptions Created** - listCommSubscriptions :  '+listCommSubscriptions);
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
        System.debug('**listCommSubChannelTypes Created** - listCommSubChannelTypes :  '+listCommSubChannelTypes);

        //Creation of CommSubscriptionConsent
        CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent();
        commSubConsent.Name = 'subcriptionName';
        commSubConsent.AccountId__c = accounts[0].Id;
        commSubConsent.ContactPointId = listContactPointEmail[1].Id;
        commSubConsent.EffectiveFromDate = System.today();
        commSubConsent.ConsentCapturedDateTime = System.now();
        commSubConsent.ConsentCapturedSource = customInputObj.CaptureContactPointType;
        commSubConsent.CommSubscriptionChannelTypeId = listCommSubChannelTypes[0].Id;
        insert commSubConsent;

        //Update Accounts Add PersonContactId !!! cannot update PersonContactId because is not writeable
    /*accounts[0].PersonContactId = contactsByAccountId.get(accounts[0].Id).Id;
        accounts[1].PersonContactId = contactsByAccountId.get(accounts[1].Id).Id;
        accounts[2].PersonContactId = contactsByAccountId.get(accounts[2].Id).Id;
        update accounts;*/
        
    }
    @IsTest
    Static void testLogic(){
        
        ConsentManagementHelper_Test.Setup();
        Test.startTest();
        //test 1
        ConsentManagementHelper.ContactConsentMangement(listCustomInputs1);
        //test 2 
        ConsentManagementHelper.ContactConsentMangement(listCustomInputs2);
        //test 3
        ConsentManagementHelper.ContactConsentMangement(listCustomInputs3);
        //test 4
        ConsentManagementHelper.ContactConsentMangement(listCustomInputs4);
        //Test except case
        ConsentManagementHelper.migrateConsentGlobalMethod(ConsentManagementHelper_Test.staticAccountsList,null,true);

        List <CommSubscriptionConsent> listCommSubConsent = [Select Id, Name, CommSubscriptionChannelType.Name, CommSubscriptionChannelTypeId,sku__c
                                                            From CommSubscriptionConsent
                                                            ];
        /*List <CommSubscriptionChannelType> listCommSubChnType = [Select Id, Name, CreatedDate
                                                            From CommSubscriptionChannelType
                                                            ];*/
        List <Account> account = [Select Id, Name , OptinEmailing__pc, LastUpdateOptinEmailing__pc From Account ];
        Test.stopTest();
        //Account Assertion
        System.assertEquals(account.size(),4);
        System.assertEquals(account[1].OptinEmailing__pc,true);
        System.assertEquals(account[1].LastUpdateOptinEmailing__pc.date(),System.today());

        System.debug('***CommSubDispConsent list Size : *** : '+listCommSubConsent.size());
        //CommSubscriptionConsent Assertion
        System.assertEquals(listCommSubConsent.size(),7);
        for(CommSubscriptionConsent commSubCons : listCommSubConsent){
            System.debug('----commSubCons : --- : '+commSubCons);
            if(commSubCons.sku__c != null){
                System.assertEquals(commSubCons.CommSubscriptionChannelType.Name, 'BackInStock');
            }
        }
        
        
        
    }
    
    
}