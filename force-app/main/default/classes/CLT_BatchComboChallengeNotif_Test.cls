@isTest
private class CLT_BatchComboChallengeNotif_Test {
    @TestSetup
    static void comboChallengeBatchPrepareData(){
        CLT_TestDateFactory.createTestRClientConfigurations(true);

        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        sa.LanguageLocaleKey = 'fr';
        insert sa;

		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

		List<Account> clients = new List<Account>();
        Account client1 = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, false);
        client1.Last_Transaction_SA__pc = sa.Id;
        client1.LastPurchaseDate__pc = Date.today().addDays(-10);
		clients.add(client1);
        Account client2 = CLT_TestDateFactory.createTestClient('Test client 2', 'Test Last Name2', sa.Id, store.Id, false);
        client2.Last_Transaction_SA__pc = sa.Id;
        client2.LastPurchaseDate__pc = Date.today().addDays(-10);
		clients.add(client2);
		Account client3 = CLT_TestDateFactory.createTestClient('Test client 3', 'Test Last Name3', sa.Id, store.Id, false);
        client3.Last_Transaction_SA__pc = sa.Id;
        client3.LastPurchaseDate__pc = Date.today().addDays(-10); 
		clients.add(client3);
		insert clients;

        List<Transaction__c> transactions = new List<Transaction__c>();
        Transaction__c transction1 = CLT_TestDateFactory.createTestTransaction(client1.Id, Date.today().addDays(-10), false);
        transction1.Store__c = store.Id;
        transactions.add(transction1);
        Transaction__c transction2 = CLT_TestDateFactory.createTestTransaction(client2.Id, Date.today().addDays(-10), false);
        transction2.Store__c = store.Id;
        transactions.add(transction2);
        Transaction__c transction3 = CLT_TestDateFactory.createTestTransaction(client3.Id, Date.today().addDays(-10), false);
        transction3.Store__c = store.Id;
        transactions.add(transction3);
        insert transactions;

        Product2 product = CLT_TestDateFactory.createTestStandardProduct('TEST123', true);

        List<TransactionItem__c> transactionItems = new List<TransactionItem__c>();
        TransactionItem__c transactionItem1 = CLT_TestDateFactory.createTestTransactionItem(transction1.Id, client1.Id, product.Id, false);
        transactionItem1.Sales_Advisor__c = sa.Id;
        transactionItem1.ExclTaxAmount__c = 80;
        transactionItem1.Type__c = 'Sale';
        transactionItems.add(transactionItem1);
        TransactionItem__c transactionItem2 = CLT_TestDateFactory.createTestTransactionItem(transction2.Id, client2.Id, product.Id, false);
        transactionItem2.Sales_Advisor__c = sa.Id;
        transactionItem2.ExclTaxAmount__c = 80;
        transactionItem2.Type__c = 'Sale';
        transactionItems.add(transactionItem2);
        TransactionItem__c transactionItem3 = CLT_TestDateFactory.createTestTransactionItem(transction3.Id, client3.Id, product.Id, false);
        transactionItem3.Sales_Advisor__c = sa.Id;
        transactionItem3.ExclTaxAmount__c = 80;
        transactionItem3.Type__c = 'Sale';
        transactionItems.add(transactionItem3);
        insert transactionItems;

        List<Task> tasks = new List<Task>();
        Task outreach2 = CLT_TestDateFactory.createTask(sa.Id, false);
        outreach2.WhatId = client2.Id;
        outreach2.ActivityDate = Date.today().addDays(-6);
        outreach2.Outreach_Type__c = 'SMS';
        tasks.add(outreach2);
        Task outreach3 = CLT_TestDateFactory.createTask(sa.Id, false);
        outreach3.WhatId = client3.Id;
        outreach3.ActivityDate = Date.today().addDays(-6);
        outreach3.Outreach_Type__c = 'SMS';
        tasks.add(outreach3);
        Task task = CLT_TestDateFactory.createTask(sa.Id, false);
        task.WhatId = client3.Id;
        task.ActivityDate = Date.today().addDays(-5);
        tasks.add(task);
        insert tasks;    

        System.runAs(sa) {
            Note__c note = CLT_TestDateFactory.createTestNote('Wanted the lightest luggage possible', client3.Id, true);
            Client_Insight__c ci = new Client_Insight__c(
                ExternalId__c = client3.Id,
                Client__c = client3.Id,
                FrequentTraveler__c = 'Yes',
                HistoricalClient__c = 'Yes',
                Collaboration__c = 'Yes',
                Hobbies__c = 'Art'
            );
            insert ci;
            Test.setCreatedDate(note.Id, Date.today().addDays(-3));
        }
        
    }

    @isTest
    static void CLT_BatchComboChallengeNotifTest() {
        Test.startTest();
        CLT_BatchComboChallengeNotif b = new CLT_BatchComboChallengeNotif();
        Database.executeBatch(b);
        Test.stopTest();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        CLT_NotificationManagement__mdt comboNotificationSetting = [SELECT Id,Type__c,Subtype__c,Name__c,Message__c,RedirectionScreen__c 
                                                                    FROM CLT_NotificationManagement__mdt 
                                                                    WHERE Type__c = 'general' AND  Subtype__c = 'combo'
                                                                    LIMIT 1];
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        List<Notification__c> notificationsListAfterBatch = [SELECT Id 
                                                            FROM Notification__c 
                                                            WHERE User__c = :sa.Id AND Type__c = :comboNotificationSetting.Type__c AND Subtype__c = :comboNotificationSetting.Subtype__c];
        System.assertEquals(2, notificationsListAfterBatch.size(), 'Notifications list size is not 2 after batch run');
    }

    @isTest
    static void CLT_SchedBatchComboChallengeNotifTest() {
        Test.startTest();
        CLT_BatchComboChallengeNotif schedBatch = new CLT_BatchComboChallengeNotif();
        String sch = '0 0 23 * * ?'; 
        Id jobId = System.schedule('Test CLT_BatchComboChallengeNotif Sched', sch, schedBatch);
        CronTrigger cronTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(sch, cronTrig.CronExpression);
        Test.stopTest();
    }
}