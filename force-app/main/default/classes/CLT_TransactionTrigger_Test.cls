/*
 * Created by israel on 7/14/2019.
 */
@IsTest
private class CLT_TransactionTrigger_Test {

    @IsTest static void testOne() {
        Store__c store = new Store__c(Name = 'Test Store');
        insert store;
        
        Account account = new Account(Name = 'Name');
        insert account;

        Transaction__c trans = new Transaction__c(Client__c = account.Id,
                                                 TransactionDate__c = Date.today(),
                                                 Vendor__c = UserInfo.getUserId(),
                                                 Store__c = store.Id);
        insert trans;
    }
}