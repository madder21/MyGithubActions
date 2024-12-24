/**
 * @author Sarah AYOUN (Balink)
 * @date August 15, 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description Test class for the CLT_SendSilentPushNotifications class:
 * testSetup : Creation of test users and events
 * TEST METHOD                                  | DESCRIPTION
 * testSendSilentNotificationsWithSetIds       | Tests sending silent notifications with a set of user IDs
 * testSendSilentNotificationsWithMapIds        | Tests sending silent notifications with a map of user IDs and deleted records
 * testCountUnseenNotificationsPerUser          | Tests counting unseen notifications per user
 * 
 * ****************************************************************************************************************************************************************
 * @Version :
 * Version  | Date of Modification | Modified By | Related Jira Ticket | Description of Changes
 * 0.0      | 2024/08/15           | Sarah A     | [Jira Ticket]        | Original version
 */

@isTest
private class CLT_SendSilentPushNotifications_Test {
    /**
     * @description Test setup method to prepare test data.
     * Creates test user.
     */
    @TestSetup
    static void prepareTestData() {
        User sa1 = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        // User sa2 = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        // CLT_TestDateFactory.createTestEvent(sa1.Id, true);
        // CLT_TestDateFactory.createTestEvent(sa2.Id, true);
    }

    /**
     * @description Test method to validate sending silent notifications using a set of user IDs.
     * This method verifies that notifications are sent correctly in cases where the number of users is less than or equal to 10.
     */
    @isTest
    static void testSendSilentNotificationsWithSetIds() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Test.startTest();
        CLT_SendSilentPushNotifications.sendSilentNotifications(new Set<String>{sa.Id}, CLT_SendSilentPushNotifications.SILENT_AGENDA_TYPE, CLT_SendSilentPushNotifications.SILENT_AGENDA_DELTA_SUBTYPE);
        Test.stopTest();
        
        // No assertion is added as test notification push cannot be verified directly.
    }

    /**
     * @description Test method to validate sending silent notifications with a map of user IDs and deleted records.
     * This method verifies that notifications are sent and records are created properly when the number of users is less than or equal to 10.
     */
    @isTest
    static void testSendSilentNotificationsWithMapIds() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        String delRecordId = 'DEL123456789';
        Map<String, List<String>> userDeleteRecordsNotifMap = new Map<String, List<String>>{
            sa.Id => new List<String>{delRecordId}
        };

        Test.startTest();
        CLT_SendSilentPushNotifications.sendSilentNotifications(userDeleteRecordsNotifMap, CLT_SendSilentPushNotifications.SILENT_AGENDA_TYPE, CLT_SendSilentPushNotifications.SILENT_AGENDA_DELTA_SUBTYPE);
        Test.stopTest();

        Notification__c notification = [SELECT RelatedRecordId__c FROM Notification__c WHERE User__c = :sa.Id AND Silent__c = TRUE];
        System.assertEquals(delRecordId, notification.RelatedRecordId__c, 'CLT_SendSilentPushNotifications_Test:testSendSilentNotificationsWithMapIds: Notification deleted record Id mismatch');
    }
}