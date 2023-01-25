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
        System.debug('test fo+'+fo);
        Map<Id, FulfillmentOrder> fotest = new Map<Id, FulfillmentOrder>(lFO);
        System.debug('fotest'+fotest);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        System.debug('test shipment+'+test);
        Invoice invoice = [SELECT Id , ReferenceEntityId , InvoiceNumber__c , CurrencyIsoCode from Invoice where ReferenceEntity.type = 'OrderSummary' AND ReferenceEntityId = :los[0].Id];
        System.debug('listeInvoice++'+invoice);
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
    }
}