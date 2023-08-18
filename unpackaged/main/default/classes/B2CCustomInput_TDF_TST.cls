/**
 * @author Ulrich M
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description  this class conducts comprehensive testing for the class B2CCustomInput_TDF
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|12062023			|.UMNN		|.					|.
*/
@isTest(SeeAllData=false)
public with sharing class B2CCustomInput_TDF_TST {

    @isTest static void testCaseCreateB2CCustomInput() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive//NOPMD
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            Test.startTest();
            List<B2CCustomInput__c> b2CCustomInputList = B2CCustomInput_TDF.buildB2CCustomInput(5, true);
            List<B2CCustomInput__c> retrievedB2CCustomInputList = [SELECT Id FROM B2CCustomInput__c];
            Test.stopTest();
            System.assertEquals(b2CCustomInputList.size(), retrievedB2CCustomInputList.size());
        }
    }


    @isTest static void testCaseWithoutCreateB2CCustomInput() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive//NOPMD
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            Test.startTest();
            List<B2CCustomInput__c> b2CCustomInputList = B2CCustomInput_TDF.buildB2CCustomInput(5, false);
            List<B2CCustomInput__c> retrievedB2CCustomInputList = [SELECT Id FROM B2CCustomInput__c];
            Test.stopTest();
            System.assertNotEquals(b2CCustomInputList.size(), retrievedB2CCustomInputList.size());
        }
    }
}