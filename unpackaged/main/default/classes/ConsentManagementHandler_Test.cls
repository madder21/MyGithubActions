/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class ConsentManagementHandler, 
 * 				including both unit tests and mass tests that validate the behavior of all its methods
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
 * 0.1		|1010203			 |.PLM		 |.CI-219		 |.Modification of method : emailConsentHandlerTest_Newsletter_Optin_DoubleOptin_UnitTest, assert modify for Optout in case of double optin
*/
@isTest
public with sharing class ConsentManagementHandler_Test {
    
    
    public static User userTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'ecom', Email='eco-integration@rimowa.com',
        				  EmailEncodingKey='UTF-8', LastName='Integration', FirstName='ECO', LanguageLocaleKey='en_US',
        				  LocaleSidKey='en_US', ProfileId = p.Id,
        				  TimeZoneSidKey='America/Los_Angeles',
        				  UserName='eco-integration@rimowa.com.testcontext');
        return u;
    }
    
    @TestSetup
    static void setup() {
        //Create CommSubscriptionChannelType
        List<CommSubscriptionChannelType> channelTypeTestDataList = ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
    }
    
    /*
    * @description test the method emailConsentHandlerTest with one record 
    * @Expected behaviour : create newsletter for an account
    */
    @isTest
    static void emailConsentHandlerTest_Newsletter_Optin_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Update account data
        for (Integer i=0; i < testAccList.size(); i++) {

            Account aAccount = testAccList[i];
    
            aAccount.OptinEmailing__pc = false;
            aAccount.LastName = 'Test ' + i;
            aAccount.Salutation = 'Salutation ' + i;
            aAccount.Phone = '012345678' + i;
            aAccount.PersonEmail = 'test' + i +'@gmail.com';
            aAccount.WebsiteLocale__pc = 'FR';
            aAccount.WebsiteCountry__pc = 'FR';
            aAccount.Country__pc = 'FR';
            testAccList[i] = aAccount;

        }
        update testAccList;
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput 
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('Newsletter');
        Test.startTest();
            // Call the method being tested
            ConsentManagementHandler consentManagement = new ConsentManagementHandler();
            List<consentWrapper> result = consentManagement.emailConsentHandler(testcustomInputs);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
       
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
		// check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testAccList[0].Id, outputConsent.cpEmail.AccountId__c);
        Assert.areEqual(testAccList[0].PersonEmail, outputConsent.cpEmail.EmailAddress);
        Assert.isNotNull(outputConsent.cpEmail.Id);
		
         // check that the ConsentWrapper instance has the correct ContactPointTypeConsent record
        Assert.areEqual(outputConsent.indiv.Id, outputConsent.cpTypeConsent.PartyId);
        Assert.areEqual(testAccList[0].Id, outputConsent.cpTypeConsent.AccountId__c);
        Assert.areEqual('Optin', outputConsent.cpTypeConsent.PrivacyConsentStatus);
        Assert.isNotNull(outputConsent.cpTypeConsent.Id);
	
        // check that the ConsentWrapper instance has the correct ContactPointConsent record
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.cpConsent.ContactPointId);
        Assert.areEqual(testAccList[0].Id, outputConsent.cpConsent.AccountId__c);
        Assert.areEqual('Optin', outputConsent.cpConsent.PrivacyConsentStatus);
        Assert.isNull(outputConsent.cpConsent.DoubleOptInHash__c);
        Assert.isNotNull(outputConsent.cpConsent.Id);
		
        // check that the ConsentWrapper instance has the correct commSubscriptionConsent record
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.commSubConsent.ContactPointId);
        Assert.areEqual(testAccList[0].Id, outputConsent.commSubConsent.AccountId__c);
        Assert.areEqual('Newsletter', outputConsent.commSubConsent.Name);
        Assert.isNotNull(outputConsent.commSubConsent.Id);

        Assert.areEqual(true, outputConsent.clientToUpdate);


    }

	/*
    * @description test the method emailConsentHandlerTest with multiple records
    * @Expected behaviour : commSubscriptionConsent of newsletter for a specific account
    */
    @isTest
    static void emailConsentHandlerTest_Newsletter_Optin_MassTest() {

       //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Update account data
        for (Integer i=0; i < testAccList.size(); i++) {

            Account aAccount = testAccList[i];
    
            aAccount.OptinEmailing__pc = false;
            aAccount.LastName = 'Test ' + i;
            aAccount.Salutation = 'Salutation ' + i;
            aAccount.Phone = '012345678' + i;
            aAccount.PersonEmail = 'test' + i +'@gmail.com';
            aAccount.WebsiteLocale__pc = 'FR';
            aAccount.WebsiteCountry__pc = 'FR';
            aAccount.Country__pc = 'FR';
            testAccList[i] = aAccount;

        }
        update testAccList;
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput 
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('Newsletter');
        Test.startTest();
            // Call the method being tested
            ConsentManagementHandler consentManagement = new ConsentManagementHandler();
            List<consentWrapper> result = consentManagement.emailConsentHandler(testcustomInputs);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(2, result.size(), 'Size must be equal to 1');
        
        //Verify the result for the first consentWrapper
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testAccList[0].Id, outputConsent.cpEmail.AccountId__c);
        Assert.areEqual(testAccList[0].PersonEmail, outputConsent.cpEmail.EmailAddress);
        Assert.isNotNull(outputConsent.cpEmail.Id);

        // check that the ConsentWrapper instance has the correct ContactPointTypeConsent record
        Assert.areEqual(outputConsent.indiv.Id, outputConsent.cpTypeConsent.PartyId);
        Assert.areEqual(testAccList[0].Id, outputConsent.cpTypeConsent.AccountId__c);
        Assert.areEqual('Optin', outputConsent.cpTypeConsent.PrivacyConsentStatus);
        Assert.isNotNull(outputConsent.cpTypeConsent.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointConsent record
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.cpConsent.ContactPointId);
        Assert.areEqual(testAccList[0].Id, outputConsent.cpConsent.AccountId__c);
        Assert.areEqual('Optin', outputConsent.cpConsent.PrivacyConsentStatus);
        Assert.isNull(outputConsent.cpConsent.DoubleOptInHash__c);
        Assert.isNotNull(outputConsent.cpConsent.Id);
		
        // check that the ConsentWrapper instance has the correct commSubscriptionConsent record
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.commSubConsent.ContactPointId);
        Assert.areEqual(testAccList[0].Id, outputConsent.commSubConsent.AccountId__c);
        Assert.areEqual('Newsletter', outputConsent.commSubConsent.Name);
        Assert.isNotNull(outputConsent.commSubConsent.Id);

        Assert.areEqual(true, outputConsent.clientToUpdate);
		
        //Verify the result for the second consentWrapper
        outputConsent = result[1];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[1].Id, outputConsent.client.Id);
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testAccList[1].Id, outputConsent.cpEmail.AccountId__c);
        Assert.areEqual(testAccList[1].PersonEmail, outputConsent.cpEmail.EmailAddress);
        Assert.isNotNull(outputConsent.cpEmail.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointTypeConsent record
        Assert.areEqual(outputConsent.indiv.Id, outputConsent.cpTypeConsent.PartyId);
        Assert.areEqual(testAccList[1].Id, outputConsent.cpTypeConsent.AccountId__c);
        Assert.areEqual('Optin', outputConsent.cpTypeConsent.PrivacyConsentStatus);
        Assert.isNotNull(outputConsent.cpTypeConsent.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointConsent record
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.cpConsent.ContactPointId);
        Assert.areEqual(testAccList[1].Id, outputConsent.cpConsent.AccountId__c);
        Assert.areEqual('Optin', outputConsent.cpConsent.PrivacyConsentStatus);
        Assert.isNull(outputConsent.cpConsent.DoubleOptInHash__c);
        Assert.isNotNull(outputConsent.cpConsent.Id);
		
        // check that the ConsentWrapper instance has the correct commSubscriptionConsent record
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.commSubConsent.ContactPointId);
        Assert.areEqual(testAccList[1].Id, outputConsent.commSubConsent.AccountId__c);
        Assert.areEqual('Newsletter', outputConsent.commSubConsent.Name);
        Assert.isNotNull(outputConsent.commSubConsent.Id);

        Assert.areEqual(true, outputConsent.clientToUpdate);
    }

    /*
    * @description test the method emailConsentHandlerTest with one record
    * @Expected behaviour : unsubscribe a specific account from a newsletter, 
    */
    @isTest
    static void emailConsentHandlerTest_Newsletter_Optout_UnitTest() {
        
        //Get the channel
        commSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'Newsletter' LIMIT 1];
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        //Update account data
        testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        //Create a test ContactPointEmail record 
        List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput 
        for (Integer i=0; i < testcustomInputs.size(); i++) {

            B2CCustomInput__c customInput = testcustomInputs[i];
            customInput.CaptureContactPointType__c = 'Web';
            customInput.CaptureSource__c = 'SFDC Contact Process';
            customInput.contactPointType__c = null;
            customInput.CustomContactPointType__c = 'SFDC';
            customInput.EmailConsent__c = false;
            customInput.OptOutContactPointType__c = 'SFDC';
            customInput.SubscriptionName__c = 'Newsletter';
            testcustomInputs[i] = customInput;
        }
        //Create contactPointTypeConsent
        contactPointTypeConsent cpTypeConsent = new contactPointTypeConsent(Name ='Standard', ContactPointType ='Email', 
                                                                            PartyId = testIndivList[0].Id,
                                                                            PrivacyConsentStatus = Label.LABS_Consent_Optin,
                                                                            EffectiveFrom = DateTime.now(),
                                                                            AccountId__c = testCpEmailList[0].AccountId__c);
        insert cpTypeConsent;
        
        //Create contactPointConsent
        contactPointConsent cpConsent = new contactPointConsent(Name ='Standard', ContactPointId = testCpEmailList[0].Id,
                                                                            PrivacyConsentStatus = Label.LABS_Consent_Optin,
                                                                            EffectiveFrom = DateTime.now(),
                                                                			AccountId__c = testCpEmailList[0].AccountId__c);
        insert cpConsent;
        
        //Create commSubscriptionConsent 
        CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = testCpEmailList[0].AccountId__c,
                                                                               ContactPointId = testCpEmailList[0].Id,
                                                                               CommSubscriptionChannelTypeId = channelType.Id,
                                                                               EffectiveFromDate = DateTime.now().date(),
                                                                               ConsentCapturedDateTime = DateTime.now(),
                                                                               ConsentCapturedSource = 'Test Source');
        insert commSubConsent;

        Test.startTest();
            // Call the method being tested
            ConsentManagementHandler consentManagement = new ConsentManagementHandler();
            List<consentWrapper> result = consentManagement.emailConsentHandler(testcustomInputs);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
        
        // check that the ConsentWrapper instance has optout status for CommSubscriptionConsent
        Assert.areEqual(commSubConsent.Id, outputConsent.commSubConsent.Id);
        Assert.areEqual('Optout', outputConsent.commSubConsent.PrivacyConsentStatus); //added on 06/06/2023
        Assert.isNotNull(outputConsent.commSubConsent.EffectiveToDate);
        
        Assert.areEqual(true, outputConsent.clientToUpdate);
    }
	
    /*
    * @description test the method emailConsentHandlerTest with one record
    * @Expected behaviour : create for ConsentWrapper all the sObject except CommSubscriptionConsent
    */
    @isTest
    static void emailConsentHandlerTest_Newsletter_Optin_DoubleOptin_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Update account data
        for (Integer i=0; i < testAccList.size(); i++) {

            Account aAccount = testAccList[i];
    
            aAccount.OptinEmailing__pc = false;
            aAccount.LastName = 'Test ' + i;
            aAccount.Salutation = 'Salutation ' + i;
            aAccount.Phone = '012345678' + i;
            aAccount.PersonEmail = 'testdoubleoptin' + i +'@gmail.com';
            aAccount.WebsiteLocale__pc = 'DE';
            aAccount.WebsiteCountry__pc = 'DE';
            aAccount.Country__pc = 'DE';
            testAccList[i] = aAccount;

        }
        update testAccList;
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput 
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('NewsLetter');
        Test.startTest();
            // Call the method being tested
            ConsentManagementHandler consentManagement = new ConsentManagementHandler();
            List<consentWrapper> result = consentManagement.emailConsentHandler(testcustomInputs);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
       	
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testAccList[0].Id, outputConsent.cpEmail.AccountId__c);
        Assert.areEqual(testAccList[0].PersonEmail, outputConsent.cpEmail.EmailAddress);
        Assert.isNotNull(outputConsent.cpEmail.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointTypeConsent record
        Assert.areEqual(outputConsent.indiv.Id, outputConsent.cpTypeConsent.PartyId);
        Assert.areEqual(testAccList[0].Id, outputConsent.cpTypeConsent.AccountId__c);
        Assert.areEqual('Optout', outputConsent.cpTypeConsent.PrivacyConsentStatus);
        Assert.isNotNull(outputConsent.cpTypeConsent.Id);
		
        // check that the ConsentWrapper instance has optout status for ContactPointConsent
        Assert.isNotNull(outputConsent.cpConsent.DoubleOptInHash__c);
        Assert.areEqual('Optout', outputConsent.cpConsent.PrivacyConsentStatus);
		
        // check that the ConsentWrapper instance hasn't CommSubscriptionConsent record
        Assert.isNull(outputConsent.commSubConsent);

        Assert.areEqual(true, outputConsent.clientToUpdate);
        Assert.isFalse(outputConsent.client.OptinEmailing__pc);


    }
	
    /*
    * @description test the method emailConsentHandlerTest with one record
    * @Expected behaviour : create commSubscriptionConsent of BackInStock for a specific account
    */
    @isTest
    static void emailConsentHandlerTest_BackInStock_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Update account data
        for (Integer i=0; i < testAccList.size(); i++) {

            Account aAccount = testAccList[i];
    
            aAccount.OptinEmailing__pc = false;
            aAccount.LastName = 'Test ' + i;
            aAccount.Salutation = '1';
            aAccount.Phone = '012345678' + i;
            aAccount.PersonEmail = 'test' + i +'@gmail.com';
            aAccount.WebsiteLocale__pc = 'FR';
            aAccount.WebsiteCountry__pc = 'FR';
            aAccount.Country__pc = 'FR';
            //aAccount.PersonBirthdate = Datetime.now().date()-1;
            testAccList[i] = aAccount;

        }
        update testAccList;
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput 
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('BackInStock');
        
        Test.startTest();
            // Call the method being tested
            ConsentManagementHandler consentManagement = new ConsentManagementHandler();
            List<consentWrapper> result = consentManagement.emailConsentHandler(testcustomInputs);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testAccList[0].Id, outputConsent.cpEmail.AccountId__c);
        Assert.areEqual(testAccList[0].PersonEmail, outputConsent.cpEmail.EmailAddress);
        Assert.isNotNull(outputConsent.cpEmail.Id);

		// check that the ConsentWrapper instance has a ContactPointTypeConsent record
        Assert.isNull(outputConsent.cpTypeConsent);
		
        // check that the ConsentWrapper instance has a ContactPointConsent record
        Assert.isNull(outputConsent.cpConsent);
		
        // check that the ConsentWrapper instance has the correct commSubscriptionConsent record
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.commSubConsent.ContactPointId);
        Assert.areEqual(testAccList[0].Id, outputConsent.commSubConsent.AccountId__c);
        Assert.areEqual('BackInStock', outputConsent.commSubConsent.Name);
        Assert.isNotNull(outputConsent.commSubConsent.Id);

        Assert.areEqual(false, outputConsent.clientToUpdate);

    }
	
    /*
    * @description test the method emailConsentHandlerTest with one record
    * @Expected behaviour : create commSubscriptionConsent of BackInStock for a specific account
    */
    @isTest
    static void emailConsentHandlerTest_BackInStock_MassTest() {
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Update account data
        for (Integer i=0; i < testAccList.size(); i++) {

            Account aAccount = testAccList[i];
    
            aAccount.OptinEmailing__pc = false;
            aAccount.LastName = 'Test ' + i;
            aAccount.Salutation = 'Salutation ' + i;
            aAccount.Phone = '012345678' + i;
            aAccount.PersonEmail = 'test' + i +'@gmail.com';
            aAccount.WebsiteLocale__pc = 'FR';
            aAccount.WebsiteCountry__pc = 'FR';
            aAccount.Country__pc = 'FR';
            aAccount.PersonBirthdate = Datetime.now().date()-1;
            testAccList[i] = aAccount;

        }
        update testAccList;
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput 
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('BackInStock');
        Test.startTest();
            // Call the method being tested
            ConsentManagementHandler consentManagement = new ConsentManagementHandler();
            List<consentWrapper> result = consentManagement.emailConsentHandler(testcustomInputs);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(2, result.size(), 'Size must be equal to 2');
        
        //Verify the result for the first consentWrapper
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testAccList[0].Id, outputConsent.cpEmail.AccountId__c);
        Assert.areEqual(testAccList[0].PersonEmail, outputConsent.cpEmail.EmailAddress);
        Assert.isNotNull(outputConsent.cpEmail.Id);

		// check that the ConsentWrapper instance has a ContactPointTypeConsent record
        Assert.isNull(outputConsent.cpTypeConsent);
		
        // check that the ConsentWrapper instance has a ContactPointConsent record
        Assert.isNull(outputConsent.cpConsent);
		
		// check that the ConsentWrapper instance has the correct commSubscriptionConsent record        
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.commSubConsent.ContactPointId);
        Assert.areEqual(testAccList[0].Id, outputConsent.commSubConsent.AccountId__c);
        Assert.areEqual('BackInStock', outputConsent.commSubConsent.Name);
        Assert.isNotNull(outputConsent.commSubConsent.Id);

        Assert.areEqual(false, outputConsent.clientToUpdate);
		
        //Verify the result for the second consentWrapper
        outputConsent = result[1];
        
        // check that the ConsentWrapper instance has the correct account record
        Assert.areEqual(testAccList[1].Id, outputConsent.client.Id);
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.client.PersonIndividualId);
		// check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.client.PersonIndividualId, outputConsent.indiv.Id);
		
        // check that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testAccList[1].Id, outputConsent.cpEmail.AccountId__c);
        Assert.areEqual(testAccList[1].PersonEmail, outputConsent.cpEmail.EmailAddress);
        Assert.isNotNull(outputConsent.cpEmail.Id);

		// check that the ConsentWrapper instance has a ContactPointTypeConsent record
        Assert.isNull(outputConsent.cpTypeConsent);
        
		// check that the ConsentWrapper instance has a ContactPointConsent record
        Assert.isNull(outputConsent.cpConsent);
		
        // check that the ConsentWrapper instance has the correct commSubscriptionConsent record 
        Assert.areEqual(outputConsent.cpEmail.Id, outputConsent.commSubConsent.ContactPointId);
        Assert.areEqual(testAccList[1].Id, outputConsent.commSubConsent.AccountId__c);
        Assert.areEqual('BackInStock', outputConsent.commSubConsent.Name);
        Assert.isNotNull(outputConsent.commSubConsent.Id);

        Assert.areEqual(false, outputConsent.clientToUpdate);
    }


    @isTest
    static void cgiConsentHandlerTest_UnitTest() {

    }

    @isTest
    static void cgiConsentHandlerTest_MassTest() {

    }
	
    /*
    * @description test the method insertIndividuals with one record
    * @Expected behaviour : consentWrapper has an individual
    */
    @isTest
    static void insertIndividualsTest_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        //Get Individual 
        testConsentWrapperList = ConsentManagementHelper.getIndividuals(testConsentWrapperList);

        Test.startTest();
            // Call the method being tested
            List<ConsentWrapper> result = ConsentManagementHandler.insertIndividuals(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.indiv);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.indiv.Id, outputConsent.client.PersonIndividualId);
        Assert.areEqual(true, outputConsent.clientToUpdate);

    }
	
    /*
    * @description test the method insertIndividuals with multiple records
    * @Expected behaviour : each consentWrapper has an individual
    */
    @isTest
    static void insertIndividualsTest_MassTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        //Get Individual 
        testConsentWrapperList = ConsentManagementHelper.getIndividuals(testConsentWrapperList);

        Test.startTest();
            // Call the method being tested
            List<ConsentWrapper> result = ConsentManagementHandler.insertIndividuals(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(2, result.size(), 'Size must be equal to 2');
        
        //Verify the result for the first consentWrapper
        ConsentWrapper outputConsent = result[0];
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.indiv);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.indiv.Id, outputConsent.client.PersonIndividualId);
        Assert.areEqual(true, outputConsent.clientToUpdate);
		
        //Verify the result for the second consentWrapper
        outputConsent = result[1];
        
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull(outputConsent.indiv);
        // check that the ConsentWrapper instance has the correct individual record
        Assert.areEqual(outputConsent.indiv.Id, outputConsent.client.PersonIndividualId);
        Assert.areEqual(true, outputConsent.clientToUpdate);

    }
	
    /*
    * @description test the method contactPointTypeConsentOptoutHandler with one record
    * @Expected behaviour : consentWrapper has a contactPointTypeConsent with optout status
    */
    @isTest
    static void contactPointTypeConsentOptoutHandlerTest_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        //Update Account & individual
        testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        // Create a test ContactPointTypeConsent record
        List<ContactPointTypeConsent> testCptcList= ConsentManagement_TestDataFactory.createContactPointTypeConsent(testAccList);

        Test.startTest();
            // Call the method being tested
            ContactPointTypeConsent result = ConsentManagementHandler.contactPointTypeConsentOptoutHandler(testCptcList[0], Datetime.now());
        Test.stopTest();

        // Verify the output
        // check that the ConsentWrapper instance has optout status for contactPointTypeConsent
        Assert.areEqual('Optout', result.PrivacyConsentStatus, 'PrivacyConsentStatus must be Output'); 
        Assert.isNotNull(result.EffectiveTo); 
    }

  	/*
    * @description test the method contactPointConsentOptoutHandler with one record
    * @Expected behaviour : consentWrapper has a contactPointConsent with optout status
    */
    @isTest
    static void contactPointConsentOptoutHandlerTest_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        //Update Account & individual
        testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        //Create a test ContactPointEmail record
        List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
        //Create a test ContactPointConsent record
        List<ContactPointConsent> testCpConsentList = ConsentManagement_TestDataFactory.createContactPointConsent(testCpEmailList);
        
        Test.startTest();
            // Call the method being tested
            contactPointConsent result = ConsentManagementHandler.contactPointConsentOptoutHandler(testCpConsentList[0], Datetime.now());
        Test.stopTest();

        // Verify the output
        // // check that the ConsentWrapper instance has optout status for contactPointConsent
        Assert.areEqual('Optout', result.PrivacyConsentStatus, 'PrivacyConsentStatus must be Output'); 
        Assert.isNotNull(result.EffectiveTo);

    }

    /*
    * @description test the method CommSubscriptionConsentOptoutHandler with one record
    * @Expected behaviour : consentWrapper has a CommSubscriptionConsent with optout status
    */
    @isTest
    static void CommSubscriptionConsentOptoutHandlerTest_UnitTest() {

        //Get the channel
        commSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'NewsLetter' LIMIT 1];
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        //Update Account & individual
        testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        //Create a test ContactPointEmail record 
        List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
       //Create a test CommSubscriptionConsent record
        CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = testCpEmailList[0].AccountId__c,
                                                                               ContactPointId = testCpEmailList[0].Id,
                                                                               CommSubscriptionChannelTypeId = channelType.Id,
                                                                               EffectiveFromDate = DateTime.now().date(),
                                                                               ConsentCapturedDateTime = DateTime.now(),
                                                                               ConsentCapturedSource = 'Test Source');
        //Insert CommSubscriptionConsent 
        insert commSubConsent;

        Test.startTest();
            // Call the method being tested
            CommSubscriptionConsent result = ConsentManagementHandler.commSubscriptionConsentOptoutHandler(commSubConsent, Datetime.now().date());
        Test.stopTest();

        // Verify the output
        // check that the ConsentWrapper instance has optout status for commSubscriptionConsent 
        Assert.isNotNull(result.EffectiveToDate);

    }
    
    
    /*
    * @description test the method 
    * @Expected behaviour : 
    */
    @isTest
    static void emailConsentHandlerTest_optinEmailing_withoutEmail_insert_UnitTest() {
		
        //Create a test account record
        Account aAccount = new Account();
        aAccount.OptinEmailing__pc = true;
        aAccount.LastName = 'Test 1';
        aAccount.Salutation = '1';
        aAccount.Country__pc = 'FR';
        
        Test.startTest();
        	insert aAccount;
        Test.stopTest();
        
        // Verify the output
        // check that the ConsentWrapper instance has an individual record
        Assert.isNull([SELECT Id, PersonIndividualId from Account where Id = : aAccount.ID][0].PersonIndividualId);
        
        // check that the ConsentWrapper instance hasn't a ContactPointEmail record
        Assert.areEqual(0,[SELECT Id from ContactPointEmail where AccountId__c = : aAccount.ID].size());
        
        // check that the ConsentWrapper instance hasn't a ContactPointTypeConsent record
        Assert.areEqual(0,[SELECT Id from ContactpointTypeConsent where AccountId__c = : aAccount.ID].size());
        
        // check that the ConsentWrapper instance hasn't a ContactPointConsent record
        Assert.areEqual(0,[SELECT Id from ContactPointConsent where AccountId__c = : aAccount.ID].size());
        
        // check that the ConsentWrapper instance hasn't a commSubscriptionConsent record
        Assert.areEqual(0,[SELECT Id from commSubscriptionConsent where AccountId__c = : aAccount.ID].size());
    
    }
    
    /*
    * @description test the method 
    * @Expected behaviour : 
    */
    @isTest
    static void emailConsentHandlerTest_optinEmailing_withoutEmail_update_UnitTest() {
		
        
        //Create a test account record
        Account aAccount = new Account();
        aAccount.OptinEmailing__pc = true;
        aAccount.personEmail = 'fromTestContext@gmail.com';
        aAccount.LastName = 'Test 1';
        aAccount.Salutation = '1';
        aAccount.Country__pc = 'FR';
        insert aAccount;
        
        aAccount.personEmail = null;
        aAccount.OptinEmailing__pc = false;
        
        Test.startTest();
        	update aAccount;
        Test.stopTest();
        
        // Verify the output
        // check that the ConsentWrapper instance has an individual record
        Assert.isNotNull([SELECT Id, PersonIndividualId from Account where Id = : aAccount.ID][0].PersonIndividualId);
        
        // check that the ConsentWrapper instance hasn't a ContactPointEmail record
        Assert.areEqual(1,[SELECT Id from ContactPointEmail where AccountId__c = : aAccount.ID AND ActiveToDate != null].size());
        Assert.areEqual(1,[SELECT Id from ContactPointEmail where AccountId__c = : aAccount.ID].size());
        
        // check that the ConsentWrapper instance hasn't a ContactPointTypeConsent record
        Assert.areEqual(1,[SELECT Id from ContactpointTypeConsent where PrivacyConsentStatus = 'Optout' AND AccountId__c = : aAccount.ID].size());
        Assert.areEqual(1,[SELECT Id from ContactpointTypeConsent where AccountId__c = : aAccount.ID].size());
        
        // check that the ConsentWrapper instance hasn't a ContactPointConsent record
        Assert.areEqual(1,[SELECT Id from ContactPointConsent where PrivacyConsentStatus = 'Optout' AND AccountId__c = : aAccount.ID].size());
        Assert.areEqual(1,[SELECT Id from ContactPointConsent where AccountId__c = : aAccount.ID].size());
        
        // check that the ConsentWrapper instance hasn't a commSubscriptionConsent record
        Assert.areEqual(1,[SELECT Id from commSubscriptionConsent where PrivacyConsentStatus = 'Optout' AND AccountId__c = : aAccount.ID].size());
        Assert.areEqual(1,[SELECT Id from commSubscriptionConsent where AccountId__c = : aAccount.ID].size());
    
    }
    

}