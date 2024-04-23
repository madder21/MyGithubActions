@isTest
public class SOM_DynamicTreeGridControllerTEST {
    
    public static Id storeOriginID ;
    public static Id CountryID ;
    public static Id postalCodeID ;
    public static Id odmID ;
    
    @isTest
    public static void makeData() {
        
        List<PricebookEntry> priceEntries = new List<PricebookEntry>();
        Product2 prd0 = SOM_testDataFactory.createProduct('Standard delivery', 'ProductCode1','sku10002',true);
        insert prd0;
        PricebookEntry entry0 = SOM_testDataFactory.createPricebookEntry(0, prd0.Id, Test.getStandardPricebookId());
        insert entry0;
        OrderDeliveryMethod odm = SOM_testDataFactory.createOrderDeliveryMethod('standard_GB', prd0.Id, 'standard_GB');
        insert odm;
        odmID = odm.Id;
        STWNurembergDeliveryMethod__c storeOrigin = SOM_testDataFactory.createStoreOrigin('StoreOrigin');
        storeOriginID = storeOrigin.Id;
        STWNurembergDeliveryMethod__c Country 	  = SOM_testDataFactory.createStwCountry('AE',storeOriginID ); 
        System.debug('Country' + Country);
        CountryID = Country.Id;
        STWNurembergDeliveryMethod__c postalCode  = SOM_testDataFactory.createStwPostalCode('AE',odm.id,storeOriginID );   
        postalCodeID = postalCode.Id;
    }
    
    
    @isTest
    public static void getAllParentCasesTest() {
        makeData();
        Test.startTest();
        List<STWNurembergDeliveryMethod__c> stwList = SOM_DynamicTreeGridController.getAllParentCases();
        System.assertNotEquals(stwList, null, 'STWNurembergDeliveryMethod Generated');
        Test.stopTest(); 
    }
    
    @isTest
    public static void getChildCasesTest() {
        Test.startTest();
        makeData();
        List<STWNurembergDeliveryMethod__c> stwList = SOM_DynamicTreeGridController.getChildCases(storeOriginID);
        System.assertNotEquals(stwList, null, 'STWNurembergDeliveryMethod Generated');
        Test.stopTest(); 
    }
    
    @isTest
    public static void delSTWTest() {
        Test.startTest();
        makeData();
        SOM_DynamicTreeGridController.delSTW(storeOriginID);
        List<STWNurembergDeliveryMethod__c> stwListDeleted = [Select id from  STWNurembergDeliveryMethod__c where id=: storeOriginID ];
        System.assertEquals(stwListDeleted.size(), 0, 'STWNurembergDeliveryMethod Deleted');
        Test.stopTest(); 
    }
    
    @isTest
    public static void getCreateRecordLevelTest() {
        Test.startTest();
        makeData();
        String Level2 = SOM_DynamicTreeGridController.getCreateRecordLevel(CountryID);
        String Level3 = SOM_DynamicTreeGridController.getCreateRecordLevel(postalCodeID);
        System.assertEquals(Level2, 'L2' );
        System.assertEquals(Level3, 'L0' );
        Test.stopTest();  
    }
    
    @isTest
    public static void getOrderDeliveryMethodTest() {
        Test.startTest(); 
        makeData();
        List<SOM_DynamicTreeGridController.Wr_PicklistValue> listOrderDeliveryMethod = new List<SOM_DynamicTreeGridController.Wr_PicklistValue>();
        listOrderDeliveryMethod = SOM_DynamicTreeGridController.getOrderDeliveryMethod(postalCodeID);
        System.assertNotEquals(listOrderDeliveryMethod, null );
        Test.stopTest(); 
    }
    
    @isTest
    public static void createSTWTest() {
        Test.startTest(); 
        makeData(); 
        String recordToCreate1 = '{"storeOrigin":"OKK"}';
        String recordToCreate2 = '{"recordID":"'+storeOriginID+'","country":"AE"}';
        String recordToCreate3 = '{"recordID":"'+CountryID+'","postalCode":"10022","deliveryMethod":"'+odmID+'"}';
        SOM_DynamicTreeGridController.createSTW(recordToCreate1);
        SOM_DynamicTreeGridController.createSTW(recordToCreate2);
        SOM_DynamicTreeGridController.createSTW(recordToCreate3);
        List<STWNurembergDeliveryMethod__c> recordToCreated = [Select id from  STWNurembergDeliveryMethod__c ];
        System.assertNotEquals(recordToCreated.size(), 0 );
        Test.stopTest(); 
    }

    
}