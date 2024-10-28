@isTest
public with sharing class SOM_LWC_ExchangeOrderController_Test {
        public static Id osID ;
    	public static String OdmId ;
    
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
        OrderDeliveryMethod mId = SOM_testDataFactory.createOrderDeliveryMethod('standard_FN','standard_FN','Home Delivery');
        OdmId = mId.Id;
        osID = los[0].Id;
    }
    
    @isTest(seeAllData=true)
    public static void getOSDetailsTest() {
        makeData();
        Test.startTest();
        OrderSummary result = SOM_LWC_ExchangeOrderController.getOSDetails(osID);
        Test.stopTest();
        System.assertNotEquals(Null,result);
    }
    
        @isTest(seeAllData=true)
    public static void getOrderDelievryGroupDetailsTest() {
        makeData();
        Test.startTest();
        OrderDeliveryGroupSummary result = SOM_LWC_ExchangeOrderController.getOrderDelievryGroupDetails(osID);
        Test.stopTest();
        System.assertNotEquals(Null,result);
    }
    
    
    @isTest(seeAllData=true)
    public static void getOrderDelievryMethodsTest() {
        makeData();
        Test.startTest();
        List<OrderDeliveryMethod> result = SOM_LWC_ExchangeOrderController.getOrderDelievryMethods('AE');
        Test.stopTest();
        System.assertNotEquals(Null,result);
    }
    
    
    @isTest(seeAllData=true)
    public static void getOrderDelievryMethodNameTest() {
        makeData();
        Test.startTest();
        OrderDeliveryMethod result = SOM_LWC_ExchangeOrderController.getOrderDelievryMethodName(OdmId);
        Test.stopTest();
        System.assertNotEquals(Null,result);
    }
}
