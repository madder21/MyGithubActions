@isTest
private class CLT_Wishlist_Test {
	
	@isTest static void test_method_one() {
		Map<String, String> params = new Map<String, String>();
		Map<String, Object> body = new Map<String, Object>();
		params.put('', '');
		CLT_Wishlist cltWishlist = new CLT_Wishlist();

		Test.startTest();
		cltWishlist.retrieveGet(params);
		cltWishlist.retrieveDelete(params);
		cltWishlist.retrievePost(params, body);
        Test.stopTest();
	}
	
}