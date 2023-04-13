@isTest
public class SOM_LWC_Update_OnHands_Controller_Test {
    public static Id osID ;
    public static String Sku ;
    //public static SOM_LWC_Update_OnHands_Controller.Wr_PicklistValue request = new SOM_LWC_Update_OnHands_Controller.Wr_PicklistValue('','');
    
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
        osID = los[0].Id;
        Sku = product.StockKeepingUnit;
        
        //System.debug('**********createOrderDeliveryMethod*********' + mId );
    }
    
    @isTest(seeAllData=true)
    public static void getValidSkusTest() {
        makeData();
        Test.startTest();
        List<String> result = SOM_LWC_Update_OnHands_Controller.getValidSkus();
        Test.stopTest();
        System.assertNotEquals(Null,result);
    }
    
    @isTest(seeAllData=true)
    public static void getLocationsTest() {
        makeData();
        Test.startTest();
        list<SOM_LWC_Update_OnHands_Controller.Wr_PicklistValue> requestList = SOM_LWC_Update_OnHands_Controller.getLocations();
        Test.stopTest();
        System.assertNotEquals(Null,requestList);
    }
    
    @isTest(seeAllData=true)
    public static void getOnHandTest() {
        makeData();
        Test.startTest();
        list<SOM_LWC_Update_OnHands_Controller.Wr_PicklistValue> requestList = SOM_LWC_Update_OnHands_Controller.getLocations();
        String Value = requestList[0].value;
        SOM_LWC_Update_OnHands_Controller.getOnHand(Sku,Value);
        Test.stopTest();
        System.assertNotEquals(Null,SOM_LWC_Update_OnHands_Controller.getOnHand(Sku,Value));
    }
}