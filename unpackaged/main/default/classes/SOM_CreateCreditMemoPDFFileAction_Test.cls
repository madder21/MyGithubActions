@IsTest
public with sharing class SOM_CreateCreditMemoPDFFileAction_Test {

    @isTest(seeAllData = true)
    public static void testCreateCreditMemoPDFFileAction(){

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
        Test.startTest();
        SOM_CreateCreditMemoPDFFileAction.CreateInvoicePDFFileAction(creditMemoIds);
        Test.stopTest();
        List<Attachment> attach = [select id from Attachment where ParentId  =: creditMemoIds[0] ];
        System.assertEquals(1,attach.size());
    }

}