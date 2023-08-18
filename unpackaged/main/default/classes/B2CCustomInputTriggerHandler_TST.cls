/**
* @author		Ulrich.M NDONG NGOMO
* @date		    22/05/2023 
* @description Classe Test pour tester la classe B2CCustomInputTriggerHandler
*/
@IsTest(seeAllData=false) 
public with sharing class B2CCustomInputTriggerHandler_TST {

    //Test de la méthode BeforeUpdate de Account
    @isTest 
    static void testBeforeUpdate() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            b2CCustomInputHandler.BeforeUpdate(mapNewItems, mapOldItems);
        }
    }    
    //Test de la méthode AfterInsert de Account
    @isTest 
    static void testAfterInsert() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            b2CCustomInputHandler.AfterInsert(mapNewItems);
        }
    }
      //Test de la méthode AfterUpdate de Account
    @isTest 
    static void testAfterUpdate() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            Map<id,SObject> mapNewItems = new Map<id,SObject>();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            b2CCustomInputHandler.AfterUpdate(mapNewItems, mapOldItems);
        }
    }
      //Test de la méthode AfterDelete de Account
    @isTest 
    static void testAfterDelete() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            b2CCustomInputHandler.AfterDelete(mapOldItems);
        }
    }
    //Test de la méthode BeforeDelete de Account
    @isTest 
    static void testBeforeDelete() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            b2CCustomInputHandler.BeforeDelete(mapOldItems);
        }
    }
    //Test de la méthode BeforeDelete de Account
    @isTest 
    static void testBeforeInsert() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            List<SObject> listOldItems = new List<SObject>();
            b2CCustomInputHandler.BeforeInsert(listOldItems);
        }
    }
    //Test de la méthode BeforeDelete de Account
    @isTest 
    static void testAfterUndelete() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            Map<id,SObject> mapOldItems = new Map<id,SObject>();
            b2CCustomInputHandler.AfterUndelete(mapOldItems);
        }
    }
    //Test de la méthode byPass de Account
    @isTest 
    static void testByPass() {
        TriggerSettings__c BypassTrigger = new TriggerSettings__c(B2CCustomInput__c = true,
                                               SetupOwnerId = UserInfo.getUserId());
        
        insert BypassTrigger;
        User testUser = [SELECT Id, Name, ProfileId, Profile.Name, isActive
                         FROM User WHERE ID =:UserInfo.getUserId()];
        System.runAs(testUser){
            B2CCustomInputTriggerHandler b2CCustomInputHandler = new B2CCustomInputTriggerHandler();
            b2CCustomInputHandler.IsDisabled();
        }
    }
}