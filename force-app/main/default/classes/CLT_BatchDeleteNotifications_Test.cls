/**
 * @author Sarah AYOUN (Balink)
 * @date August,19 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_BatchDeleteNotifications :
 * testSetup : Creation of test user and notifications
 * TEST METHOD				                |	DESCRIPTION
 * testCLT_BatchDeleteNotifications         |	Test of Batch CLT_BatchDeleteNotifications initialization and running
 * testSchedCLT_BatchDeleteNotifications    |	Test the implementation of the scheduler of CLT_BatchDeleteNotifications
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2024/08/19			|.Sarah A		|RCLIENT-976			|.original version
*/
@isTest
private class CLT_BatchDeleteNotifications_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

        List<Notification__c> notifications = new List<Notification__c>();
        //non silent prior to last 30 days
        notifications.add(CLT_TestDateFactory.createTestNotification('TEST 1', sa.Id, DateTime.now().addDays(-31), false));
        //non silent in last 30 days
        notifications.add(CLT_TestDateFactory.createTestNotification('TEST 2', sa.Id, DateTime.now().addDays(-15), false));
        //silent prior to last 2 days
        Notification__c silent1 = CLT_TestDateFactory.createTestNotification('TEST 3', sa.Id, DateTime.now().addDays(-3), false);
        silent1.Silent__c = true;
        notifications.add(silent1);
        //silent in last 2 days
        Notification__c silent2 = CLT_TestDateFactory.createTestNotification('TEST 4', sa.Id, DateTime.now().addMinutes(-60), false);
        silent2.Silent__c = true;
        notifications.add(silent2);

        insert notifications;
	}

    @isTest
    static void testCLT_BatchDeleteNotifications() {
        Test.startTest();
        CLT_BatchDeleteNotifications testBatch = new CLT_BatchDeleteNotifications();
        Database.executeBatch(testBatch);
        Test.stopTest();

        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        List<Notification__c> notificationsAfterBatchRun = [SELECT Id FROM Notification__c WHERE User__c = :sa.Id];

        System.assertEquals(2, notificationsAfterBatchRun.size(), 'CLT_BatchDeleteNotifications_Test:testCLT_BatchDeleteNotifications: notifications list size is not 2 after delete batch run');
    }

    @isTest
    static void testSchedCLT_BatchDeleteNotifications() {
        Test.startTest();
        CLT_BatchDeleteNotifications schedBatch = new CLT_BatchDeleteNotifications();
        String sch = '0 0 23 * * ?'; 
        Id jobId = System.schedule('Test CLT_BatchDeleteNotifications Sched', sch, schedBatch);
        CronTrigger cronTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(sch, cronTrig.CronExpression, 'CLT_BatchDeleteNotifications_Test:testSchedCLT_BatchDeleteNotifications: cron expression is not the same as the scheduled one');
        Test.stopTest();
    }
}