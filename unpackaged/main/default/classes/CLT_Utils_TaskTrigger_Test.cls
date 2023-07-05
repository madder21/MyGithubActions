/*
 * Created by israel on 7/15/2019.
 */
@IsTest
private class CLT_Utils_TaskTrigger_Test {

	@IsTest static void testOne() {

		Id recordTypeId = [SELECT Id FROM RecordType WHERE IsPersonType = true LIMIT 1].Id;

		Account account = new Account(LastName = 'Name', RecordTypeId = recordTypeId);
		insert account;

		Task task = new Task(Outreach_Type__c = 'Call', WhatId = account.Id);
		insert task;
	}
    
    @isTest
    static void testTwo() {
        List<Catalog_Product__c> products = new List<Catalog_Product__c>();
        
        Catalog_Product__c product1 = new Catalog_Product__c();
        product1.Product_SKU__c = 'testSku1';
        product1.Name = 'testSku1';
        products.add(product1);
        
        Catalog_Product__c product2 = new Catalog_Product__c();
        product2.Product_SKU__c = 'testSku2';
        product2.Name = 'testSku2';
        products.add(product2);
        
        insert products;
        
        Task task = new Task();
        task.Subject = 'test task';
        task.ActivityDate = Date.today();
        task.Related_Products__c = product1.Id + ';' + product2.Id + ';';
        
		insert task;
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
}