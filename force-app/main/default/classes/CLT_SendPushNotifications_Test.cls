@isTest
private class CLT_SendPushNotifications_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        Date tommorowDate = Date.today().addDays(1);
        sa.MutedNotifications__c = JSON.serialize(new Map<String, Object> {
            'TESTMGMNTID' => tommorowDate.year() + '-' + tommorowDate.month() + '-' + tommorowDate.day()
        });
        insert sa;
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
	}

    @isTest
    static void testSendNotifications() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        
        List<Notification__c> notificationList = new List<Notification__c>();
        notificationList.add(CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), false));
        insert notificationList;

        CLT_SendPushNotifications.FlowInputs testFlowInput = new CLT_SendPushNotifications.FlowInputs();
        testFlowInput.id = notificationList[0].Id;
        testFlowInput.userId = sa.Id;
        testFlowInput.type = 'TEST TYPE';
        testFlowInput.subtype = 'TEST SUB TYPE';
        testFlowInput.title = 'TEST TITLE';
        testFlowInput.type = 'TEST TYPE';
        testFlowInput.body = 'TEST BODY';
        testFlowInput.targetId = 'TEST targetId';
        testFlowInput.targetScreenId = 'TEST targetScreenId';

        CLT_SendPushNotifications.sendNotifications(new List<CLT_SendPushNotifications.FlowInputs> {testFlowInput});
    }

    @isTest
    static void testSendNotificationsMuted() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id,MutedNotifications__c FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        List<Notification__c> notificationList = new List<Notification__c>();
        notificationList.add(CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), false));
        insert notificationList;

        CLT_SendPushNotifications.FlowInputs testFlowInput = new CLT_SendPushNotifications.FlowInputs();
        testFlowInput.id = notificationList[0].Id;
        testFlowInput.userId = sa.Id;
        testFlowInput.type = 'TEST TYPE';
        testFlowInput.subtype = 'TEST SUB TYPE';
        testFlowInput.title = 'TEST TITLE';
        testFlowInput.type = 'TEST TYPE';
        testFlowInput.body = 'TEST BODY';
        testFlowInput.targetId = 'TEST targetId';
        testFlowInput.targetScreenId = 'TEST targetScreenId';
        testFlowInput.managementId = 'TESTMGMNTID';

        CLT_SendPushNotifications.sendNotifications(new List<CLT_SendPushNotifications.FlowInputs> {testFlowInput});
    }

    @isTest
    static void testSendPushNotification() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        
        List<Notification__c> notificationList = new List<Notification__c>();
        notificationList.add(CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), false));
        insert notificationList;

        CLT_SendPushNotifications.FlowInputs testFlowInput = new CLT_SendPushNotifications.FlowInputs();
        testFlowInput.id = notificationList[0].Id;
        testFlowInput.type = 'TEST TYPE';
        testFlowInput.subtype = 'TEST SUB TYPE';
        testFlowInput.title = 'TEST TITLE';
        testFlowInput.type = 'TEST TYPE';
        testFlowInput.body = 'TEST BODY';
        testFlowInput.targetId = 'TEST targetId';
        testFlowInput.targetScreenId = 'TEST targetScreenId';

        CLT_SendPushNotifications.sendPushNotification(new Set<String> {sa.Id}, testFlowInput, 2);
    }
}