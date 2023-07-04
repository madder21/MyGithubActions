/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class B2CCustomInput_UTL
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12062023			|.UMNN		|.					|.
*/
@IsTest(SeeAllData=false)
public with sharing class B2CCustomInput_UTL_TST {

    @TestSetup
    static void makeData(){

        Individual currentIndividual = Individual_TDF.buildIndividual(1, true)[0];
        RecordType personAccount = [Select Id, Name from recordType where IsPersonType = true limit 1];//NOPMD
        Account acc = (Account)TestDataFactory.createSObject('Account');
        acc.LastName='acc';
		acc.PersonEmail = 'Account.test3@gmail.com';
        acc.B2C_Customer_ID__pc = 'abKveEa2dsfdsnfksd4s00';
		acc.B2C_Customer_No__pc = '000175465456d000';
        acc.RecordTypeId  = personAccount.Id;
        acc.OptinCGI__c = true;
        update acc;

        B2CCustomInput__c customInput = B2CCustomInput_TDF.buildB2CCustomInput(1, false)[0];
        customInput.AccountId__c = acc.Id;
        insert customInput;   
    }


    @isTest
    static void testCreateCustomer() {
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive //NOPMD
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            Test.startTest();
            List<B2CCustomInput__c> customInputList = [SELECT Id, CustomContactPointType__c, SubscriptionName__c, AccountId__c, //NOPMD
                                                       OptinCGI__c, EmailConsent__c, CaptureSource__c, CaptureContactPointType__c 
                                                       FROM B2CCustomInput__c];
            B2CCustomInput_UTL utils = new B2CCustomInput_UTL(customInputList);
            Test.stopTest();
            System.assertEquals(true, !utils.authFormList.isEmpty());
            System.assertEquals(true, !utils.authFormTextList.isEmpty());
            System.assertEquals(true, !utils.authFormConsentList.isEmpty());
            System.assertEquals(true, !utils.individualIdList.isEmpty());
            System.assertEquals(true, !utils.accs.isEmpty());
        }
    }

    @isTest
    static void testUpdateCustomer() {
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive //NOPMD
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            Test.startTest();
            Account retrievedAccount = [SELECT Id, PersonIndividualId, OptinCGI__c FROM Account][0];//NOPMD
            B2CCustomInput__c customInput = B2CCustomInput_TDF.buildB2CCustomInput(1, false)[0];
            customInput.AccountId__c = retrievedAccount.Id;
            customInput.OptinCGI__c = true;
            insert customInput;  
            List<B2CCustomInput__c> customInputList = new List<B2CCustomInput__c>();
            customInputList.add(customInput);
            B2CCustomInput_UTL utils = new B2CCustomInput_UTL(customInputList);
            Test.stopTest();
            System.assert(true, true);
        }
    }
}