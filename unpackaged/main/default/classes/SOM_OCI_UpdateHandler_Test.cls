@isTest
public with sharing class SOM_OCI_UpdateHandler_Test {

    @IsTest(seeAllData=true)
    public static void testUpdateOciOnHandQuantities(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,2);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        List<OrderItemSummary> ois = [SELECT Id, QuantityFulfilled, QuantityAvailableToReturn FROM OrderItemSummary WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('oissssssssss  ::::: ' + ois);

        ReturnOrder ro = SOM_testDataFactory.createReturnOrder(lOS[0]);
        ReturnOrderLineItem roli = [SELECT Id,OrderItemSummary.ReservedAtLocationId, OrderItemSummary.Product2.StockKeepingUnit, QuantityReturned, QuantityReceived, QuantityRejected, QuantityExpected,Description,ReasonForRejection
                                        FROM ReturnOrderLineItem 
                                        WHERE returnOrderId =: ro.Id LIMIT 1];

        Schema.Location loc = [SELECT Id, ExternalReference FROM Location WHERE Id =: roli.OrderItemSummary.ReservedAtLocationId LIMIT 1];

        Future_Stock__c futureStock                     = new Future_Stock__c();
        futureStock.SKU__c                              = '97375004';//roli.OrderItemSummary.Product2.StockKeepingUnit;
        futureStock.Quantity__c                         = 1000;                  
        futureStock.Location__c                         = roli.OrderItemSummary.ReservedAtLocationId;
        futureStock.Date_of_Release__c                  = DateTime.newInstance(2023, 11, 18, 3, 3, 3);
        insert futureStock;

        List<SOM_OCI_Wr_InputData> ociUpdateInputData = new List<SOM_OCI_Wr_InputData>();
        SOM_OCI_Wr_InputData ocidata = new SOM_OCI_Wr_InputData();
        List<SOM_OCI_ProductLine> ociProductLines = new List<SOM_OCI_ProductLine>();
        List<SOM_OCI_LocationAvailability> ociLocationAvailabilities = new List<SOM_OCI_LocationAvailability>();
        SOM_OCI_ProductLine ociProductLine = new SOM_OCI_ProductLine();
        SOM_OCI_LocationAvailability ociLocationAvailability = new SOM_OCI_LocationAvailability();

        ociProductLine.sku              = '97375004';//roli.OrderItemSummary.Product2.StockKeepingUnit;
        System.debug('roli.QuantityReturned ::::: ' + roli.QuantityReturned);
        
        System.debug('roli.QuantityReceived ::::: ' + roli.QuantityReceived);

        ociProductLine.onHandQuantity   = (Integer) roli.QuantityReceived;
        ociProductLine.locationId       = loc.ExternalReference;
        ociProductLines.add(ociProductLine);
        
        List<SOM_OCI_InventoryRecord> ociInventoryRecords = new List<SOM_OCI_InventoryRecord>();
        SOM_OCI_InventoryRecord ociInventoryRecord = new SOM_OCI_InventoryRecord();
        ociInventoryRecord.onHand           = 9946;
        ociInventoryRecord.sku              = '97375004';//roli.OrderItemSummary.Product2.StockKeepingUnit;
        ociInventoryRecord.effectiveDate    = DateTime.newInstance(2022, 9, 25, 3, 3, 3);
        ociInventoryRecord.safetyStockCount = 1000;
        ociInventoryRecords.add(ociInventoryRecord);

        System.debug('ociInventoryRecords :::::::::::: '+ociInventoryRecords);
        ociLocationAvailability.ociInventoryRecords = ociInventoryRecords;
        ociLocationAvailability.location            = loc.ExternalReference;
        ociLocationAvailabilities.add(ociLocationAvailability);
        System.debug('ociLocationAvailabilities :::::::::::: '+ociLocationAvailabilities);

        ocidata.ociProductLines = ociProductLines;
        ocidata.ociLocationAvailabilities = ociLocationAvailabilities;
        ocidata.returnOrderNumber = ro.ReturnOrderNumber;
        //ocidata.=submitOutpUt;
        ociUpdateInputData.add(ocidata);
        System.debug('ociUpdateInputData :::::::::::: '+ociUpdateInputData);


        Test.startTest();
        List<Boolean> res = SOM_OCI_UpdateHandler.updateOciOnHandQuantities(ociUpdateInputData);
        System.assertEquals(true,res[0]);
        Test.stopTest();
    }

}