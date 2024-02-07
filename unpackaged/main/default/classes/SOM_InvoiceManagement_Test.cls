@isTest
public with sharing class SOM_InvoiceManagement_Test {
    
    @isTest(seeAllData = true)
    static void makeData(){
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaries(false,SOM_testDataFactory.OrderType.Standard,1);
        OrderSummary os = [SELECT Id , SalesChannelName__c  from OrderSummary where  Id = :los[0].Id];
        //OrderSummary os = SOM_testDataFactory.generateOrderSummary(); 
        System.debug('los[0].SalesChannelName__c' + os.SalesChannelName__c);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId = :los[0].id];
        Map<Id, FulfillmentOrder> fotest = new Map<Id, FulfillmentOrder>(lFO);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        System.debug('ltest' + test);
        System.debug('fotest' + fotest);
        Invoice invoice = [SELECT Id , ReferenceEntityId , PDFGenerationStatus__c,InvoiceNumber__c , CurrencyIsoCode from Invoice where ReferenceEntity.type =: SOM_Constants.ORDER_SUMMARY_NAME AND ReferenceEntityId = :los[0].Id];
        Map<Id,Invoice> mapInvoice = new Map<Id,Invoice>();
        Map<Id,Invoice> New_mapInvoice = new Map<Id,Invoice>();
        invoice.PDFGenerationStatus__c = 'Not started';
        Update invoice; 
        mapInvoice.put(invoice.Id , invoice);
        invoice.PDFGenerationStatus__c = 'Posted To BLOB Storage';
        Update invoice; 
        New_mapInvoice.put(invoice.Id , invoice);
        SOM_InvoiceManagement.UpdateInvoicesNumber(New_mapInvoice,mapInvoice);
        System.debug('invoice1' + New_mapInvoice);
        System.debug('invoice2' + mapInvoice);
    }
    
    
    
}