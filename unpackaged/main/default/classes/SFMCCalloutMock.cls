@IsTest 
global with sharing class SFMCCalloutMock implements WebServiceMock {
    
    global void doInvoke( Object stub,Object request, Map<String, Object> response,
        String endpoint,String soapAction,String requestName,String responseNS,
        String responseName,String responseType){
            Account a = new Account (Name = 'TestCallout');
            insert a; 
            //response.put('response', response_x) ; 

    }
}