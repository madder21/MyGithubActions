@isTest
private class CLT_PushNotification_Utils_Test {
    @TestSetup
    static void pushNotificationUtilsPrepareData() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', false);
        store.Country__c = 'ZW';
        insert store;
    }

    @isTest
    private static void testGetUsersSendingTimeHour() {
        Integer testSendHour = 9;
        Integer offset = Timezone.getTimeZone('Africa/Harare').getOffset(DateTime.newInstanceGMT(Date.today().addDays(1), Time.newInstance(testSendHour, 0, 0, 0))) / 3600000;

        User u = [SELECT Id,StoreCode__c FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Map<String,Integer> userSendingTimeMap = CLT_PushNotification_Utils.getUsersSendingTimeHour(new Map<String, List<String>> {u.StoreCode__c => new List<String>{u.Id}}, testSendHour);

        System.assertEquals(testSendHour - offset, userSendingTimeMap.get(u.Id), 'testGetUsersSendingTimeHour - user sending time for country ZW different than Africa/Harare');
    }
}