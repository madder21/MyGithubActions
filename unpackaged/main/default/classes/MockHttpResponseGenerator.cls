/**
 * @author ?
 * @date ?
 * @Type Apex Test Class
 * @description This class is a Mock generator class, used for each Mock Test for API test CLASS
 * 
 * @Version : 
 * Version		Date of modication		Modified By			Related Jira Ticket				Description of changes			
 * 0.0			?						?					?								?
 * 0.1			06/03/2023				.PLM				.								.Add access_token to the body for Access token retrieve from body use case, and update API Version to 57
 * 0.2			24/04/2023				.PLM				.								.Add a xml path for SOAP Mock

*/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    private String responseXml;
    public MockHttpResponseGenerator(String responseXml) {
        this.responseXml = responseXml;
    }
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(String.isNotEmpty(this.responseXml)){
            res.setBody(this.responseXml);
            res.setHeader('Content-Type', 'text/xml');
        }
        else{
            res.setBody('{"example":"test","access_token":"tokkenTestBelike"}');
            res.setHeader('Content-Type', 'application/json');
        }
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
    }
   
}