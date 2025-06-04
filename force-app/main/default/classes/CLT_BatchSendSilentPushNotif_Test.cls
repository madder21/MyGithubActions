/**
 * @author Sarah AYOUN(Balink)
 * @date August, 15 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description Test class for the CLT_BatchSendSilentPushNotif batch Apex class :
 * testSetup : Creation of test user
 * TEST METHOD				                            |	DESCRIPTION
 * testCLT_BatchSendSilentPushNotifWithSetIds       	|	Test of Batch CLT_BatchSendSilentPushNotif initialization with set of Ids and running
 * testSchedBatch_ClientBirthday                        |	Test of Batch CLT_BatchSendSilentPushNotif initialization with map of Ids and their related records to delete and running
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	            |Description of changes			
 * 0.0		|2024/08/15			|.Sarah A		|RCLIENT-1235						|.Original version
*/
@isTest
private class CLT_BatchSendSilentPushNotif_Test {
    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
	}

    /**
     * @description Test method to validate the batch processing of sending silent push notifications with a set of user IDs.
     * This method ensures that the batch job executes successfully with a single user ID.
     */
    @isTest
    static void testCLT_BatchSendSilentPushNotifWithSetIds() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Test.startTest();
        CLT_BatchSendSilentPushNotif b = new CLT_BatchSendSilentPushNotif(new Set<String> {sa.Id}, 'test type', 'test subtype');
        Database.executeBatch(b, 10);
        Test.stopTest();
    }

    /**
     * @description Test method to validate the batch processing of sending silent push notifications with a map of user IDs and related records.
     * This method ensures that deleted records are handled correctly and verifies that notifications are created for these records.
     */
    @isTest
    static void testCLT_BatchSendSilentPushNotifWithMapIdsDeletedRecords() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        String recordIdDel = 'TST123456789';

        Test.startTest();
        CLT_BatchSendSilentPushNotif b = new CLT_BatchSendSilentPushNotif(new Map<String, List<String>> {sa.Id => new List<String>{recordIdDel}}, 'test type', 'test subtype');
        Database.executeBatch(b, 10);
        Test.stopTest();

        List<Notification__c> notificationAfterBatch = [SELECT RelatedRecordId__c FROM Notification__c WHERE User__c = :sa.Id AND Silent__c = TRUE];
        System.assertEquals(recordIdDel, notificationAfterBatch[0].RelatedRecordId__c, 'CLT_BatchSendSilentPushNotif_Test:testCLT_BatchSendSilentPushNotifWithMapIdsDeletedRecords: deleted record after batch is not on notification');
    }
}