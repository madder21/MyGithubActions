@isTest
private class CLT_Config_Test {
	
	@isTest static void test_method_one() {
		Map<String, String> params = new Map<String, String>();
		Map<String, Object> body = new Map<String, Object>();
		CLT_Config cltConfig = new CLT_Config();

		Test.startTest();
		cltConfig.retrieveGet(params);
		cltConfig.retrievePost(params, body);
        Test.stopTest();
	}

}