@isTest(seeAllData=false)
public class SFSuppressionProcessTest {
    
    @TestSetup
    public static void initDate() {
        
        Individual individual = new Individual();
        individual.LastName='individual';
        insert individual;
        
        Account testAcc = new Account();
        testAcc.LastName = 'test';
        testAcc.PersonEmail = 'test@email.com';
        testAcc.PersonIndividualId = individual.Id;
        insert testAcc;
        
        B2CCustomInput__c input = ConsentManagement_TestDataFactory.createB2CCustomInput(true, testAcc.Id);
        input.CaptureSource__c = 'capture';
        update input;
        Case testCase = DataFactoryForTests.createCase();
        testCase.AccountId = testAcc.Id;
        update testCase;
        
        ClientSource__c source1 = new ClientSource__c(
            Source__c = 'SF',
            SourceCode__c = testAcc.Id,
            SourceCreationDate__c = Date.valueOf('2021-05-17'),
            SourceLastUpdateDate__c = DateTime.valueOf('2021-10-16 15:20:41.990679+00:00'),
            Client__c = testAcc.Id
        );
        
        insert source1;
        
        ClientAddress__c address1 = new ClientAddress__c(
            Address1__c = '7007 FRIARS RD STE 513',
            City__c = 'SAN DIEGO',
            Country__c = 'US',
            PostalCode__c = '92108-1142',
            State__c = 'CA',
            AddressTypology__c = 'STANDARD',
            IsValid__c = false,
            Client__c = testAcc.Id
        );
        
        insert address1;
        
        ContactPointTypeConsent conpointtypecons1 = new ContactPointTypeConsent();
        conpointtypecons1.Name = 'EmailConsent1';
        conpointtypecons1.PartyId = testAcc.PersonIndividualId;
        conpointtypecons1.ContactPointType = 'Email';
        conpointtypecons1.PrivacyConsentStatus = 'OptIn';
        conpointtypecons1.EffectiveFrom = System.now().addDays(-10);
        conpointtypecons1.EffectiveTo = null;
        conpointtypecons1.CaptureDate = System.now().addDays(-10);
        conpointtypecons1.CaptureContactPointType = 'Web';
        conpointtypecons1.CaptureSource = 'Test source';
        conpointtypecons1.DoubleConsentCaptureDate = null;
        conpointtypecons1.AccountId__c = testAcc.Id;
        insert conpointtypecons1;
        
        EmailMessage emailWithAllowedDomain = new EmailMessage();
        emailWithAllowedDomain.FromAddress = 'user1@example.com';
        emailWithAllowedDomain.ToSme__c = true;
        emailWithAllowedDomain.RelatedToId = testAcc.Id;
        insert emailWithAllowedDomain;
    }
    
    @isTest
    static void testSuppression() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(Account__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        insert BypassTrigger;
        Account acc = [SELECT Id, LastName, PersonEmail FROM Account LIMIT 1];
        List<SFAnonymizationProcessWrapper> wrapperList = new List<SFAnonymizationProcessWrapper>();
        SFAnonymizationProcessWrapper wrapper = new SFAnonymizationProcessWrapper();
        wrapper.clientIdStr = acc.Id;
        wrapper.objectList = 'Account,Case,ClientAddress,ClientSource,ContactPointTypeConsent,EmailMessage,B2CCustomInput,Entitlement';
        wrapper.timeStamp = '122342452343';
        wrapper.separator = ';';
        wrapperList.add(wrapper);
        Test.StartTest();
        SuppressionSFProcess.initSuppressionProcess(wrapperList);
        Test.StopTest();
        List<ClientSource__c> csList = [SELECT Id FROM ClientSource__c WHERE Client__c =:acc.Id];
        System.assertEquals(true, csList.isEmpty(), 'client source records have been deleted');
    }

}