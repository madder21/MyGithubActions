@isTest
private class CLT_Users_Test {
    @TestSetup
	static void prepareTestData(){
		CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
	}

    @isTest
	static void test_Users_DELETE() {
		CLT_Users cltUsers = new CLT_Users();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object cltUsersDeleteResponse = cltUsers.retrieveDelete(new Map<String, String>());
            System.assertEquals(null, cltUsersDeleteResponse, 'CLT_Users.retrieveDelete: Delete method defined and not tested');

            Test.stopTest();
        }
	}

	@isTest
	static void test_Users_POST() {
		CLT_Users cltUsers = new CLT_Users();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Date date5days = Date.today().addDays(5);
            Map<String, Object> mutedMap = new Map<String, Object> {'mutedNotifications' => date5days.year() + '-' + date5days.month() + '-' + date5days.day()};
            Map<String,Object> body = new Map<String,Object>{'mutedNotifications' => mutedMap};
            
            Object cltUsersPostResponse = cltUsers.retrievePost(new Map<String, String>(), body);

            User saAfterWs = [SELECT Id,MutedNotifications__c FROM User WHERE Id = :sa.Id LIMIT 1];
            System.assertEquals(JSON.serialize(mutedMap), saAfterWs.MutedNotifications__c, 'CLT_Users.retrievePost: mutedNotification not equal to what sent in the body of POST call');

            Test.stopTest();
        }
	}

	@isTest
	static void test_Users_GET() {
		CLT_Users cltUsers = new CLT_Users();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object cltUsersGetResponse = cltUsers.retrieveGet(new Map<String, String>());
            System.assertEquals(null, cltUsersGetResponse, 'CLT_Users.retrieveGet: Get method defined and not tested');

            Test.stopTest();
        }
	}
}