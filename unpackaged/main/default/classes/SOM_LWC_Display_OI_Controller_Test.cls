@isTest
public with sharing class SOM_LWC_Display_OI_Controller_Test {
    
    public static Id osID ;
    public static Id roID ;
    public static String pID ;
    public static String productId ;
    public static String pStockKeepingUnit ;
    public static String locationExternalReference ;
    //public static Id pricebookId ;
    
    @isTest(seeAllData=true)
    public static void makeData() {
        Id pricebookId = Test.getStandardPricebookId();
        //OrderSummary OS = SOM_testDataFactory.generateOrderSummary(); 
        
        Product2 product = SOM_testDataFactory.createProduct('produit 1', '10012002', 'sku1051684523156001',false);
        productId = SOM_testDataFactory.createProductTEST('produit 1', '10012002', 'sku1051684523156001',false);
        PricebookEntry PBEntry = SOM_testDataFactory.createPricebookEntryTEST(1000,productId, pricebookId);
        Schema.Location location1 = SOM_testDataFactory.createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        //PricebookEntry PBEntryId = [Select Product2Id from PricebookEntry where Product2Id =: product.Id limit 1 ];
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id,FulfillmentOrder> mapFO = new Map<Id,FulfillmentOrder>();
        mapFO.put(fo.Id,fo);
        Map<Id, Shipment> shipmentMap = SOM_testDataFactory.createShipments(mapFO);
        //ReturnOrder ro = SOM_testDataFactory.createReturnOrder(los[0]);
        ReturnOrder ro = SOM_testDataFactory.createReturnOrderEXCHANGEROI(los[0]);
        osID = los[0].Id;
        roID = ro.Id;
        //product.Id='01t1t088884HKfxAAS';
        //pID = PBEntryId.Product2Id;
        System.debug('>>>>>>>>>>>>>>>>>>>> productLine <<<<<<<<<<<<<<<<<<<<<<<<' + productId);
        pStockKeepingUnit = product.StockKeepingUnit;
        locationExternalReference = location1.ExternalReference;
        //List<SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryDataRequest> listLocationsBySku = new List<SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryDataRequest>();
        
    }
    @isTest(seeAllData=true)
    public static void getListLineItemsWithNoRO() {
        makeData();
        Test.startTest();
        
        String result = SOM_LWC_DisplayOrderItems_Controller.getListLineItems(osID,'',true);
        String result2 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems(osID,roID,true);
        String result3 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems(osID,roID,false);
        Test.stopTest();
        System.assertEquals(null,result);
    }
    
    @isTest(seeAllData=true)
    public static void getListLineItemsWithNotFromRO() {
        makeData();
        Test.startTest();
        String result = SOM_LWC_DisplayOrderItems_Controller.getListLineItems('',roID,false);
        String result1 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems('',roID,true);
        String result2 = SOM_LWC_DisplayOrderItems_Controller.getListLineItems('','',true);
        Test.stopTest(); 
        System.assertEquals(null,result);
    }
    
    @isTest(seeAllData=true)
    public static void getTotalLinesROTest() {
        makeData();
        Test.startTest();
        Decimal result = SOM_LWC_DisplayOrderItems_Controller.getTotalLinesRO(roID,true);
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
        SOM_LWC_DisplayOrderItems_Controller.getLocations('');
        Test.stopTest(); 
    }
    
    @isTest(seeAllData=true)
    public static void getSKUsDeliveryTest() { 
        makeData();
        Test.startTest();
        SOM_LWC_DisplayOrderItems_Controller.getSKUsDelivery();
        Test.stopTest(); 
    }
    
    @isTest(seeAllData=true)
    public static void getProductAtsTest() { 
        makeData();
    	List<SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryDataRequest> listLocationsBySku = new List<SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryDataRequest>();
        listLocationsBySku.add(
                    new SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryDataRequest(pStockKeepingUnit,
                    locationExternalReference
                    ));
        Test.startTest();
        SOM_LWC_DisplayOrderItems_Controller.getProductAts('');
        SOM_LWC_DisplayOrderItems_Controller.getProductAts(JSON.serialize(listLocationsBySku));
        Test.stopTest(); 
    }
    
    /*@isTest(seeAllData=true)
    public static void Wr_InventoryDataRequestTest() {
        makeData();
        Test.startTest();
        SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryDataRequest('Key1','Value1');
        Test.stopTest(); 
    }*/
    
    
    
    @isTest(seeAllData=true)
    public static void getProductDetailsTest() {
        makeData();
        String pricebookId = Test.getStandardPricebookId();
        Test.startTest();
        SOM_LWC_DisplayOrderItems_Controller.getProductDetails('{"sku":"sku1","ats":"0","description":null,"lineNumber":"1","location":"rimowa-inventory-ae","originalQuantity":"1","pbEntryId":"'+ pricebookId +'","productId":"'+ productId +'","quantity":"1","taxType":true,"unitPrice":"1000","taxValue":"10","taxRate":"10","lineTotal":"10","amountId":"sku1001","percentId":"null"}','AED',pricebookId);
        SOM_LWC_DisplayOrderItems_Controller.getProductDetails('','AED',pricebookId);
        SOM_LWC_DisplayOrderItems_Controller.getProductDetails('','','');
        SOM_LWC_DisplayOrderItems_Controller.getProductDetails('{"sku":"sku1","ats":"0","description":null,"lineNumber":"1","location":"rimowa-inventory-ae","originalQuantity":"1","pbEntryId":"'+ pricebookId +'","productId":"'+ productId +'","quantity":"1","taxType":true,"unitPrice":"1000","taxValue":"10","taxRate":"10","lineTotal":"10","amountId":"sku1001","percentId":"null"}','',pricebookId);
        SOM_LWC_DisplayOrderItems_Controller.getProductDetails('{"sku":"sku1","ats":"0","description":null,"lineNumber":"1","location":"rimowa-inventory-ae","originalQuantity":"1","pbEntryId":"'+ pricebookId +'","productId":"'+ productId +'","quantity":"1","taxType":true,"unitPrice":"1000","taxValue":"10","taxRate":"10","lineTotal":"10","amountId":"sku1001","percentId":"null"}','AED','');

        Test.stopTest(); 
    }
    
    @isTest(seeAllData=true)
    public static void Wr_InventoryRecordResponseTest(){
        String sku = 'Test SKU';
        Double ats = 10.0;
        String location = 'Test Location';
        SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryRecordResponse Wr_InventoryRecordResponseTest = new SOM_LWC_DisplayOrderItems_Controller.Wr_InventoryRecordResponse(sku, ats, location);
        System.assertEquals(sku, Wr_InventoryRecordResponseTest.sku);
        System.assertEquals(ats, Wr_InventoryRecordResponseTest.ats);
        System.assertEquals(location, Wr_InventoryRecordResponseTest.location);
        
    }
}
