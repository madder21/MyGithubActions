@IsTest
private class CLT_CatalogProducts_Test {

	@isTest static void test_CatalogProducts_methods() {
        Catalog_Product__c product = new Catalog_Product__c();
        product.Product_SKU__c = 'testSku1';
        product.Name = 'testSku1';
        
        insert product;
        
        User ca = [SELECT Id, StoreCode__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        Store__c store = new Store__c();
        store.Name = 'test store';
        store.SourceStoreId__c = ca.StoreCode__c;
        
        insert store;
        
        Account client = new Account();
        client.FirstName = 'test';
        client.LastName = 'test';
        client.ClientAdvisor__pc = ca.Id;
        client.MainStore__pc = store.Id;
        
        insert client;
        
        WishlistItem__c wishlist = new WishlistItem__c();
        wishlist.Product__c = product.Id;
        wishlist.Client__c = client.Id;
        wishlist.TECH_uniqueKey__c = client.Id + '-' + product.Id;
        
        insert wishlist;
        
        CLT_CatalogProducts catalog = new  CLT_CatalogProducts();
 		Test.startTest();

		catalog.retrieveGet(new Map<String, String>());
        catalog.retrieveGet(new Map<String, String>{'listType' => 'waitedProduct'});
        catalog.retrieveGet(new Map<String, String>{'listType' => 'waitingClients'});        
        catalog.retrieveGet(new Map<String, String>{'productId' => product.id});        
		catalog.retrieveDelete(new Map<String, String>());
		catalog.retrievePost(new Map<String, String>(),new Map<String,Object>());

		Test.stopTest();

    }
}