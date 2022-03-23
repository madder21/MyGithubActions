/**
 * 
 * @author Jeremy Martiano
 * @since March 2020
 * @group balink WS General Test
 * @description Test class for HTTP related utils
 */
@isTest
private class BL_HTTP_UTILS_Test {
	
	@isTest static void test_all() {


		Test.startTest();

			BL_HTTP_UTILS httpUtils = new BL_HTTP_UTILS();
			
			Map<String,String> allHeaders = new Map<String,String>();
			allHeaders.put('test', 'http://www.google.com');

			httpUtils.get('http://www.google.com');
			httpUtils.put('http://www.google.com');
			httpUtils.post('http://www.google.com');
			httpUtils.patch('http://www.google.com');
			httpUtils.del('http://www.google.com');
			httpUtils.header('test', 'http://www.google.com');
			httpUtils.body('{http://www.google.com}');
			httpUtils.addHeaders(allHeaders);
			httpUtils.timeout(1);
			httpUtils.call();
			httpUtils.getResponse();
			allHeaders = httpUtils.getHeaders();
			httpUtils.getParameters();
			
		Test.stopTest();
	}
}