/*
Author : Naimy Bouchaib
Description : test the creation of invoice
coverage : 95%
*/
@isTest
public with sharing class SOM_InvoiceDocumentController_test {
    public static Set<Id> correctiveInvoiceId = new Set<Id>();

    @isTest(seeAllData = true)
    static void makeData(){
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId = :los[0].id];
        Map<Id, FulfillmentOrder> fotest = new Map<Id, FulfillmentOrder>(lFO);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        Invoice invoice = [SELECT Id , CreatedDate, ReferenceEntityId , InvoiceNumber__c , CurrencyIsoCode from Invoice where ReferenceEntity.type =: SOM_Constants.ORDER_SUMMARY_NAME AND ReferenceEntityId = :los[0].Id];
        List<InvoiceLine> invoiceLines = [SELECT Id, Type, TaxRate,TaxAmount, Product2.Description, Quantity, UnitPrice, GrossUnitPrice, ChargeAmountWithTax, ChargeTaxAmount, TYPEOF ReferenceEntityItem WHEN OrderItemSummary THEN hsCode__c,hsCodeDescription__c,COO__c, Description, LineNumber END FROM InvoiceLine WHERE InvoiceId = :invoice.Id];
        System.debug('invoiceLine.GrossUnitPrice test1' + invoiceLines.size() + invoiceLines[0]  );
        System.debug('invoiceLine.GrossUnitPrice test2' + invoiceLines.size() + invoiceLines[1]  );
        System.debug('invoiceLine.GrossUnitPrice test3' + invoiceLines.size() + invoiceLines[2]  );
        System.debug('invoiceLine.GrossUnitPrice test4' + invoiceLines.size() + invoiceLines[3]  );
        Map<Id,Invoice> mapInvoice = new Map<Id,Invoice>();
        mapInvoice.put(invoice.Id , invoice);
        Map<Id,CorrectiveInvoice__c> mapCorrectiveInvoice = SOM_testDataFactory.createCorrectiveInvoices(mapInvoice);
        correctiveInvoiceId = mapCorrectiveInvoice.keySet();
    }

    @isTest(seeAllData = true)
    public static void callConstructor() {
        makeData();
        ApexPages.currentPage().getParameters().put('template', 'CoreModel');
        ApexPages.currentPage().getParameters().put('invoiceId',correctiveInvoiceId.iterator().next());
        SOM_InvoiceDocumentController inv_doc_constructor = new SOM_InvoiceDocumentController();
        
        System.assertNotEquals(inv_doc_constructor.invoiceConfigs.size(),0, 'InvoiceCnfigs Returned');
        System.assertNotEquals(inv_doc_constructor.invoiceTaxLineItems.size(),0, 'invoiceTaxLineItems Returned' );
        System.assertNotEquals(inv_doc_constructor.countryMap.size(),0, 'countryMap Returned');
        System.assertNotEquals(inv_doc_constructor.AmountsFormat,null, 'AmountsFormat Returned');
        
        
    }
}