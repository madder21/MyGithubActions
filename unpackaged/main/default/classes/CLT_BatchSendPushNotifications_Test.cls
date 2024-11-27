@isTest
private class CLT_BatchSendPushNotifications_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), true);
	}

    @isTest
    static void testCLT_BatchSendPushNotifications() {
        List<CLT_SendPushNotifications.FlowInputs> flowInput = new List<CLT_SendPushNotifications.FlowInputs>();
        for(Notification__c notif : [SELECT Id,User__c,NotificationManagementId__c,Type__c,Subtype__c,Seen__c,Read__c,SendingTime__c,Title__c,Body__c,RelatedRecordId__c,TargetScreenId__c,Client__c,Client__r.Name 
                                    FROM Notification__c]) {
            flowInput.add(new CLT_SendPushNotifications.FlowInputs(notif.Id, notif.User__c, notif.NotificationManagementId__c, notif.Type__c,notif.Subtype__c,
                notif.Title__c, notif.Body__c, notif.RelatedRecordId__c, notif.TargetScreenId__c, notif.Client__c, (notif.Client__c != null ? notif.Client__r.Name : '')));
        }
        Test.startTest();
        CLT_BatchSendPushNotifications b = new CLT_BatchSendPushNotifications(flowInput);
        Database.executeBatch(b, 10);
        Test.stopTest();
        
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        List<Notification__c> sentNotificationsListAfterBatch = [SELECT Id FROM Notification__c WHERE User__c = :sa.Id AND Sent__c = true];
        System.assertEquals(1, sentNotificationsListAfterBatch.size(), 'testCLT_BatchSendPushNotifications - Sent Notifications list size is not 1 after batch run');
    }
}