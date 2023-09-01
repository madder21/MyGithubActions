@isTest
public class SOM_CreditMemoHelperTest {
    public static Id creditMemoId;
    public static Boolean attachedToRO = false ;
    public static Boolean discount = false ;
    public static List<CreditMemo> creditmemo = new List<CreditMemo>();
    
    @isTest(seeAllData=true)
    public static void makeData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id,FulfillmentOrder> mapFO = new Map<Id,FulfillmentOrder>();
        mapFO.put(fo.Id,fo);
        Map<Id, Shipment> shipmentMap = SOM_testDataFactory.createShipments(mapFO);
        Refund refund = SOM_testDataFactory.createRefundWithCreditMemo(los[0] ,attachedToRO,discount);
        creditmemo = [SELECT ID, ReturnOrder__c, Credit_Memo_Date__c, CreatedDate,Refund__r.RefundOrigin__c, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id, CurrencyIsoCode, Account.Name, OrderNumber, BillingCity, BillingPostalCode, BillingState, BillingContactFirstName__c, 
                      BillingContactLastName__c, BillingCountry, BillingStreet END, CreditDate, CreditMemoNumber, DocumentNumber, TotalAmount, TotalAmountWithTax, TotalTaxAmount,
                      (SELECT ID, Type, RelatedLineId, Product2.Description, AdjustmentAmountWithTax, AdjustmentAmount, AdjustmentTaxAmount, ChargeTaxAmount, ChargeAmount, ChargeAmountWithTax, ReturnOrderLineItem__c, ReturnOrderLineItem__r.QuantityReturned, ReturnOrderLineItem__r.SerialNumber__c,  
                       TYPEOF ReferenceEntityItem WHEN OrderItemSummary THEN TaxRate__c, hsCode__c, hsCodeDescription__c, COO__c END FROM CreditMemoLines) FROM CreditMemo WHERE Refund__c = :refund.Id];
        List<CreditMemoLine> credMemoLines = [select Id , ReturnOrderLineItem__c , Type from CreditMemoLine where CreditMemoId =: creditmemo[0].Id];
        creditMemoId = creditmemo[0].Id;
    }
    
    @isTest(seeAllData=true)
    public static void callConstructorAttachedToRO() {
        attachedToRO = true ;
        makeData();
        attachedToRO = false ;
        SOM_CreditMemoHelper.updateCreditMemoDate(creditmemo);        
        System.assertNotEquals(creditmemo[0].Credit_Memo_Date__c,null, 'Credit_Memo_Date__c Updated');
    }
    
    
    
}