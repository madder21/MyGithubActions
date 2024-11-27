/**
 * @author Sarah AYOUN (Balink)
 * @date February,12 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_Notifications :
 * testSetup : Creation of test user and store
 * TEST METHOD				            |	DESCRIPTION
 * test_Notifications_DELETE       	    |	Test of null implementation of retrieveDelete Method from RetailInterface
 * test_Notifications_POST       	    |	Test update of seen and read values on notifications
 * test_Notifications_GETWithoutSilent  |	Test get only notifications of the connected user in the last 30 days that are not silent
 * test_Notifications_GETWithSilent     |   Test get only notifications of the connected user in the last 30 days including silent
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2024/02/12			|.Sarah A		|.						|.original version
 * 1.0		|2024/08/15			|.Sarah A		|.						|.test include silent
*/
@isTest
private class CLT_Notifications_Test {
    @TestSetup
	static void prepareTestData(){
		CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		CLT_TestDateFactory.createTestStore('TST123', true);
	}

    @isTest
	static void test_Notifications_DELETE() {
		CLT_Notifications cltNotifications = new CLT_Notifications();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object cltNotificationsDeleteResponse = cltNotifications.retrieveDelete(new Map<String, String>());
            System.assertEquals(null, cltNotificationsDeleteResponse, 'CLT_Notifications.retrieveDelete: Delete method defined and not tested');

            Test.stopTest();
        }
	}

	@isTest
	static void test_Notifications_POST() {
		CLT_Notifications cltNotifications = new CLT_Notifications();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		Notification__c notification = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), true);
        System.runAs(sa) {
            Test.startTest();
            Map<String,Object> body = new Map<String,Object>();
            body.put('id', notification.Id);
            body.put('read', false);
            body.put('seen', true);
            
            Object cltNotificationsPostResponse = cltNotifications.retrievePost(new Map<String, String>(), new Map<String, Object> {'items' => new List<Object>{body}});

            Notification__c notificationAfterPost = [SELECT Seen__c FROM Notification__c WHERE Id = :notification.Id LIMIT 1];
            System.assertEquals(true, notificationAfterPost.Seen__c, 'CLT_Notifications.retrievePost: notification seen value is false after POST method');

            Test.stopTest();
        }
	}

	@isTest
	static void test_Notifications_GETWithoutSilent() {
		CLT_Notifications cltNotifications = new CLT_Notifications();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		List<Notification__c> notificationList = new List<Notification__c>();
        Notification__c notif1 = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), false);
        notif1.Sent__c = true;
        notificationList.add(notif1);
        Notification__c notif2 = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now().addDays(-29), false);
        notif2.Sent__c = true;
        notificationList.add(notif2);
        Notification__c notif3 = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now().addDays(-35), false);
        notif3.Sent__c = true;
        notificationList.add(notif3);
        insert notificationList;

        System.runAs(sa) {
            Test.startTest();
            
            Object cltNotificationsGetResponse = cltNotifications.retrieveGet(new Map<String, String>());
            List<Object> notificationGetResponseList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(cltNotificationsGetResponse));
            System.assertEquals(2, notificationGetResponseList.size(), 'CLT_Notifications.retrieveGet: returned notifications list from GET method size is not 2');

            Test.stopTest();
        }
	}

    @isTest
	static void test_Notifications_GETWithSilent() {
		CLT_Notifications cltNotifications = new CLT_Notifications();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		List<Notification__c> notificationList = new List<Notification__c>();
        Notification__c notif1 = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), false);
        notif1.Sent__c = true;
        notificationList.add(notif1);
        Notification__c notif2 = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now().addDays(-29), false);
        notif2.Sent__c = true;
        notificationList.add(notif2);
        Notification__c notif3 = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now().addDays(-25), false);
        notif3.Sent__c = true;
        notif3.Silent__c =true;
        notificationList.add(notif3);
        Notification__c notif4 = CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), false);
        notif4.Sent__c = true;
        notif4.Silent__c =true;
        notificationList.add(notif4);
        insert notificationList;

        System.runAs(sa) {
            Test.startTest();
            
            Object cltNotificationsGetResponse = cltNotifications.retrieveGet(new Map<String, String>{'includeSilent' => 'true'});
            List<Object> notificationGetResponseList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(cltNotificationsGetResponse));
            System.assertEquals(3, notificationGetResponseList.size(), 'CLT_Notifications.retrieveGet: returned notifications list from GET method size is not 2');

            Test.stopTest();
        }
	}
}