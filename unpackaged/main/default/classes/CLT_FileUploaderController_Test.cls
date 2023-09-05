@isTest
private class CLT_FileUploaderController_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('test FileUploader fn', 'test FileUploader ln', sa.Id, store.Id, true);
	}

    @isTest
	static void testInsertMembersFromFile(){
        ClientList__c clientList = CLT_TestDateFactory.createTestClientList('membered test list', '', false);
        clientList.Type__c = 'Membered';
        insert clientList;

        Account client = [SELECT Id FROM Account WHERE FirstName = 'test FileUploader fn' AND LastName = 'test FileUploader ln' LIMIT 1];

		CLT_FileUploaderController.insertMembersFromFile(clientList.Id, 'testFile.csv', Blob.valueof('Id;\n' + client.Id + ';'));

        List<ClientListMember__c> clmList = [SELECT Id FROM ClientListMember__c WHERE ClientList__c = :clientList.Id];
		System.assertEquals(1, clmList.size(), 'Client list members list size is not 1 after file upload');
        
	}
}