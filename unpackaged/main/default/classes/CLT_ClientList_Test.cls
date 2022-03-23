@IsTest
private class CLT_ClientList_Test {
    
    @testSetup
    static void clientListTestDataFactory() {
        List<Account> clients = new List<Account>();
        
        Account c1 = new Account(FirstName = 'Client1', LastName = 'Test1', CLienttype__pc = 'Client', VIP__pc = 'Yes', ClientAdvisor__pc = UserInfo.getUserId());
        clients.add(c1);
        
        Account c2 = new Account(FirstName = 'Client2', LastName = 'Test2', CLienttype__pc = 'Client', VIP__pc = 'Yes', ClientAdvisor__pc = UserInfo.getUserId());
        clients.add(c2);
        
        insert clients;

		List<ClientList__c> clientLists = new List<ClientList__c>();

		ClientList__c clientList1 = new ClientList__c(Name = 'TEST', clientListQuery__c = 'AND CLienttype__pc in (\'PROSPECT_T\', \'Client\', \'Company\') AND VIP__pc = \'Yes\'');
		clientLists.add(clientList1);
        
		ClientList__c clientList2 = new ClientList__c(clientListQuery__c = 'AND FirstName = \'Test\'', InMyStore__c = true);
		clientLists.add(clientList2);
        
		ClientList__c clientList3 = new ClientList__c(clientListQuery__c = 'AND FirstName = \'Testy\'', VisibilityBasedOnField__c = 'Local_Main_CA__c');
		clientLists.add(clientList3);
        
		insert clientLists;
    }

	@isTest 
    static void test_method_one() {
        
        ClientList__c clientList1 = [SELECT Id FROM ClientList__c WHERE Name = 'TEST' LIMIT 1];
        
		CLT_ClientList clt_clientLists = new  CLT_ClientList();
 		Test.startTest();

		clt_clientLists.retrieveGet(new Map<String, String>{'Type' => clientList1.Id});
		clt_clientLists.retrieveGet(new Map<String, String>{'Type' => null});
		clt_clientLists.retrieveDelete(new Map<String, String>());
		clt_clientLists.retrievePost(new Map<String, String>(),new Map<String,Object>());

		Test.stopTest();
	}

}