@isTest
global class Test_WS_Case {

    @isTest
    static void testcaseCreation() {
        String jsonInput = '{"Subject": "warranty 12 test","Description": "Question about my warranty etc","Civility__c": "Mr","FirstName__c": "Edouard","LastName__c": "Knies","CustomerEmail__c": "test@test2.com","Phone__c": "3361234568","Productreference__c": "97353004123456789","WebCountry__c": "AU","Region__c": "West Coast","csc_activity__c": "CS"}';

        RestRequest mockRequest = new RestRequest();
        mockRequest.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = mockRequest;

        RestResponse mockResponse = new RestResponse();
        RestContext.response = mockResponse;

        WS_Case.caseCreation();

        String responseBody = RestContext.response.responseBody.toString();
        
        JSONGenerator body = JSON.createGenerator(true);
        body.writeStartArray();
        body.writeStartObject();
        body.writeStringField('Status:', 'Success');
        body.writeEndObject();
        body.writeEndArray();
            
        String expectedResponse = (body.getAsString());
        System.assertEquals(expectedResponse, responseBody, 'Response should not be null');

     }
}