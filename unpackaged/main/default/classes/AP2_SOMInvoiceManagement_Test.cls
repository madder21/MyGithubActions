/**
 * @author Paul Louis MONY
 * @date March,2nd 2023
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from AP2 :
 * testSetup : Creation of OrderSummary and Invoice, need SeeAllData = true to use ConnectAPI
 * CLASS FROM AP2       			|	RELATED TEST METHOD				|	DESCRIPTION
 * SOM_ServerConnect				|	serverAzureConnectionSuccess	|	Test of Success Connection on a particular InvoiceID
 * SOM_ServerConnect				|	serverAzureConnectionError		|	Test of Catch error when API parameters are not correctly set, the seeAllData = false permit to not set the Custom Settings which lead to an Error 400
 * SOM_AuthSFMCAccessToken			|	authSFMCSuccess					|	Test of success access token retreive from API call
 * SOM_UploadInSFMCAsset			|	uploadSFMCSuccess				|	Test of successfull Upload to Content Builder, of Blob Invoice converted in Base 64
 * SOM_UploadInSFMCAsset			|	uploadSFMCError					|	Test of Catch Error when API parameters are not correctly set, the seeAllData = false permit to not set the Custom Settings which lead to an Error 400
 * SOM_GenerateInvoicesInSFMC		|	generateOneInvoiceInSFMCSuccess	| 	Trigger test TransactionalEmailAfterInsertUpdate
 * SOM_GenerateInvoiceInSFMC		|	generateOneInvoiceInSFMCSuccess	|	Launched by SOM_GenerateInvoicesInSFMC to use @future context for list of transac email
 * SOM_DeleteInvoicesFromSFMC		|	deleteOneInvoiceInSFMCSuccess	|	Trigger test TransactionalEmailAfterInsertUpdate
 * SOM_DeleteInvoiceFromSFMC		|	deleteOneInvoiceInSFMCSuccess	| 	Launched by SOM_DeleteInvoicesFromSFMC to use @future context for list of transac email
 * SOM_GetAssetIdByCustomerKeyInSFMC|	getAssetIdSFMCSuccess			|	Test of success Asset ID retreive from API call
 * SOM_GetAssetIdByCustomerKeyInSFMC| 	getAssetIdSFMCError				|	Test of Catch error when API parameters are not correctly set, the seeAllData = false permit to not set the Custom Settings which lead to an Error 400
 * SOM_DeleteInSFMCAsset			|	deleteAssetInSFMCSuccess		|	Test of success deletion of asset from API Call
 * SOM_DeleteInSFMCAsset			|	deleteAssetInSFMCError			|	Test of Catch error deletion of asset from API Call
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2023/03/03			|.PLM			|.						|.original version
 * 0.1		|2023/03/08			|.PLM			|.						|.add testSetup, Add Test Method for Deletion of asset, Add Test Method for Asset ID querying
 * 0.2		|2023/04/18			|.PLM			|.						|.Modification of All Assert, replace System.assertEquals by Assert Class, Modification of serverAzureConnectionSuccess() test method
*/
@IsTest
public with sharing class AP2_SOMInvoiceManagement_Test {
    public static OrderSummary os = new OrderSummary();
    
    public static void testSetup(){        
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,3);
        os = los[0];
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder where Id =: fo.Id];
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        System.debug('mapIDFO'+mapIDFO);
        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);
        Account accTest = new Account(personEmail = 'test@test.com',lastName = 'test');
        insert accTest;
        List<Invoice> inv = [SELECT Id FROM Invoice WHERE ReferenceEntityId = :os.id];
        inv[0].InvoiceNumber__c = 'invtest1';
        update inv;
    }
    
    @IsTest (seeAllData = true)
    public static void serverAzureConnectionSuccess() {
         // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        testSetup();
        List<Invoice> inv = [SELECT Id FROM Invoice WHERE InvoiceNumber__c = 'invtest1'];
        Assert.areEqual(1,inv.size());
        system.debug('***serverAzureConnectionSuccess : invoiceID : '+inv[0].Id+'***');
        ID invoiceID = inv[0].Id ;
        String res = '';
        Test.startTest();
        	res = AP2_SOMInvoiceManagement.SOM_ServerConnect(invoiceID);
        	system.debug('***serverAzureConnectionSuccess : res : '+res+'***');
        Test.stopTest();
        Assert.isNotNull(res);
     }
    
    @isTest (seeAllData = false)
    static void serverAzureConnectionError() {
          // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        ID invoiceID = '3tt000000000000000';
        Test.startTest();
        	String res = AP2_SOMInvoiceManagement.SOM_ServerConnect(invoiceID);
        Test.stopTest();
        Assert.isNull(res); 
     }
    
    @isTest (seeAllData = true)
    public static void authSFMCSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        	String res = AP2_SOMInvoiceManagement.SOM_AuthSFMCAccessToken();
        system.debug( res);
        Test.stopTest();
        Assert.isNotNull(res); //Token shouldn't be null
        Assert.areNotEqual('Error',res);//Token shoudn't return 'Error' word.
     }
    
    @isTest (seeAllData = true) 
    static void uploadSFMCSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String myTestInvoice = 'myTestBlob';
		String customerKey = AP2_SOMInvoiceManagement.SOM_UploadInSFMCAsset(myTestInvoice, 'invoice-123456789.pdf', 'tokkenTestBelike');        
        Test.stopTest();
        Assert.areEqual('customerKeyBeLike',customerKey); 
     }
    
    @isTest (seeAllData = false)
    static void uploadSFMCError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String myTestInvoice = 'myTestBlob';
		String customerKey = AP2_SOMInvoiceManagement.SOM_UploadInSFMCAsset(myTestInvoice, 'invoice-123456789.pdf', 'tokkenTestBelike');        
        Test.stopTest();
        Assert.areEqual('Error',customerKey); 
     }
    
    @isTest (seeAllData = true)
    static void getAssetIdSFMCSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String myTestResponse;
		String customerKey = 'customerKeyBeLike';
        String tokkenTest= 'tokkenTestBelike';
        myTestResponse = AP2_SOMInvoiceManagement.SOM_GetAssetIdByCustomerKeyInSFMC(customerKey, tokkenTest);        
        Test.stopTest();
        Assert.areEqual('1010',myTestResponse); 
     }
    
    @isTest (seeAllData = true)
    static void deleteAssetInSFMCSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String myTestResponse;
		String AssetTest = '1010';
        String tokkenTest= 'tokkenTestBelike'; 
        myTestResponse = AP2_SOMInvoiceManagement.SOM_DeleteInSFMCAsset(AssetTest, tokkenTest);        
        Test.stopTest();
        Assert.areEqual('OK',myTestResponse); 
     }
    
    @isTest (seeAllData = false)
    static void getAssetIdSFMCError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String myTestResponse;
		String customerKey = 'customerKeyBeLike';
        String tokkenTest= 'tokkenTestBelike';
        myTestResponse = AP2_SOMInvoiceManagement.SOM_GetAssetIdByCustomerKeyInSFMC(customerKey, tokkenTest);        
        Test.stopTest();
        Assert.areEqual('Error',myTestResponse); 
     }
    
    @isTest (seeAllData = false)
    static void deleteAssetInSFMCError() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        String myTestResponse;
		String AssetTest = '1010';
        String tokkenTest= 'tokkenTestBelike'; 
        myTestResponse = AP2_SOMInvoiceManagement.SOM_DeleteInSFMCAsset(AssetTest, tokkenTest);        
        Test.stopTest();
        Assert.areEqual('Bad request',myTestResponse); 
     }
    
    @isTest (seeAllData = true)
    static void generateOneInvoiceInSFMCSuccess(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        testSetup();
        Account accTest = [SELECT ID,personEmail from Account where personEmail = 'test@test.com' and lastName = 'test' Limit 1];
        Test.startTest();
        
        TransactionalEmail__c transacEmail =  new TransactionalEmail__c(Client__c =  accTest.Id, 
                                                                         email__c = accTest.PersonEmail, 
                                                                         OrderSummary__c = os.Id, 
                                                                         Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND, 
                                                                         Template__c = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE);
        
		insert transacEmail;
        Test.stopTest();
        TransactionalEmail__c transEmail= [SELECT ID,Name,email__c,TECH_GenerateInvoice__c,OrderSummary__c,Client__c,TECH_CustomerKey__c from TransactionalEmail__c
                                 WHERE Template__c = :SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE
                                	AND Status__c = :SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND
                                           AND email__c = :accTest.PersonEmail
                                           AND Client__c = :accTest.Id AND OrderSummary__c = :os.Id LIMIT 1];
        System.debug('**AP2 TEST : generateOneInvoiceInSFMCSuccess : ' + transEmail);
        Assert.isTrue(transEmail.TECH_GenerateInvoice__c);
        Assert.areNotEqual('Error',transEmail.TECH_CustomerKey__c);
        Assert.isNotNull(transEmail.TECH_CustomerKey__c);
    }
	
    @isTest (seeAllData = true)
    static void deleteOneInvoiceInSFMCSuccess(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        testSetup();
        Account accTest = [SELECT ID,personEmail from Account where personEmail = 'test@test.com' and lastName = 'test' Limit 1];
        TransactionalEmail__c transacEmail =  new TransactionalEmail__c(Client__c =  accTest.Id, 
                                                                        email__c = accTest.PersonEmail, 
                                                                        OrderSummary__c = os.Id, 
                                                                        Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_SENT, 
                                                                        Template__c = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE,
                                                                        TECH_GenerateInvoice__c = true,
                                                                        TECH_CustomerKey__c = 'CustomerKeyBeLike');
        
        Test.startTest();
        	insert transacEmail;
        Test.stopTest();
        TransactionalEmail__c trEmail = [Select id,TECH_GenerateInvoice__c,TECH_CustomerKey__c,Status__c,Template__c 
                                         FROM TransactionalEmail__c 
                                         WHERE  Client__c = :accTest.Id 
                                         AND email__c = :accTest.PersonEmail 
                                         AND OrderSummary__c = :os.Id];
		Assert.isFalse(trEmail.TECH_GenerateInvoice__c);        
        Assert.isNull(trEmail.TECH_CustomerKey__c);
        Assert.areEqual(SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE,trEmail.Template__c);
        Assert.areEqual(SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_SENT,trEmail.Status__c);
    }
}