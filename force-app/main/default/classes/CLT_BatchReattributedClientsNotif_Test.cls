@isTest
private class CLT_BatchReattributedClientsNotif_Test {
    @TestSetup
    static void reattributedClientsBatchPrepareData(){
        CLT_TestDateFactory.createTestRClientConfigurations(true);
        
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

        Account client = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, false);
        client.Local_Main_CA__c = sa.Id;
        client.Targeted_Customers_CAreattribution__c = true;
		insert client;
    }

    @isTest
    static void CLT_BatchReattributedClientsNotifTest() {
        Test.startTest();
        CLT_BatchReattributedClientsNotif b = new CLT_BatchReattributedClientsNotif();
        Database.executeBatch(b);
        Test.stopTest();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        List<Notification__c> notificationsListAfterBatch = [SELECT Id FROM Notification__c WHERE User__c = :sa.Id];
        System.assertEquals(1, notificationsListAfterBatch.size(), 'Notifications list size is not 1 after batch run');
    }

    @isTest
    static void CLT_SchedBatchReattributedClientsNotifTest() {
        Test.startTest();
        CLT_BatchReattributedClientsNotif schedBatch = new CLT_BatchReattributedClientsNotif();
        String sch = '0 0 23 * * ?'; 
        Id jobId = System.schedule('Test CLT_BatchReattributedClientsNotif Sched', sch, schedBatch);
        CronTrigger cronTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(sch, cronTrig.CronExpression);
        Test.stopTest();
    }
}