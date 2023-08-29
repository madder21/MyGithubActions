/**
 * @author Paul Louis MONY
 * @date 07-JUNE-2023
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class AccountConsent_SVE, 
 * 				including both unit tests and mass tests that validate the behavior of all its methods
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|07062023			|.PLM		|.					|.
*/
@isTest
public without sharing class AccountConsent_SVE_Test {
    
    @TestSetup
    static void setup() {
        //Create CommSubscriptionChannelType
        List<CommSubscriptionChannelType> channelTypeTestDataList = ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
    }
    @isTest
    static void createB2CCustomInput_UnitTestOptinEmailingOnNewAccount() {
        
        Account client = new Account();
        client.LastName = 'Test ';
        client.PersonEmail = 'test@gmail.com';
        client.Phone = '012345678';
        client.Salutation = '1';
        client.Country__pc = 'FR';
        client.OptinEmailing__pc = true;
        client.OptinCGI__c = true;  
        client.OptinInstantMessaging__pc = true;
        client.OptinCalling__pc = true;
        
        Test.startTest();
            insert client;
        Test.stopTest();

        // check that the customInput instance has the correct account record
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optin' AND AccountId__c =: client.Id]?.Id);
    }
    
     @isTest
    static void createB2CCustomInput_UnitTestOptinEmailingOnExistingAccount() {
        
        Account client = new Account();
        client.LastName = 'Test ';
        client.PersonEmail = 'test@gmail.com';
        client.Phone = '012345678';
        client.Salutation = '1';
        client.Country__pc = 'FR';
        insert client;
        
        client.OptinEmailing__pc = true;
        client.OptinCGI__c = true;  
        client.OptinInstantMessaging__pc = true;
        client.OptinCalling__pc = true;
        
        Test.startTest();
            update client;
        Test.stopTest();

        // check that the customInput instance has the correct account record
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optin' AND AccountId__c =: client.Id]?.Id);
    }
    @isTest
    static void createB2CCustomInput_UnitTestOptoutEmailingOnExistingAccount() {
        
        Account client = new Account();
        client.LastName = 'Test ';
        client.PersonEmail = 'test@gmail.com';
        client.Phone = '012345678';
        client.Salutation = '1';
        client.Country__pc = 'FR';
        client.OptinEmailing__pc = true;
        insert client;
        
        client.OptinEmailing__pc = false;
        
        Test.startTest();
            update client;
        Test.stopTest();

        // check that the customInput instance has the correct account record
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optout' AND AccountId__c =: client.Id]?.Id);
    }

    @isTest
    static void createB2CCustomInput_MassTestOptinEmailingOnNewAccount() {
        
        //Create test accounts
       	List<Account> testAccList = new List<Account>();
        //Update account data
        for (Integer i=0; i < 2; i++) {
            Account aAccount = new Account();
            aAccount.LastName = 'Testsve ' + i;
            aAccount.PersonEmail = 'testsve' + i +'@gmail.com';
            aAccount.Phone = '012345678' + i;
            aAccount.Salutation = '1';
            aAccount.WebsiteLocale__pc = 'FR';
            aAccount.WebsiteCountry__pc = 'FR';
            aAccount.Country__pc = 'FR';
            aAccount.OptinEmailing__pc = true;
            aAccount.OptinCGI__c = false;  
            aAccount.OptinInstantMessaging__pc = false;
            aAccount.OptinCalling__pc = false;
            aAccount.OptinMarketingPartner__c = true;
            testAccList.Add(aAccount);
        }
        
        Test.startTest();
             insert testAccList;
        Test.stopTest();

        // check that the customInput instance has the correct account record
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optin' AND AccountId__c =: testAccList[0].Id]?.Id);
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optin' AND AccountId__c =: testAccList[1].Id]?.Id);
    }
    
    @isTest
    static void createB2CCustomInput_MasstTestOptinEmailingOnExistingAccount() {
        
        //Create test accounts
       	List<Account> testAccList = new List<Account>();
        //Insert account data
        for (Integer i=0; i < 2; i++) {
            Account client = new Account();
            client.LastName = 'Testsve ' + i;
            client.PersonEmail = 'testsve' + i +'@gmail.com';
            client.Phone = '012345678' + i;
            client.Salutation = '1';
            client.WebsiteLocale__pc = 'FR';
            testAccList.Add(client);
        }
        insert testAccList;
        
        for (Integer i=0; i < testAccList.size(); i++) {
            testAccList[i] = new Account(Id = testAccList[i].Id, OptinEmailing__pc = true);
        }

        Test.startTest();
             update testAccList;
        Test.stopTest();

        // check that the customInput instance has the correct account record
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optin' AND AccountId__c =: testAccList[0].Id]?.Id);
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optin' AND AccountId__c =: testAccList[1].Id]?.Id);
    }
    
     @isTest
    static void createB2CCustomInput_MassTestOptoutEmailingOnExistingAccount() {
        
        //Create test accounts
       	List<Account> testAccList = new List<Account>();
        //Insert account data
        for (Integer i=0; i < 2; i++) {
            Account client = new Account();
            client.LastName = 'Testsve ' + i;
            client.PersonEmail = 'testsve' + i +'@gmail.com';
            client.Phone = '012345678' + i;
            client.Salutation = '1';
            client.WebsiteLocale__pc = 'FR';
            client.OptinEmailing__pc = true;
            testAccList.Add(client);
        }
        insert testAccList;
        
        for (Integer i=0; i < testAccList.size(); i++) {
            testAccList[i] = new Account(Id = testAccList[i].Id, OptinEmailing__pc = false);
        }

        Test.startTest();
             update testAccList;
        Test.stopTest();

        // check that the customInput instance has the correct account record
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optout' AND AccountId__c =: testAccList[0].Id]?.Id);
        Assert.isNotNull([SELECT Id FROM commSubscriptionConsent WHERE Name = 'Newsletter' AND PrivacyConsentStatus = 'Optout' AND AccountId__c =: testAccList[1].Id]?.Id);
    }

}