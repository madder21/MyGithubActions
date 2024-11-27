/**
 * @author Israel Zygelboim (Balink)
 * @date February,07 2019
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_ClientDetail :
 * testSetup : Creation of test user and store
 * TEST METHOD				                    |	DESCRIPTION
 * test_ClientDetails_GET       				|	Test retrieveGet
 * test_ClientDetails_POST       				|	Test retrievePost
 * test_ClientDetails_POST_clientInsightReview  |	Test retrievePost when review mode of insights
 * test_ClientDetails_DELETE                    |	Test retrieveDelete that is not defined
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2019/02/07			|.Israel Z.		|.						|.original version
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

	@isTest 
    static void test_ClientDetails_POST() {
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
            System.assertEquals(sa.Id, lastModifiedById, 'Last Modified Id is not user Id after Post');

            Test.stopTest();
        }
    }

    @isTest 
    static void test_ClientDetails_POST_clientInsightReview() {
        CLT_ClientDetail clientDetails = new  CLT_ClientDetail();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
            Map<String,Object> clientInsightMap = new MAp<String, Object> {
                'clientId' => client.Id,
                'historicalClient' => 'Yes',
                'isReview' => true
            };            
            clientDetails.retrievePost(new Map<String, String>(),new Map<String,Object>{'clientInsights' => clientInsightMap});
            
            Test.stopTest();
            Client_Insight__c ciAfterReview = [SELECT LastReviewDate__c FROM Client_Insight__c WHERE ExternalId__c = :client.Id];
            System.assertEquals(Date.today(), ciAfterReview.LastReviewDate__c, 'last review date is not equal to today after review');

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