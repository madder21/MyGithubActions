/**
 * @author (Balink)
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_Homepage :
 * testSetup : Creation of test user and store
 * TEST METHOD				        		    |	DESCRIPTION
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	    |Related Jira Ticket	|Description of changes			
*/
@isTest
private class CLT_Homepage_Test {
    @TestSetup
    static void homepageDataFactory(){
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        sa.LanguageLocaleKey = 'fr';
        insert sa;

		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);

		List<Account> clients = new List<Account>();

        Account client1 = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, false);
        client1.Last_Transaction_SA__pc = sa.Id;
		client1.LifeTimePurchaseAmount__pc = 2500;
		client1.LightCurrentCluster__pc = 'VIC';
        client1.ClientType__pc = 'Client';
		clients.add(client1);

        Account client2 = CLT_TestDateFactory.createTestClient('Test client 2', 'Test Last Name2', sa.Id, store.Id, false);
        client2.Last_Transaction_SA__pc = sa.Id;
		client2.LifeTimePurchaseAmount__pc = 1200;
		client2.LightCurrentCluster__pc = 'Inactive Client';
        client1.ClientType__pc = 'Client';
		clients.add(client2);

		Account client3 = CLT_TestDateFactory.createTestClient('Test client 3', 'Test Last Name3', sa.Id, store.Id, false);
        client3.Last_Transaction_SA__pc = sa.Id;
		client3.LifeTimePurchaseAmount__pc = 0;
		client2.LightCurrentCluster__pc = 'Prospect';
		client3.ClientType__pc = 'PROSPECT_T';
		clients.add(client3);

		insert clients;
    }

    @isTest 
    static void test_Homepage_Delete() {
        CLT_Homepage homepage = new  CLT_Homepage();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object homepageDeleteResponse = homepage.retrieveDelete(new Map<String, String>());
            System.assertEquals(null, homepageDeleteResponse, 'Delete method defined and not tested');

            Test.stopTest();
        }
    }

    @isTest 
    static void test_Homepage_Post() {
        CLT_Homepage homepage = new  CLT_Homepage();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object homepagePostResponse = homepage.retrievePost(new Map<String, String>(), new Map<String,Object>());
            System.assertEquals(null, homepagePostResponse, 'Post method defined and not tested');

            Test.stopTest();
        }
    }

    @isTest 
    static void test_Homepage_Get() {
        CLT_Homepage homepage = new  CLT_Homepage();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            
            Object homepageGetResponse = homepage.retrieveGet(new Map<String, String>());
            Object homepagePortfolioResponse = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepageGetResponse))).get('portfolioInfo');
            Integer getProspectCount = (Integer)((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepagePortfolioResponse))).get('prospect');
            List<Account> prospectList = [SELECT Id FROM Account WHERE ClientAdvisor__pc = :sa.Id AND LightCurrentCluster__pc = 'Prospect'];
            System.assertEquals(prospectList.size(), getProspectCount, 'prospect count is not 1');

            Test.stopTest();
        }
    }

    @isTest 
    static void test_Homepage_Get_NewsContentTranslation() {
        News__c news = CLT_TestDateFactory.createTestNews('https://www.rimowa.com/ww/en/stories/rimowa-x-gewa-introduction.html', 'RIMOWA × GEWA:THE ULTIMATE CASE FOR VIOLINS RIMOWA', true);
        NewsContent__c newsContent = CLT_TestDateFactory.createTestNewsContent(news.Id, 'fr', 'https://www.rimowa.com/fr/fr/stories/rimowa-x-gewa-introduction.html', 'RIMOWA × GEWA : LÉTUI POUR VIOLON IDÉAL', true);
        
        CLT_Homepage homepage = new  CLT_Homepage();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        System.runAs(sa) {
            Test.startTest();
            
            Object homepageGetResponse = homepage.retrieveGet(new Map<String, String>());
            Object homepageNewsInfoResponse = ((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepageGetResponse))).get('newsInfo');
            List<Object> homepageNewsResponse = (List<Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepageNewsInfoResponse))).get('news')));
            Map<String, Object> wrappedNews = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepageNewsResponse[0]));
            System.assertEquals('https://www.rimowa.com/fr/fr/stories/rimowa-x-gewa-introduction.html', (String)wrappedNews.get('link'), 'New Content link is not french link');

            Test.stopTest();
        }
    }

    @isTest
    static void test_Homepage_Get_ComboChallenge() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = 'TST123' LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE ClientAdvisor__pc = :sa.Id LIMIT 1];

        Transaction__c transction = CLT_TestDateFactory.createTestTransaction(client.Id, Date.today().addDays(-7), false);
        transction.Store__c = store.Id;
        insert transction;

        Product2 product = CLT_TestDateFactory.createTestStandardProduct('TEST123', true);

        TransactionItem__c transactionItem = CLT_TestDateFactory.createTestTransactionItem(transction.Id, client.Id, product.Id, false);
        transactionItem.Sales_Advisor__c = sa.Id;
        insert transactionItem;

        client.Last_Transaction_SA__pc = sa.Id;
        client.LastPurchaseDate__pc = Date.today().addDays(-7);
        update client;

        List<Task> tasks = new List<Task>();

        Task outreach = CLT_TestDateFactory.createTask(sa.Id, false);
        outreach.WhatId = client.Id;
        outreach.ActivityDate = Date.today().addDays(-6);
        outreach.Outreach_Type__c = 'SMS';
        tasks.add(outreach);

        Task task = CLT_TestDateFactory.createTask(sa.Id, false);
        task.WhatId = client.Id;
        task.ActivityDate = Date.today().addDays(-5);
        tasks.add(task);

        insert tasks;        

        CLT_Homepage homepage = new  CLT_Homepage();

        System.runAs(sa) {
            Note__c note = CLT_TestDateFactory.createTestNote('Wanted the lightest luggage possible', client.Id, true);
            Test.setCreatedDate(note.Id, Date.today().addDays(-3));
            Test.startTest();
            
            Object homepageGetResponse = homepage.retrieveGet(new Map<String, String>());
            List<Object> homepageComboResponse = (List<Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepageGetResponse))).get('comboChallenge')));
            System.assertEquals(1, homepageComboResponse.size(), 'Combo Challenge list size is not 1');

            Test.stopTest();
        }
    }

    @isTest
    static void test_Homepage_Get_ComboChallengeV2() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
		Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = 'TST123' LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE ClientAdvisor__pc = :sa.Id LIMIT 1];

        Transaction__c transction = CLT_TestDateFactory.createTestTransaction(client.Id, Date.today().addDays(-7), false);
        transction.Store__c = store.Id;
        insert transction;

        Product2 product = CLT_TestDateFactory.createTestStandardProduct('TEST123', true);

        TransactionItem__c transactionItem = CLT_TestDateFactory.createTestTransactionItem(transction.Id, client.Id, product.Id, false);
        transactionItem.Sales_Advisor__c = sa.Id;
        transactionItem.Type__c = 'Sale';
        transactionItem.ExclTaxAmount__c = 100.00;
        insert transactionItem;

        client.Last_Transaction_SA__pc = sa.Id;
        client.LastPurchaseDate__pc = Date.today().addDays(-7);
        update client;

        List<Task> tasks = new List<Task>();

        Task outreach = CLT_TestDateFactory.createTask(sa.Id, false);
        outreach.WhatId = client.Id;
        outreach.ActivityDate = Date.today().addDays(-6);
        outreach.Outreach_Type__c = 'SMS';
        tasks.add(outreach);

        Task task = CLT_TestDateFactory.createTask(sa.Id, false);
        task.WhatId = client.Id;
        task.ActivityDate = Date.today().addDays(-5);
        tasks.add(task);

        insert tasks;        

        CLT_Homepage homepage = new  CLT_Homepage();

        System.runAs(sa) {
            Note__c note = CLT_TestDateFactory.createTestNote('Wanted the lightest luggage possible', client.Id, true);
            Client_Insight__c ci = new Client_Insight__c(
                ExternalId__c = client.Id,
                Client__c = client.Id,
                FrequentTraveler__c = 'Yes',
                HistoricalClient__c = 'Yes',
                Collaboration__c = 'Yes',
                Hobbies__c = 'Art'
            );
            insert ci;
            Test.setCreatedDate(note.Id, Date.today().addDays(-3));
            Test.startTest();
            
            Object homepageGetResponse = homepage.retrieveGet(new Map<String, String>{'versionNum' => '2.13'});
            List<Object> homepageComboResponse = (List<Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepageGetResponse))).get('comboChallenge')));
            Boolean noteV2 = (Boolean)(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(homepageComboResponse[0]))).get('noteId'));
            System.assertEquals(true, noteV2, 'note is not true even when 4 insights + note');

            Test.stopTest();
        }
    }

    @isTest 
    static void test_Homepage_Get_Feedbacks() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE Last_Transaction_SA__pc = :sa.Id LIMIT 1];
        due__Diduenjoy_Feedback__c feedback = CLT_TestDateFactory.createTestFeedback(client.Id, true);
        due__Diduenjoy_Answer__c answer = CLT_TestDateFactory.createTestFeedbackAnswer(feedback.Id, 10, true);
        
        CLT_Homepage homepage = new  CLT_Homepage();

        System.runAs(sa) {
            Test.startTest();
            
            Object homepageGetResponse = homepage.retrieveGet(new Map<String, String>());
            List<Object> homepageFeedbackResponse = (List<Object>)JSON.deserializeUntyped(JSON.serialize(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(homepageGetResponse))).get('feedbacks')));
            System.assertEquals(1, homepageFeedbackResponse.size(), 'Feedback list size is not 1');

            Test.stopTest();
        }
    }
}