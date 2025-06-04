@isTest
private class CLT_ProductDetails_Test {
    @isTest
    static void test_ProductDetails() {
        Catalog_Product__c product = new Catalog_Product__c();
        product.Product_SKU__c = 'testSku1';
        product.Name = 'testSku1';
        
        insert product;
        
        CLT_ProductDetails productDetails = new  CLT_ProductDetails();
 		Test.startTest();

        productDetails.retrieveGet(new Map<String, String>{'productId' => product.Id});      
		productDetails.retrieveDelete(new Map<String, String>());
		productDetails.retrievePost(new Map<String, String>(),new Map<String,Object>());

		Test.stopTest();
    }
}