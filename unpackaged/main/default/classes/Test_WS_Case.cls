@isTest
global class Test_WS_Case {
@isTest
    
    static void testcaseCreation() {
        //List< Map<String, Object>> invoiceBodyList = new List< Map<String, Object>>();
        Map<String, Object> invoiceBody = new Map<String, Object>();
        invoiceBody.put('Subject', 'warranty');
        invoiceBody.put('Description', 'Question about my warranty etc');
        invoiceBody.put('Civility__c', 'Mr');
        invoiceBody.put('FirstName__c', 'Test');
        invoiceBody.put('LastName__c', 'Test');
        invoiceBody.put('CustomerEmail__c', 'test@test.com');
        invoiceBody.put('Phone__c', '0102030405');
        invoiceBody.put('Productreference__c', 'test-123');
        invoiceBody.put('WebCountry__c', 'FR');
        invoiceBody.put('Region__c', 'TestRegion');
        invoiceBody.put('csc_activity__c', 'CC');
        
        //invoiceBodyList.add(invoiceBody);
        
        String jsonBody = JSON.serialize(invoiceBody);
        
        // Préparation de la requête HTTP
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/CaseCreation/';
        req.httpMethod = 'POST'; 
        req.addHeader('Content-Type', 'application/json');
        req.requestBody = Blob.valueOf(jsonBody);
        
        // Appel de la méthode REST
        RestContext.request = req;
        RestContext.response = new RestResponse();
        Test.startTest();
        WS_Case.caseCreation();
        Test.stopTest();
	}
}