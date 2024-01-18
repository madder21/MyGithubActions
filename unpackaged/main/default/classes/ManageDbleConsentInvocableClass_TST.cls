@isTest(seeAllData = false)
public with sharing class ManageDbleConsentInvocableClass_TST {

    @TestSetup
    static void testData(){
        //Create CommSubscriptionChannelType
        ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
    }

    @isTest
    static void testSendAccountData() {
        ManageDbleConsentInvocableClass.DbleConsentIntegrationWrapper inputWrapper = new ManageDbleConsentInvocableClass.DbleConsentIntegrationWrapper();
        //Create a test account record
        List<Account> testAccList = ConsentManagement_TestDataFactory.createAccounts(true, 1);
        //Create a test individual record
        List<Individual> testIndivList = ConsentManagement_TestDataFactory.createIndividuals(true, 1);
        System.debug('testIndivList **** '+testIndivList);
        //Update Account & individual
        testAccList = ConsentManagement_TestDataFactory.updateAccountAndIndividual();
        //Create a test ContactPointEmail record 
        List<ContactPointEmail> testCpEmailList = ConsentManagement_TestDataFactory.createContactPointEmail(testAccList);
        //Create a test ContactPointConsent record
        List<ContactPointConsent> testCpConsentList = ConsentManagement_TestDataFactory.createContactPointConsent(testCpEmailList);
        List<ManageDbleConsentInvocableClass.DbleConsentIntegrationWrapper> inputList = new List<ManageDbleConsentInvocableClass.DbleConsentIntegrationWrapper>();
        inputWrapper.account = testAccList[0];
        inputWrapper.consent = testCpConsentList[0];
        inputList.add(inputWrapper);
        Test.startTest();
        try {
            ManageDbleConsentInvocableClass.sendAccountData(inputList);
        } catch (Exception e) {
            System.assert(false, 'An excetion occurend with this described message: '+e.getMessage());
        }

        Test.stopTest();
               
    }
}