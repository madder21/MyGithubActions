/**
* @author		Amine SAMODI
* @date		    01/04/2025 
* @description Classe Test pour tester la classe CaseTriggerHandler
*/
@IsTest(seeAllData=false) 
public class CaseTriggerHandler_Test {
    
    //Test de la méthode BeforeUpdate de Case
    @isTest 
    static void testBeforeUpdate() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            caseHandler.BeforeUpdate(mapNewItems, mapOldItems);
        }
    }
	//Test de la méthode BeforeInsert de Case
    @isTest 
    static void testBeforeInsert() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            List<SObject> newItems = new List<SObject>();
            caseHandler.BeforeInsert(newItems);
        }
    }    
    //Test de la méthode AfterInsert de Case
    @isTest 
    static void testAfterInsert() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            caseHandler.AfterInsert(mapNewItems);
        }
    }
      //Test de la méthode AfterUpdate de Case
    @isTest 
    static void testAfterUpdate() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            caseHandler.AfterUpdate(mapNewItems, mapOldItems);
        }
    }
    //Test de la méthode AfterDelete de Case
    @isTest 
    static void testAfterDelete() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            caseHandler.AfterDelete(mapOldItems);
        }
    }
    //Test de la méthode BeforeDelete de Case
    @isTest 
    static void testBeforeDelete() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            caseHandler.BeforeDelete(mapOldItems);
        }
    }
      //Test de la méthode byPass de Case
    @isTest 
    static void testByPass() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            caseHandler.IsDisabled();
        }
    }
    
    //Test de la méthode BeforeInsert de Case
    @isTest 
    static void testAfterUndelete() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(CaseApex__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            CaseTriggerHandler caseHandler = new CaseTriggerHandler();
            Map<Id, SObject> oldItems = new Map<Id, SObject>();
            caseHandler.AfterUndelete(oldItems);
        }
    }   
}