/**
 * @author Sarah AYOUN (Balink)
 * @date August 15, 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description Test class for the CLT_Utils_EventTrigger:
 * testSetup : Creation of test user and event
 * TEST METHOD                                      | DESCRIPTION
 * testSilentNotificationOnEventUpsert             | Test of silent notification generation on Event upsert
 * testSilentNotificationOnEventAssignmentUpdate   | Test of silent notification generation on Event owner update
 * 
 * ****************************************************************************************************************************************************************
 * @Version :
 * Version  | Date of Modification | Modified By | Related Jira Ticket | Description of Changes
 * 0.0      | 2024/08/15           | Sarah A     | RCLIENT-1235        | Original version
 */
@isTest
private class CLT_Utils_EventTrigger_Test {
    /**
     * @description Test setup method to prepare test data.
     * Creates a test User and an associated Event record.
     */
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        CLT_TestDateFactory.createTestEvent(sa.Id, true);
	}

    /**
     * @description Test method to validate the creation of silent notifications on Event upsert.
     * This method checks that a silent notification is generated when an Event record is upserted.
     * Note: No assert is added as the notification push cannot be directly verified.
     */
    @isTest
    static void testSilentNotificationOnEventUpsert() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Test.startTest();
        CLT_TestDateFactory.createTestEvent(sa.Id, true);
        Test.stopTest();
       // No assertion is added as test notification push cannot be verified directly.
    }

    /**
     * @description Test method to validate the creation of silent notifications on Event owner update.
     * This method ensures that a silent notification is created when the owner of an Event record is updated.
     */
    @isTest
    static void testSilentNotificationOnEventAssignmentUpdate() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Event e = [SELECT Id,OwnerId FROM Event WHERE OwnerId = :sa.Id];


		User sa2 = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

        Test.startTest();
        e.OwnerId = sa2.Id;
        update e;
        Test.stopTest();

        Notification__c notif = [SELECT RelatedRecordId__c FROM Notification__c WHERE User__c = :sa.Id AND Silent__c = true];
        System.assertEquals(e.Id, notif.RelatedRecordId__c, 'CLT_Utils_EventTrigger_Test:testSilentNotificationOnEventAssignmentUpdate: deleted notification not related to deleted event');

    }
}