@isTest
public with sharing class SOM_CreditMemoDocumentController_Test {
    public static Id creditMemoId;
    public static Boolean attachedToRO = false ;
    public static Boolean discount = false ;

    @isTest(seeAllData=true)
    public static void makeData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id,FulfillmentOrder> mapFO = new Map<Id,FulfillmentOrder>();
        mapFO.put(fo.Id,fo);
        Map<Id, Shipment> shipmentMap = SOM_testDataFactory.createShipments(mapFO);
        Refund refund = SOM_testDataFactory.createRefundWithCreditMemo(los[0] ,attachedToRO,discount);
        List<CreditMemo> creditmemo = [SELECT ID, ReturnOrder__c, Refund__r.RefundOrigin__c, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id, CurrencyIsoCode, Account.Name, OrderNumber, BillingCity, BillingPostalCode, BillingState, BillingContactFirstName__c, 
        BillingContactLastName__c, BillingCountry, BillingStreet END, CreditDate, CreditMemoNumber, DocumentNumber, TotalAmount, TotalAmountWithTax, TotalTaxAmount,
        (SELECT ID, Type, RelatedLineId, Product2.Description, AdjustmentAmountWithTax, AdjustmentAmount, AdjustmentTaxAmount, ChargeTaxAmount, ChargeAmount, ChargeAmountWithTax, ReturnOrderLineItem__c, ReturnOrderLineItem__r.QuantityReturned, ReturnOrderLineItem__r.SerialNumber__c,  
        TYPEOF ReferenceEntityItem WHEN OrderItemSummary THEN TaxRate__c, hsCode__c, hsCodeDescription__c, COO__c END FROM CreditMemoLines) FROM CreditMemo WHERE Refund__c = :refund.Id];
        List<CreditMemoLine> credMemoLines = [select Id , ReturnOrderLineItem__c , Type from CreditMemoLine where CreditMemoId =: creditmemo[0].Id];
        System.debug('++++cccc'+credMemoLines);
        creditMemoId = creditmemo[0].Id;
    }

    @isTest(seeAllData=true)
    public static void callConstructorAttachedToRO() {
        attachedToRO = true ;
        makeData();
        attachedToRO = false ;
        System.debug('debug2'+creditMemoId);
        ApexPages.currentPage().getParameters().put('template', 'CoreModel');
        ApexPages.currentPage().getParameters().put('creditMemoId',creditMemoId);
        SOM_CreditMemoDocumentController creditMedmoCtrl = new SOM_CreditMemoDocumentController();
    }

    @isTest(seeAllData=true)
    public static void callConstructorWithDiscount() {
        discount = true ;
        makeData();
        discount = false ;
        System.debug('debug2'+creditMemoId);
        ApexPages.currentPage().getParameters().put('template', 'CoreModel');
        ApexPages.currentPage().getParameters().put('creditMemoId',creditMemoId);
        SOM_CreditMemoDocumentController creditMedmoCtrl = new SOM_CreditMemoDocumentController();
    }
}