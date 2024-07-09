@isTest
public with sharing class SOM_CreateShipment_Test {
    
    public static List<List<SOM_Wr_ShipmentShipmentItems>> listeShipmentItemsData = new List<List<SOM_Wr_ShipmentShipmentItems>>();
    public static Map<Id, Shipment> ShipmentRec = new Map<Id, Shipment>();
    public static List<OrderSummary> os = new List<OrderSummary>();
    public static boolean serialNumberNull = false;
    @isTest(seeAllData = true)
    public static void makeData() {
        SOM_Wr_ShipmentShipmentItems ship = new SOM_Wr_ShipmentShipmentItems();
        List<SOM_Wr_ShipmentShipmentItems> listeShipmentItems = new List<SOM_Wr_ShipmentShipmentItems>();
        os = SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(os[0]);
        Map<Id, FulfillmentOrder> listFulfillmentOrders = new Map<Id, FulfillmentOrder>();
        listFulfillmentOrders.put(fo.Id, fo);
        ShipmentRec = SOM_testDataFactory.createShipments(listFulfillmentOrders);
        ship.foId = fo.Id;
        ship.dispatchDate = System.now();
        ship.orderMethodId = fo.DeliveryMethodId;
        ship.shipmentExternalId = '1234567978523714';
        ship.trackingNumber = 'trc4531151456';
        ship.timezone = 'GB';
        List<FulfillmentOrderLineItem> listefoli = [SELECT Id , Quantity , Product2Id from fulfillmentorderlineitem where FulfillmentOrderId =: fo.Id];
        List<OrderItemSummary> listeosli = [SELECT Id from OrderItemSummary where OrderSummaryId =: os[0].Id];
        ship.quantity = (Integer) listefoli[0].Quantity;
        ship.foliId = listefoli[0].Id;
        ship.productId = listefoli[0].Product2Id;
        ship.osItemId = listeosli[0].Id;
        if(serialNumberNull == false) {
            ship.serialNumber = '12345677912375671';
        } else {
            ship.serialNumber = null;
        }
        listeShipmentItems.add(ship);
        listeShipmentItemsData.add(listeShipmentItems);
    }
 @isTest(seeAllData = true)
    public static void CreateShipmentAndShipmentItemsTest() {
        makeData();
        Test.startTest();
            SOM_CreateShipment.CreateShipmentAndShipmentItems(listeShipmentItemsData);
        Test.stopTest();
    }

    @isTest(seeAllData = true)
    public static void CreateShipmentAndShipmentItemsTestSerialNull() {
        serialNumberNull = true ;
        makeData();
        Test.startTest();
            SOM_CreateShipment.CreateShipmentAndShipmentItems(listeShipmentItemsData);
        Test.stopTest();
    }
}
