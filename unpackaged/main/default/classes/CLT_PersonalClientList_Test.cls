@isTest
private class CLT_PersonalClientList_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', false);
        store.Country__c = 'FR';
        insert store; 

        List<Account> clients = new List<Account>();

		clients.add(CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, false));
		clients.add(CLT_TestDateFactory.createTestClient('Test client 2', 'Test Last Name2', sa.Id, store.Id, false));
		clients.add(CLT_TestDateFactory.createTestClient('Test client 3', 'Test Last Name3', sa.Id, store.Id, false));

		insert clients;
	}

    @isTest
	static void testGetPersonalClientList() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		ClientList__c cl = CLT_TestDateFactory.createTestPersonalClientList('Test Personal Client List', sa.Id, true);

        List<ClientListMember__c> clmList = new List<ClientListMember__c>();
        for (Account client : [SELECT Id 
                                FROM Account 
                                WHERE FirstName IN ('Test client 1', 'Test client 2', 'Test client 3') AND LastName IN ('Test Last Name1', 'Test Last Name2', 'Test Last Name3')]) {
            clmList.add(CLT_TestDateFactory.createTestPersonalClientListMember(cl.Id, client.Id, false));
        }
		insert clmList;
        
        System.runAs(sa) {
			CLT_PersonalClientList cltPersonalClientList = new CLT_PersonalClientList();
			Test.startTest();
			Object responseGetPersonalClientList = cltPersonalClientList.retrieveGet(new Map<String, String>());
			Test.stopTest();
			List<Object> clientsList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(responseGetPersonalClientList))).get('clients')));

			System.assertEquals(3, clientsList.size(), 'Clients size is not 3');
		}
	}

    @isTest
	static void testPostPersonalClientListInsert() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        List<String> clmIdsList = new List<String>();
        for (Account client : [SELECT Id 
                                FROM Account 
                                WHERE FirstName IN ('Test client 1', 'Test client 2', 'Test client 3') AND LastName IN ('Test Last Name1', 'Test Last Name2', 'Test Last Name3')]) {
            clmIdsList.add(client.Id);
        }
        
        Map<String, Object> body = new Map<String, Object>();
        body.put('name', 'test insert client list');
        body.put('memberIds', clmIdsList);
        
        System.runAs(sa) {
			CLT_PersonalClientList cltPersonalClientList = new CLT_PersonalClientList();
			Test.startTest();
			String clId = (String)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cltPersonalClientList.retrievePost(new Map<String, String>(), body)))).get('id');
            Test.stopTest();
            
			List<ClientListMember__c> clmList = [SELECT Id FROM ClientListMember__c WHERE ClientList__c = :clId];

			System.assertEquals(3, clmList.size(), 'Clients size is not 3');
		}
	}

    @isTest
	static void testPostPersonalClientListUpdate() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		ClientList__c cl = CLT_TestDateFactory.createTestPersonalClientList('Test Personal Client List', sa.Id, true);

        List<ClientListMember__c> clmList = new List<ClientListMember__c>();
        List<String> clientsIds = new List<String>();
        for (Account client : [SELECT Id, FirstName
                                FROM Account 
                                WHERE FirstName IN ('Test client 1', 'Test client 2', 'Test client 3') AND LastName IN ('Test Last Name1', 'Test Last Name2', 'Test Last Name3')]) {
            if(client.FirstName == 'Test client 1' || client.FirstName == 'Test client 2') {
                clmList.add(CLT_TestDateFactory.createTestPersonalClientListMember(cl.Id, client.Id, false));
            }
            if(client.FirstName == 'Test client 1' || client.FirstName == 'Test client 3') {
                clientsIds.add(client.Id);
            }                                    
        }
		insert clmList;

        Map<String, String> params = new Map<String, String>{'id' => cl.Id};
        
        Map<String, Object> body = new Map<String, Object>();
        body.put('name', 'test update client list');
        body.put('memberIds', clientsIds);
        
        System.runAs(sa) {
			CLT_PersonalClientList cltPersonalClientList = new CLT_PersonalClientList();
			Test.startTest();
			String clId = (String)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cltPersonalClientList.retrievePost(params, body)))).get('id');
            Test.stopTest();
            
			List<ClientListMember__c> clmListAfterUpdate = [SELECT Id FROM ClientListMember__c WHERE ClientList__c = :clId];
            System.assertEquals(2, clmListAfterUpdate.size(), 'Clients size is not 2');

            ClientList__c clAfterUpdate = [SELECT Id,Name FROM ClientList__c WHERE Id = :cl.Id];
            System.assertEquals('test update client list', clAfterUpdate.Name, 'Client List Name is not updated');
		}
	}

    @isTest
	static void testDeletePersonalClientList() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1'];
		ClientList__c cl = CLT_TestDateFactory.createTestPersonalClientList('Test Personal Client List', sa.Id, true);
		ClientListMember__c clm = CLT_TestDateFactory.createTestPersonalClientListMember(cl.Id, client.Id, true);
        
        System.runAs(sa) {
			CLT_PersonalClientList cltPersonalClientList = new CLT_PersonalClientList();
			Test.startTest();
			cltPersonalClientList.retrieveDelete(new Map<String, String>{'id' => cl.Id});
			Test.stopTest();
            List<ClientList__c> clAfterDelete = [SELECT Id FROM ClientList__c WHERE Id = :cl.Id];
			System.assertEquals(0, clAfterDelete.size(), 'Client list list size is not 0 after delete');
            
            try {
                cltPersonalClientList.retrieveDelete(new Map<String, String>{'id' => cl.Id}); 
            }
            catch (Exception ex) {
                System.assertEquals('No client List with this id were found', ex.getMessage(), 'deletd Client list id not giving no id found error');
            }

            try {
                cltPersonalClientList.retrieveDelete(new Map<String, String>()); 
            }
            catch (Exception ex) {
                System.assertEquals('No client List id received', ex.getMessage(), 'delete call with no id not giving no id received message');
            }
		}
	}

    @isTest
	static void testGetClientsByFilters() {
		User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		
        List<Transaction__c> transactionsToInsert = new List<Transaction__c>();
        List<Account> clientsToUpdate = new List<Account>();

        Gift__c gift = CLT_TestDateFactory.createTestGift('Wedding', true);
        Event__c event = CLT_TestDateFactory.createTestClientelingEvent('Holiday Season 2023', true);
        List<Task> tasksToInsert = new List<Task>();

        CLT_TestDateFactory.createTestCountryCode('France', 'FR', 'FRA', true);

        for (Account client : [SELECT Id,LightCurrentCluster__pc,Country__pc,LifeTimePurchaseAmount__pc,LastPurchaseDate__pc
                                FROM Account 
                                WHERE FirstName IN ('Test client 1', 'Test client 2', 'Test client 3') AND LastName IN ('Test Last Name1', 'Test Last Name2', 'Test Last Name3')]) {
            client.LightCurrentCluster__pc = 'VIC';
            client.Country__pc = 'FR';
            client.LifeTimePurchaseAmount__pc = 2244.78;
            client.LastPurchaseDate__pc = Date.newInstance(2022, 12, 25);
            clientsToUpdate.add(client);

            transactionsToInsert.add(CLT_TestDateFactory.createTestTransaction(client.Id, Date.newInstance(2022, 12, 25), false));

            Task giftTask = CLT_TestDateFactory.createTask(sa.Id, false);
            giftTask.WhatId = client.Id;
            giftTask.Gift__c = gift.Id;
            giftTask.Gifted__c = true;
            giftTask.GiftedDate__c = Date.today();
            tasksToInsert.add(giftTask);

            Task eventTask = CLT_TestDateFactory.createTask(sa.Id, false);
            eventTask.WhatId = client.Id;
            eventTask.Event__c = event.Id;
            eventTask.EventClientAttended__c = true;
            eventTask.EventAttendedDate__c = Date.today();
            tasksToInsert.add(eventTask);
        }
        update clientsToUpdate;
        insert transactionsToInsert;

        Product2 product = CLT_TestDateFactory.createTestStandardProduct('tst12345', false);
        product.model__c = 'ATTACHE';
        product.size__c = 'Cabin Plus';
        product.material_v3__c = 'ALUMINUM';
        product.color_v3__c = 'Silver';

        insert product;

        List<TransactionItem__c> transactionItemsToInsert = new List<TransactionItem__c>();
        for(Transaction__c t : transactionsToInsert) {
            transactionItemsToInsert.add(CLT_TestDateFactory.createTestTransactionItem(t.Id, t.Client__c, product.Id, false));
        }
        insert transactionItemsToInsert;

        insert tasksToInsert;
        
        System.runAs(sa) {
			CLT_PersonalClientList cltPersonalClientList = new CLT_PersonalClientList();
			Test.startTest();
            Map<String,Object> body = new Map<String, Object> {
                'segment' => new List<String> {'VIC'},
                'type' => new List<String> {'Local'},
                'lifetimeTurnover' => new Map<String, String>{
                    'fromValue' => '1500.00',
                    'toValue' =>'3000.00'
                },
                'lastPurchaseDate' => new Map<String, String>{
                    'fromValue' => '2022-01-01',
                    'toValue' =>'2022-12-31'
                },
                'product' =>  new List<String> {'tst12345'},
                'collection' => new List<String> {'ATTACHE'},
                'size' => new List<String> {'Cabin Plus'},
                'material' => new List<String> {'ALUMINUM'},
                'color' => new List<String> {'Silver'},
                'giftGifted' => true,
                'giftGiftedDate' => DateTime.now().addDays(-30).format('yyyy-MM-dd'),
                'eventAttended' => true,
                'eventAttendedDate' => DateTime.now().addDays(-30).format('yyyy-MM-dd') 
            };
			Object responseGetClientsByFilters = cltPersonalClientList.retrievePost(new Map<String, String>{'clientsFilters' => 'true'}, body);
			Test.stopTest();
			List<Object> clientsList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(responseGetClientsByFilters));

			System.assertEquals(3, clientsList.size(), 'Clients size is not 3');
		}
	}
}