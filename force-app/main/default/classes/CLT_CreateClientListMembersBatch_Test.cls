/**
 * @author Sarah AYOUN (Balink)
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains methods to test the CLT_CreateClientListMembersBatch functionality:
 * TEST METHOD					                        |	DESCRIPTION
 * testCreateClientListMembersBatch                     |	Test batch execution 
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modification	|Modified By	|Related Jira Ticket	|Description of changes			
 * 1.0		|2024/10/06			    |Sarah A.	    |RCLIENT-860			|Initial creation of test class for CLT_CreateClientListMembersBatch.
 */
@isTest
private class CLT_CreateClientListMembersBatch_Test {

    @TestSetup
    static void prepareTestData() {
        // Create a User for testing
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        // Create a Store for the testing User
        Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        // Create test Accounts (clients)
        Account client1 = CLT_TestDateFactory.createTestClient('Test Client 1', 'Test Client 1 LN', sa.Id, store.Id, true);
        CLT_TestDateFactory.createTestClient('Test Client 2', 'Test Client 2 LN', sa.Id, store.Id, true);
        ClientList__c clientList = CLT_TestDateFactory.createTestClientList('Test Membered List', '', false);
        clientList.Type__c = 'Membered';
        insert clientList;

        CLT_TestDateFactory.createTestPersonalClientListMember(clientList.Id, client1.Id, true);
    }

    @isTest
    static void testCreateClientListMembersBatch() {
        ClientList__c cl = [SELECT Id FROM ClientList__c WHERE Type__c = 'Membered' LIMIT 1];
        List<Account> clients = [SELECT Id FROM Account WHERE FirstName = 'Test Client 1' OR FirstName = 'Test Client 2'];
        // Prepare a CSV file content with valid client IDs
        String csvContent = 'Id;\n' + clients[0].Id + ';\n' + clients[1].Id + ';';
        
        // Create an instance of the batch class
        CLT_CreateClientListMembersBatch batch = new CLT_CreateClientListMembersBatch(cl.Id, csvContent, 5, 0, 1);

        // Execute the batch
        Test.StartTest();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify that ClientListMember__c records were created
        List<ClientListMember__c> clmList = [SELECT Id FROM ClientListMember__c WHERE ClientList__c = :cl.Id];
        System.assertEquals(2, clmList.size(), 'Expected 2 Client List Members to be created.');
    }
}