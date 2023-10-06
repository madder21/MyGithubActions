/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 03-10-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@IsTest(SeeAllData=false)
public with sharing class WS_AccountUTL_TST {

    // Mock the AccountAPI__c object for testing
    public static AccountAPI__c createMockAccountAPI(String sObjectInstance) {
        AccountAPI__c api = new AccountAPI__c();
        api.Name = sObjectInstance;
        api.EndPoint__c = 'https://example.com/api';
        api.Method__c = 'POST';
        api.Content_Type__c = 'application/json';
        api.Client_Id__c = 'client_id';
        api.Client_secret__c = 'client_secret';
        insert api;
        return api;
    }
    
    @isTest
    static void testBuildRequest() {
        // Create a test AccountAPI__c record
        AccountAPI__c api = createMockAccountAPI('TestInstance');
        
        // Call the buildRequest method
        HttpRequest req = WS_AccountUTL.buildRequest('TestInstance');
        
        // Create a sample JSON content
        String jsonContent = '{"key": "value"}';
        Test.startTest();
        
        // Call the pushRequest method
        WS_AccountUTL.pushRequest(jsonContent, 'TestInstance');
        
        Test.stopTest();
        
        // Verify the values in the request
        System.assertEquals(api.EndPoint__c, req.getEndpoint());
        System.assertEquals(api.Method__c, req.getMethod());
        System.assertEquals(api.Content_Type__c, req.getHeader('Content-Type'));
        System.assertEquals(api.Client_Id__c, req.getHeader('client_id'));
        System.assertEquals(api.Client_secret__c, req.getHeader('client_secret'));
    }
}