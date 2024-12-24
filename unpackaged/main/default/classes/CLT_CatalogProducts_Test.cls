@IsTest
private class CLT_CatalogProducts_Test {

    @TestSetup
	static void prepareTestData(){
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        sa.Email_templates__c = 'FR';
        sa.LanguageLocaleKey = 'fr';
        insert sa;

		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        List<Catalog_Product__c> products = new List<Catalog_Product__c>();
        Catalog_Product__c product = CLT_TestDateFactory.createTestProduct('testSKU1', true);
        CLT_TestDateFactory.createTestProductTranslation(product.Id, true);
        Test.setCreatedDate(product.Id, Date.today().addDays(-3));
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
	}

	@isTest 
    static void test_CatalogProducts_GET() {
        CLT_CatalogProducts catalog = new  CLT_CatalogProducts();

        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Catalog_Product__c product = [SELECT Id FROM Catalog_Product__c WHERE Product_SKU__c = 'testSKU1' LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];
        System.runAs(sa) {
            WishlistItem__c wishlist = CLT_TestDateFactory.createTestWishlist(product.Id, client.Id, true);
            Test.startTest();

            Object newVersionNoParamsGetResponse = catalog.retrieveGet(new Map<String, String>{'isNewVersion' => 'true'});
            Object catalogProductsResponse = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(newVersionNoParamsGetResponse))).get('catalogProducts');
            String getProductId = (String)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)JSON.deserializeUntyped(JSON.serialize(catalogProductsResponse)))[0]))).get('id');
            System.assertEquals(product.Id, getProductId, 'product id is different than the inserted product');

            Object v2NoParamsGetResponse = catalog.retrieveGet(new Map<String, String>{'versionNum' => '2'});
            Object productTranslationsResponse = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(v2NoParamsGetResponse))).get('productTranslations');
            System.assertEquals(1, ((List<Object>)JSON.deserializeUntyped(JSON.serialize(productTranslationsResponse))).size(), 'translations list size is different than 1');

            Object waitedProductGetResponse = catalog.retrieveGet(new Map<String, String>{'listType' => 'waitedProduct'});
            Integer myTimesAdded = (Integer)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)JSON.deserializeUntyped(JSON.serialize(waitedProductGetResponse)))[0]))).get('myTimesAdded');
            System.assertEquals(1, myTimesAdded, 'product not added once to wishlist by me');
           
            Object waitingClientsGetResponse = catalog.retrieveGet(new Map<String, String>{'listType' => 'waitingClients'}); 
            String myWaitingClientId = (String)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)JSON.deserializeUntyped(JSON.serialize(waitingClientsGetResponse)))[0]))).get('clientId');
            System.assertEquals(client.Id, myWaitingClientId, 'my client is not the waiting client');

            Object getTranslationResponse = catalog.retrieveGet(new Map<String, String>{'listType' => 'productTranslation'}); 
            System.assertEquals(1, ((List<Object>)JSON.deserializeUntyped(JSON.serialize(getTranslationResponse))).size(), 'translations list size is different than 1');

            Object productGetResponse = catalog.retrieveGet(new Map<String, String>{'productId' => product.id}); 
            Integer myProductAddedTime = (Integer)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)JSON.deserializeUntyped(JSON.serialize(waitedProductGetResponse)))[0]))).get('myTimesAdded');
            System.assertEquals(1, myProductAddedTime, 'my product not added once to wishlist by me');
            
                   
            catalog.retrieveDelete(new Map<String, String>());
            catalog.retrievePost(new Map<String, String>(),new Map<String,Object>());

            Test.stopTest();
        }
    }

    @isTest
    static void test_CatalogProducts_GET_Delta() {
        Catalog_Product__c product = CLT_TestDateFactory.createTestProduct('testSKU2', true);

        CLT_CatalogProducts catalog = new  CLT_CatalogProducts();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Object deltaGetResponse = catalog.retrieveGet(new Map<String, String>{'daysDelta' => '1'});

            Object catalogProductsDeltaResponse = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(deltaGetResponse))).get('catalogProducts');
            System.assertEquals(1, ((List<Object>)JSON.deserializeUntyped(JSON.serialize(catalogProductsDeltaResponse))).size(), 'Catalog Product Delta list size is different than 1');
        }
    }

    @isTest 
    static void test_CatalogProducts_POST() {
        CLT_CatalogProducts catalog = new  CLT_CatalogProducts();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object productPostResponse = catalog.retrievePost(new Map<String, String>(),new Map<String,Object>());
            System.assertEquals(null, productPostResponse, 'Post method defined and not tested');

            Test.stopTest();
        }
    }

    @isTest static void test_CatalogProducts_DELETE() {
        CLT_CatalogProducts catalog = new  CLT_CatalogProducts();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest(); 
            
            Object productDeleteResponse = catalog.retrieveDelete(new Map<String, String>());
            System.assertEquals(null, productDeleteResponse, 'Delete method defined and not tested');

            Test.stopTest();
        }
    }
}