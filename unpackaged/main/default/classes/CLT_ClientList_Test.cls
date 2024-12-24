@IsTest
private class CLT_ClientList_Test {
    
    @testSetup
    static void clientListTestDataFactory() {
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

		List<Account> clients = new List<Account>();

        Account client1 = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, false);
		client1.CLienttype__pc = 'Client';
		client1.VIP__pc = 'Yes';
		client1.Local_Main_CA__c = sa.Id;
		clients.add(client1);

		Account client2 = CLT_TestDateFactory.createTestClient('Test client 2', 'Test Last Name2', sa.Id, store.Id, false);
		client2.CLienttype__pc = 'Client';
		client2.VIP__pc = 'Yes';
		clients.add(client2);

		insert clients;

		List<ClientList__c> clientLists = new List<ClientList__c>();

		ClientList__c clientList1 = CLT_TestDateFactory.createTestClientList('TEST MY VIP', 'AND CLienttype__pc in (\'PROSPECT_T\', \'Client\', \'Company\') AND VIP__pc = \'Yes\'', false);
		clientLists.add(clientList1);

		ClientList__c clientList2 = CLT_TestDateFactory.createTestClientList('TEST Client List 2', 'AND FirstName = \'Test client 2\'', false);
		clientList2.InMyStore__c = true;
		clientLists.add(clientList2);

		ClientList__c clientList3 = CLT_TestDateFactory.createTestClientList('TEST Client List 3', 'AND FirstName = \'Test client%\'', false);
		clientList3.VisibilityBasedOnField__c = 'Local_Main_CA__c';
		clientLists.add(clientList3);
        
		insert clientLists;
    }

	@isTest
	static void test_ClientList_GET() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		CLT_ClientList cltClientList = new CLT_ClientList();

		ClientList__c cl = [SELECT Id FROM ClientList__c WHERE Name = 'TEST MY VIP' LIMIT 1];

		System.runAs(sa) {
			
			Test.startTest();

			Object getSpecificClientListResponse = cltClientList.retrieveGet(new Map<String, String>{'Type' => cl.Id, 'noLimit' => 'true'});
			List<Object> clientListsInGetSpecific = (List<Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(getSpecificClientListResponse))).get('clientLists')));
			System.assertEquals(1, clientListsInGetSpecific.size(), 'returned specific client list size is different than 1');

			Object getClientListEmptyParamsResponse = cltClientList.retrieveGet(new Map<String, String>{'Type' => null});
			List<Object> clientListsInGetGeneral = (List<Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(getClientListEmptyParamsResponse))).get('clientLists')));
			System.assertEquals(3, clientListsInGetGeneral.size(), 'returned general client list size is different than 3');

			Test.stopTest();
		}
	}

	@isTest
	static void test_ClientList_GET_Membered() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		CLT_ClientList cltClientList = new CLT_ClientList();

		System.runAs(sa) {
			ClientList__c clientList = new ClientList__c (
            Name = 'test membered client list',
            Type__c = 'Membered'
			);
            insert clientList;

			Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1' LIMIT 1];

			ClientListMember__c clm = new ClientListMember__c(
				ClientList__c = clientList.Id,
				Client__c = client.Id
			);
			insert clm;

			Test.startTest();

			String memberedUnreachedQuery = CLT_Utils_ClientLists.buildDynamicQuery(clientList, sa.Id, 'TST123', true, true);
			List<Account> queriedMembersList = Database.query('SELECT Id FROM Account WHERE IsPersonAccount = TRUE ' + memberedUnreachedQuery); 
			System.assertEquals(1, queriedMembersList.size(), 'queried membbers list is not 1');
		
			Test.stopTest();
		}
	}


	@isTest
	static void test_ClientList_POST() {
		CLT_ClientList cltClientList = new CLT_ClientList();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object cltClientListPostResponse = cltClientList.retrievePost(new Map<String, String>(),new Map<String,Object>());
            System.assertEquals(null, cltClientListPostResponse, 'Post method defined and not tested');

            Test.stopTest();
        }
	}

	@isTest
	static void test_ClientList_DELETE() {
		CLT_ClientList cltClientList = new CLT_ClientList();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object cltClientListDeleteResponse = cltClientList.retrieveDelete(new Map<String, String>());
            System.assertEquals(null, cltClientListDeleteResponse, 'Delete method defined and not tested');

            Test.stopTest();
        }
	}
}