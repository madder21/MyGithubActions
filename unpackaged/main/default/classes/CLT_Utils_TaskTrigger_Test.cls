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
}