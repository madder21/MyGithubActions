/**
 * @author BALINK
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description Test class for the `CLT_Config` Apex class:
 * testSetup : Creation of test data including User, Store, Gift, and Clienteling Event
 * TEST METHOD              | DESCRIPTION
 * test_Config_DELETE       | Tests the `retrieveDelete` method of the `CLT_Config` class to ensure it handles deletion correctly.
 * test_Config_POST         | Tests the `retrievePost` method of the `CLT_Config` class to verify it processes POST requests properly.
 * test_Config_GET          | Tests the `retrieveGet` method of the `CLT_Config` class to ensure it retrieves data correctly for empty parameters.
 * test_Config_GET_Gifts   | Tests the `retrieveGet` method with parameters for 'gift' to verify it retrieves gift data correctly.
 * test_Config_GET_Events  | Tests the `retrieveGet` method with parameters for 'event' to ensure it retrieves event data correctly.
 * 
 * ****************************************************************************************************************************************************************
 * @Version :
 * Version  | Date of Modification | Modified By        | Related Jira Ticket | Description of Changes
 * 0.0      |                      | BALINK             | .                   | Original version.
 * 1.0      |18/12/2024            | Sarah A.(Balink)   | RCLIENT-1572        | only Online Appointment Service that are Online should be retruned.
 */
@isTest
private class CLT_Config_Test {

    /**
     * @description Test setup method to prepare test data.
     * Creates a test User, Store, Gift, and Clienteling Event records.
     */
	@TestSetup
	static void prepareTestData(){
		CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        String giftNameOption =  Gift__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
		CLT_TestDateFactory.createTestGift(giftNameOption, true);
        String eventNameOption =  Event__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
		CLT_TestDateFactory.createTestClientelingEvent(eventNameOption, true);
        insert new AppointmentService__c(
            Store__c = store.Id,
            Status__c = 'Online',
            Name = 'Test',
            BooxiId__c = '123'
        );
	}

    /**
     * @description Test method to validate the deletion functionality in `CLT_Config`.
     * Verifies that the `retrieveDelete` method correctly handles delete operations.
    */
	@isTest
	static void test_Config_DELETE() {
		CLT_Config cltConfig = new CLT_Config();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object cltConfigDeleteResponse = cltConfig.retrieveDelete(new Map<String, String>());
            System.assertEquals(null, cltConfigDeleteResponse, 'Delete method defined and not tested');

            Test.stopTest();
        }
	}

    /**
     * @description Test method to validate the POST functionality in `CLT_Config`.
     * Verifies that the `retrievePost` method correctly processes POST requests.
     */
	@isTest
	static void test_Config_POST() {
		CLT_Config cltConfig = new CLT_Config();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object cltConfigPostResponse = cltConfig.retrievePost(new Map<String, String>(), new Map<String,Object>());
            System.assertEquals(null, cltConfigPostResponse, 'Post method defined and not tested');

            Test.stopTest();
        }
	}

    /**
     * @description Test method to validate the GET functionality in `CLT_Config` for empty parameters.
     * Verifies that the `retrieveGet` method correctly retrieves data when no parameters are provided.
     */
	@isTest
	static void test_Config_GET() {
		CLT_Config cltConfig = new CLT_Config();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Map<String, String> params = new Map<String, String>();
            Object cltConfigGetResponseEmptyParams = cltConfig.retrieveGet(params);
			Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cltConfigGetResponseEmptyParams));
			List<Object> giftsList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(objMap.get('gifts')));

			System.assertEquals(1, giftsList.size(), 'Gifts list size is different than 1');
            Test.stopTest();
        }
	}

    /**
     * @description Test method to validate the GET functionality in `CLT_Config` for 'gift' type.
     * Verifies that the `retrieveGet` method correctly retrieves gift data when 'type' parameter is set to 'gift'.
     */
    @isTest
	static void test_Config_GET_Gifts() {
		CLT_Config cltConfig = new CLT_Config();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Map<String, String> params = new Map<String, String>{'type' => 'gift'};
            Object cltConfigGetResponseGiftParams = cltConfig.retrieveGet(params);
			List<Object> giftsList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(cltConfigGetResponseGiftParams));

			System.assertEquals(1, giftsList.size(), 'CLT_Config_Test - test_Config_GET_Gifts - Gifts list size is different than 1');
            Test.stopTest();
        }
	}

    /**
     * @description Test method to validate the GET functionality in `CLT_Config` for 'event' type.
     * Verifies that the `retrieveGet` method correctly retrieves event data when 'type' parameter is set to 'event'.
     */
    @isTest
	static void test_Config_GET_Events() {
		CLT_Config cltConfig = new CLT_Config();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Map<String, String> params = new Map<String, String>{'type' => 'event'};
            Object cltConfigGetResponseEventParams = cltConfig.retrieveGet(params);
			List<Object> eventsList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(cltConfigGetResponseEventParams));

			System.assertEquals(1, eventsList.size(), 'CLT_Config_Test - test_Config_GET_Events - Events list size is different than 1');
            Test.stopTest();
        }
	}
}