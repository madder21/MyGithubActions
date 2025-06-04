/**
 * @author Sarah Ayoun (Balink)
 * @date Mai,30 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_Utils_ClientDetails :
 * testSetup : Creation of test user and store
 * TEST METHOD				                    |	DESCRIPTION
 * testUpsertClientinsight       				|	Test upsertClientinsight
 * testGetClientFields       				    |	Test getClientFields
 * testGetClientIds            				    |	Test getClientIds
 * testGetPurchases            				    |	Test getPurchases
 * testGetClientTimeline            		    |	Test getClientTimeline
 * testGetClientNotes              				|	Test getClientNotes
 * testGetClientWishList              			|	Test getClientWishList
 * testGetClientAddresses              			|	Test getClientAddresses
 * testGetClientGifts              			    |	Test getClientGifts
 * testGetClientEvents              			|	Test getClientEvents
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2024/05/30			|.Israel Z.		|.						|.original version
*/
@isTest
private class CLT_Utils_ClientDetails_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
	}

    @isTest
	static void testUpsertClientinsight() {
        Map<String,Object> body = new Map<String,Object>();
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
        Map<String,Object> clientInsightMap = new MAp<String, Object> {
            'clientId' => client.Id,
            'historicalClient' => 'Yes'
        }; 
        body.put('clientInsights', clientInsightMap);

        Map<String, Object> receivedInsightMap = CLT_Utils_ClientDetails.upsertClientinsight(body);

        System.assertEquals(client.Id, (String)receivedInsightMap.get('clientId'), 'CLT_Utils_ClientDetails_Test:testUpsertClientinsight: client id of insight is not the same as sent');
    }

    @isTest
	static void testGetClientFields() {
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];

        Map<String, Object> clientFieldsMap = CLT_Utils_ClientDetails.getClientFields(client.Id);
        System.assertEquals('Test First Name', (String)clientFieldsMap.get('firstName'), 'CLT_Utils_ClientDetails_Test:testgetClientFields: first nameis not as expected');
    }

    @isTest
    static void testGetClientIds() {
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
        CLT_TestDateFactory.createTestClientSource(client.Id, '001', 'TST00123', true);
        Map<String, Object> clientIdsMap = CLT_Utils_ClientDetails.getClientIds(client.Id);
        System.assertEquals(1, clientIdsMap.keySet().size(), 'CLT_Utils_ClientDetails_Test:testGetClientIds: client ids list size is not 1');
    }

    @isTest
    static void testGetPurchases() {
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
        Transaction__c transction = CLT_TestDateFactory.createTestTransaction(client.Id, Date.today().addDays(-7), true);
        Product2 product = CLT_TestDateFactory.createTestStandardProduct('TEST123', true);
        TransactionItem__c transactionItem = CLT_TestDateFactory.createTestTransactionItem(transction.Id, client.Id, product.Id, true);

        List<Map<String, Object>> purchasesMap = CLT_Utils_ClientDetails.getPurchases(client.Id);
        System.assertEquals(1, purchasesMap.size(), 'CLT_Utils_ClientDetails_Test:testGetPurchases: purchasess list size is not 1');
    }

    @isTest
    static void testGetClientTimeline() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];

        Task task = CLT_TestDateFactory.createTask(sa.Id, false);
        task.WhatId = client.Id;
        insert task;

        Event event = CLT_TestDateFactory.createTestEvent(sa.Id, false);
        event.WhatId = client.Id;
        insert event;

        List<Object> timelineMap = CLT_Utils_ClientDetails.getClientTimeline(client.Id, 'TST123');
        System.assertEquals(2, timelineMap.size(), 'CLT_Utils_ClientDetails_Test:testGetPurchases: timelineMap list size is not 1');
    }

    @isTest
    static void testGetClientNotes() {
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
        CLT_TestDateFactory.createTestNote('Test Note', client.Id, true);
        List<Map<String, Object>> notesMap = CLT_Utils_ClientDetails.getClientNotes(client.Id);
        System.assertEquals(1, notesMap.size(), 'CLT_Utils_ClientDetails_Test:testGetClientNotes: notes list size is not 1');
    }

    @isTest
    static void testGetClientWishList() {
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
        Catalog_Product__c product = CLT_TestDateFactory.createTestProduct('testSKU1', true);
        CLT_TestDateFactory.createTestWishlist(product.Id, client.Id, true);
        List<Map<String, Object>> wishlistsMap = CLT_Utils_ClientDetails.getClientWishList(client.Id);
        System.assertEquals(1, wishlistsMap.size(), 'CLT_Utils_ClientDetails_Test:testGetClientWishList: wishlists list size is not 1');
    }

    @isTest
    static void testGetClientAddresses() {
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
        CLT_TestDateFactory.createTestClientAddress(client.Id, true);
        List<Map<String, Object>> clientAddressesMap = CLT_Utils_ClientDetails.getClientAddresses(client.Id);
        System.assertEquals(1, clientAddressesMap.size(), 'CLT_Utils_ClientDetails_Test:testGetClientAddresses: client addresses list size is not 1');
    }

    @isTest
    static void testGetClientGifts() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];

        Task giftTask = CLT_TestDateFactory.createTask(sa.Id, false);
        giftTask.WhatId = client.Id;
        giftTask.Outreach_Type__c = 'Gift';
        insert giftTask;

        List<Map<String, Object>> giftsMap = CLT_Utils_ClientDetails.getClientGifts(client.Id);
        System.assertEquals(1, giftsMap.size(), 'CLT_Utils_ClientDetails_Test:testGetClientGifts: gifts list size is not 1');
    }

    @isTest
    static void testGetClientEvents() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];

        Task eventTask = CLT_TestDateFactory.createTask(sa.Id, false);
        eventTask.WhatId = client.Id;
        eventTask.Outreach_Type__c = 'Event';
        insert eventTask;

        List<Map<String, Object>> eventsMap = CLT_Utils_ClientDetails.getClientEvents(client.Id);
        System.assertEquals(1, eventsMap.size(), 'CLT_Utils_ClientDetails_Test:testGetClientEvents: events list size is not 1');
    }
}