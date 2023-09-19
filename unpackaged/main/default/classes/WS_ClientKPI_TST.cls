/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 29-08-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@IsTest(SeeAllData=false)
public without sharing class WS_ClientKPI_TST {

    @isTest
    static void testCreateClientAddress() {
        
        Test.StartTest();
        // Create test data for the JSON payload
        Map<String, Object> jsonData = new Map<String, Object>();
        List<Account> accList = TestDataFactory.createSObjectList('Account', 1);
        List<Store__c> storeList = TestDataFactory.createSObjectList('Store__c', 1, false);
        storeList[0].SourceStoreId__c = 'FR01';
        insert storeList;
        Account acc = new Account(
        	id= accList[0].Id,
            OriginStore__pr = storeList[0],
            PreferredStore__pr = storeList[0],
            MainStore__pr = storeList[0]
        );
        
        jsonData.put('Client__c', accList[0].Id);
        jsonData.put('client', acc);
        
        List<ClientSource__c> clientSources = new List<ClientSource__c>();
        List<ClientAddress__c> clientAddresses = new List<ClientAddress__c>();
        ClientSource__c source1 = new ClientSource__c(
            Source__c = 'SF',
            SourceCode__c = accList[0].Id,
            SourceCreationDate__c = Date.valueOf('2021-05-17'),
            SourceLastUpdateDate__c = DateTime.valueOf('2021-10-16 15:20:41.990679+00:00')
        );
        
        ClientAddress__c address1 = new ClientAddress__c(
            Address1__c = '7007 FRIARS RD STE 513',
            City__c = 'SAN DIEGO',
            Country__c = 'US',
            PostalCode__c = '92108-1142',
            State__c = 'CA',
            AddressTypology__c = 'STANDARD',
            IsValid__c = false
        );
        clientAddresses.add(address1);
        clientSources.add(source1);
        
        jsonData.put('client_Sources', clientSources);
        jsonData.put('client_Adresses', clientAddresses);
        
        // Convert the test data to JSON
        String requestBody = JSON.serialize(jsonData);
        
        // Simulate the HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ClientKPI';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        
        // Call the REST endpoint
        String response = WS_ClientKPI.upsertClientInformation();
        
		List<ClientAddress__c> retrievedAddress = [SELECT Id FROM ClientAddress__c WHERE Client__c =: accList[0].Id]; 
        Test.StopTest();
        // Verify the response or perform assertions as needed
        System.assertEquals(false, retrievedAddress.isEmpty());
    }
    
    
    @isTest
    static void testUpdateClientAddress() {
        // Create test data for the JSON payload
        Map<String, Object> jsonData = new Map<String, Object>();
        List<Account> accList = TestDataFactory.createSObjectList('Account',1);
        List<Store__c> storeList = TestDataFactory.createSObjectList('Store__c', 1, false);
        storeList[0].SourceStoreId__c = 'FR01';
        insert storeList;
        Account acc = new Account(
        	id= accList[0].Id,
            OriginStore__pr = storeList[0],
            PreferredStore__pr = storeList[0],
            MainStore__pr = storeList[0]
        );
        jsonData.put('Client__c', accList[0].Id);
        jsonData.put('client', acc);
        
        List<ClientSource__c> clientSources = new List<ClientSource__c>();
        List<ClientAddress__c> clientAddresses = new List<ClientAddress__c>();
       
        ClientSource__c source1 = new ClientSource__c(
            Source__c = 'SF',
            SourceCode__c = accList[0].Id,
            SourceCreationDate__c = Date.valueOf('2021-05-17'),
            SourceLastUpdateDate__c = DateTime.valueOf('2021-10-16 15:20:41.990679+00:00'),
            Client__c = accList[0].Id
        );
        ClientAddress__c address1 = new ClientAddress__c(
            Address1__c = '7007 FRIARS RD STE 513',
            City__c = 'SAN DIEGO',
            Country__c = 'US',
            PostalCode__c = '92108-1142',
            State__c = 'CA',
            AddressTypology__c = 'STANDARD',
            IsValid__c = false
        );        
        ClientAddress__c address2 = new ClientAddress__c(
            Address1__c = '7007 FRIARS RD STE 503',
            Address2__c = 'Test Address 2',
            Address3__c = 'Test Address 3',
            City__c = 'SAN DIEGO',
            Country__c = 'US',
            PostalCode__c = '92108-1142',
            State__c = 'CA',
            AddressTypology__c = 'STANDARD',
            IsValid__c = false,
            Client__c = accList[0].Id
        );
        insert address2;
        
        clientSources.add(source1);
        clientAddresses.add(address1);
        insert clientSources;
        
        jsonData.put('client_Sources', clientSources);
        jsonData.put('client_Adresses', clientAddresses);
                
        // Convert the test data to JSON
        String requestBody = JSON.serialize(jsonData);
        
        // Simulate the HTTP request
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ClientKPI';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(requestBody);
        RestContext.request = request;
        
        // Call the REST endpoint
        String response = WS_ClientKPI.upsertClientInformation();
        
		List<ClientAddress__c> retrievedAddress = [SELECT Id FROM ClientAddress__c WHERE Client__c =: accList[0].Id];       
        // Verify the response or perform assertions as needed
        System.assertEquals(false, retrievedAddress.isEmpty());
    }
}