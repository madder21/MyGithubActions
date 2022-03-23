/*
 * Created by Israel Zygelboim on 07/02/2019.
 */
@IsTest
private class CLT_ClientDetails_Test {

	@isTest static void test_method_one() {

//		TestDataFactory.createCustomSettings();
		Account account = new Account(Name = 'client');
		insert account;

		 CLT_ClientDetail clientDetails = new  CLT_ClientDetail();
		Test.startTest()
		;
		String jsonString  = '{"items" : [{"id" : "' + account.Id + '", "PersonEmail" : "dev@balink.net"}], "objectName" : "Account"}';


		clientDetails.retrieveGet(new Map<String, String>{'clientId' => account.Id});
		clientDetails.retrieveDelete(new Map<String, String>());
		clientDetails.retrievePost(new Map<String, String>(), (Map<String, Object>)JSON.deserializeUntyped(jsonString));

		Test.stopTest();
	}

}