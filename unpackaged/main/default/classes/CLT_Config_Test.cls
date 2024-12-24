@isTest
private class CLT_Config_Test {

	@TestSetup
	static void prepareTestData(){
		CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		CLT_TestDateFactory.createTestStore('TST123', true);
        String giftNameOption =  Gift__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
		CLT_TestDateFactory.createTestGift(giftNameOption, true);
        String eventNameOption =  Event__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
		CLT_TestDateFactory.createTestClientelingEvent(eventNameOption, true);
	}

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