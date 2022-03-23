@isTest
private class Batch_UpdateLastStoreAndSA_Test {
    // @isTest
    // static void test_batch_updateLastStoreAndSA() {
    //     List<Account> clients = new List<Account>();

    //     Account c1 = new Account(FirstName = 'Client', LastName = 'Test1',LightCurrentCluster__pc = 'VIC_L');
    //     clients.add(c1);

    //     Account c2 = new Account(FirstName = 'Client', LastName = 'Test2',LightCurrentCluster__pc = 'VIC_L');
    //     clients.add(c2);

    //     insert clients;

    //     List<Store__c> stores = new List<Store__c>();

    //     Store__c s1 = new Store__c(Name = 'Test 1',SourceStoreId__c = 'TST1');
    //     stores.add(s1);

    //     Store__c s2 = new Store__c(Name = 'Test 2',SourceStoreId__c = 'TST2');
    //     stores.add(s2);

    //     insert stores;

    //     List<Transaction__c> transactions = new List<Transaction__c>();

    //     Transaction__c t1 = new Transaction__c(Vendor__c = UserInfo.getUserId(), Store__c = s1.Id, Client__c = c1.Id, TransactionDate__c = Date.newInstance(2020,10,25));
    //     transactions.add(t1);

    //     Transaction__c t2 = new Transaction__c(Vendor__c = UserInfo.getUserId(), Store__c = s2.Id, Client__c = c1.Id, TransactionDate__c = Date.newInstance(2018,10,25));
    //     transactions.add(t2);

    //     Transaction__c t3 = new Transaction__c(Vendor__c = UserInfo.getUserId(), Store__c = s2.Id, Client__c = c2.Id, TransactionDate__c = Date.newInstance(2020,10,25));
    //     transactions.add(t3);

    //     Transaction__c t4 = new Transaction__c(Vendor__c = UserInfo.getUserId(), Store__c = s1.Id, Client__c = c2.Id, TransactionDate__c = Date.newInstance(2018,10,25));
    //     transactions.add(t4);

    //     insert transactions;

    //     Test.startTest();
    //     Database.executeBatch(new Batch_UpdateLastStoreAndSA());
    //     Account client1 = [SELECT Id, Last_Transaction_Store__pc FROM Account WHERE LastName = 'Test1' LIMIT 1];
    //     System.assertEquals(client1.Last_Transaction_Store__pc, s1.Id);
    //     Account client2 = [SELECT Id, Last_Transaction_Store__pc FROM Account WHERE LastName = 'Test2' LIMIT 1];
    //     System.assertEquals(client2.Last_Transaction_Store__pc, s2.Id);
    //     Test.stopTest();
    // }
    @isTest
    static void test_batch_updateLastStoreAndSA() {
        List<Account> clients = new List<Account>();

        Account c1 = new Account(FirstName = 'Client', LastName = 'Test1',LightCurrentCluster__pc = 'VIC_L');
        clients.add(c1);

        Account c2 = new Account(FirstName = 'Client', LastName = 'Test2',LightCurrentCluster__pc = 'VIC_L');
        clients.add(c2);

        insert clients;

        List<Store__c> stores = new List<Store__c>();

        Store__c s1 = new Store__c(Name = 'Test 1',SourceStoreId__c = 'TST1');
        stores.add(s1);

        Store__c s2 = new Store__c(Name = 'Test 2',SourceStoreId__c = 'TST2');
        stores.add(s2);

        insert stores;

        Transaction__c tr1 = new Transaction__c(Vendor__c = UserInfo.getUserId(), Store__c = s1.Id, Client__c = c1.Id, TransactionDate__c = Date.newInstance(2020,10,25));
        insert tr1;
        Transaction__c tr2 = new Transaction__c(Vendor__c = UserInfo.getUserId(), Store__c = s2.Id, Client__c = c1.Id, TransactionDate__c = Date.newInstance(2020,10,25));
        insert tr2;

        List<TransactionItem__c> transactions = new List<TransactionItem__c>();

        TransactionItem__c t1 = new TransactionItem__c(Sales_Advisor__c = UserInfo.getUserId(), Store__c = s1.Id, Client__c = c1.Id, TransactionDate__c = Date.newInstance(2020,10,25), Transaction__c = tr1.id);
        transactions.add(t1);

        TransactionItem__c t2 = new TransactionItem__c(Sales_Advisor__c = UserInfo.getUserId(), Store__c = s2.Id, Client__c = c1.Id, TransactionDate__c = Date.newInstance(2018,10,25), Transaction__c = tr2.id);
        transactions.add(t2);

        TransactionItem__c t3 = new TransactionItem__c(Sales_Advisor__c = UserInfo.getUserId(), Store__c = s2.Id, Client__c = c2.Id, TransactionDate__c = Date.newInstance(2020,10,25), Transaction__c = tr2.id);
        transactions.add(t3);

        TransactionItem__c t4 = new TransactionItem__c(Sales_Advisor__c = UserInfo.getUserId(), Store__c = s1.Id, Client__c = c2.Id, TransactionDate__c = Date.newInstance(2018,10,25), Transaction__c = tr1.id);
        transactions.add(t4);

        insert transactions;

        Test.startTest();
        Database.executeBatch(new Batch_UpdateLastStoreAndSA());
        Account client1 = [SELECT Id, Last_Transaction_Store__pc FROM Account WHERE LastName = 'Test1' LIMIT 1];
        // System.assertEquals(client1.Last_Transaction_Store__pc, s1.Id);
        // Account client2 = [SELECT Id, Last_Transaction_Store__pc FROM Account WHERE LastName = 'Test2' LIMIT 1];
        // System.assertEquals(client2.Last_Transaction_Store__pc, s2.Id);
        Test.stopTest();
    }
}