@IsTest
global with sharing class WS_SOM_ValidateBrazilianAddressTEST {
    public static Boolean attachedToRO = false ;
    public static Boolean discount = false ;
    
    @IsTest (seeAllData=true)
    public static void testValidateBrazilianAddress(){
        
        List<String> CED = new List<String>{'22776-070'};
        List<WS_SOM_ValidateBrazilianAddress.AutomaticResponse> Response;
        
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        
        Test.startTest();
        Response = WS_SOM_ValidateBrazilianAddress.ValidateBrazilianAddress(CED);
        System.assertNotEquals(Response[0].localidade, 'Rio de Janeiro' );
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