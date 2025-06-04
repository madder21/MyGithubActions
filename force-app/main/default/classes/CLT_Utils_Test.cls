@isTest
private class CLT_Utils_Test {
    @TestSetup
	static void prepareTestData(){
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        sa.Email_templates__c = 'EN;FR';
        insert sa;
	}

    @isTest
	static void testGetMyUser() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            User myUser = CLT_Utils.getMyUser();
            System.assertEquals('EN;FR', myUser.Email_templates__c, 'Email Template field on user not the same as  inserted');
        }
    }

    @isTest
	static void testCreateLogFuture() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            CLT_Utils.createLogFuture(
                '', 
                '',
                0.33, 
                0, 
                0, 
                'clientDetails', 
                'GET',
                'test', 
                '{clientId=test}', 
                '',
                '{}',
                false,
                '',
                '',
                '****CURRENT LIMITS****\nCPU : 46 Of 10000',
                'Request_Headers__c',
                '');
            Test.stopTest();
            List<Log__c> log = [SELECT Id FROM Log__c WHERE CreatedById = :sa.Id AND Method__c = 'GET' AND Service_Name__c = 'clientDetails'];
            System.assertEquals(1, log.size(), 'inserted log size is not 1');
        }
    }
}