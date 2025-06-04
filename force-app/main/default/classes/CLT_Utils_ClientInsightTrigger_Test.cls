@isTest
private class CLT_Utils_ClientInsightTrigger_Test {
    @TestSetup
    static void prepareTestData(){
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, true);
    }

    @isTest
    static void testClientInsightTrigger_Insert() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1' LIMIT 1];

        System.runAs(sa) {
            Client_Insight__c ci = new Client_Insight__c(
                ExternalId__c = client.Id,
                Client__c = client.Id,
                FrequentTraveler__c = 'Yes',
                HistoricalClient__c = 'Yes',
                Collaboration__c = 'Yes'
            );
            Test.startTest();
            insert ci;
            Test.stopTest();
        }

        List<Client_Insight_History__c> ciHistoryList = [SELECT Id
                                                        FROM Client_Insight_History__c 
                                                        WHERE ClientInsight__r.ExternalId__c = :client.Id AND ModifiedBy__c = :sa.Id];

        System.assertEquals(3, ciHistoryList.size(), 'Client Isight histories list is not 3 when inserting with 3 fields filled');
    }

    @isTest
    static void testClientInsightTrigger_Update() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1' LIMIT 1];

        Client_Insight__c ci = new Client_Insight__c(
            ExternalId__c = client.Id,
            Client__c = client.Id,
            FrequentTraveler__c = 'Yes',
            HistoricalClient__c = 'Yes',
            Collaboration__c = 'Yes'
        );
        insert ci;

        System.runAs(sa) {
            ci.FrequentTraveler__c = 'No';
            ci.HistoricalClient__c = 'No';
            Test.startTest();
            update ci;
            Test.stopTest();
        }

        List<Client_Insight_History__c> ciHistoryList = [SELECT Id
                                                        FROM Client_Insight_History__c 
                                                        WHERE ClientInsight__r.ExternalId__c = :client.Id AND ModifiedBy__c = :sa.Id];

        System.assertEquals(2, ciHistoryList.size(), 'Client Isight histories list is not 2 when updating 2 fields values by the SA');
    }
}