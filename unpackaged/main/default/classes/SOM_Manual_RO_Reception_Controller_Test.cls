@isTest
public class SOM_Manual_RO_Reception_Controller_Test {
    public static Id osID ;
    public static Id roID ;
    public static ReturnOrder ro ;
    public static String pID ; 
    public static String orIS ;
    public static list<String> PickValues = new list<String>{'Refund','Exchange','Reship'};
    public static list<String> ConditionValues = new list<String>{'Resalable','Used','Damaged'};

    
    @isTest(seeAllData=true)
    public static void makeData() {
        Id pricebookId = Test.getStandardPricebookId();
        Product2 product = SOM_testDataFactory.createProduct('produit 1', '10012002', 'sku10001',true);
        PricebookEntry PBEntry = SOM_testDataFactory.createPricebookEntry(1000,product.Id, pricebookId);
        Schema.Location location1 = SOM_testDataFactory.createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id,FulfillmentOrder> mapFO = new Map<Id,FulfillmentOrder>();
        mapFO.put(fo.Id,fo);
        Map<Id, Shipment> shipmentMap = SOM_testDataFactory.createShipments(mapFO);
        ro = SOM_testDataFactory.createReturnOrder(los[0]);
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
        String result1 = SOM_Manual_RO_Reception_Controller.getReturnOrderLineItems('');
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
   	
    @isTest(SeeAlldata=true) static void getFollowUpsValuesTest(){
        makeData();
        test.startTest();
        list<SOM_Manual_RO_Reception_Controller.Wr_PicklistValue> fieldResult = SOM_Manual_RO_Reception_Controller.getFollowUps();
        test.stopTest() ; 
        for(SOM_Manual_RO_Reception_Controller.Wr_PicklistValue pickvals : fieldResult ){
            System.assertEquals(PickValues.contains(pickvals.value), true);
        }
    }
     @isTest(SeeAlldata=true) static void getCondtionsTest(){
        makeData();
        test.startTest();
        list<SOM_Manual_RO_Reception_Controller.Wr_PicklistValue> fieldResult = SOM_Manual_RO_Reception_Controller.getCondtions();
        test.stopTest() ; 
        for(SOM_Manual_RO_Reception_Controller.Wr_PicklistValue ConditionVals : fieldResult ){
            System.assertEquals(ConditionValues.contains(ConditionVals.value), true);
        }
    }
    @isTest(SeeAlldata=true) static void getShipmentSerialNumbersEmptytest(){
         makeData();
        test.startTest();
        String ShipmentSerialNumbers = SOM_Manual_RO_Reception_Controller.getShipmentSerialNumbers('[]');
        test.stopTest() ; 
		system.assertEquals(null, ShipmentSerialNumbers, 'There is one or more ShipmentSerialNumbers');
    }
    
    @isTest(SeeAlldata=true) static void getShipmentSerialNumberstest(){
        makeData();
        String ois = '["'+orIS+'"]';
        test.startTest();
        String ShipmentSerialNumbers = SOM_Manual_RO_Reception_Controller.getShipmentSerialNumbers(ois);
        test.stopTest() ; 
		system.assertNotEquals(null, ShipmentSerialNumbers, 'There are no ShipmentSerialNumbers');
    }
    
    @isTest(SeeAlldata=true) static void getROLIEmptyConditionTest(){
        makeData();
        list<ReturnOrderLineItem> rolis = new list<ReturnOrderLineItem>();
        system.debug('RO : '+ro);
        for(ReturnOrderLineItem roli : [select Id,ConditionId__c,SerialNumber__c,RepaymentMethod,QuantityExpected,QuantityReceived from ReturnOrderLineItem where ReturnOrderId=:ro.Id]){
            roli.QuantityReceived =0;
            roli.RepaymentMethod=null ; 
            rolis.add(roli);
        }
        update rolis ;
        test.startTest();
        list<ReturnOrderLineItem> ROLineItem = (list<ReturnOrderLineItem>)JSON.deserialize(SOM_Manual_RO_Reception_Controller.getReturnOrderLineItems(ro.Id), list<ReturnOrderLineItem>.class) ;
        test.stopTest() ; 
        for(ReturnOrderLineItem roli :ROLineItem){
         	system.assertEquals(SOM_Constants.RETURN_LINE_ITEM_CONDITION_RESALABLE, roli.ConditionId__c, 'ROLI condition is not resalable');
			system.assertEquals('', roli.SerialNumber__c, 'ROLI has a SerialNumber');
			system.assertEquals('', roli.RepaymentMethod, 'ROLI has a RepaymentMethod');
        }
		

    }
    
    
}
