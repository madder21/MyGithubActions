@isTest
public class somLwcProductChangesSelectionC_Test {
    
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
        osID = los[0].Id;
        
    }

    @isTest(seeAllData=true)
    public static void getCurrencyTest() {
        makeData();
        Test.startTest();
        String result = somLwcProductChangesSelection_Controller.getCurrency(osID);
        Test.stopTest(); 
    }
    
    @isTest(seeAllData=true)
    public static void getReturnReasonsTest() {
        makeData();
        Test.startTest();
        somLwcProductChangesSelection_Controller.getReturnReasons();
        Test.stopTest(); 
    }
    
}