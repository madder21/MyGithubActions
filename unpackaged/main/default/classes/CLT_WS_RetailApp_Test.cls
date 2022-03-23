/*
 * Created by israel on 7/14/2019.
 */
@IsTest
private class CLT_WS_RetailApp_Test {
	static testMethod void testPostItem() {
		RestRequest request=new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI=Url.getSalesforceBaseUrl()+'/services/apexrest/retail/notes';
		request.httpMethod='POST';
		request.requestBody=Blob.valueOf('{"Name":"test"}');
		RestContext.request=request;
		RestContext.response=res;
		CLT_WS_RetailApp.postItem();
	}

	static testMethod void testGetItem() {
		RestRequest request=new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI=Url.getSalesforceBaseUrl()+'/services/apexrest/retail/notes';
		request.httpMethod='GET';
		request.requestBody=Blob.valueOf('[]');
		RestContext.request=request;
		RestContext.response=res;
		CLT_WS_RetailApp.getItem();
	}

	static testMethod void testDeleteItem() {
		RestRequest request=new RestRequest();
		RestResponse res = new RestResponse();
		request.requestURI=Url.getSalesforceBaseUrl()+'/services/apexrest/retail/notes';
		request.httpMethod='DELETE';
		request.requestBody=Blob.valueOf('[]');
		RestContext.request=request;
		RestContext.response=res;
		CLT_WS_RetailApp.deleteItem();
	}

}