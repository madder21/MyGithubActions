/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 29-08-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@IsTest(SeeAllData=false)
public class ProductManagementUTL_TST {
    
    @isTest
    static void testUpsertProduct() {
        
        // Create a test Product2 record
        Product2 testProduct = new Product2(
            Name = 'Test Product',
            StockKeepingUnit = 'TEST-SKU'
        );
        Test.startTest();
        String resultId = ProductManagementUTL.upsertProduct(testProduct);

        Product2 upsertedProduct = [SELECT Id, Name, StockKeepingUnit FROM Product2 WHERE Id = :resultId LIMIT 1];
        System.assertNotEquals(null, upsertedProduct, 'Upserted product should not be null');
        System.assertEquals('Test Product', upsertedProduct.Name, 'Name should match');
        System.assertEquals('TEST-SKU', upsertedProduct.StockKeepingUnit, 'SKU should match');

        testProduct.Name = 'Updated Test Product';
        String updatedResultId = ProductManagementUTL.upsertProduct(testProduct);
        Test.stopTest();
        System.assertEquals(resultId, updatedResultId, 'Record should be updated, not inserted');
        Product2 updatedProduct = [SELECT Id, Name FROM Product2 WHERE Id = :resultId LIMIT 1];
        System.assertEquals('Updated Test Product', updatedProduct.Name, 'Name should be updated');
    }

}