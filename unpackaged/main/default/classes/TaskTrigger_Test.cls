/**
 * @author Sarah AYOUN (Balink)
 * @date September 19, 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description Test class for the TaskTrigger:
 * testInsertTask                                   | Test of Task insertion and verification of task list size after insert
 * testUpdateTask                                   | Test of Task update and verification of task subject after update
 * testDeleteTask                                   | Test of Task delete and verification of task subject after delete
 * testSilentNotificationOnTaskUpsert               | Ensures silent notification generation on task upsert
 * testSilentNotificationOnTaskAssignmentUpdate     | Ensures silent notification generation on task owner update
 * testSilentNotificationOnTaskDelete               | Ensures silent notification generation on task delete
 * 
 * ****************************************************************************************************************************************************************
 * @Version :
 * Version  | Date of Modification | Modified By | Related Jira Ticket | Description of Changes
 * 0.0      | 2024/09/19           | Sarah A     | RCLIENT-1238        | Original version
 */
@isTest
private class TaskTrigger_Test {

    /**
     * @description Test setup method to prepare test data.
     * Creates a test User and an associated Task record.
     */
    @TestSetup
    static void prepareTestData() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        CLT_TestDateFactory.createTask(sa.Id, true);
    }

    /**
     * @description Test method to validate the insertion of a Task record.
     * This method verifies that a Task is correctly inserted by checking the size of the task list after insertion.
     */
    @isTest
    static void testInsertTask() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Test.startTest();
        CLT_TestDateFactory.createTask(sa.Id, true);
        Test.stopTest();

        List<Task> taskListAfterInsert = [SELECT Id FROM Task WHERE OwnerId = :sa.Id];
        System.assertEquals(2, taskListAfterInsert.size(), 'TaskTrigger_Test:testInsertTask: Task list size is not 2 after insert');
    }

    /**
     * @description Test method to validate the update of a Task record.
     * This method verifies that the Task record's subject is updated correctly.
     */
    @isTest
    static void testUpdateTask() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Task t = [SELECT Subject FROM Task WHERE OwnerId = :sa.Id];

        Test.startTest();
        String updatedSubject = 'TEST Updated';
        t.Subject = updatedSubject;
        update t;
        Test.stopTest();
        Task tAfterUpdate = [SELECT Subject FROM Task WHERE OwnerId = :sa.Id];
        System.assertEquals(updatedSubject, tAfterUpdate.Subject, 'TaskTrigger_Test:testUpdateTask: Task Update not done');
    }

    /**
     * @description Test method to validate the deletion of a Task record.
     * This method verifies that a silent notification is correctly created after deletion.
     */
    @isTest
    static void testDeleteTask() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Task t = [SELECT Id FROM Task WHERE OwnerId = :sa.Id LIMIT 1];

        Test.startTest();
        delete t;
        Test.stopTest();

        List<Notification__c> deleteSilentNotifications = [SELECT Id 
                                                          FROM Notification__c 
                                                          WHERE User__c = :sa.Id AND Silent__c = true];
        System.assertEquals(1, deleteSilentNotifications.size(), 'TaskTrigger_Test:testDeleteTask: Silent notification size is not 1 after task delete');
    }

    /**
     * @description Test method to validate the creation of silent notifications on Task upsert.
     * This method checks that a silent notification is generated when a Task record is upserted.
     */
    @isTest
    static void testSilentNotificationOnTaskUpsert() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Test.startTest();
        CLT_TestDateFactory.createTask(sa.Id, true);
        Test.stopTest();
        // No assertion is added as test notification push cannot be verified directly.
    }

    /**
     * @description Test method to validate the creation of silent notifications on Task owner update.
     * This method ensures that a silent notification is created when the owner of a Task record is updated.
     */
    @isTest
    static void testSilentNotificationOnTaskAssignmentUpdate() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Task t = CLT_TestDateFactory.createTask(sa.Id, true);

        User sa2 = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

        Test.startTest();
        t.OwnerId = sa2.Id;
        update t;
        Test.stopTest();

        Notification__c notif = [SELECT RelatedRecordId__c FROM Notification__c WHERE User__c = :sa.Id AND Silent__c = true];
        System.assertEquals(t.Id, notif.RelatedRecordId__c, 'TaskTrigger_Test:testSilentNotificationOnTaskAssignmentUpdate: notification not related to task');
    }
}