/**
 * @author Sarah AYOUN (Balink)
 * @date Mai,07 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_TestDateFactory :
 * each method of CLT_TestDateFactory has its own test method, this is only test factory class so the assert equals checks that the data was created as expected
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2024/05/07			|.Sarah A		|.						|.original version
*/
@isTest
private class CLT_TestDateFactory_Test {
    @isTest
    static void createTestUserWithLangCodeTest() {
        User u = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, 'fr', true);
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        List<User> uFactoryAfterInsert = [SELECT Id FROM User WHERE LanguageLocaleKey = 'fr' AND Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser];
        System.assertEquals(1, uFactoryAfterInsert.size(), 'user created with profile name and with lang code size is not 1');
    }

    @isTest
    static void createTestUserWithProfileTest() {
        User u = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        List<User> uFactoryAfterInsert = [SELECT Id FROM User WHERE LanguageLocaleKey = 'en_US' AND Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser];
        System.assertEquals(1, uFactoryAfterInsert.size(), 'user created with profile name and without lang code size is not 1');
    }

    @isTest
    static void createTestUserWithNoProfileTest() {
        User u = CLT_TestDateFactory.createTestUser();
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;

        List<User> uFactoryAfterInsert = [SELECT Id FROM User WHERE LanguageLocaleKey = 'en_US' AND Username LIKE :testUserEmailPostfix AND Profile.Name = 'System Administrator'];
        System.assertEquals(1, uFactoryAfterInsert.size(), 'user created without precised profile and no lang code size is not 1');
    }

    @isTest
    static void createTaskTest() {
        User u = CLT_TestDateFactory.createTestUser();
        Task t = CLT_TestDateFactory.createTask(u.Id, true);
        List<Task> tasksAfterFactoryInsert = [SELECT Id FROM Task WHERE OwnerId = :u.Id];
        System.assertEquals(1, tasksAfterFactoryInsert.size(), 'user assigned tasks list size is not 1');
    }

    @isTest
    static void createEventTest() {
        User u = CLT_TestDateFactory.createTestUser();
        Event e = CLT_TestDateFactory.createTestEvent(u.Id, true);
        List<Event> eventsAfterFactoryInsert = [SELECT Id FROM Event WHERE OwnerId = :u.Id];
        System.assertEquals(1, eventsAfterFactoryInsert.size(), 'user assigned events list size is not 1');
    }

    @isTest
    static void createTestStoreTest() {
        Store__c s = CLT_TestDateFactory.createTestStore('TST123', true);
        List<Store__c> storesAfterFactoryInsert = [SELECT Id FROM Store__c WHERE SourceStoreId__c = 'TST123'];
        System.assertEquals(1, storesAfterFactoryInsert.size(), 'store with TST123 code  list size is not 1');
    }

    @isTest
    static void createTestProductTest() {
        Catalog_Product__c p = CLT_TestDateFactory.createTestProduct('TST123', true);
        List<Catalog_Product__c> productsAfterFactoryInsert = [SELECT Id FROM Catalog_Product__c WHERE Product_SKU__c = 'TST123'];
        System.assertEquals(1, productsAfterFactoryInsert.size(), 'product with TST123 sku list size is not 1');
    }

    @isTest
    static void createTestProductTranslationTest() {
        Catalog_Product__c p = CLT_TestDateFactory.createTestProduct('TST123', true);
        Product_Translation__c pt = CLT_TestDateFactory.createTestProductTranslation(p.Id, true);
        List<Product_Translation__c> productTranslationsAfterFactoryInsert = [SELECT Id FROM Product_Translation__c WHERE Product_Catalog__c = :p.Id];
        System.assertEquals(1, productTranslationsAfterFactoryInsert.size(), 'product translations list size is not 1');
    }

    @isTest
    static void createTestClientTest() {
        Store__c s = CLT_TestDateFactory.createTestStore('TST123', true);
        User u = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);

        Account client = CLT_TestDateFactory.createTestClient('testfirstname', 'testlastname', u.Id, s.Id, true);
        List<Account> clientsAfterFactoryInsert = [SELECT Id FROM Account WHERE IsPersonAccount = true AND FirstName = 'testfirstname' AND LastName = 'testlastname' AND ClientAdvisor__pc = :u.Id AND MainStore__pc = :s.Id];
        System.assertEquals(1, clientsAfterFactoryInsert.size(), 'clients list size is not 1');
    }

    @isTest
    static void createTestCountryCodeTest() {
        CountryCode__c cc = CLT_TestDateFactory.createTestCountryCode('France', 'FR', 'FRA', true);

        List<CountryCode__c> countryCodesAfterFactoryInsert = [SELECT Id FROM CountryCode__c WHERE Name = 'France' AND Alpha_2_code__c = 'FR' AND Alpha_3_code__c = 'FRA'];
        System.assertEquals(1, countryCodesAfterFactoryInsert.size(), 'country codes list size is not 1');
    }

    @isTest
    static void createTestClientSourceTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        ClientSource__c cs = CLT_TestDateFactory.createTestClientSource(client.Id, '001', 'TST00123', true);

        List<ClientSource__c> clientSourcesAfterFactoryInsert = [SELECT Id FROM ClientSource__c WHERE Client__c = :client.Id AND Source__c = '001' AND SourceCode__c = 'TST00123'];
        System.assertEquals(1, clientSourcesAfterFactoryInsert.size(), 'country codes list size is not 1');
    }

    @isTest
    static void createTestWishlistTest() {
        Catalog_Product__c p = CLT_TestDateFactory.createTestProduct('TST123', true);
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        WishlistItem__c wishlist = CLT_TestDateFactory.createTestWishlist(p.Id, client.Id, true);

        List<WishlistItem__c> wishlistItemsAfterFactoryInsert = [SELECT Id FROM WishlistItem__c WHERE Client__c = :client.Id AND Product__c = :p.Id];
        System.assertEquals(1, wishlistItemsAfterFactoryInsert.size(), 'wishlist items list size is not 1');
    }

    @isTest
    static void createTestClientListTest() {
        CLT_TestDateFactory.createTestClientList('test client list', ' FirstName = \'Test\' ', true);

        List<ClientList__c> clientListsAfterFactoryInsert = [SELECT Id FROM ClientList__c WHERE Name = 'test client list'];
        System.assertEquals(1, clientListsAfterFactoryInsert.size(), 'clisnt lists list size is not 1');
    }

    @isTest
    static void createTestGiftTest() {
        String giftNameOption =  Gift__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
        Gift__c gift = CLT_TestDateFactory.createTestGift(giftNameOption, true);

        List<Gift__c> giftsAfterFactoryInsert = [SELECT Id FROM Gift__c WHERE Name__c = :giftNameOption];
        System.assertEquals(1, giftsAfterFactoryInsert.size(), 'gifts list size is not 1');
    }

    @isTest
    static void createTestClientelingEventTest() {
        String eventNameOption =  Event__c.Name__c.getDescribe().getPicklistValues()[0].getLabel();
        Event__c evnt = CLT_TestDateFactory.createTestClientelingEvent(eventNameOption, true);

        List<Event__c> eventsAfterFactoryInsert = [SELECT Id FROM Event__c WHERE Name__c = :eventNameOption];
        System.assertEquals(1, eventsAfterFactoryInsert.size(), 'events list size is not 1');
    }

    @isTest
    static void createTestPersonalClientListTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        ClientList__c cl = CLT_TestDateFactory.createTestPersonalClientList('Test Personal Client List', sa.Id, true);

        List<ClientList__c> clientListsAfterFactoryInsert = [SELECT Id FROM ClientList__c WHERE Name = 'Test Personal Client List' AND OwnerId = :sa.Id];
        System.assertEquals(1, clientListsAfterFactoryInsert.size(), 'client lists list size is not 1');
    }

    @isTest
    static void createTestPersonalClientListMemberTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

        Account client = CLT_TestDateFactory.createTestClient('Test client', 'Test Last Name', sa.Id, store.Id,  true);
        ClientList__c cl = CLT_TestDateFactory.createTestPersonalClientList('Test Personal Client List', sa.Id, true);
        CLT_TestDateFactory.createTestPersonalClientListMember(cl.Id, client.Id, true);

        List<ClientListMember__c> clientListsMembersAfterFactoryInsert = [SELECT Id FROM ClientListMember__c WHERE ClientList__c = :cl.Id];
        System.assertEquals(1, clientListsMembersAfterFactoryInsert.size(), 'client list Members list size is not 1');
    }

    @isTest
    static void createTestStandardProductTest() {
        Product2 p = CLT_TestDateFactory.createTestStandardProduct('TST123', true);

        List<Product2> standardProductsAfterFactoryInsert = [SELECT Id FROM Product2 WHERE StockKeepingUnit = 'TST123'];
        System.assertEquals(1, standardProductsAfterFactoryInsert.size(), 'products list size is not 1');
    }

    @isTest
    static void createTestTransactionTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        Transaction__c t = CLT_TestDateFactory.createTestTransaction(client.Id, Date.today(), true);

        List<Transaction__c> transactionsAfterFactoryInsert = [SELECT Id FROM Transaction__c WHERE TransactionDate__c = TODAY AND Client__c = :client.Id];
        System.assertEquals(1, transactionsAfterFactoryInsert.size(), 'transactions list size is not 1');
    }

    @isTest
    static void createTestTransactionItemTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        Transaction__c t = CLT_TestDateFactory.createTestTransaction(client.Id, Date.today(), true);
        Product2 product = CLT_TestDateFactory.createTestStandardProduct('TEST123', true);
        TransactionItem__c ti = CLT_TestDateFactory.createTestTransactionItem(t.Id, client.Id, product.Id, true);

        List<TransactionItem__c> transactionItemsAfterFactoryInsert = [SELECT Id FROM TransactionItem__c WHERE Transaction__c = :t.Id];
        System.assertEquals(1, transactionItemsAfterFactoryInsert.size(), 'transaction items list size is not 1');
    }

    @isTest
    static void createTestNewsTest() {
        CLT_TestDateFactory.createTestNews('https://www.rimowa.com/ww/en/stories/rimowa-x-gewa-introduction.html', 'RIMOWA × GEWA:THE ULTIMATE CASE FOR VIOLINS RIMOWA', true);

        List<News__c> newsAfterFactoryInsert = [SELECT Id FROM News__c WHERE Link__c = 'https://www.rimowa.com/ww/en/stories/rimowa-x-gewa-introduction.html'];
        System.assertEquals(1, newsAfterFactoryInsert.size(), 'news list size is not 1');
    }

    @isTest
    static void createTestNewsContentTest() {
        News__c n = CLT_TestDateFactory.createTestNews('https://www.rimowa.com/ww/en/stories/rimowa-x-gewa-introduction.html', 'RIMOWA × GEWA:THE ULTIMATE CASE FOR VIOLINS RIMOWA', true);
        CLT_TestDateFactory.createTestNewsContent(n.Id, 'fr', 'https://www.rimowa.com/fr/fr/stories/rimowa-x-gewa-introduction.html', 'RIMOWA × GEWA : LÉTUI POUR VIOLON IDÉAL', true);
        
        List<NewsContent__c> newsContentsAfterFactoryInsert = [SELECT Id FROM NewsContent__c WHERE News__c = :n.Id];
        System.assertEquals(1, newsContentsAfterFactoryInsert.size(), 'news contents list size is not 1');
    }

    @isTest
    static void createTestFeedbackTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        CLT_TestDateFactory.createTestFeedback(client.Id, true);

        List<due__Diduenjoy_Feedback__c> feedbacksAfterFactoryInsert = [SELECT Id FROM due__Diduenjoy_Feedback__c WHERE due__Account__c = :client.Id];
        System.assertEquals(1, feedbacksAfterFactoryInsert.size(), 'feedbacks list size is not 1');
    }

    @isTest
    static void createTestFeedbackAnswerTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        due__Diduenjoy_Feedback__c feedback = CLT_TestDateFactory.createTestFeedback(client.Id, true);
        CLT_TestDateFactory.createTestFeedbackAnswer(feedback.Id, 10, true);

        List<due__Diduenjoy_Answer__c> feedbackAnswersAfterFactoryInsert = [SELECT Id FROM due__Diduenjoy_Answer__c WHERE due__Diduenjoy_Feedback__c = :feedback.Id];
        System.assertEquals(1, feedbackAnswersAfterFactoryInsert.size(), 'feedback answers list size is not 1');
    }

    @isTest
    static void createTestNoteTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        CLT_TestDateFactory.createTestNote('test note', client.Id, true);

        List<Note__c> notesAfterFactoryInsert = [SELECT Id FROM Note__c WHERE Client__c = :client.Id];
        System.assertEquals(1, notesAfterFactoryInsert.size(), 'notes list size is not 1');
    }

    @isTest
    static void createTestClientAddressTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
        CLT_TestDateFactory.createTestClientAddress(client.Id, true);

        List<ClientAddress__c> clientAddressesAfterFactoryInsert = [SELECT Id FROM ClientAddress__c WHERE Client__c = :client.Id];
        System.assertEquals(1, clientAddressesAfterFactoryInsert.size(), 'clientAddresses list size is not 1');
    }

    @isTest
    static void createTestNotificationTest() {
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
         
        CLT_TestDateFactory.createTestNotification('TEST TYPE', sa.Id, DateTime.now(), true);

        List<Notification__c> notificationsAfterFactoryInsert = [SELECT Id FROM Notification__c WHERE User__c = :sa.Id];
        System.assertEquals(1, notificationsAfterFactoryInsert.size(), 'notifications list size is not 1');
    }

    @isTest
    static void createTestRClientConfigurationsTest() {
        CLT_TestDateFactory.createTestRClientConfigurations(true);
        System.assertNotEquals(null, RClientConfigurations__c.getOrgDefaults(), 'Client Configurations is null');
    }
}