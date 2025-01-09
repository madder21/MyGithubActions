/**
 * @author (Balink)
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains methods to test the CLT_FileUploaderController functionality:
 * TEST METHOD					                        |	DESCRIPTION
 * testInsertMembersFromFile                            |	Test the file upload functionality for valid files
 * testInsertMembersFromFile_NonCSVFile                 |	Test the file upload functionality for invalid file types
 * testInsertMembersFromFile_MissingDynamicColumn       |	Test the file upload functionality when required fields are missing
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modification	|Modified By	|Related Jira Ticket	|Description of changes			
 * 1.0		|2024/10/06			    |.Sarah A.	    |RCLIENT-860			|client list members created by batch
 */
@isTest
private class CLT_FileUploaderController_Test {

    @TestSetup
    static void prepareTestData() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('test FileUploader fn', 'test FileUploader ln', sa.Id, store.Id, true);
    }

    @isTest
    static void testInsertMembersFromFile() {
        ClientList__c clientList = CLT_TestDateFactory.createTestClientList('membered test list', '', false);
        clientList.Type__c = 'Membered';
        insert clientList;

        Account client = [SELECT Id FROM Account WHERE FirstName = 'test FileUploader fn' AND LastName = 'test FileUploader ln' LIMIT 1];

        Test.StartTest();
        CLT_FileUploaderController.insertMembersFromFile(clientList.Id, 'testFile.csv', 'Id;\n' + client.Id + ';');
        Test.stopTest();

        List<ClientListMember__c> clmList = [SELECT Id FROM ClientListMember__c WHERE ClientList__c = :clientList.Id];
        System.assertEquals(1, clmList.size(), 'Client list members list size is not 1 after file upload');
    }

    @isTest
    static void testInsertMembersFromFile_NonCSVFile() {
        ClientList__c clientList = CLT_TestDateFactory.createTestClientList('membered test list', '', false);
        insert clientList;

        Test.StartTest();
        // Attempt to upload a non-CSV file
        try {
            CLT_FileUploaderController.insertMembersFromFile(clientList.Id, 'testFile.txt', 'Id;\n1;');
            System.assert(false, 'Expected CustomException for non-CSV file format.');
        } catch (CLT_FileUploaderController.CustomException e) {
            System.assertEquals('File format is wrong. Only CSV format is allowed.', e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void testInsertMembersFromFile_MissingDynamicColumn() {
        ClientList__c clientList = CLT_TestDateFactory.createTestClientList('membered test list', '', false);
        insert clientList;

        Test.StartTest();
        // Attempt to upload a CSV file without the required 'Id' column
        try {
            CLT_FileUploaderController.insertMembersFromFile(clientList.Id, 'testFile.csv', 'Name;\nJohn Doe;');
            System.assert(false, 'Expected CustomException for missing dynamic column.');
        } catch (CLT_FileUploaderController.CustomException e) {
            System.assertEquals('File doesn\'t contain a Id column.', e.getMessage());
        }
        Test.stopTest();
    }
}