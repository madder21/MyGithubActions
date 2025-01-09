/**
 * @author Sarah AYOUN (Balink)
 * @date August 15, 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description Test class for the EventTrigger:
 * testSetup : Creation of test user and event
 * TEST METHOD              | DESCRIPTION
 * testInsertEvent          | Test of Event insertion and verification of event list size after insert
 * testUpdateEvent          | Test of Event update and verification of event subject after update
 * testDeleteEvent          | Test of Event delete and verification of event subject after delete
 * 
 * ****************************************************************************************************************************************************************
 * @Version :
 * Version  | Date of Modification | Modified By | Related Jira Ticket | Description of Changes
 * 0.0      | 2024/08/15           | Sarah A     | RCLIENT-1235        | Original version
 * 0.1      | 2024/09/18           | Sarah A     | RCLIENT-1238        | add of testDeleteEvent
 */
@isTest
private class EventTrigger_Test {
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
     * @description Test method to validate the insertion of an Event record.
     * This method verifies that an Event is correctly inserted by checking the size of the event list after insertion.
     */
    @isTest
    static void testInsertEvent() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Test.startTest();
        CLT_TestDateFactory.createTestEvent(sa.Id, true);
        Test.stopTest();

        List<Event> eventListAfterInsert = [SELECT Id FROM Event WHERE OwnerId = :sa.Id];
        System.assertEquals(2, eventListAfterInsert.size(), 'EventTrigger_Test:testInsertEvent: Event list size is not 2 after insert');

    }

    /**
     * @description Test method to validate the update of an Event record.
     * This method verifies that the Event record's subject is updated correctly.
     */
    @isTest
    static void testUpdateEvent() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Event e = [SELECT Subject FROM Event WHERE OwnerId = :sa.Id];

        Test.startTest();
        String updatedSubject = 'TEST Updated';
        e.Subject = updatedSubject;
        update e;
        Test.stopTest();
        Event eAfterUpdate = [SELECT Subject FROM Event WHERE OwnerId = :sa.Id];
        System.assertEquals(updatedSubject, eAfterUpdate.Subject, 'EventTrigger_Test:testUpdateEvent: Event Update not done');
    }

    /**
     * @description Test method to validate the delete of an Event record.
     * This method verifies that the owner of the Event record's is notified correctly.
     */
    @isTest
    static void testDeleteEvent() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Event e = [SELECT Subject FROM Event WHERE OwnerId = :sa.Id];

        Test.startTest();
        delete e;
        Test.stopTest();

        List<Notification__c> deleteSilentNotifications = [SELECT Id 
                                                        FROM Notification__c 
                                                        WHERE User__c = :sa.Id AND Type__c = :CLT_SendSilentPushNotifications.SILENT_AGENDA_TYPE 
                                                            AND Subtype__c = :CLT_SendSilentPushNotifications.SILENT_AGENDA_DELETE_SUBTYPE 
                                                            AND Sent__c = true AND Silent__c = true];
        System.assertEquals(1, deleteSilentNotifications.size(), 'EventTrigger_Test:testDeleteEvent: Silent notification size is not 1 after event delete');
    }
}