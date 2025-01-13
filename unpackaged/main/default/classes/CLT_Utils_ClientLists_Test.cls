/**
 * @author Sarah AYOUN (Balink)
 * @date January,13 2025
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_Utils_ClientLists :
 * testSetup : Creation of test user and store
 * TEST METHOD				        		|	DESCRIPTION
 * testBuildDynamicQueryNonSpecific       	|	Test buildDynamicQuery function when client list is not specific
 * testBuildDynamicQuerySpecific       		|	Test buildDynamicQuery function when client list is a specific one
 * testBuildDynamicQueryStoreNoLimit    	|	Test buildDynamicQuery function when client list returned with no limit
 * testBuildDynamicQuerySpecificField       |	Test buildDynamicQuery function when client list is calculated with a specific field
 * testBuildDynamicQueryMemberedList        |	Test buildDynamicQuery function when client list is a membered list
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2025/01/13			|.Sarah A.		|.						|.original version
*/
@isTest
private class CLT_Utils_ClientLists_Test {
    @TestSetup
	static void prepareTestData(){
		CLT_TestDateFactory.createTestRClientConfigurations(true);
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

        List<ClientList__c> clientLists = new List<ClientList__c>();

		clientLists.add(CLT_TestDateFactory.createTestClientList('TEST MY VIP', 'AND VIP__pc = \'Yes\' LIMIT 1', false));

        ClientList__c clientList2 = CLT_TestDateFactory.createTestClientList('TEST Client List 2', 'AND FirstName = \'Test client 2\'', false);
		clientList2.InMyStore__c = true;
		clientLists.add(clientList2);

		ClientList__c clientList3 = CLT_TestDateFactory.createTestClientList('TEST Client List 3', 'AND FirstName = \'Test client%\' ORDER BY FirstName DESC LIMIT 1', false);
		clientList3.VisibilityBasedOnField__c = 'Local_Main_CA__c';
		clientLists.add(clientList3);

        insert clientLists;
	}

    @isTest
    static void testBuildDynamicQueryNonSpecific() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        ClientList__c cl = [SELECT Id,OwnerId,Owner.FirstName,CreatedDate,LastModifiedDate,Type__c,Owner.LastName,Description__c,Position__c,Name,ClientListQuery__c,InMyStore__c,StaticList__c,
                                    IsDarkText__c,OrderBy__c,Ascendant__c,DisplayType__c,VisibilityBasedOnField__c,SpecificFieldDisplay__c,SpecificFieldDisplayLabel__c,
                                    DisplayToReachOutContactedSection__c,ContactedSectionDisplayPeriod__c,AlwaysLimitedList__c
                            FROM ClientList__c 
                            WHERE Name = 'TEST MY VIP' LIMIT 1];
        
        String dynamicQuery = CLT_Utils_ClientLists.buildDynamicQuery(cl, sa.Id, 'TST123', false, false);
        System.assertEquals(' AND ClientAdvisor__pc = \'' + sa.Id + '\' AND VIP__pc = \'Yes\'  ORDER BY CreatedDate DESC LIMIT 1', dynamicQuery, 'CLT_Utils_ClientLists_Test:testBuildDynamicQueryNonSpecific: dynamic query not calculated as expected');
    }

    @isTest                                                                     
    static void testBuildDynamicQuerySpecific() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        ClientList__c cl = [SELECT Id,OwnerId,Owner.FirstName,CreatedDate,LastModifiedDate,Type__c,Owner.LastName,Description__c,Position__c,Name,ClientListQuery__c,InMyStore__c,StaticList__c,
                                    IsDarkText__c,OrderBy__c,Ascendant__c,DisplayType__c,VisibilityBasedOnField__c,SpecificFieldDisplay__c,SpecificFieldDisplayLabel__c,
                                    DisplayToReachOutContactedSection__c,ContactedSectionDisplayPeriod__c,AlwaysLimitedList__c
                            FROM ClientList__c 
                            WHERE Name = 'TEST MY VIP' LIMIT 1];
        
        String dynamicQuery = CLT_Utils_ClientLists.buildDynamicQuery(cl, sa.Id, 'TST123', true, true);
        System.assertEquals(' AND ClientAdvisor__pc = \'' + sa.Id + '\' AND VIP__pc = \'Yes\'  ORDER BY CreatedDate DESC ', dynamicQuery, 'CLT_Utils_ClientLists_Test:testBuildDynamicQuerySpecific: dynamic query not calculated as expected');
    }

    @isTest
    static void testBuildDynamicQueryStoreNoLimit() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        ClientList__c cl = [SELECT Id,OwnerId,Owner.FirstName,CreatedDate,LastModifiedDate,Type__c,Owner.LastName,Description__c,Position__c,Name,ClientListQuery__c,InMyStore__c,StaticList__c,
                                    IsDarkText__c,OrderBy__c,Ascendant__c,DisplayType__c,VisibilityBasedOnField__c,SpecificFieldDisplay__c,SpecificFieldDisplayLabel__c,
                                    DisplayToReachOutContactedSection__c,ContactedSectionDisplayPeriod__c,AlwaysLimitedList__c
                            FROM ClientList__c 
                            WHERE Name = 'TEST Client List 2' LIMIT 1];
        
        String dynamicQuery = CLT_Utils_ClientLists.buildDynamicQuery(cl, sa.Id, 'TST123', false, true);
        System.assertEquals(' AND MainBoutiqueCode__c = \'TST123\' AND FirstName = \'Test client 2\' ORDER BY CreatedDate DESC LIMIT 200', dynamicQuery, 'CLT_Utils_ClientLists_Test:testBuildDynamicQueryStoreNoLimit: dynamic query not calculated as expected');
    }

    @isTest
    static void testBuildDynamicQuerySpecificField() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        ClientList__c cl = [SELECT Id,OwnerId,Owner.FirstName,CreatedDate,LastModifiedDate,Type__c,Owner.LastName,Description__c,Position__c,Name,ClientListQuery__c,InMyStore__c,StaticList__c,
                                    IsDarkText__c,OrderBy__c,Ascendant__c,DisplayType__c,VisibilityBasedOnField__c,SpecificFieldDisplay__c,SpecificFieldDisplayLabel__c,
                                    DisplayToReachOutContactedSection__c,ContactedSectionDisplayPeriod__c,AlwaysLimitedList__c
                            FROM ClientList__c 
                            WHERE Name = 'TEST Client List 3' LIMIT 1];
        
        String dynamicQuery = CLT_Utils_ClientLists.buildDynamicQuery(cl, sa.Id, 'TST123', false, true);
        System.assertEquals(' AND Local_Main_CA__c = \'' + sa.Id + '\' AND FirstName = \'Test client%\' ORDER BY FirstName DESC , CreatedDate DESC LIMIT 1', dynamicQuery, 'CLT_Utils_ClientLists_Test:testBuildDynamicQuerySpecificField: dynamic query not calculated as expected');
    }

    @isTest
    static void testBuildDynamicQueryMemberedList() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = :'TST123'];
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);

        CLT_ClientList cltClientList = new CLT_ClientList();
		System.runAs(sa) {
			ClientList__c clientList = new ClientList__c (
            Name = 'test membered client list',
            Type__c = 'Membered'
			);
            insert clientList;

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
}