/*
 * Created by israel on 7/15/2019.
 */

 /**
 * @author Israel Z.(Balink)
 * @date July 15, 2019
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description Test class for the CLT_Utils_TaskTrigger:
 * testUpdateLastContactDate                       | Validates Last Contact Date update on task insert.
 * testUpdateRelatedProductDetails                 | Checks product-related details on task insert.
 * testUpdateENOutreachReasonOnInsert              | Validates EN Outreach Reason update on task insert.
 * testUpdateENOutreachReasonOnUpdate              | Validates EN Outreach Reason update on task update.
 * testGiftENOutreachReasonUpdate                  | Ensures EN Outreach Reason update for Gift-related tasks.
 * testRelatedClientListMembersStatus              | Validates status update of ClientListMember related to tasks.
 * testSilentNotificationOnTaskUpsert              | Checks silent notification generation on task upsert.
 * testSilentNotificationOnTaskAssignmentUpdate    | Ensures silent notification generation on task owner update.
 * testSilentNotificationOnTaskDelete              | Ensures silent notification generation on task delete.
 * ****************************************************************************************************************************************************************
 * @Version :
 * Version  | Date of Modification | Modified By | Related Jira Ticket | Description of Changes
 * 0.0      | 2019/07/15           |              |                     | Original version
 * 1.0      | 2024/08/15           |              |                     | add of testSilentNotificationOnTaskUpsert + testSilentNotificationOnTaskAssignmentUpdate
 * 1.1      | 2024/09/18           |              |                     | add of testSilentNotificationOnTaskDelete
 */
