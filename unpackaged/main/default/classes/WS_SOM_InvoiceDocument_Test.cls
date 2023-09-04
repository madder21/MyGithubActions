@isTest
public with sharing class WS_SOM_InvoiceDocument_Test {
	
    @isTest(seeAllData=true)
    public static String setUpData(){
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        Invoice invoice = [SELECT Id , CreatedDate, ReferenceEntityId , InvoiceNumber__c , CurrencyIsoCode from Invoice where ReferenceEntity.type =: SOM_Constants.ORDER_SUMMARY_NAME AND ReferenceEntityId = :los[0].Id];
        SOM_testDataFactory.createAttachment('test Attachment', invoice.Id, 'test blob');
        return invoice.Id;
    }
    
    @isTest(seeAllData=true)
    public static void doGetTest(){
        String inv = setUpData();
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestUri = 'https://rimowa--devsom.my.salesforce.com/services/apexrest/InvoiceDocument/'+ inv;
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
    	RestContext.response= res;
        Test.startTest();
        WS_SOM_InvoiceDocument.doGet();
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    public static void doGetTestFail(){
        String fakeInv = 'fakeId';
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestUri = 'https://rimowa--devsom.my.salesforce.com/services/apexrest/InvoiceDocument/'+ fakeInv;
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
    	RestContext.response= res;
        Test.startTest();
        WS_SOM_InvoiceDocument.doGet();
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    public static void doDeleteTest(){
        String inv = setUpData();
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestUri = 'https://rimowa--devsom.my.salesforce.com/services/apexrest/InvoiceDocument/'+ inv;
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
    	RestContext.response= res;
        Test.startTest();
        WS_SOM_InvoiceDocument.doDelete(); 
        Test.stopTest();
        List<Attachment> att = [SELECT Id FROM Attachment WHERE ParentId = :inv LIMIT 1]; 
        System.assert(att.size() == 0);
    }
    
    @isTest(seeAllData=true)
    public static void doDeleteTestFail(){ 
        String FakeInv = 'fakeId';
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestUri = 'https://rimowa--devsom.my.salesforce.com/services/apexrest/InvoiceDocument/'+ FakeInv;
        req.httpMethod = 'GET';
        req.requestBody = Blob.valueof('{}');
        RestContext.request = req;
    	RestContext.response= res;
        Test.startTest();
        WS_SOM_InvoiceDocument.doDelete(); 
        Test.stopTest();
        List<Attachment> att = [SELECT Id FROM Attachment WHERE ParentId = :FakeInv LIMIT 1];
        System.assert(att.size() == 0);
    }
}
