/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP001_DM_Account_Test  
-- - Author             : Ilhem Zraiga
-- - Description        : Data Managment Account Object Test Class
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 19/05/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
@IsTest(SeeAllData=false)
public class TNP001_DM_Account_Test {
    @isTest
    static public void getAccount(){   
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        TNP001_DM_Account.getAccountById(acc.Id);
        system.assertNotEquals (acc , null);
    }
    
    @isTest
    static public void testPreventDeletionWithClientTypeEmpty(){   
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            FirstName = 'R360',
            LastName = 'Integration',
            Alias = 'tuser',
            Email = 'testusersdsd@rimowa.com',
            Username = 'testusersdsd@example.com',
            ProfileId = profile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            StaffCode__c = 'User1'
        );
        insert testUser;
        System.runAs(testUser) {
            Account acc = new Account(Name = 'Test',ClientType__pc = 'Client',ContactableByEmail__pc = true);
            List<Account> accList = TestDataFactory.createSObjectList('Account', 1, false);
            accList[0].ClientType__pc = 'Company';
            insert accList;
                    
            List<Account> retrievedAccList = [SELECT Id, ClientType__pc, ContactableByEmail__pc FROM Account WHERE Id = : accList[0].Id];
            retrievedAccList[0].ClientType__pc = null;
            update retrievedAccList;
            
            List<Account> verifiedAccList = [SELECT Id, ClientType__pc, ContactableByEmail__pc FROM Account WHERE Id = : retrievedAccList[0].Id];          
            System.assertEquals('Company', verifiedAccList[0].ClientType__pc);
        }
    }
    
    @isTest
    static public void testPreventDeletionWithClientTypeFilledin(){   
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            FirstName = 'R360',
            LastName = 'Integration',
            Alias = 'tuser',
            Email = 'testusersdsd@rimowa.com',
            Username = 'testusersdsd@example.com',
            ProfileId = profile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            StaffCode__c = 'User1'
        );
        insert testUser;
        System.runAs(testUser) {
            Account acc = new Account(Name = 'Test',ClientType__pc = 'Client',ContactableByEmail__pc = true);
            List<Account> accList = TestDataFactory.createSObjectList('Account', 1, false);
            accList[0].ClientType__pc = 'Company';
            insert accList;
                    
            List<Account> retrievedAccList = [SELECT Id, ClientType__pc FROM Account WHERE Id = : accList[0].Id];
            retrievedAccList[0].ClientType__pc = 'Client';
            update retrievedAccList;
            
            System.assertEquals('Client', retrievedAccList[0].ClientType__pc);
        }
    }
    
       	@isTest
    static void testBackupKPIInfoWithR360User() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            FirstName = 'R360',
            LastName = 'Integration',
            Alias = 'tuser',
            Email = 'testusersdsd@rimowa.com',
            Username = 'testusersdsd@example.com',
            ProfileId = profile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            StaffCode__c = 'User1'
        );
        insert testUser;
        System.runAs(testUser) {
            Store__c s1 = new Store__c(Name = 'Test 1',SourceStoreId__c = 'NL02');
            insert s1;
            List<Account> accList = TestDataFactory.createSObjectList('Account', 1, false);
            accList[0].ClientAdvisorId__pc = 'User2';
            accList[0].Other_sources_ID__c = 'Test';
            accList[0].MainStoreId__pc = 'NL02';
            accList[0].OriginStore__pc = s1.Id;
            insert accList;
            
            TNP_001_AccountTrigger_SVE.backupKPIInfo(accList);
            Account acc = [SELECT Id, ClientAdvisor__pc, MainStoreId__pc FROM Account WHERE Id = :accList[0].Id];
            System.assertNotEquals(null, acc.MainStoreId__pc);
        }
    }
    
   	@isTest
    static void testBackupKPIInfoWithOtherUser() {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            FirstName = 'MulesoftUser',
            LastName = 'Integration',
            Alias = 'tuser',
            Email = 'testusermulesoft@rimowa.com',
            Username = 'testusermulesoft@example.com',
            ProfileId = profile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York',
            StaffCode__c = 'User1'
        );
        insert testUser;
        System.runAs(testUser) {
            Store__c s1 = new Store__c(Name = 'Test 1',SourceStoreId__c = 'NL02');
            insert s1;
            List<Account> accList = TestDataFactory.createSObjectList('Account', 1, false);
            accList[0].ClientAdvisorId__pc = 'User2';
            accList[0].Other_sources_ID__c = 'Test';
            accList[0].MainStoreId__pc = 'NL02';
            accList[0].OriginStore__pc = s1.Id;
            insert accList;
            
            TNP_001_AccountTrigger_SVE.backupKPIInfo(accList);
            Account acc = [SELECT Id, ClientAdvisor__pc, MainStoreId__pc FROM Account WHERE Id = :accList[0].Id];
            System.assertNotEquals(null, acc.MainStoreId__pc);
        }
    }
    
    @isTest
    static void testManageClientSourceWithR360User() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            FirstName = 'R360',
            LastName = 'Integration',
            Alias = 'tuser',
            Email = 'testusersdsd@rimowa.com',
            Username = 'testusersdsd@example.com',
            ProfileId = profile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York'
        );
        insert testUser;
        System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - testUser *** '+testUser);
        System.runAs(testUser) {
            Store__c s1 = new Store__c(Name = 'Test 1',SourceStoreId__c = 'NL03');
            insert s1;
            List<Account> accList = TestDataFactory.createSObjectList('Account', 1, false);
            Account acc = accList[0];
            acc.Other_sources_ID__c = 'Test';
            acc.MainStoreId__pc = 'NL03';
            acc.OriginStore__pc = s1.Id;
            insert acc;
    		System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - acc *** '+acc);
            List<Account> retrievedAccList = [SELECT Id, Other_sources_ID__c, MainStoreId__pc, ClientAdvisorId__pc,
                                              CreatedById, OriginStoreCode__c 
                                              FROM Account WHERE Id = :acc.Id];
            System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - retrievedAccList *** '+retrievedAccList);
            List<ClientSource__c> clientSources = [SELECT Id FROM ClientSource__c WHERE Client__c = :acc.Id];
            System.assertEquals(1, clientSources.size());
        }
    }
    
     @isTest
    static void testManageClientSourceWithOtherUser() {

        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            FirstName = 'FirstName',
            LastName = 'LasName',
            Alias = 'tuser',
            Email = 'testFirstLast@rimowa.com',
            Username = 'testFirstLast@example.com',
            ProfileId = profile.Id,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/New_York'
        );
        insert testUser;
        System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - testUser *** '+testUser);
        System.runAs(testUser) {
            Store__c s1 = new Store__c(Name = 'Test 1',SourceStoreId__c = 'NL03');
            insert s1;
            List<Account> accList = TestDataFactory.createSObjectList('Account', 1, false);
            Account acc = accList[0];
            acc.Other_sources_ID__c = 'Test';
            acc.MainStoreId__pc = 'NL03';
            acc.OriginStore__pc = s1.Id;
            insert acc;
    		System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - acc *** '+acc);
            List<Account> retrievedAccList = [SELECT Id, Other_sources_ID__c, MainStoreId__pc, ClientAdvisorId__pc,
                                              CreatedById, OriginStoreCode__c 
                                              FROM Account WHERE Id = :acc.Id];
            System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - retrievedAccList *** '+retrievedAccList);
            List<ClientSource__c> clientSources = [SELECT Id FROM ClientSource__c WHERE Client__c = :acc.Id];
            System.assertEquals(0, clientSources.size());
        }
    }

}