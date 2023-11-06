@IsTest(SeeAllData=false)
public class WS_TransactionPaymentUTL_TST {
    
    @isTest
    static void testUpsertTransactionPayment() {
        List<Account> accList = TestDataFactory.createSObjectList('Account', 1);
        Transaction__c transact = new Transaction__c(
            SourceTransactionId__c = 'TestSourceId',
            InclTaxAmount__c = 100.00
        );
        insert transact;

        TransactionPayment__c transactionPayment = new TransactionPayment__c(
            Transaction__c = transact.Id,
            PaidAmount__c = 50.00,
            Client__c = accList[0].Id
        );

        Test.startTest();
        String response = WS_TransactionPaymentUTL.upsertTransactionPayment(transactionPayment, transact);
        Test.stopTest();
        System.assertNotEquals('Some information are missing', response);
    }
}