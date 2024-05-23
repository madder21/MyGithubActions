/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 20-10-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@IsTest(SeeAllData=false)
public class WS_TransactionPayment_TST {
    
    @isTest
    static void upsertTransactionTest() {
        
        List<Account> accList = TestDataFactory.createSObjectList('Account', 1);
        Transaction__c transact = new Transaction__c(
            SourceTransactionId__c = 'TestSourceIdU',
            InclTaxAmount__c = 100.00
        );
        insert transact;

        TransactionPayment__c transactionPayment = new TransactionPayment__c(
            Transaction__c = transact.Id,
            PaidAmount__c = 50.00,
            Client__c = accList[0].Id
        );
        insert transactionPayment;

        // Create a sample JSON request body for testing.
        String requestBody = '{"CurrencyIsoCode": "EUR","Client__c": "'+accList[0].Id+'","PaymentMethod__c": null,"PaidAmount__c": -1090,"UCRCreationDate__c": "2020-02-14T00:00:00","UCRLastUpdateDate__c": "2020-02-14T00:00:00","Transaction__r": {"SourceTransactionId__c": "TestSourceIdU"}}';
        System.debug('requestBody'+requestBody);
        Blob requestBodyBlob = Blob.valueOf(requestBody);

        // Create a mock REST request and response.
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/ManageTransactionPayment/';
        request.httpMethod = 'POST';
        request.requestBody = requestBodyBlob;

        RestResponse response = new RestResponse();

        // Set the mock request and response.
        RestContext.request = request;
        RestContext.response = response;
        Test.startTest();
        String jsonResponse = WS_TransactionPayment.upsertTransactionPayment();
        Test.stopTest();
        
    }

}