@isTest
public class SOM_CreditMemoTriggerTest {
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
        creditmemo = [SELECT ID, Credit_Memo_Date__c, CreatedDate, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id END 
                       FROM CreditMemo WHERE Refund__c = :refund.Id];
        creditMemoId = creditmemo[0].Id;
    }
    
    @isTest(seeAllData=true)
    public static void callConstructorAttachedToRO() {
        makeData();
        SOM_CreditMemoHelper.updateCreditMemoDate(creditmemo);        
        System.assertNotEquals(creditmemo[0].Credit_Memo_Date__c,null, 'Credit_Memo_Date__c Updated');
    }
    
    
}