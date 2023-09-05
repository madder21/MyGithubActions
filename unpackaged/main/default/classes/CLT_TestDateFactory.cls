public class CLT_TestDateFactory {
    public static User createTestUser(String profileName, String langCode, Boolean toInsert) {
        String profileId = [SELECT Id FROM Profile WHERE name =: profileName].Id;
        String username = Datetime.now().getTime()+'clttestuser@rimowa.com';
        User u = new User(
            Username = username,
            LastName = 'test',
            FirstName = 'test',
            Email = username,
            Alias = 'TST',
            StoreCode__c = 'TST123',
            CommunityNickname = username.substring(0, username.indexOf('@')),
            TimeZoneSidKey = 'America/Los_Angeles', 
            LocaleSidKey = 'en_US',
            EmailEncodingKey='ISO-8859-1',
            ProfileId = profileId,
            LanguageLocaleKey = langCode,
            isActive=true
        );

        if(toInsert) {
            insert u;
        }

        return u;
    }

    public static User createTestUser(String profileName, Boolean toInsert) {
        return CLT_TestDateFactory.createTestUser(profileName, 'en_US', toInsert);  
    }

    public static User createTestUser() {
        return CLT_TestDateFactory.createTestUser('System Administrator', true);    
    }

    public static Task createTask(String ownerId, Boolean toInsert) {
        Task t = new Task(
            Subject = 'test Subject',
            OwnerId = ownerId,
            Priority = 'Normal',
            Status = 'Open'
        );

        if(toInsert) {
            insert t;
        }

        return t;
    }

    public static Event createTestEvent(String ownerId, Boolean toInsert) {
        Event e = new Event(
            Subject = 'test Subject',
            OwnerId = ownerId,
            StartDateTime = Datetime.now().addHours(24),
            EndDateTime = Datetime.now().addHours(25)
        );
        
        if(toInsert) {
            insert e;
        }

        return e;
    }

    public static Store__c createTestStore(String storeCode, Boolean toInsert) {
        Store__c s = new Store__c(
            SourceStoreId__c = storeCode,
            Name = 'test store'
        );

        if(toInsert) {
            insert s;
        }

        return s;
    }

    public static Catalog_Product__c createTestProduct(String sku, Boolean toInsert) {        
        Catalog_Product__c cp = new Catalog_Product__c(
            Product_SKU__c = sku,
            Name = 'test Product'
        );

        if(toInsert) {
            insert cp;
        }

        return cp;
    }

    public static Product_Translation__c createTestProductTranslation(String pcId, Boolean toInsert) {        
        Product_Translation__c pt = new Product_Translation__c(
            Product_Catalog__c = pcId,
            Language__c = 'fr',
            Long_Description__c = '<p>La première valise en polycarbonate au monde, conçue en Allemagne pour offrir le meilleur des fonctionnalités de pointe.</p>',
            Product_Color__c = 'Noir mat',
            Product_Name__c = 'Test nom de produit'
        );

        if(toInsert) {
            insert pt;
        }

        return pt;
    }

    public static Account createTestClient(String firstName, String lastName, String caId, String storeId, Boolean toInsert) {    
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();   
        Account client = new Account(
            FirstName = firstName,
            LastName = lastName,
            ClientAdvisor__pc = caId,
            MainStore__pc = storeId,
            RecordTypeId = personAccountRTId
        );

        if(toInsert) {
            insert client;
        }

        return client;
    }

    public static CountryCode__c createTestCountryCode(String name, String twoLetters, String threeLetters, Boolean toInsert) {
        CountryCode__c countryCode = new CountryCode__c(
            Name = name,
            Alpha_2_code__c = twoLetters,
            Alpha_3_code__c = threeLetters
        );

        if(toInsert) {
            insert countryCode;
        }

        return countryCode;
    }

    public static ClientSource__c createTestClientSource(String clientId, String source, String sourceCode, Boolean toInsert) {
        ClientSource__c clientSource = new ClientSource__c(
            Client__c = clientId,
            Source__c = source,
            SourceCode__c = sourceCode
        );

        if(toInsert) {
            insert clientSource;
        }

        return clientSource;
    }

    public static WishlistItem__c createTestWishlist(String productId, String clientId, Boolean toInsert) {
        WishlistItem__c wishlist = new WishlistItem__c (
            Product__c = productId,
            Client__c = clientId,
            TECH_uniqueKey__c = clientId + '-' + productId
        );

        if(toInsert) {
            insert wishlist;
        }

        return wishlist;
    }

    public static ClientList__c createTestClientList(String name, String query, Boolean toInsert) {
        ClientList__c clientList = new ClientList__c (
            Name = name,
            clientListQuery__c = query
        );

        if(toInsert) {
            insert clientList;
        }

        return clientList;
    }

    public static Gift__c createTestGift(String name,  Boolean toInsert) {
        Gift__c gift = new Gift__c (
            Name__c = name
        );

        if(toInsert) {
            insert gift;
        }

        return gift;
    }

    public static Event__c createTestClientelingEvent(String name,  Boolean toInsert) {
        Event__c event = new Event__c (
            Name__c = name
        );

        if(toInsert) {
            insert event;
        }

        return event;
    }

    public static ClientList__c createTestPersonalClientList(String name, String ownerId, Boolean toInsert) {
        ClientList__c clientList = new ClientList__c (
            Name = name,
            OwnerId = ownerId,
            Type__c = 'Personal'
        );

        if(toInsert) {
            insert clientList;
        }

        return clientList;
    }

    public static ClientListMember__c createTestPersonalClientListMember(String clientListId, String clientId, Boolean toInsert) {
        ClientListMember__c clientListMember = new ClientListMember__c (
            ClientList__c = clientListId,
            Client__c = clientId
        );

        if(toInsert) {
            insert clientListMember;
        }

        return clientListMember;
    }

    public static Product2 createTestStandardProduct(String sku, Boolean toInsert) {        
        Product2 p = new Product2(
            StockKeepingUnit = sku,
            Name = 'test Product',
            IsActive = true
        );

        if(toInsert) {
            insert p;
        }

        return p;
    }

    public static Transaction__c createTestTransaction(String clientId, Date transactionDate, Boolean toInsert) {        
        Transaction__c t = new Transaction__c(
            TransactionDate__c = transactionDate,
            Client__c = clientId
        );

        if(toInsert) {
            insert t;
        }

        return t;
    }

    public static TransactionItem__c createTestTransactionItem(String transactionId, String clientId, String productId, Boolean toInsert) {        
        TransactionItem__c ti = new TransactionItem__c(
            Transaction__c = transactionId,
            Client__c = clientId,
            Product__c = productId
        );

        if(toInsert) {
            insert ti;
        }

        return ti;
    }

    public static News__c createTestNews(String link, String text, Boolean toInsert) {
        News__c news = new News__c(
            Link__c = link,
            Text__c = text
        );

        if(toInsert) {
            insert news;
        }

        return news;
    }

    public static NewsContent__c createTestNewsContent(String newsId, String language, String link, String text, Boolean toInsert) {
        NewsContent__c newsContent = new NewsContent__c(
            News__c = newsId,
            Language__c = language,
            ContentLink__c = link,
            ContentText__c = text
        );

        if(toInsert) {
            insert newsContent;
        }

        return newsContent;
    }

    public static due__Diduenjoy_Feedback__c createTestFeedback(String clientId, Boolean toInsert) {
        due__Diduenjoy_Feedback__c feedback =  new due__Diduenjoy_Feedback__c(
            due__Account__c = clientId,
            Name = 'Post Purchase In Store - NPS',
            due__Comment__c = 'Service was great.',
            due__CreatedAt__c = DateTime.now().addDays(-10),
            due__Profile__c = 'promoter',
            due__Solved__c = true,
            due__Permalink__c = 'https://dashboard.diduenjoy.com/companies/chats?selectedFeedbackId=tst'
        );
        if(toInsert) {
            insert feedback;
        }

        return feedback;
    }

    public static due__Diduenjoy_Answer__c createTestFeedbackAnswer(String feedbackId, Integer score, Boolean toInsert) {
        due__Diduenjoy_Answer__c answer = new due__Diduenjoy_Answer__c(
            due__Diduenjoy_Feedback__c = feedbackId,
            due__Question__c = 'Would you recommend RIMOWA to your friends and family members?',
            due__Score__c = score,
            due__Position__c = 1
        );
        if(toInsert) {
            insert answer;
        }

        return answer;
    }

    public static Note__c createTestNote(String name, String clientId, Boolean toInsert) {
        Note__c note = new Note__c(
            Name = name,
            Body__c = name,
            Client__c = clientId
        );
        if(toInsert) {
            insert note;
        }

        return note;
    }
}