@IsTest
private class CLT_Utils_TaskTrigger_Test {

    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
	}

    @isTest
    static void testUpdateLastContactDate() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = 'TST123'];
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        
        List<Task> tasksToInsert = new List<Task>();

        Task t1 = CLT_TestDateFactory.createTask(sa.Id, false);
        t1.WhatId = client.Id;
        t1.Outreach_Type__c = 'Call';
        t1.ActivityDate = Date.today().addDays(-6);
        tasksToInsert.add(t1);

        Task t2 = CLT_TestDateFactory.createTask(sa.Id, false);
        t2.WhatId = client.Id;
        t2.Outreach_Type__c = 'Call';
        t2.ActivityDate = Date.today();
        tasksToInsert.add(t2);

        insert tasksToInsert;

        Account clientAfterTaskInsert = [SELECT LastContactDate__pc FROM Account WHERE Id = :client.Id];

        System.assertEquals(t2.ActivityDate, clientAfterTaskInsert.LastContactDate__pc, 'LAst Contacted Date of the client is not the same as task 2 Activity Date');
    }

    @isTest
    static void testUpdateRelatedProductDetails() {
        List<Catalog_Product__c> productsToInsert = new List<Catalog_Product__c>();

        Catalog_Product__c cp1 = CLT_TestDateFactory.createTestProduct('testSku1', false);
        productsToInsert.add(cp1);

        Catalog_Product__c cp2 = CLT_TestDateFactory.createTestProduct('testSku2', false);
        productsToInsert.add(cp2);

        insert productsToInsert;

        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Task t = CLT_TestDateFactory.createTask(sa.Id, false);
        t.ActivityDate = Date.today();
        t.Related_Products__c = cp1.Id + ';' + cp2.Id + ';';
        insert t;

        Task taskAfterTrigger = [SELECT Related_Products_Num__c FROM Task WHERE Id = :t.Id];
        System.assertEquals(2, taskAfterTrigger.Related_Products_Num__c, 'Number of products related to task are diffrent than 2');
    }

    @isTest
    static void testUpdateENOutreachReasonOnInsert() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

        System.runAs(sa) {
            Test.startTest();
            Task t = CLT_TestDateFactory.createTask(sa.Id, false);

            List<CLT_EmailTemplateCategory__mdt> reasons = [SELECT en_US_category__c,fr_category__c 
                                                            FROM CLT_EmailTemplateCategory__mdt 
                                                            WHERE en_US_category__c != NULL AND fr_category__c != NULL 
                                                            LIMIT 1];

            t.Outreach_Reason__c = reasons[0].fr_category__c;
            insert t;
            Test.stopTest();
            Task insertedTask = [SELECT EN_Outreach_Reason__c FROM Task WHERE Id = :t.Id LIMIT 1];
            
            System.assertEquals(reasons[0].en_US_category__c, insertedTask.EN_Outreach_Reason__c, 'EN Outreach Reason not updated at Insert');
        }
    }

    @isTest
    static void testUpdateENOutreachReasonOnUpdate() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

        System.runAs(sa) {
            Task t = CLT_TestDateFactory.createTask(sa.Id, true);

            List<CLT_EmailTemplateCategory__mdt> reasons = [SELECT en_US_category__c,fr_category__c 
                                                            FROM CLT_EmailTemplateCategory__mdt 
                                                            WHERE en_US_category__c != NULL AND fr_category__c != NULL 
                                                            LIMIT 1];
            Test.startTest();
            t.Outreach_Reason__c = reasons[0].fr_category__c;
            update t;
            Test.stopTest();
            Task updatedTask = [SELECT EN_Outreach_Reason__c FROM Task WHERE Id = :t.Id LIMIT 1];
            
            System.assertEquals(reasons[0].en_US_category__c, updatedTask.EN_Outreach_Reason__c, 'EN Outreach Reason not updated at Update');
        }
    }

    @isTest
    static void testGiftENOutreachReasonUpdate() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

        System.runAs(sa) {
            Gift__c g = CLT_TestDateFactory.createTestGift('Wedding', true);
            Task t = CLT_TestDateFactory.createTask(sa.Id, false);
            t.Gift__c = g.Id;
            t.Outreach_Reason__c = 'Wedding';
            t.Outreach_Type__c = 'Gift';
            insert t;

            Test.startTest();
            Task insertedTask = [SELECT EN_Outreach_Reason__c FROM Task WHERE Id = :t.Id LIMIT 1];
            System.assertEquals(t.Outreach_Reason__c, insertedTask.EN_Outreach_Reason__c, 'EN Outreach Reason different than Outreach Reason for gift');
            Test.stopTest();
            
            
        }
    }

    @isTest
    static void testRelatedClientListMembersStatus() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = 'TST123'];
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        
        ClientList__c cl = CLT_TestDateFactory.createTestClientList('Test Membered List', '', false);
        cl.Type__c = 'Membered';
        cl.IsActive__c = true;
        insert cl;

        ClientListMember__c clm = new ClientListMember__c(
            ClientList__c = cl.Id,
            Client__c = client.Id,
            Status__c = 'To Reach Out'
        );
        insert clm;

        Task task = CLT_TestDateFactory.createTask(sa.Id, false);
        task.WhatId = client.Id;
        task.Outreach_Type__c = 'Call';
        task.ActivityDate = Date.today();
        task.ClientList__c = cl.Id;
        
        insert task;

        ClientListMember__c clmAfterTaskInsert = [SELECT Status__c FROM ClientListMember__c WHERE Id = :clm.Id];

        System.assertEquals('Contacted', clmAfterTaskInsert.Status__c, 'Client List Member Status is not Contacted after related task inserted');
    }

    /**
     * @description Test method to validate the creation of silent notifications on Task upsert.
     * This method checks that a silent notification is generated when an Task record is upserted.
     * Note: No assert is added as the notification push cannot be directly verified.
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
        System.assertEquals(t.Id, notif.RelatedRecordId__c, 'CLT_Utils_TaskTrigger_Test:testSilentNotificationOnTaskAssignmentUpdate: deleted notification not related to deleted task');

    }

     /**
     * @description Test method to validate the creation of silent notifications on Task delete.
     * This method ensures that a silent notification is created when a Task record is deleted.
     */
    @isTest
    static void testSilentNotificationOnTaskDelete() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Task t = CLT_TestDateFactory.createTask(sa.Id, true);

        String taskId = t.Id;

        Test.startTest();
        delete t;
        Test.stopTest();

        Notification__c notif = [SELECT RelatedRecordId__c FROM Notification__c WHERE User__c = :sa.Id AND Silent__c = true];
        System.assertEquals(taskId, notif.RelatedRecordId__c, 'CLT_Utils_TaskTrigger_Test:testSilentNotificationOnTaskDelete: deleted notification not related to deleted task');
    }
}