@IsTest
private class CLT_ProductHierarchy_Test {

	@isTest static void test_ProductHierarchy_methods() {
        
       CLT_ProductHierarchy productHierarchy = new  CLT_ProductHierarchy();
 		Test.startTest();

		productHierarchy.retrieveGet(new Map<String, String>());
		productHierarchy.retrieveDelete(new Map<String, String>());
		productHierarchy.retrievePost(new Map<String, String>(),new Map<String,Object>());

		Test.stopTest();

    }
}