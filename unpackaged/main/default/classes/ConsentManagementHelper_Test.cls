/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class ConsentManagementHelper, 
 * 				including both unit tests and mass tests that validate the behavior of all its methods
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
 * 0.1		|01042024			|.PLM		|.CI-303			|.Modification of setEmailConsentFields_UnitTest and setEmailConsentFields_MassTest with adding a email to accounts
*/
@isTest
public class ConsentManagementHelper_Test {
    
    private static List<Account> accTestDataList = new List<Account>();
    private static List<B2CCustomInput__c> customInputsTestDataList = new List<B2CCustomInput__c>();
    private static List<Individual> indivTestDataList = new List<Individual>();
    private static List<CommSubscriptionChannelType> channelTypeTestDataList = new List<CommSubscriptionChannelType>();
    
    @TestSetup
    static void testData(){
        //Create CommSubscriptionChannelType
        channelTypeTestDataList = ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
    }
    
    public static User userTest() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'ecom', Email='eco-integration@rimowa.com',
        				  EmailEncodingKey='UTF-8', LastName='Integration', FirstName='ECO', LanguageLocaleKey='en_US',
        				  LocaleSidKey='en_US', ProfileId = p.Id,
        				  TimeZoneSidKey='America/Los_Angeles',
        				  UserName='eco-integration@rimowa.com.testcontext');
        return u;
    }

    /*
    * @description test the method getCustomInput with one record
    * @Expected behaviour : one consentWrapper is created and it is populated with the account
    */
    @isTest
    static void getCustomInput_UnitTest() {
        
        //Create a teste account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        //Update Account & individual
        System.runAs(userTest()) {
        	testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        }
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        
        Test.startTest();
            // Call the method to test
            List<ConsentWrapper> result = ConsentManagementHelper.getCustomInputs(testcustomInputs);
        Test.stopTest();
        
        // Verify the output
        //Check if a unique consentWrapper was created
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        //Check if the consentWrapper is populated with the previously created account within this method
        Assert.areEqual(testAccList[0].Id, result[0].client.Id, 'Ids are not equal');
    }
    
    /*
    * @description test the method getCustomInput with multiple records
    * @Expected behaviour : multiple consentWrapper are created and they are populated with the account
    */
    @isTest
    static void getCustomInputs_MassTest() {

        //Create a teste account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 2);
        //Update Account & individual
        System.runAs(userTest()) {
        	testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        }
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        
        Test.startTest();
            // Call the method to test
            List<ConsentWrapper> result = ConsentManagementHelper.getCustomInputs(testcustomInputs);
        Test.stopTest();

        // Verify the output
        //Check if twice consentWrapper was created
        Assert.areEqual(2, result.size(), 'Size must be equal to 2');
        //Check if the twice consentWrapper are populated with the previously created accounts within this method
        Assert.areEqual(testAccList[0].Id, result[0].client.Id, 'Ids are not equal');
        Assert.areEqual(testAccList[1].Id, result[1].client.Id, 'Ids are not equal');

    }
    
    /*
    * @description test the method getOldAccounts with one record which hasn't an email
    * @Expected behaviour : no account is found
    */
    @isTest
    static void getOldAccounts_UnitTest() {
        
        System.runAs(userTest()) {
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
            
            Test.startTest();
                // Call the method to test
            Map<Id, Account> result = ConsentManagementHelper.getOldAccounts(new Set<Id>{testAccList[0].Id});
            Test.stopTest();
            
            // Verify the output
            //Check if a unique consentWrapper was updated
            Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        }
        
    }
    
    /*
    * @description test the method getOldAccounts with mass records
    * @Expected behaviour : an account is found for the first account & no account is found for the second account
    */
    @isTest
    static void getOldAccounts_MassTest() {
        
        System.runAs(userTest()) {
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
            
          	Set<Id> accountSet =new Set<Id>{testAccList[0].Id, testAccList[1].Id};
            
            Test.startTest();
                // Call the method to test
            Map<Id, Account> result = ConsentManagementHelper.getOldAccounts(accountSet);
            Test.stopTest();
            
            // Verify the output
            //Check if a unique consentWrapper was updated
            Assert.areEqual(2, result.size(), 'Size must be equal to 1');
        }
        
    }
    
    /*
    * @description test the method setEmailConsentFields with one record
    * @Expected behaviour : consentWrapper variables are updated
    */
    @isTest
    static void setEmailConsentFields_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        for(Account acc : testAccList){
            acc.personEmail = 'test@test.com';
        }
        update testAccList;
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('Newsletter');
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        
        Test.startTest();
            // Call the method to test
            List<ConsentWrapper> result = ConsentManagementHelper.setEmailConsentFields(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        //Check if a unique consentWrapper was updated
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        
        ConsentWrapper outputConsent = result[0];
        //Check if the variables are updated with the correct values
        Assert.areEqual(false, outputConsent.doubleOptin, 'Not expected value of the doubleOptin field');
        Assert.areEqual(true, outputConsent.client.OptinEmailing__pc, 'Not expected value of the OptinEmailing field');
        Assert.areEqual(outputConsent.optDate, outputConsent.client.LastUpdateOptinEmailing__pc, 'Not expected value of the LastUpdateOptinEmailing field');
        Assert.areEqual(true, outputConsent.clientToUpdate, 'Not expected value of the clientToUpdate');
    }
    
    /*
    * @description test the method setEmailConsentFields with multiple records
    * @Expected behaviour : all ConsentWrapper variables are updated
    */
    @isTest
    static void setEmailConsentFields_MassTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        for(Account acc : testAccList){
            acc.personEmail = 'test@test.com';
        }
        update testAccList;
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('Newsletter');
        //Create consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        
        Test.startTest();
            // Call the method to test
            List<ConsentWrapper> result = ConsentManagementHelper.setEmailConsentFields(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        //Check if twice consentWrapper were updated
        Assert.areEqual(2, result.size(), 'Size must be equal to 2');
        
        //Check the first ConsentWrapper was updated
        ConsentWrapper outputConsent = result[0];
        //Check if the variables are updated with the correct values
        Assert.areEqual(false, outputConsent.doubleOptin, 'Not expected value of the doubleOptin field');
        Assert.areEqual(true, outputConsent.client.OptinEmailing__pc, 'Not expected value of the OptinEmailing field');
        Assert.areEqual(outputConsent.optDate, outputConsent.client.LastUpdateOptinEmailing__pc, 'Not expected value of the LastUpdateOptinEmailing field');
        Assert.areEqual(true, outputConsent.clientToUpdate, 'Not expected value of the clientToUpdate');
		
        //Check the second ConsentWrapper was updated
        outputConsent = result[1];
        //Check if the variables are updated with the correct values
        Assert.areEqual(false, outputConsent.doubleOptin, 'Not expected value of the doubleOptin field');
        Assert.areEqual(true, outputConsent.client.OptinEmailing__pc, 'Not expected value of the OptinEmailing field');
        Assert.areEqual(outputConsent.optDate, outputConsent.client.LastUpdateOptinEmailing__pc, 'Not expected value of the LastUpdateOptinEmailing field');
        Assert.areEqual(true, outputConsent.clientToUpdate, 'Not expected value of the clientToUpdate');
    }
	
    /*
    * @description test the method getIndividuals with one record
    * @Expected behaviour : consentWrapper is updated with Individual
    */
    @isTest
    static void getIndividuals_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        
        Test.startTest();
            // Call the method to test
            List<ConsentWrapper> result = ConsentManagementHelper.getIndividuals(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        //Check if a unique consentWrapper was updated
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        //Check if the consentWrapper was updated with Individual
        ConsentWrapper outputConsent = result[0];
        Assert.isNotNull(outputConsent.indiv, 'Not expected result : the individual is null');
    }
	
    /*
    * @description test the method getIndividuals with multiple records
    * @Expected behaviour : all consentWrapper are updated with Individual
    */
    @isTest
    static void getIndividuals_MassTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        
        Test.startTest();
            // Call the method to test
            List<ConsentWrapper> result = ConsentManagementHelper.getIndividuals(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        // //Check if twice consentWrapper were updated
        Assert.areEqual(2, result.size(), 'Size must be equal to 2');
        
        //Check the first ConsentWrapper was updated
        ConsentWrapper outputConsent = result[0];
        //Check if the consentWrapper was updated with Individual
        Assert.isNotNull(outputConsent.indiv, 'Not expected result : the individual is null');
        
        //Check the second ConsentWrapper was updated
        outputConsent = result[1];
        //Check if the consentWrapper was updated with Individual
        Assert.isNotNull(outputConsent.indiv, 'Not expected result : the individual is null');
    }
        
	/*
    * @description test the method getContactPointEmails with one record
    * @Expected behaviour : consentWrapper is updated with ContactPointEmail
    */
    @isTest
    static void getContactPointEmails_UnitTest() {
        
        //Create a teste account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        //Update Account & individual
        

        System.runAs(userTest()) {
        	testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        }
        //Create a test ContactPointEmail record
        List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
        
        //Update account with ContactPointEmail
        testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                FROM Account]; 
        
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        
        Test.startTest();
        // Call the method being tested
            List<ConsentWrapper> result = ConsentManagementHelper.getContactPointEmails(testConsentWrapperList);
        Test.stopTest();

        // Verify that the ConsentWrapper instance has the correct ContactPointEmail record
        ConsentWrapper outputConsent = result[0];
        Assert.areEqual(testCpEmailList[0].Id, outputConsent.cpEmail.Id, 'Not expected result : Ids are not equal');
    }
	
    /*
    * @description test the method getContactPointEmails with multiple record
    * @Expected behaviour : all consentWrapper are updated with ContactPointEmail
    */
    @isTest
    static void getContactPointEmails_MassTest(){
       
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 2);
        //Update Account & individual
        System.runAs(userTest()) {
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        }
        //Create a test ContactPointEmail record
        List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
        
        //Update accounts with ContactPointEmail
        testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                FROM Account]; 
        
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
        
        Test.startTest();
        // Call the method being tested
            List<ConsentWrapper> result = ConsentManagementHelper.getContactPointEmails(testConsentWrapperList);
        Test.stopTest();

        //Check the first ConsentWrapper was updated
        ConsentWrapper outputConsent = result[0];
        // Verify that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testCpEmailList[0].Id, outputConsent.cpEmail.Id, 'Not expected result : Ids are not equal');
	
        //Check the second ConsentWrapper was updated
        outputConsent = result[1];
        // Verify that the ConsentWrapper instance has the correct ContactPointEmail record
        Assert.areEqual(testCpEmailList[1].Id, outputConsent.cpEmail.Id, 'Not expected result : Ids are not equal');
    }
	
    /*
    * @description test the method getContactPointTypeConsents with one record
    * @Expected behaviour : consentWrapper is updated with ContactPointTypeConsent
    */
    @isTest
    static void getContactPointTypeConsents_UnitTest() {
		
        System.runAs(userTest()) {
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        //Update Account & individual
        testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        // Create a test ContactPointTypeConsent
        List<ContactPointTypeConsent> testCptcList= ConsentManagement_TestDataFactory.createContactPointTypeConsent(testAccList);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('NewsLetter');
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);

        // Create a set of account IDs to use in the method call
        Set<Id> accountIds = new Set<Id>();
        for (Account aAccount : testAccList) {
            accountIds.add(aAccount.Id);
        }

        Test.startTest();
            // Call the method being tested
            List<ConsentWrapper> result = ConsentManagementHelper.getContactPointTypeConsents(testConsentWrapperList, accountIds, 'Email');
        Test.stopTest();

        // Verify the output
        // //Check if a unique consentWrapper was updated
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        ConsentWrapper outputConsent = result[0];
        //Check if the consentWrapper was updated with ContactPointTypeConsent
        Assert.isNotNull(outputConsent.cpTypeConsent);
        Assert.areEqual(testCptcList[0].Id, outputConsent.cpTypeConsent.Id);
        }

    }
    
	/*
    * @description test the method getContactPointTypeConsents with multiple record
    * @Expected behaviour : all consentWrapper are updated with ContactPointTypeConsent
    */
    @isTest
    static void getContactPointTypeConsents_MassTest() {
		
        System.runAs(userTest()) {
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 2);
            //Update Account & individual
             testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            // Create a test ContactPointTypeConsent record
            List<ContactPointTypeConsent> testCptcList= ConsentManagement_TestDataFactory.createContactPointTypeConsent(testAccList);
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Update B2CCustomInput
            testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('NewsLetter');
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            
            // Create a set of account IDs to use in the method call
            Set<Id> accountIds = new Set<Id>();
            for (Account aAccount : testAccList) {
                accountIds.add(aAccount.Id);
            }
    
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getContactPointTypeConsents(testConsentWrapperList, accountIds, 'Email');
            Test.stopTest();
    
            // Verify the output
            // //Check if twice consentWrapper was updated
            Assert.areEqual(2, result.size(), 'Size must be equal to 2');
            
            ConsentWrapper outputConsent = result[0];
            //Check if the first consentWrapper was updated with ContactPointTypeConsent
            Assert.isNotNull(outputConsent.cpTypeConsent, 'Not expected result : ContactPointTypeConsent is Null');
            Assert.areEqual(testCptcList[0].Id, outputConsent.cpTypeConsent.Id, 'Ids are not equal'); 
             
            outputConsent = result[1];
            //Check if the second consentWrapper was updated with ContactPointTypeConsent
            Assert.isNotNull(outputConsent.cpTypeConsent, 'Not expected result : ContactPointTypeConsent is Null');
            Assert.areEqual(testCptcList[1].Id, outputConsent.cpTypeConsent.Id, 'Ids are not equal'); 
    	}
    }
	
    /*
    * @description test the method getContactPointConsents with one record
    * @Expected behaviour : consentWrapper is updated with ContactPointConsent
    */
    @isTest
    static void getContactPointConsents_UnitTest() {
		
        System.runAs(userTest()) {
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
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
    
            // Create a set of account IDs to use in the method call
            Set<Id> accountIdSet = new Set<Id>();
            for (Account aAccount : testAccList) {
                accountIdSet.add(aAccount.Id);
            }
    
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getContactPointConsents(testConsentWrapperList, accountIdSet, System.label.LABS_ContactPointType_Email);
            Test.stopTest();
    
            // Verify the output
            // //Check if a unique consentWrapper was updated
            Assert.areEqual(1, result.size(), 'Size must be equal to 1');
            ConsentWrapper outputConsent = result[0];
            //Check if the consentWrapper was updated with ContactPointConsent
            Assert.isNotNull(outputConsent.cpConsent);
            Assert.areEqual(testCpConsentList[0].Id, outputConsent.cpConsent.Id);
        }
    }
	
    /*
    * @description test the method getContactPointTypeConsents with multiple record
    * @Expected behaviour : all consentWrapper are updated with ContactPointConsent
    */
    @isTest
    static void getContactPointConsents_MassTest() {
		System.runAs(userTest()) {
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 2);
            //Update Account & individual
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            //Create a test ContactPointEmail record 
            List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
            //Create a test ContactPointConsent record
            List<ContactPointConsent> testCpConsentList = ConsentManagement_TestDataFactory.createContactPointConsent(testCpEmailList);
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a testconsent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            
            // Create a set of account IDs to use in the method call
            Set<Id> accountIds = new Set<Id>();
            for (Account aAccount : testAccList) {
                accountIds.add(aAccount.Id);
            }
            
            Test.startTest();
            // Call the method being tested
            List<ConsentWrapper> result = ConsentManagementHelper.getContactPointConsents(testConsentWrapperList, accountIds, System.label.LABS_ContactPointType_Email);
            Test.stopTest();
            
            // Verify the output
            // //Check if twice consentWrapper was updated
            Assert.areEqual(2, result.size(), 'Size must be equal to 1');
            
            ConsentWrapper outputConsent = result[0];
            //Check if the first consentWrapper was updated with ContactPointConsent
            Assert.isNotNull(outputConsent.cpConsent);
            Assert.areEqual(testCpConsentList[0].Id, outputConsent.cpConsent.Id); 
            
            outputConsent = result[1];
            //Check if the second consentWrapper was updated with ContactPointConsent
            Assert.isNotNull(outputConsent.cpConsent);
            Assert.areEqual(testCpConsentList[1].Id, outputConsent.cpConsent.Id);
    	}
    }
	
    /*
    * @description test the method getCommSubscriptionConsents with one record
    * @Expected behaviour : consentWrapper is updated with CommSubscriptionConsent
    */
    @isTest
    static void getCommSubscriptionConsents_UnitTest() {
		
        System.runAs(userTest()) {
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
            //Update accounts with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                    PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                    (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                    FROM Account]; 
    
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
    
            // Create a set of account IDs to use in the method call
            Set<Id> accountIdSet = new Set<Id>();
            for (Account aAccount : testAccList) {
                accountIdSet.add(aAccount.Id);
            }
    
           //Create a test CommSubscriptionConsent record
           List<CommSubscriptionConsent> testCommSubConsentList = new List<CommSubscriptionConsent>();
           for (ContactPointEmail cpEmail : testCpEmailList) {
               CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = cpEmail.AccountId__c,
                                                                                   ContactPointId = cpEmail.Id,
                                                                                   CommSubscriptionChannelTypeId = channelType.Id,
                                                                                   EffectiveFromDate = DateTime.now().date(),
                                                                                   ConsentCapturedDateTime = DateTime.now(),
                                                                                   ConsentCapturedSource = 'Test Source');
               testCommSubConsentList.add(commSubConsent);
               //Update consentWrapper with ContactPointEmail
               for(Integer i=0; i<testConsentWrapperList.size(); i++) {
                   ConsentWrapper consent = testConsentWrapperList[i];
                   if (consent.client.Id == cpEmail.AccountId__c) {
                       consent.cpEmail = cpEmail;
                       testConsentWrapperList[i] = consent;
                   } 
               }
           }
           //Insert All CommSubscriptionConsent 
           insert testCommSubConsentList;
            
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getCommSubscriptionConsents(testConsentWrapperList, accountIdSet, channelType);
            Test.stopTest();
            
            // Verify the output
            // //Check if a unique consentWrapper was updated
            Assert.areEqual(1, result.size());
            
            ConsentWrapper outputConsent = result[0];
            //Check if the consentWrapper was updated with right CommSubscriptionConsent
            Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
            Assert.areEqual(testAccList[0].Id, outputConsent.commSubConsent.AccountId__c);
            Assert.areEqual(channelType.Id, outputConsent.commSubConsent.CommSubscriptionChannelTypeId);
            Assert.areEqual(testCommSubConsentList[0].ConsentCapturedDateTime, outputConsent.commSubConsent.ConsentCapturedDateTime);
            Assert.areEqual(testCommSubConsentList[0].ConsentCapturedSource, outputConsent.commSubConsent.ConsentCapturedSource);
        }
    }
	
    /*
    * @description test the method getCommSubscriptionConsents with multiple record
    * @Expected behaviour : all consentWrapper are updated with CommSubscriptionConsent
    */
    @isTest
    static void getCommSubscriptionConsents_MassTest() {
		
        System.runAs(userTest()) {
            //Get the channel
            commSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'NewsLetter' LIMIT 1];
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 2);
            //Update Account & individual
             testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            //Create a test ContactPointEmail record 
            List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
            //Update account with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                    PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                    (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                    FROM Account]; 
    
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
    
            // Create a set of account IDs to use in the method call
            Set<Id> accountIdSet = new Set<Id>();
            for (Account aAccount : testAccList) {
                accountIdSet.add(aAccount.Id);
            }
    
           //Create a test CommSubscriptionConsent record
           List<CommSubscriptionConsent> testCommSubConsentList = new List<CommSubscriptionConsent>();
           for (ContactPointEmail cpEmail : testCpEmailList) {
    
               CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = cpEmail.AccountId__c,
                                                                                   ContactPointId = cpEmail.Id,
                                                                                   CommSubscriptionChannelTypeId = channelType.Id,
                                                                                   EffectiveFromDate = DateTime.now().date(),
                                                                                   ConsentCapturedDateTime = DateTime.now(),
                                                                                   ConsentCapturedSource = 'Test Source');
               testCommSubConsentList.add(commSubConsent);
               //Update consentWrapper with ContactPointEmail
               for(Integer i=0; i<testConsentWrapperList.size(); i++) {
                   ConsentWrapper consent = testConsentWrapperList[i];
                   if (consent.client.Id == cpEmail.AccountId__c) {
                       consent.cpEmail = cpEmail;
                       testConsentWrapperList[i] = consent;
                   } 
               }
           
           }
           //Insert All CommSubscriptionConsent 
           insert testCommSubConsentList;
            
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getCommSubscriptionConsents(testConsentWrapperList, accountIdSet, channelType);
            Test.stopTest();
            
            // Verify the output
            // //Check if twice consentWrapper was updated
            Assert.areEqual(2, result.size());
            
            ConsentWrapper outputConsent = result[0];
            //Check if the first consentWrapper was updated with right CommSubscriptionConsent
            Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
            Assert.areEqual(testAccList[0].Id, outputConsent.commSubConsent.AccountId__c);
            Assert.areEqual(channelType.Id, outputConsent.commSubConsent.CommSubscriptionChannelTypeId);
            Assert.areEqual(testCommSubConsentList[0].ConsentCapturedDateTime, outputConsent.commSubConsent.ConsentCapturedDateTime);
            Assert.areEqual(testCommSubConsentList[0].ConsentCapturedSource, outputConsent.commSubConsent.ConsentCapturedSource);
    
            outputConsent = result[1];
            //Check if the second consentWrapper was updated with the right CommSubscriptionConsent
            Assert.areEqual(testAccList[1].Id, outputConsent.client.Id);
            Assert.areEqual(testAccList[1].Id, outputConsent.commSubConsent.AccountId__c);
            Assert.areEqual(channelType.Id, outputConsent.commSubConsent.CommSubscriptionChannelTypeId);
            Assert.areEqual(testCommSubConsentList[1].ConsentCapturedDateTime, outputConsent.commSubConsent.ConsentCapturedDateTime);
            Assert.areEqual(testCommSubConsentList[1].ConsentCapturedSource, outputConsent.commSubConsent.ConsentCapturedSource);
        }
    }
    
    /*
    * @description test the method getCommSubscriptionConsents with one record
    * @Expected behaviour : consentWrapper is updated with CommSubscriptionConsent when an account is updated with new email
    */
    @isTest
    static void getCommSubscriptionConsents_updateEmail_UnitTest() {
		
        System.runAs(userTest()) {
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
            //Update accounts with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                    PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                    (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                    FROM Account]; 
            
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
    
            // Create a set of account IDs to use in the method call
            Set<Id> accountIdSet = new Set<Id>();
            for (Account aAccount : testAccList) {
                accountIdSet.add(aAccount.Id);
            }
    
            //Create a test CommSubscriptionConsent record
            List<CommSubscriptionConsent> testCommSubConsentList = new List<CommSubscriptionConsent>();
            for (ContactPointEmail cpEmail : testCpEmailList) {
                CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = cpEmail.AccountId__c,
                                                                                    ContactPointId = cpEmail.Id,
                                                                                    CommSubscriptionChannelTypeId = channelType.Id,
                                                                                    EffectiveFromDate = DateTime.now().date(),
                                                                                    ConsentCapturedDateTime = DateTime.now(),
                                                                                    ConsentCapturedSource = 'Test Source');
                testCommSubConsentList.add(commSubConsent);
                //Update consentWrapper with ContactPointEmail
                for(Integer i=0; i<testConsentWrapperList.size(); i++) {
                    ConsentWrapper consent = testConsentWrapperList[i];
                    if (consent.client.Id == cpEmail.AccountId__c) {
                        consent.cpEmail = cpEmail;
                        testConsentWrapperList[i] = consent;
                    } 
                }
            }
            //Insert All CommSubscriptionConsent 
            insert testCommSubConsentList;
            
            //Update PersonEmail of the current account
            testAccList[0].PersonEmail = 'newemail@gmail.com';
            update testAccList[0];
            testConsentWrapperList[0].client= testAccList[0];
            //Update the current consent with a new test ContactPointEmail record 
            testConsentWrapperList[0].cpEmail = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList)[0];
            
            
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getCommSubscriptionConsents(testConsentWrapperList, accountIdSet, channelType);
            Test.stopTest();
            
            // Verify the output
            // //Check if a unique consentWrapper was updated
            Assert.areEqual(1, result.size());
            
            ConsentWrapper outputConsent = result[0];
            //Check if the consentWrapper was updated with right CommSubscriptionConsent
            Assert.areEqual(testAccList[0].Id, outputConsent.client.Id);
            Assert.areEqual(testAccList[0].Id, outputConsent.commSubConsent.AccountId__c);
            Assert.areEqual(channelType.Id, outputConsent.commSubConsent.CommSubscriptionChannelTypeId);
            Assert.isNull(outputConsent.commSubConsent.Id);
            Assert.isNotNull(outputConsent.commSubConsent);
        }
    }

    @isTest
    /*
    * @description test the method getNewsletterConsentSObjects with one record
    * @Expected behaviour : consentWrapper is updated with ContactPointTypeConsent & ContactPointConsent & CommSubscriptionConsent of Newsletter
    */
    private static void getNewsletterConsentSObjects_UnitTest() {
        
        System.runAs(userTest()) {
            //ChannelType NewsLetter
            CommSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'NewsLetter' LIMIT 1];
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
            //Update Account & individual
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            //Create a test ContactPointEmail record
            List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
            //Update account with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                    PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                    (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                    FROM Account];
            // Create a test ContactPointTypeConsent record
            List<ContactPointTypeConsent> testCptcList = ConsentManagement_TestDataFactory.createContactPointTypeConsent(testAccList);
            //Create a test ContactPointConsent record
            List<ContactPointConsent> testCpConsentList = ConsentManagement_TestDataFactory.createContactPointConsent(testCpEmailList); 
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            
            //Create a test CommSubscriptionConsent record
            List<CommSubscriptionConsent> testCommSubConsentList = new List<CommSubscriptionConsent>();
            for (ContactPointEmail cpEmail : testCpEmailList) {
    
                CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = cpEmail.AccountId__c,
                                                                                    ContactPointId = cpEmail.Id,
                                                                                    CommSubscriptionChannelTypeId = channelType.Id,
                                                                                    EffectiveFromDate = DateTime.now().date(),
                                                                                    ConsentCapturedDateTime = DateTime.now(),
                                                                                    ConsentCapturedSource = 'Test Source');
                testCommSubConsentList.add(commSubConsent);
                //Update consentWrapper with ContactPointEmail
                for(Integer i=0; i<testConsentWrapperList.size(); i++) {
                   ConsentWrapper consent = testConsentWrapperList[i];
                   if (consent.client.Id == cpEmail.AccountId__c) {
                       consent.cpEmail = cpEmail;
                       testConsentWrapperList[i] = consent;
                   } 
               }
            
            }
            //Insert All CommSubscriptionConsent 
            insert testCommSubConsentList;
    
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getNewsletterConsentSObjects(testConsentWrapperList, channelType);
            Test.stopTest();
    
            // Verify the output
            // //Check if a unique consentWrapper was updated
            Assert.areEqual(1, result.size(), 'Size must be equal to 1');
            ConsentWrapper outputConsent = result[0];
            
            //Check if the consentWrapper was updated with ContactPointTypeConsent & ContactPointConsent & CommSubscriptionConsent
            Assert.areEqual(testCptcList[0].Id, outputConsent.cpTypeConsent.Id );
            Assert.areEqual(testCpConsentList[0].Id, outputConsent.cpConsent.Id);
            Assert.areEqual(testCommSubConsentList[0].Id, outputConsent.commSubConsent.Id);
        }
    }
    
    /*
    * @description test the method getNewsletterConsentSObjects with multiple record
    * @Expected behaviour : all consentWrapper are updated with ContactPointTypeConsent & ContactPointConsent & CommSubscriptionConsent of Newsletter
    */
    @isTest
    private static void getNewsletterConsentSObjects_MassTest() {
        
        System.runAs(userTest()) {
            //ChannelType NewsLetter
            CommSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'NewsLetter' LIMIT 1];
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 2);
            //Update Account & individual
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            //Create a test ContactPointEmail record
            List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
            //Update account with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                    PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                    (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                    FROM Account];
            // Create a test ContactPointTypeConsent record
            List<ContactPointTypeConsent> testCptcList = ConsentManagement_TestDataFactory.createContactPointTypeConsent(testAccList);
            //Create a test ContactPointConsent record
            List<ContactPointConsent> testCpConsentList = ConsentManagement_TestDataFactory.createContactPointConsent(testCpEmailList); 
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            
            //Create a test CommSubscriptionConsent record
            List<CommSubscriptionConsent> testCommSubConsentList = new List<CommSubscriptionConsent>();
            for (ContactPointEmail cpEmail : testCpEmailList) {
    
                CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = cpEmail.AccountId__c,
                                                                                    ContactPointId = cpEmail.Id,
                                                                                    CommSubscriptionChannelTypeId = channelType.Id,
                                                                                    EffectiveFromDate = DateTime.now().date(),
                                                                                    ConsentCapturedDateTime = DateTime.now(),
                                                                                    ConsentCapturedSource = 'Test Source');
                testCommSubConsentList.add(commSubConsent);
                //Update consentWrapper with ContactPointEmail
                for(Integer i=0; i<testConsentWrapperList.size(); i++) {
                   ConsentWrapper consent = testConsentWrapperList[i];
                   if (consent.client.Id == cpEmail.AccountId__c) {
                       consent.cpEmail = cpEmail;
                       testConsentWrapperList[i] = consent;
                   } 
               }
            
            }
            //Insert All CommSubscriptionConsent 
            insert testCommSubConsentList;
    
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getNewsletterConsentSObjects(testConsentWrapperList, channelType);
            Test.stopTest();
    
            // Verify the output
            // //Check if twice consentWrapper was updated
            Assert.areEqual(2, result.size(), 'Size must be equal to 2');
            
            ConsentWrapper outputConsent = result[0];
            //Check if the first consentWrapper was updated with ContactPointTypeConsent & ContactPointConsent & CommSubscriptionConsent
            Assert.areEqual(testCptcList[0].Id, outputConsent.cpTypeConsent.Id );
            Assert.areEqual(testCpConsentList[0].Id, outputConsent.cpConsent.Id);
            Assert.areEqual(testCommSubConsentList[0].Id, outputConsent.commSubConsent.Id);
            
            outputConsent = result[1];
            //Check if the second consentWrapper was updated with ContactPointTypeConsent & ContactPointConsent & CommSubscriptionConsent
            Assert.areEqual(testCptcList[1].Id, outputConsent.cpTypeConsent.Id );
            Assert.areEqual(testCpConsentList[1].Id, outputConsent.cpConsent.Id);
            Assert.areEqual(testCommSubConsentList[1].Id, outputConsent.commSubConsent.Id);
        }
    }
    
    /*
    * @description test the method getNewsletterConsentSObjects with one record
    * @Expected behaviour : Creation of ContactPointTypeConsent & ContactPointConsent & CommSubscriptionConsent, and update the consentWrapper with them
    */
    @isTest
    private static void getNewsletterConsentSObjects_NewContact_UnitTest() {
        
        //ChannelType NewsLetter
        CommSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'NewsLetter' LIMIT 1];
        //Create a test account record
        Account testAcc = ConsentManagement_TestDataFactory.createAccount(true);
        testAcc.PersonEmail = 'test@test.com';
        update testAcc;
        //Create a test B2CCustomInput record
        B2CCustomInput__c testcustomInput = ConsentManagement_TestDataFactory.createB2CCustomInput(true, testAcc.Id);
        //Update the fields of the customInput
        testcustomInput.EmailConsent__c = true;
        testcustomInput.SubscriptionName__c = System.label.LABS_ComSubscriptionChannelType_Newsletter;
        update testcustomInput;
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent((new List<B2CCustomInput__c>{testcustomInput}), (new List<Account>{testAcc}));
        
        Test.startTest();
        // Call the method being tested
        List<ConsentWrapper> result = ConsentManagementHelper.getNewsletterConsentSObjects(testConsentWrapperList, channelType);
        Test.stopTest();
        
        // Verify the output
        Assert.areEqual(1, result.size(), 'Size must be equal to 1');
        ConsentWrapper outputConsent = result[0];
        //Check if the consentWrapper was updated with ContactPointTypeConsent & ContactPointConsent & CommSubscriptionConsent
        system.debug('cpConsentcpConsent'+outputConsent.cpConsent);
        Assert.isNotNull(outputConsent.cpTypeConsent);
        Assert.isNotNull(outputConsent.cpConsent);
        Assert.isNotNull(outputConsent.commSubConsent);
        
        
    }
    
    /*
    * @description test the method getNewsletterConsentSObjects with one record
    * @Expected behaviour : consentWrapper is updated with CommSubscriptionConsent of BackInStock
    */
    @isTest
    private static void  getBackInStockConsentSObjects_UnitTest(){
        
        System.runAs(userTest()) {
            //ChannelType NewsLetter
            CommSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'BackInStock' LIMIT 1];
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
            //Update Account & individual
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            //Create a test ContactPointEmail record
            List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
            //Update account with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                           PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                           (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                           FROM Account]; 
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            
            //Create a test CommSubscriptionConsent record
            List<CommSubscriptionConsent> testCommSubConsentList = new List<CommSubscriptionConsent>();
            for (ContactPointEmail cpEmail : testCpEmailList) {
                
                CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = cpEmail.AccountId__c,
                                                                                     ContactPointId = cpEmail.Id,
                                                                                     CommSubscriptionChannelTypeId = channelType.Id,
                                                                                     EffectiveFromDate = DateTime.now().date(),
                                                                                     ConsentCapturedDateTime = DateTime.now(),
                                                                                     ConsentCapturedSource = 'Test Source');
                testCommSubConsentList.add(commSubConsent);
                
            }
            //Insert All CommSubscriptionConsent 
            insert testCommSubConsentList;
            
            Test.startTest();
            // Call the method being tested
            List<ConsentWrapper> result = ConsentManagementHelper.getBackInStockConsentSObjects(testConsentWrapperList, channelType);
            Test.stopTest();
            
            // Verify the output
            // //Check if a unique consentWrapper was updated
            Assert.areEqual(1, result.size(), 'Size must be equal to 1');
            ConsentWrapper outputConsent = result[0];
            //Check if the consentWrapper was updated with CommSubscriptionConsent of BackInStock
            Assert.isNotNull(outputConsent.commSubConsent);
            Assert.areNotEqual(testCommSubConsentList[0].Id, outputConsent.commSubConsent.Id);
        }
    }
    
    /*
    * @description test the method getNewsletterConsentSObjects with multiple record
    * @Expected behaviour : all consentWrapper are updated with CommSubscriptionConsent of BackInStock
    */
    @isTest
    private static void  getBackInStockConsentSObjects_MassTest() {
		
        System.runAs(userTest()) {
            //ChannelType NewsLetter
            CommSubscriptionChannelType channelType = [SELECT Id, Name FROM CommSubscriptionChannelType WHERE Name = 'BackInStock' LIMIT 1];
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 2);
            //Update Account & individual
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            //Create a test ContactPointEmail record
            List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
            //Update account with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                    PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                    (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                    FROM Account]; 
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            
            //Create a test CommSubscriptionConsent record
            List<CommSubscriptionConsent> testCommSubConsentList = new List<CommSubscriptionConsent>();
            for (ContactPointEmail cpEmail : testCpEmailList) {
    
                CommSubscriptionConsent commSubConsent = new CommSubscriptionConsent(Name = channelType.Name, AccountId__c = cpEmail.AccountId__c,
                                                                                    ContactPointId = cpEmail.Id,
                                                                                    CommSubscriptionChannelTypeId = channelType.Id,
                                                                                    EffectiveFromDate = DateTime.now().date(),
                                                                                    ConsentCapturedDateTime = DateTime.now(),
                                                                                    ConsentCapturedSource = 'Test Source');
                testCommSubConsentList.add(commSubConsent);
            
            }
            //Insert All CommSubscriptionConsent 
            insert testCommSubConsentList;
    
            Test.startTest();
                // Call the method being tested
                List<ConsentWrapper> result = ConsentManagementHelper.getBackInStockConsentSObjects(testConsentWrapperList, channelType);
            Test.stopTest();
    
            // Verify the output
            // //Check if twice consentWrapper was updated
            Assert.areEqual(2, result.size(), 'Size must be equal to 2');
            ConsentWrapper outputConsent = result[0];
            //Check if the first consentWrapper was updated with CommSubscriptionConsent of BackInStock
            Assert.isNotNull(outputConsent.commSubConsent);
            Assert.areNotEqual(testCommSubConsentList[0].Id, outputConsent.commSubConsent.Id);
    
            outputConsent = result[1];
            //Check if second the consentWrapper was updated with CommSubscriptionConsent of BackInStock
            Assert.isNotNull(outputConsent.commSubConsent);
            Assert.areNotEqual(testCommSubConsentList[1].Id, outputConsent.commSubConsent.Id);
        }
    }
    
    /*
    * @description test the method getSubscriptionByName with one record
    * @Expected behaviour : consentWrapper with a specific subscription name
    */
    @isTest
    private static void  getSubscriptionByName_UnitTest() {

        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B22CustomInput 
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('NewsLetter');
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);

        Test.startTest();
            // Call the method being tested
            List<ConsentWrapper> resultNewsLetter = ConsentManagementHelper.getSubscriptionByName(testConsentWrapperList, 'NewsLetter');
            List<ConsentWrapper> resultBackInStock = ConsentManagementHelper.getSubscriptionByName(testConsentWrapperList, 'BackInStock');
        Test.stopTest();

        // Verify the output
        //Check the size of the result for each type of commSubscriptionConsent
        Assert.areEqual(1, resultNewsLetter.size(), 'Size must be equal to 1');
        Assert.areEqual(0, resultBackInStock.size(), 'Size must be equal to 0');
		//Check the type of commSubscriptionConsent
        ConsentWrapper outputConsentNewsLetter = resultNewsLetter[0];
        Assert.areEqual('NewsLetter', outputConsentNewsLetter.customInput.subscriptionName__c);
        
    }
    
    /*
    * @description test the method getSubscriptionByName with multiple records
    * @Expected behaviour : list of all consentWrapper with a specific subscription name
    */
    @isTest
    private static void  getSubscriptionByName_MassTest() {
        
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B22CustomInput 
        testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('NewsLetter');
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);

        Test.startTest();
            // Call the method being tested
            List<ConsentWrapper> resultNewsLetter = ConsentManagementHelper.getSubscriptionByName(testConsentWrapperList, 'NewsLetter');
            List<ConsentWrapper> resultBackInStock = ConsentManagementHelper.getSubscriptionByName(testConsentWrapperList, 'BackInStock');
        Test.stopTest();

        // Verify the output
        //Check the size of the result for each type of commSubscriptionConsent
        Assert.areEqual(2, resultNewsLetter.size(), 'Size must be equal to 2');
        Assert.areEqual(0, resultBackInStock.size(), 'Size must be equal to 0');

        ConsentWrapper outputConsentNewsLetter = resultNewsLetter[0];
        //Check the type of commSubscriptionConsent for the first consentWrapper
        Assert.areEqual('NewsLetter', outputConsentNewsLetter.customInput.subscriptionName__c);

        outputConsentNewsLetter = resultNewsLetter[1];
        //Check the type of commSubscriptionConsent for the second consentWrapper
        Assert.areEqual('NewsLetter', outputConsentNewsLetter.customInput.subscriptionName__c);
    }
    
    /*
    * @description test the method getChannelTypeMap with multiple records
    * @Expected behaviour : map of all the existing commSubscriptionChannelType 
    */
    @isTest
    private static void  getChannelTypeMap_MassTest(){
        
        Test.startTest();
            // Call the method being tested
            Map<String, commSubscriptionChannelType> result = ConsentManagementHelper.getChannelTypeMap();
        Test.stopTest();
		
        //Verify the output
        //Check the size of the result
        Assert.areEqual(3, result.size());
        //Check if the three type of CommSubscriptionChannel are available 
        Assert.areEqual([SELECT Id, Name From CommSubscriptionChannelType WHERE Name = 'NewsLetter'], result.get('Newsletter'));
        Assert.areEqual([SELECT Id, Name From CommSubscriptionChannelType WHERE Name = 'BackInStock'], result.get('BackInStock'));
        Assert.areEqual([SELECT Id, Name From CommSubscriptionChannelType WHERE Name = 'SpecialEvent'], result.get('SpecialEvent'));

    }
    
    /*
    * @description test the method setOfAccountIdByCustomInput with one record
    * @Expected behaviour : Set of account Ids
    */
    @isTest
    private static void  setOfAccountIdByCustomInput_UnitTest(){
        
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);

        Test.startTest();
            // Call the method being tested
            Set<Id> result = ConsentManagementHelper.setOfAccountId(testcustomInputs);
        Test.stopTest();

        // Verify the output
        // Check the size of result
        Assert.areEqual(1, result.size());
        //Check if the result contains the account Id previously created
        Assert.isTrue(result.contains(testAccList[0].Id));
    }
    
    /*
    * @description test the method setOfAccountIdByCustomInput with multiple records
    * @Expected behaviour : Set of account Ids
    */
    @isTest
    private static void  setOfAccountIdByCustomInput_MassTest(){
        
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);

        Test.startTest();
            // Call the method being tested
            Set<Id> result = ConsentManagementHelper.setOfAccountId(testcustomInputs);
        Test.stopTest();

        // Verify the output
        //Check the size of result
        Assert.areEqual(2, result.size());
        //Check if the result contains the account Id previously created
        Assert.isTrue(result.contains(testAccList[0].Id));
        Assert.isTrue(result.contains(testAccList[1].Id));
    }
    /*
    * @description test the method setOfAccountIdByCustomInput with one record
    * @Expected behaviour : Set of account Ids
    */
    @isTest
    private static void  setOfAccountIdByConsentWrapper_UnitTest(){
        
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);

        Test.startTest();
            // Call the method being tested
            Set<Id> result = ConsentManagementHelper.setOfAccountId(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        //Check the size of result
        Assert.areEqual(1, result.size());
        //Check if the result contains the account Id previously created
        Assert.isTrue(result.contains(testAccList[0].Id));
    }
    
    /*
    * @description test the method setOfAccountIdByCustomInput with multiple records
    * @Expected behaviour : Set of account Ids
    */
    @isTest
    private static void  setOfAccountIdByConsentWrapper_MassTest(){
        
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 2);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Create a test consent
        List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);

        Test.startTest();
            // Call the method being tested
            Set<Id> result = ConsentManagementHelper.setOfAccountId(testConsentWrapperList);
        Test.stopTest();

        // Verify the output
        // Check the size of result
        Assert.areEqual(2, result.size());
        //Check if the result contains the account Id previously created
        Assert.isTrue(result.contains(testAccList[0].Id));
        Assert.isTrue(result.contains(testAccList[1].Id));
    }
    
    /*
    * @description test the method matchedContactPointEmail with multiple records
    * @Expected behaviour : find the right ContactPointEmail for consentWrapper
    */
    @isTest
    private static void matchedContactPointEmail_MassTest() {
		
        System.runAs(userTest()) {
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
            //Update Account & individual
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            //Create a test ContactPointEmail record
            List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
            
            //Update accounts with ContactPointEmail
            testAccList = [SELECT Id, LastUpdateOptinEmailing__pc, OptinEmailing__pc, PersonIndividualId, LastName, Salutation, Phone, 
                                    PersonBirthdate, PersonEmail, WebsiteLocale__pc, WebsiteCountry__pc, CreatedDate, Country__pc, PersonContactId,
                                    (SELECT Id, ActiveToDate, EmailAddress FROM ContactPointEmails__r)
                                    FROM Account]; 
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            
            Test.startTest();
                // Call the method being tested
                ContactPointEmail result = ConsentManagementHelper.matchedContactPointEmail(testConsentWrapperList[0]);
            Test.stopTest();
    
            // Verify the output
            //Check that ContactPointEmail was found
            Assert.isNotNull(result);
            //Check the right ContactPointEmail is found
            Assert.areEqual(testAccList[0].ContactPointEmails__r[0].Id, result.Id);
        }
    }
    
    /*
    * @description test the method checkIsDoubleOptin with one record
    * @Expected behaviour : true if an account is from Germany else false 
    */
    @isTest
    private static void checkIsDoubleOptin_UnitTest(){
        
        //Create a test account record
        List<Account> testAccFR = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        List<Account> testAccDE = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Update account
        testAccFR[0].Country__pc = 'FR';
        testAccDE[0].Country__pc = 'DE';
        update new List<Account>{testAccFR[0], testAccDE[0]};
        
        //Create a test consent
        ConsentWrapper testConsentWrapperFR = new ConsentWrapper(testAccFR[0]);
        ConsentWrapper testConsentWrapperDE = new ConsentWrapper(testAccDE[0]);
        
        Test.startTest();
            // Call the method being tested
            Boolean resultFR = ConsentManagementHelper.checkIsDoubleOptin(testConsentWrapperFR);
            Boolean resultDE = ConsentManagementHelper.checkIsDoubleOptin(testConsentWrapperDE);
        Test.stopTest();

        // Verify the output
        Assert.areEqual(true, resultDE);
        Assert.areEqual(false, resultFR);
    }
    
    /*
    * @description test the method generateName with multiple records
    * @Expected behaviour : get the right ConsentSource metadata
    */
    @isTest   
    private static void generateName_MassTest(){
        
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 5);
        //Create a test B2CCustomInput record
        List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
        //Update B2CCustomInput
        testcustomInputs[0].subscriptionName__c = 'Newsletter';
        testcustomInputs[0].EmailConsent__c = true;
        testcustomInputs[1].subscriptionName__c = 'Newsletter';
        testcustomInputs[1].EmailConsent__c = false;
        testcustomInputs[2].subscriptionName__c = 'BackInStock';
        testcustomInputs[3].subscriptionName__c = 'CGI';
        testcustomInputs[3].OptinCGI__c = true;
        testcustomInputs[4].subscriptionName__c = 'CGI';
        testcustomInputs[4].OptinCGI__c = false;
        
        update testcustomInputs;
        
        Test.startTest();
            // Call the method being tested
            ConsentSource__mdt newsletterOptin = ConsentManagementHelper.generateName(testcustomInputs[0]);
            ConsentSource__mdt newsletterOptout = ConsentManagementHelper.generateName(testcustomInputs[1]);
            ConsentSource__mdt backInStock = ConsentManagementHelper.generateName(testcustomInputs[2]);
        	ConsentSource__mdt cgiOptin = ConsentManagementHelper.generateName(testcustomInputs[3]);
        	ConsentSource__mdt cgiOptout = ConsentManagementHelper.generateName(testcustomInputs[4]);
        Test.stopTest(); 
        
        // Verify the output
        // Check if the right consentSource metada record is given
        Assert.areEqual(ConsentSource__mdt.getInstance('Newsletter_Optin'), newsletterOptin);
        Assert.areEqual(ConsentSource__mdt.getInstance('Newsletter_Optout'), newsletterOptout);
        Assert.areEqual(ConsentSource__mdt.getInstance('BackInStock'), backInStock);
        Assert.areEqual(ConsentSource__mdt.getInstance('CGI_Optin'), cgiOptin);
        Assert.areEqual(ConsentSource__mdt.getInstance('CGI_Optout'), cgiOptout);
    }
    
    /*
    * @description test the method hashMD5 with one record
    * @Expected behaviour : encrypted string not null
    */
    @isTest
    private static void hashMD5_UnitTest(){

        //Create a test account record
        Account testAcc = new Account(LastName = 'LastNameTest', PersonEmail = 'test@email.com');
        insert testAcc;

        testAcc = [SELECT Id, personEmail, createdDate FROM Account];
        Test.startTest();
            // Call the method being tested
            String encoding = ConsentManagementHelper.hashMD5(testAcc.createdDate, testAcc.Id, testAcc.PersonEmail);
        Test.stopTest();
		
        //Verify the result
        Assert.isNotNull(encoding);
        
    }
	
	/*
    * @description test the method createIndividual
    * @Expected behaviour : an Individual record is created 
    */
    @isTest
    static void createIndividualTest() {

        //Create a test account record
        Account testAcc = new Account();
        //Update account
        testAcc.LastName = 'test';
        testAcc.Salutation = 'Salutation';
        testAcc.PersonBirthdate = System.today();
        //Create consent
        ConsentWrapper testConsentWrapper = new ConsentWrapper(testAcc);
        //Create Individual
        Individual testIndiv = new Individual();
        testIndiv.LastName = 'test';
        testIndiv.Salutation = 'Salutation';
        testIndiv.BirthDate = System.today();
        
        Test.startTest();
            // Call the method being tested
            Individual result = ConsentManagementHelper.createIndividual(testConsentWrapper);
        Test.stopTest();
		
        //Verify the output
        Assert.areEqual(result.LastName, testIndiv.LastName, 'LastName are not equal');
        Assert.areEqual(result.Salutation, testIndiv.Salutation, 'Salutation are not equal');
        Assert.areEqual(result.BirthDate, testIndiv.BirthDate, 'BirthDate are not equal');
        
    }
	
    /*
    * @description test the method createContactPointEmail
    * @Expected behaviour : a ContactPointEmail record is created 
    */
    @isTest
    static void createContactPointEmailTest() {

        //Create a test account record
        Account testAcc = new Account();
        testAcc.LastName = 'test';
        testAcc.PersonEmail = 'test@email.com';
        insert testAcc;

        //Create Individual
        Individual testIndiv = new Individual();
        testIndiv.LastName = 'test';
        insert testIndiv;
        
        //Update account
        testAcc.PersonIndividualId = testIndiv.Id;
        update testAcc;

        //Create a test consent
        ConsentWrapper testConsentWrapper = new ConsentWrapper(testAcc);

        //Create a test ContactPointEmail
        ContactPointEmail testCpEmail = new ContactPointEmail();
        testCpEmail.ActiveFromDate = testConsentWrapper.OptDate.Date();
        testCpEmail.AccountId__c   = testAcc.Id;
        testCpEmail.ParentId       = testAcc.PersonIndividualId;
        testCpEmail.EmailAddress   = testAcc.PersonEmail;
        insert testCpEmail;

        Test.startTest();
            // Call the method being tested
            ContactPointEmail result = ConsentManagementHelper.createContactPointEmail(testConsentWrapper);
        Test.stopTest();
		
        //Verify the output
        Assert.areEqual(testCpEmail.AccountId__c, result.AccountId__c, 'AccountId__c are not equal');
        Assert.areEqual(testCpEmail.ActiveFromDate, result.ActiveFromDate, 'ActiveFromDate are not equal');
        Assert.areEqual(testCpEmail.ParentId, result.ParentId,'ParentId are not equal');
        Assert.areEqual(testCpEmail.EmailAddress, result.EmailAddress, 'EmailAddress are not equal');
        
    }
	
    /*
    * @description test the method createContactPointTypeConsent
    * @Expected behaviour : a ContactPointTypeConsent record is created 
    */
    @isTest
    static void createContactPointTypeConsentTest() {
       
        System.runAs(userTest()) {
            //Create a test account record
            List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
            //Create a test individual record
            List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
            //Update Account & individual
            testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
            // Create a test ContactPointTypeConsent
            List<ContactPointTypeConsent> testCptcList= ConsentManagement_TestDataFactory.createContactPointTypeConsent(testAccList);
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Update B2CCustomInput
            testcustomInputs = ConsentManagement_TestDataFactory.updateB2CCustomInput('NewsLetter');
            //Create a test consent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
    
            Test.startTest();
                // Call the method being tested
                ContactPointTypeConsent result = ConsentManagementHelper.createContactPointTypeConsent(testConsentWrapperList[0]);
            Test.stopTest();
            
            //Verify hte output
            Assert.areEqual(testIndivList[0].Id, result.PartyId);
            Assert.areEqual('Optin', result.PrivacyConsentStatus);
            Assert.areEqual(testAccList[0].Id, result.AccountId__c);
            Assert.areEqual(testConsentWrapperList[0].optDate, result.EffectiveFrom);
        }
    
    }
	
    /*
    * @description test the method createContactPointConsent
    * @Expected behaviour : a ContactPointConsent record is created 
    */
    @isTest
    static void createContactPointConsentTest() {
        
        System.runAs(userTest()) {
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
            //Create a test B2CCustomInput record
            List<B2CCustomInput__c> testcustomInputs = ConsentManagement_TestDataFactory.createB2CCustomInputs(true, testAccList);
            //Create a testconsent
            List<ConsentWrapper> testConsentWrapperList = ConsentManagement_TestDataFactory.createConsent(testcustomInputs, testAccList);
            //Update testConsent with cpEmail
            testConsentWrapperList[0].cpEmail = testCpEmailList[0];
    
            Test.startTest();
                // Call the method being tested
                ContactPointConsent result = ConsentManagementHelper.createContactPointConsent(testConsentWrapperList[0]);
            Test.stopTest();
            
            //Verify the output
            Assert.areEqual(testCpEmailList[0].Id, result.ContactPointId);
            Assert.areEqual('Optin', result.PrivacyConsentStatus);
            Assert.areEqual(testAccList[0].Id, result.AccountId__c);
            Assert.areEqual(testConsentWrapperList[0].optDate, result.EffectiveFrom);
        }

    }
    
}