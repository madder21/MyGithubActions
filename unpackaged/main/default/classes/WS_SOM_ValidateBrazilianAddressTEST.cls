@IsTest
global with sharing class WS_SOM_ValidateBrazilianAddressTEST {
    public static Boolean attachedToRO = false ;
    public static Boolean discount = false ;
    
    @IsTest (seeAllData=true)
    public static void testValidateBrazilianAddress(){
        
        SOM_BrazilianRequest TEST1 = new SOM_BrazilianRequest();
        TEST1.ZipCode = '22776-070';
        TEST1.Identifier = 'Rec1';
        
        
        SOM_BrazilianRequest TEST2 = new SOM_BrazilianRequest();
        TEST2.ZipCode = '03182-050';
        TEST2.Identifier = 'Rec2';
        
        List<SOM_BrazilianRequest>		Reqs = new List<SOM_BrazilianRequest>();
        Reqs.add(TEST2);
        Reqs.add(TEST1);
        
        List<List<SOM_BrazilianRequest>> Requests = new List<List<SOM_BrazilianRequest>>();
        
        Requests.add(Reqs);
        
        
        List<List<SOM_BrazilianAutomaticResponse>> responsesWrappers = new List<List<SOM_BrazilianAutomaticResponse>>();
        
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        
        Test.startTest();
        responsesWrappers = WS_SOM_ValidateBrazilianAddress.ValidateBrazilianAddress(Requests);
        System.assertNotEquals(responsesWrappers.size(), 0 );
        Test.stopTest();
        
    }
    
    
    global class CybersourceCalloutMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            
            HttpResponse httpRequest = new HttpResponse();
            httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
            httpRequest.setStatusCode(200);
            httpRequest.setBody('{}');
            return httpRequest;
        }
    }
    
}