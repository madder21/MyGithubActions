@isTest
private class CLT_EmailTemplates_Test {
    
    @testSetup
    static void setup() {
        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE ( Folder.Name LIKE 'EN %' ) AND IsActive = TRUE LIMIT 1].Id;
        
        Template_Images__c ti = new Template_Images__c();
        ti.Email_Template_Id__c = emailTemplateId;
        ti.Image_1__c = 'www.google.com';
        ti.Image_2__c = 'www.google.com';
        insert ti;
    }

	@isTest static void test_method_one() {
		Map<String, String> params = new Map<String, String>();
		Map<String, Object> body = new Map<String, Object>();
		CLT_EmailTemplates cltemailTemplates = new CLT_EmailTemplates();

		Test.startTest();
		cltemailTemplates.retrieveGet(params);
		cltemailTemplates.retrievePost(params, body);
		cltemailTemplates.retrieveDelete(params);
        params.put('isNew','true');
        cltemailTemplates.retrieveGet(params);
		Test.stopTest();
	}

}