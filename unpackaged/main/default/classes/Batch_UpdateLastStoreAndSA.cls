global class Batch_UpdateLastStoreAndSA implements Database.Batchable<sObject>, Schedulable {

    String query;

    public Batch_UpdateLastStoreAndSA() {
        query = 'SELECT Id FROM Account WHERE Id != NULL AND Id IN (SELECT Client__c FROM TransactionItem__c) ORDER BY Id';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) { 
        Set<Id> clientIds = (new Map<Id,Account> (scope)).keySet();
        Map<Id, TransactionItem__c> clientsTransactionsMap = new Map<Id, TransactionItem__c>();
        List<Account> clientsToUpdate = new List<Account>();

        for(TransactionItem__c t : [SELECT TransactionDate__c, Sales_Advisor__c, Store__c,Client__c
                                FROM TransactionItem__c 
                                WHERE Client__c IN: clientIds
                                ORDER BY TransactionDate__c]) {
            if(!clientsTransactionsMap.containsKey(t.Client__c) || (clientsTransactionsMap.containsKey(t.Client__c) && clientsTransactionsMap.get(t.Client__c).TransactionDate__c < t.TransactionDate__c)) {
                clientsTransactionsMap.put(t.Client__c, t);
            }
        }

        for(TransactionItem__c t : clientsTransactionsMap.values()) {
            Account acc = new Account(Id = t.Client__c);
            acc.Last_Transaction_SA__pc = t.Sales_Advisor__c;
            acc.Last_Transaction_Store__pc = t.Store__c;
            acc.LastPurchaseDate__pc = t.TransactionDate__c;
            clientsToUpdate.add(acc);
        }

        update clientsToUpdate;
    }

    global void finish(Database.BatchableContext BC) {}

    global void execute(SchedulableContext sc) {
        Batch_UpdateLastStoreAndSA b = new Batch_UpdateLastStoreAndSA();
        Database.executeBatch(b);
    }

    // String query;

    // public Batch_UpdateLastStoreAndSA() {
    //     query = 'SELECT Id FROM Account WHERE Id != NULL AND Id IN (SELECT Client__c FROM Transaction__c)';
    // }

    // global Database.QueryLocator start(Database.BatchableContext BC) {
    //     return Database.getQueryLocator(query);
    // }

    // global void execute(Database.BatchableContext BC, List<Account> scope) { 
    //     Set<Id> clientIds = (new Map<Id,Account> (scope)).keySet();
    //     Map<Id, Transaction__c> clientsTransactionsMap = new Map<Id, Transaction__c>();
    //     List<Account> clientsToUpdate = new List<Account>();

    //     for(Transaction__c t : [SELECT TransactionDate__c, Vendor__c, Store__c,Client__c
    //                             FROM Transaction__c 
    //                             WHERE Client__c IN: clientIds
    //                             ORDER BY TransactionDate__c]) {
    //         if(!clientsTransactionsMap.containsKey(t.Client__c) || (clientsTransactionsMap.containsKey(t.Client__c) && clientsTransactionsMap.get(t.Client__c).TransactionDate__c < t.TransactionDate__c)) {
    //             clientsTransactionsMap.put(t.Client__c, t);
    //         }
    //     }

    //     for(Transaction__c t : clientsTransactionsMap.values()) {
    //         Account acc = new Account(Id = t.Client__c);
    //         acc.Last_Transaction_SA__pc = t.Vendor__c;
    //         acc.Last_Transaction_Store__pc = t.Store__c;
    //         clientsToUpdate.add(acc);
    //     }

    //     update clientsToUpdate;
    // }

    // global void finish(Database.BatchableContext BC) {}

    // global void execute(SchedulableContext sc) {
    //     Batch_UpdateLastStoreAndSA b = new Batch_UpdateLastStoreAndSA();
    //     Database.executeBatch(b);
    // }
}