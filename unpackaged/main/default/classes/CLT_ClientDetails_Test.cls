/*
 * Created by Israel Zygelboim on 07/02/2019.
 */
@IsTest
private class CLT_ClientDetails_Test {

	@TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        ClientSource__c cs1 = CLT_TestDateFactory.createTestClientSource(client.Id, '001', 'TST00123', true);
        ClientSource__c cs2 = CLT_TestDateFactory.createTestClientSource(client.Id, '002', 'TST00223', true);
	}

	@isTest
	static void test_ClientDetails_GET() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		CLT_ClientDetail clientDetails = new  CLT_ClientDetail();
		System.runAs(sa) {
			Test.startTest();

			Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
			Object clientDetailsGetResponse = clientDetails.retrieveGet(new Map<String, String>{'clientId' => client.Id});
			Object clientFieldsObj = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(clientDetailsGetResponse))).get('clientFields');
			String getClientId = (String)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(clientFieldsObj))).get('id');
            System.assertEquals(client.Id, getClientId, 'get client id is different form the sent');

			Test.stopTest();
		}	
	}

	@isTest static void test_ClientDetails_POST() {
        CLT_ClientDetail clientDetails = new  CLT_ClientDetail();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();

            Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
            Map<String,Object> clientInsightMap = new MAp<String, Object> {
                'clientId' => client.Id,
                'historicalClient' => 'Yes'
            };            
            
            Object clientDetailsPostResponse = clientDetails.retrievePost(new Map<String, String>(),new Map<String,Object>{'clientInsights' => clientInsightMap});
            String lastModifiedById = (String)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(clientDetailsPostResponse))).get('modifiedById');
            System.assertEquals(sa.Id, lastModifiedById, 'Post method defined and not tested');

            Test.stopTest();
        }
    }

    @isTest 
	static void test_ClientDetails_DELETE() {
        CLT_ClientDetail clientDetails = new  CLT_ClientDetail();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest(); 
            
            Object clientDetailsDeleteResponse = clientDetails.retrieveDelete(new Map<String, String>());
            System.assertEquals(null, clientDetailsDeleteResponse, 'Delete method defined and not tested');

            Test.stopTest();
        }
    }
}