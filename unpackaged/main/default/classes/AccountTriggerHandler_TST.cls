/**
* @author		Ulrich.M NDONG NGOMO
* @date		    22/05/2023 
* @description Classe Test pour tester la classe AccountTriggerHandler
*/
@IsTest(seeAllData=false) 
public with sharing class AccountTriggerHandler_TST {

    //Test de la méthode BeforeUpdate de Account
    @isTest 
    static void testBeforeUpdate() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(Account__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            AccountTriggerHandler accountHandler = new AccountTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            accountHandler.BeforeUpdate(mapNewItems, mapOldItems);
        }
    }    
    //Test de la méthode AfterInsert de Account
    @isTest 
    static void testAfterInsert() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(Account__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            AccountTriggerHandler accountHandler = new AccountTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            accountHandler.AfterInsert(mapNewItems);
        }
    }
      //Test de la méthode AfterUpdate de Account
    @isTest 
    static void testAfterUpdate() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(Account__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            AccountTriggerHandler accountHandler = new AccountTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            accountHandler.AfterUpdate(mapNewItems, mapOldItems);
        }
    }
      //Test de la méthode AfterDelete de Account
    @isTest 
    static void testAfterDelete() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(Account__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            AccountTriggerHandler accountHandler = new AccountTriggerHandler();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            accountHandler.AfterDelete(mapOldItems);
        }
    }
    //Test de la méthode BeforeDelete de Account
    @isTest 
    static void testBeforeDelete() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(Account__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            AccountTriggerHandler accountHandler = new AccountTriggerHandler();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            accountHandler.BeforeDelete(mapOldItems);
        }
    }
      //Test de la méthode byPass de Account
    @isTest 
    static void testByPass() {
        BypassTrigger__c BypassTrigger = new BypassTrigger__c(Account__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            AccountTriggerHandler accountHandler = new AccountTriggerHandler();
            accountHandler.IsDisabled();
        }
    }
}