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
*/
@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test", "access_token":"tokkenTestBelike"}');
        res.setStatusCode(200);
        return res;
    }
}