@isTest
private class UpdateHubHandleControllerTest {
    @isTest
    static void testGetUserHubHandle() {
        // Create a test user with a Hub__c value
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;

        User testUser = new User(
            ProfileId = p.Id,
            LastName = 'Test User',
            Email = uniqueName + '@rimowa.com',
            Username = uniqueName + '@rimowa.com',
            Alias = uniqueName.substring(18, 23),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Hub__c = 'EU'
        );
        system.debug(testUser);
        insert testUser;

        // Set the test user as the running user
        System.runAs(testUser) {
            String userHubHandle = UpdateHubHandleController.getUserHubHandle();
            System.assertEquals(testUser.Hub__c, userHubHandle);
        }
    }
}