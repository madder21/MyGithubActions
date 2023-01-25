@IsTest
global with sharing class SOM_DownloadInvoiceDocument_Test {
    
    @IsTest (seeAllData = true)
    global static void testDownloadInvoice(){
        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds];
        System.debug('foooo ' + lFO);
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);

        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);
        Set<Id> shipIds = ships.keySet();
        List<String> strShipIds = (List<String>)JSON.deserialize(JSON.serialize(shipIds), List<String>.class);

        List<Invoice> inv = [SELECT Id FROM Invoice WHERE ReferenceEntityId IN: osIds];

        PageReference page = new PageReference('/apex/SOM_InvoiceDownloadContect');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('invoiceId',inv[0].id);

        Test.setMock(HttpCalloutMock.class, new MulesoftDownloadMock());

        Test.startTest();
        SOM_DownloadInvoiceDocumentController res = new SOM_DownloadInvoiceDocumentController();
        Test.stopTest();
        System.assertEquals(false, String.isEmpty(res.invoiceData)); 
        
       
    }

    @IsTest (seeAllData = true)
    global static void testDownloadCorrectiveInvoice(){
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
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
        System.debug('mapships'+ships);
        List<Invoice> invs = [SELECT id, InvoiceNumber__c, CurrencyIsoCode FROM Invoice WHERE ReferenceEntityId =: los[0].Id];
        System.debug('mapinvs'+invs);
        Map<Id, Invoice> mapinv = new Map<Id, Invoice>(invs);
        System.debug('mapinvsddd'+mapinv);
        Map<Id,CorrectiveInvoice__c> mapCorrectiveInvoice = SOM_testDataFactory.createCorrectiveInvoices(mapinv);
        Set<Id> cmIds = mapCorrectiveInvoice.keySet();
        List<Id> creditMemoIds = new List<Id>(cmIds);
        PageReference page = new PageReference('/apex/SOM_InvoiceDownloadContect');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('invoiceId',creditMemoIds[0]);

        Test.setMock(HttpCalloutMock.class, new MulesoftDownloadMock());

        Test.startTest();
        SOM_DownloadInvoiceDocumentController res = new SOM_DownloadInvoiceDocumentController();
        Test.stopTest();
        System.assertEquals(false, String.isEmpty(res.invoiceData)); 
        
       
    }

    @IsTest (seeAllData = true)
    global static void testDownloadCreditMemo(){
        
        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds];
        System.debug('foooo ' + lFO);
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);

        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);
        Set<Id> shipIds = ships.keySet();
        List<String> strShipIds = (List<String>)JSON.deserialize(JSON.serialize(shipIds), List<String>.class);

        List<Invoice> inv = [SELECT Id FROM Invoice WHERE ReferenceEntityId IN: osIds];

        Refund ref = SOM_testDataFactory.createRefundWithCreditMemo(lOS[0],false,true);
        Map<Id,CreditMemo> creditMemoList = new Map<Id,CreditMemo>([SELECT Id, CreditMemoNumber, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id, OrderNumber, BillingCountry END FROM CreditMemo WHERE ReferenceEntity.Id IN :osIds]);
        Set<Id> cmIds = (new Map<Id,CreditMemo>(creditMemoList)).keySet();
        List<Id> creditMemoIds = new List<Id>(cmIds);

        PageReference page = new PageReference('/apex/SOM_InvoiceDownloadContect');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('invoiceId',creditMemoIds[0]);

        Test.setMock(HttpCalloutMock.class, new MulesoftDownloadMock());

        Test.startTest();
        SOM_DownloadInvoiceDocumentController res = new SOM_DownloadInvoiceDocumentController();
        Test.stopTest();
        System.assertEquals(false, String.isEmpty(res.invoiceData)); 
        
       
    }

    @IsTest (seeAllData = true)
    global static void testDownloadKO(){
        
        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds];
        System.debug('foooo ' + lFO);
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);

        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);
        Set<Id> shipIds = ships.keySet();
        List<String> strShipIds = (List<String>)JSON.deserialize(JSON.serialize(shipIds), List<String>.class);

        List<Invoice> inv = [SELECT Id FROM Invoice WHERE ReferenceEntityId IN: osIds];

        Refund ref = SOM_testDataFactory.createRefundWithCreditMemo(lOS[0],false,true);
        Map<Id,CreditMemo> creditMemoList = new Map<Id,CreditMemo>([SELECT Id, CreditMemoNumber, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id, OrderNumber, BillingCountry END FROM CreditMemo WHERE ReferenceEntity.Id IN :osIds]);
        Set<Id> cmIds = (new Map<Id,CreditMemo>(creditMemoList)).keySet();
        List<Id> creditMemoIds = new List<Id>(cmIds);

        PageReference page = new PageReference('/apex/SOM_InvoiceDownloadContect');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('invoiceId',creditMemoIds[0]);

        Test.setMock(HttpCalloutMock.class, new MulesoftDownloadErrorMock());

        Test.startTest();
        SOM_DownloadInvoiceDocumentController res = new SOM_DownloadInvoiceDocumentController();
        Test.stopTest();
        System.assertEquals(false, String.isEmpty(res.errorMessage)); 
        
       
    }

    @IsTest (seeAllData = true)
    global static void testDownloadNoIvoiceKO(){
        
        PageReference page = new PageReference('/apex/SOM_InvoiceDownloadContect');
        Test.setCurrentPage(page);
        ApexPages.currentPage().getParameters().put('invoiceId','3tt1X00000m4KNVQAm');

        Test.setMock(HttpCalloutMock.class, new MulesoftDownloadMock());

        Test.startTest();
        SOM_DownloadInvoiceDocumentController res = new SOM_DownloadInvoiceDocumentController();
        Test.stopTest();
        System.assertEquals(false, String.isEmpty(res.errorMessage)); 
        
       
    }

    global class MulesoftDownloadMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(200);
            res.setBody('{}');
            return res;
        }
    }
    
    global class MulesoftDownloadErrorMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
    
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setStatusCode(401);
            return res;
        }
    }
}