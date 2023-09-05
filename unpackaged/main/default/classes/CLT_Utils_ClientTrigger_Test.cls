@isTest
private class CLT_Utils_ClientTrigger_Test {
    @TestSetup
    static void prepareTestData(){
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

		List<Account> clients = new List<Account>();

        Account client1 = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, false);
		clients.add(client1);

		Account client2 = CLT_TestDateFactory.createTestClient('Test client 2', 'Test Last Name2', sa.Id, store.Id, false);
        client2.Targeted_Customers_CAreattribution__c = true;
		clients.add(client2);

		insert clients;
    }

    @isTest
    static void testUpdateTargetedCustomersCAreattributionDateAfterUpdate() {
        Account client = [SELECT Targeted_Customers_CAreattribution__c FROM Account WHERE FirstName = 'Test client 1' LIMIT 1];
        client.Targeted_Customers_CAreattribution__c = true;

        Test.startTest();
        update client;
        Test.stopTest();

        Account clientAfterUpdate = [SELECT Targeted_Customers_CAreattribution_Date__c FROM Account WHERE FirstName = 'Test client 1' LIMIT 1];
        System.assertEquals(Date.today(), clientAfterUpdate.Targeted_Customers_CAreattribution_Date__c, 'Targeted Customers CAreattribution Date is not equal to today after update');
    }

    @isTest
    static void testUpdateTargetedCustomersCAreattributionDateAfterInsert() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = 'TST123'];

        Account client = CLT_TestDateFactory.createTestClient('Test client 3', 'Test Last Name3', sa.Id, store.Id, false);
        client.Targeted_Customers_CAreattribution__c = true;

        Test.startTest();
        insert client;
        Test.stopTest();

        Account clientAfterInsert = [SELECT Targeted_Customers_CAreattribution_Date__c FROM Account WHERE FirstName = 'Test client 3' LIMIT 1];
        System.assertEquals(Date.today(), clientAfterInsert.Targeted_Customers_CAreattribution_Date__c, 'Targeted Customers CAreattribution Date is not equal to today after insert');
    }

    @isTest
    static void testUpdateTargetedCAreattributionContactDateAfterUpdate() {
        Account client = [SELECT Targeted_Customers_CAreattribution_Date__c,LastContactDate__pc FROM Account WHERE FirstName = 'Test client 2' LIMIT 1];
        client.Targeted_Customers_CAreattribution_Date__c = Date.today().addDays(-3);
        client.LastContactDate__pc = Date.today().addDays(-1);

        Test.startTest();
        update client;
        Test.stopTest();

        Account clientAfterUpdate = [SELECT Targeted_CAreattribution_Contact_Date__c FROM Account WHERE FirstName = 'Test client 2' LIMIT 1];
        System.assertEquals(Date.today().addDays(-1), clientAfterUpdate.Targeted_CAreattribution_Contact_Date__c, 'Targeted Customers CAreattribution Contact Date is not equal to today after update');
    }

    @isTest
    static void testUpdateTargetedCAreattributionContactDateAfterInsert() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = 'TST123'];

        Account client = CLT_TestDateFactory.createTestClient('Test client 4', 'Test Last Name4', sa.Id, store.Id, false);
        client.Targeted_Customers_CAreattribution__c = true;
        client.LastContactDate__pc = Date.today();

        Test.startTest();
        insert client;
        Test.stopTest();

        Account clientAfterInsert = [SELECT Targeted_CAreattribution_Contact_Date__c FROM Account WHERE FirstName = 'Test client 4' LIMIT 1];
        System.assertEquals(Date.today(), clientAfterInsert.Targeted_CAreattribution_Contact_Date__c, 'Targeted Customers CAreattribution Contact Date is not equal to today after insert');
    }
}