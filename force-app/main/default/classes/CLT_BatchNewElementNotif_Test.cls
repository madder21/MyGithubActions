@isTest
private class CLT_BatchNewElementNotif_Test {
    @TestSetup
    static void comboChallengeBatchPrepareData(){
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        sa.StoreCode__c = 'TST123';
        sa.Email_templates__c = 'FR;';
        insert sa;

		Store__c store = CLT_TestDateFactory.createTestStore('TST123', false);
        store.Region__c = '001';
        store.Country__c = 'FR';
        insert store;

        CLT_TestDateFactory.createTestRClientConfigurations(true);
    }

    @isTest
    static void CLT_BatchNewElementNotifTest() {
        String eventNameOption =  Event__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
        Event__c evnt = CLT_TestDateFactory.createTestClientelingEvent(eventNameOption, false);
        evnt.Region__c = '001';
        insert evnt;
        Test.setCreatedDate(evnt.Id, DateTime.now().addHours(-5));

        String giftNameOption =  Gift__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
        Gift__c gift = CLT_TestDateFactory.createTestGift(giftNameOption, false);
        gift.Region__c = '001';
        gift.Countries__c = 'FR';
        insert gift;
        Test.setCreatedDate(gift.Id, DateTime.now().addHours(-5));

        Catalog_Product__c catalogProduct = CLT_TestDateFactory.createTestProduct('TST123', true);
        Test.setCreatedDate(catalogProduct.Id, DateTime.now().addHours(-5));

        CLT_Email_Template__c cltEt = new CLT_Email_Template__c(
            JSON__c = JSON.serialize(new Map<String, Object> {'developerName' => 'French_EMAIL'}),
            Is_Active__c = true,
            PersonalizedTemplate__c = false
        );
        insert cltEt;
        Test.setCreatedDate(cltEt.Id, DateTime.now().addHours(-5));

        Test.startTest();
        CLT_BatchNewElementNotif b = new CLT_BatchNewElementNotif();
        Database.executeBatch(b);
        Test.stopTest();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        List<Notification__c> notificationsListAfterBatch = [SELECT Id FROM Notification__c WHERE User__c = :sa.Id];
        System.assertEquals(4, notificationsListAfterBatch.size(), 'Notifications list size is not 4 after batch run');
    }

    @isTest
    static void CLT_SchedBatchNewElementNotifTest() {
        Test.startTest();
        CLT_BatchNewElementNotif schedBatch = new CLT_BatchNewElementNotif();
        String sch = '0 0 23 * * ?'; 
        Id jobId = System.schedule('Test CLT_BatchNewElementNotif Sched', sch, schedBatch);
        CronTrigger cronTrig = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(sch, cronTrig.CronExpression, 'CLT_SchedBatchNewElementNotifTest scheduler not set at the correct time');
        Test.stopTest();
    }
}