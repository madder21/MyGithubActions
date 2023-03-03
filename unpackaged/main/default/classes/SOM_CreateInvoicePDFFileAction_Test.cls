/**************************************************************************************

-- - Author        : Fatima-Ezzahra LAFTOUMI

-- - Description   : Test class for 'SOM_CreateInvoicePDFFileAction' Class

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 05-08-2022    FEL    1.0          Initial version

***************************************************************************************/
@isTest
public with sharing class SOM_CreateInvoicePDFFileAction_Test {

    public static OrderSummary os = new OrderSummary();
    public static List<Invoice> listeInvoice = new List<Invoice>();
    public static Map<Id,CorrectiveInvoice__c> mapCorrectiveInvoiceHandler = new Map<Id,CorrectiveInvoice__c>();

     /**
     * @description setup : create test data (Order Summaries, Invoices, Corrective Invoices)
     */
    public static void setup() {
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
        System.debug('mapships'+ships);
        List<Invoice> invs = [SELECT id, InvoiceNumber__c, CurrencyIsoCode FROM Invoice WHERE ReferenceEntityId =: los[0].Id];
        listeInvoice = invs;
        System.debug('mapinvs'+invs);
        Map<Id, Invoice> mapinv = new Map<Id, Invoice>(invs);
        System.debug('mapinvsddd'+mapinv);
        Map<Id,CorrectiveInvoice__c> mapCorrectiveInvoice = SOM_testDataFactory.createCorrectiveInvoices(mapinv);
        mapCorrectiveInvoiceHandler = mapCorrectiveInvoice;
    }

     /**
     * @description testCreateInvoicePDFFileAction : Testing Scenario of Creating PDF Document in case of Invoice Object
     */
    @isTest(seeAllData = true)
    public static void testCreateInvoicePDFFileAction(){
        setup();
        Set<Id> invIds = (new Map<Id,Invoice>(listeInvoice)).keySet();
        List<Id> listInvoiceIds = new List<Id>(invIds);
        Test.startTest();
        SOM_CreateInvoicePDFFileAction.CreateInvoicePDFFileAction(listInvoiceIds);
        Test.stopTest();
        List<Attachment> attach = [select id from Attachment where ParentId  =: listeInvoice[0].Id ];
        System.assertEquals(1,attach.size());
    }

    /**
     * @description testCreateInvoicePDFFileAction : Testing Scenario of Creating PDF Document in case of CorrectiveInvoice Object
     */
    @isTest(seeAllData = true)
    public static void testCreateCorrectiveInvoicePDFFileAction(){
        setup();
        Set<Id> cIds = mapCorrectiveInvoiceHandler.keySet();
        List<Id> listCInvIds = new List<Id>(cIds);
        System.debug('cIds'+cIds);
        System.debug('listeInvoice'+listeInvoice[0].Id);
        Test.startTest();
        SOM_CreateInvoicePDFFileAction.CreateInvoicePDFFileAction(listCInvIds);
        Test.stopTest();
        List<Attachment> attach = [select id from Attachment where ParentId  =: listCInvIds[0]];
        System.assertEquals(1,attach.size());
    }

}