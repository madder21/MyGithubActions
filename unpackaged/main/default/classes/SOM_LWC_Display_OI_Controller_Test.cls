@isTest
public with sharing class SOM_LWC_Display_OI_Controller_Test {
    
    public static Id osID ;
    public static Id roID ;
    public static String pID ;
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
        osID = los[0].Id;
        roID = ro.Id;
        pID = product.Id;
    }
    @isTest(seeAllData=true)
    public static void getListLineItemsWithNoRO() {
        makeData();
        Test.startTest();
        
        String result = SOM_LWC_DisplayOrderItems_Controller.getListLineItems(osID,'',true);
        //String result2 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems('',roID,false);
        //String result3 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems(osID,'',false);
        //String result4 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems('',roID,true);
        Test.stopTest();
        System.assertEquals(null,result);
    }
    
    @isTest(seeAllData=true)
    public static void getListLineItemsWithNotFromRO() {
        makeData();
        Test.startTest();
        String result = SOM_LWC_DisplayOrderItems_Controller.getListLineItems('',roID,false);
        String result1 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems('',roID,true);
        Test.stopTest(); 
        System.assertEquals(null,result);
    }
    
    @isTest(seeAllData=true)
    public static void getTotalLinesROTest() {
        makeData();
        Test.startTest();
        Decimal result = SOM_LWC_DisplayOrderItems_Controller.getTotalLinesRO(roID,true);
        System.debug('*getTotalLinesRO ' + result);
        Test.stopTest(); 
    }
    
    @isTest(seeAllData=true)
    public static void getCurrencyTest() {
        makeData();
        Test.startTest();
        String result = SOM_LWC_DisplayOrderItems_Controller.getCurrency(osID);
        Test.stopTest(); 
    }
    
    @isTest(seeAllData=true)
    public static void getLocationsTest() {
        makeData();
        Test.startTest();
        SOM_LWC_DisplayOrderItems_Controller.getLocations('AE');
        //SOM_LWC_DisplayOrderItems_Controller.getLocations('FR');
        //SOM_LWC_DisplayOrderItems_Controller.getLocations('');
        Test.stopTest(); 
    }
    
    @isTest(seeAllData=true)
    public static void getProductDetailsTest() {
        makeData();
        String pricebookId = Test.getStandardPricebookId();
        Test.startTest();
        SOM_LWC_DisplayOrderItems_Controller.getProductDetails('{"sku":"sku1","ats":"0","description":null,"lineNumber":"1","location":"rimowa-inventory-ae","originalQuantity":"1","pbEntryId":"'+ pricebookId +'","productId":"'+ pID +'","quantity":"1","taxType":true,"unitPrice":"1000","taxValue":"10","taxRate":"10","lineTotal":"10","amountId":"sku1001","percentId":null}','EUR',pricebookId);
        Test.stopTest(); 
    }
    
}