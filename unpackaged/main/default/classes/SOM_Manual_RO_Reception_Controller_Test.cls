@isTest
public class SOM_Manual_RO_Reception_Controller_Test {
    public static Id osID ;
    public static Id roID ;
    public static String pID ; 
    public static String orIS ;
    
    //public static Id pricebookId ;
    
    @isTest(seeAllData=true)
    public static void makeData() {
        Id pricebookId = Test.getStandardPricebookId();
        System.debug('**********pricebookId*********' + pricebookId);
        Product2 product = SOM_testDataFactory.createProduct('produit 1', '10012002', 'sku10001',true);
        PricebookEntry PBEntry = SOM_testDataFactory.createPricebookEntry(1000,product.Id, pricebookId);
        Schema.Location location1 = SOM_testDataFactory.createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id,FulfillmentOrder> mapFO = new Map<Id,FulfillmentOrder>();
        mapFO.put(fo.Id,fo);
        Map<Id, Shipment> shipmentMap = SOM_testDataFactory.createShipments(mapFO);
        ReturnOrder ro = SOM_testDataFactory.createReturnOrder(los[0]);
        List<OrderItemSummary> orderItemSummries = [SELECT Id, OrderSummaryId, ReservedAtLocationId, QuantityAvailableToReturn,
                                                        Type, Product2Id, Quantity,Status
                                                        FROM OrderItemSummary WHERE OrderSummaryId =: los[0].Id ];
        
        osID = los[0].Id;
        roID = ro.Id; 
        pID = product.Id;
        orIS = orderItemSummries[0].Id;
    }
    
    @isTest(seeAllData=true)
    public static void getReturnOrderLineItemsTest() {
        makeData();
        Test.startTest();
        String result = SOM_Manual_RO_Reception_Controller.getReturnOrderLineItems(roID);
        //String result1 = SOM_Manual_RO_Reception_Controller.getReturnOrderLineItems('');
        //String result2 = SOM_Manual_RO_Reception_Controller.getReturnOrderLineItems(roId2);
        Test.stopTest();
        System.assertNotEquals(Null,result);
    }
    
    @isTest(seeAllData=true)
    public static void getFollowUpsTest() {
        makeData();
        Test.startTest();
        SOM_Manual_RO_Reception_Controller.getFollowUps();
        SOM_Manual_RO_Reception_Controller.getCondtions();
        Test.stopTest();
        System.assertNotEquals(Null,SOM_Manual_RO_Reception_Controller.getFollowUps());
        System.assertNotEquals(Null,SOM_Manual_RO_Reception_Controller.getCondtions());
        
    }
    
      /* @isTest(seeAllData=true) 
    public static void getShipmentSerialNumbersTest() {
        makeData();
        Test.startTest();
        //SOM_Manual_RO_Reception_Controller.getShipmentSerialNumbers('[{ "Id" : "'+orIS+'""}]');
        Test.stopTest();
        //System.assertNotEquals(Null,SOM_Manual_RO_Reception_Controller.getShipmentSerialNumbers('[{ "Id" : "'+orIS+'""}]'));
    }*/
    
}
