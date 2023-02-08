@IsTest
public with sharing class SOM_RetryAllocation_Test {


    public static List<OrderSummary> makeData(){

        List<OrderSummary> osList = new List<OrderSummary>();
        List<ProcessException> pes = new List<ProcessException>();

        // HD
        List<OrderSummary> osHDList = new List<OrderSummary>();
        osHDList = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,6);
        List<OrderItemSummary> oisHDList = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId =: osHDList[0].Id AND Type =: 'Order Product'];
        ProcessException peToCreate = new ProcessException();
        peToCreate.Category         = 'Fulfillment';
        peToCreate.Status           = 'New';
        peToCreate.Severity         = 'High';
        peToCreate.Message          = 'Insufficient Stock';
        peToCreate.Priority         = 'High';
        peToCreate.AttachedToId     = oisHDList[0].Id;
        peToCreate.OrderSummaryId   = osHDList[0].Id;
        pes.add(peToCreate);
        osList.addAll(osHDList);

        //STW
        List<OrderSummary> osSTWList = new List<OrderSummary>();
        osSTWList = SOM_testDataFactory.createSTWOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,6);
        List<OrderItemSummary> oisSTWList = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId =: osSTWList[0].Id AND Type =: 'Order Product'];
        ProcessException peToCreate2 = new ProcessException();
        peToCreate2.Category         = 'Fulfillment';
        peToCreate2.Status           = 'New';
        peToCreate2.Severity         = 'High';
        peToCreate2.Message          = 'Insufficient Stock';
        peToCreate2.Priority         = 'High';
        peToCreate2.AttachedToId     = oisSTWList[0].Id;
        peToCreate2.OrderSummaryId   = osSTWList[0].Id;
        pes.add(peToCreate2);
        osList.addAll(osSTWList);

        insert pes;

        Set<Id> osIds = (new Map<Id,OrderSummary>(osList)).keySet();        
        SOM_testDataFactory.createFO(osList[1]);
        SOM_testDataFactory.createFO(osList[2]);
        SOM_testDataFactory.createFO(osList[3]);
        SOM_testDataFactory.createFO(osList[4]);
        SOM_testDataFactory.createFO(osList[5]);
        SOM_testDataFactory.createFO(osList[7]);
        SOM_testDataFactory.createFO(osList[8]);
        SOM_testDataFactory.createFO(osList[9]);
        SOM_testDataFactory.createFO(osList[10]);

        return osList;
    }

    public static ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation createInventAvailabilityRecords(){

        ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation inventRep = new ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation();
        List<ConnectApi.OCILocationAvailabilityOutputRepresentation> locs = new List<ConnectApi.OCILocationAvailabilityOutputRepresentation>();
        ConnectApi.OCILocationAvailabilityOutputRepresentation loc = new ConnectApi.OCILocationAvailabilityOutputRepresentation();
        
        List<ConnectApi.OCIInventoryRecordOutputRepresentation> inventRecs = new List<ConnectApi.OCIInventoryRecordOutputRepresentation>();
        ConnectApi.OCIInventoryRecordOutputRepresentation inventRec1 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        inventRec1.onHand = 1000;
        inventRec1.stockKeepingUnit = 'sku10001';

        ConnectApi.OCIInventoryRecordOutputRepresentation inventRec2 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        inventRec2.onHand = 0;
        inventRec2.stockKeepingUnit = 'sku10003';

        ConnectApi.OCIInventoryRecordOutputRepresentation inventRec3 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        inventRec1.onHand = 1000;
        inventRec1.stockKeepingUnit = 'sku10004';

        ConnectApi.OCIInventoryRecordOutputRepresentation inventRec4 = new ConnectApi.OCIInventoryRecordOutputRepresentation();
        inventRec1.onHand = 0;
        inventRec1.stockKeepingUnit = 'sku10006';

        inventRecs.add(inventRec1);
        inventRecs.add(inventRec2);
        inventRecs.add(inventRec3);
        inventRecs.add(inventRec4);

        loc.locationIdentifier = 'rimowa-inventory-ae';
        loc.inventoryRecords = inventRecs;

        locs.add(loc);

        inventRep.locations = locs;

        return inventRep;
    
    }


    @isTest (seeAllData= true)
    public static void testMethRetry() {

        List<String> osIds = new List<String>();
        List<OrderSummary> os = makeData();
        for(OrderSummary o : os ){
            osIds.add(o.Id);
        }

        List<OrderItemSummary> ois = [SELECT ID, ReservedAtLocationId, TYPEOF ReservedAtLocation WHEN Location THEN ExternalReference END, StockKeepingUnit, OrderSummary.SalesChannel.SalesChannelName, Quantity FROM OrderItemSummary WHERE orderSummaryId IN :osIds AND Type =: 'Order Product' AND Status =: 'Ordered' AND ( IsPreOrder__c =: false OR (IsPreOrder__c =: true AND DeliveryStartDate__c <=: system.now()))];
        System.debug('ois:::'+ ois);
        ConnectApi.OCIGetInventoryAvailabilityOutputRepresentation inventRep = createInventAvailabilityRecords();

        Test.startTest();
        SOM_Retry_Allocation.retryAlloc(ois, inventRep);
        Test.stopTest();

        System.assertEquals( SOM_Constants.ORDER_SUMMARY_VALIDATED, os[0].Status);
        System.assertEquals( SOM_Constants.ORDER_SUMMARY_VALIDATED, os[6].Status);


    }
}