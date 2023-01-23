@IsTest
global with sharing class SOM_Batch_CustomerTokenDeletionTest {

    @testSetup static void setup() {
        OrderSummary orderSummary = SOM_testDataFactory.generateOrderSummary();
        createCybersourceSettings();
        orderSummary.Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
        update orderSummary;      
    }

    @IsTest
    public static void testDeleteCustomerToken(){
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        Test.startTest();
        List<PaymentAuthorization> payAuths = [SELECT ID, CustomerToken__c, OrderPaymentSummary.OrderSummaryId FROM PaymentAuthorization];
        System.debug('Payment Authorizations to handle: ' + payAuths);
        SOM_Batch_CustomerTokenDeletion.deleteCustomerToken(payAuths);
        List<PaymentAuthorization> payAuthsToAssert = [SELECT ID, CustomerTokenDeletionStatus__c FROM PaymentAuthorization];
        System.assertEquals(SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED,
                payAuthsToAssert.get(0).CustomerTokenDeletionStatus__c,
                'The customer token deletion status is different to Deleted.'); 
        Test.stopTest();
    }

    @IsTest
    public static void testCustomerTokenIsEmpty(){
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        Test.startTest();
        List<PaymentAuthorization> payAuths = [SELECT ID, CustomerToken__c, OrderPaymentSummary.OrderSummaryId FROM PaymentAuthorization];
        System.debug('Payment Authorizations to handle: ' + payAuths);
        PaymentAuthorization paymentAuth = payAuths.get(0);
        paymentAuth.CustomerToken__c     = null;
        update paymentAuth;
        SOM_Batch_CustomerTokenDeletion.deleteCustomerToken(payAuths);
        List<PaymentAuthorization> payAuthsToAssert = [SELECT ID, CustomerTokenDeletionStatus__c FROM PaymentAuthorization];
        System.assertNotEquals(SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED,
                payAuthsToAssert.get(0).CustomerTokenDeletionStatus__c); 
        Test.stopTest();
    }

    @IsTest
    public static void testDeleteCustomerTokenFutureMethod(){
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutMock());
        Test.startTest();
        List<PaymentAuthorization> payAuths = [SELECT ID, CustomerToken__c, OrderPaymentSummary.OrderSummaryId FROM PaymentAuthorization];
        System.debug('Payment Authorizations to handle: ' + payAuths);
        SOM_Batch_CustomerTokenDeletion ctd = new SOM_Batch_CustomerTokenDeletion();
        ctd.execute(null);
        List<PaymentAuthorization> payAuthsToAssert = [SELECT ID, CustomerTokenDeletionStatus__c FROM PaymentAuthorization];
        System.assertNotEquals(SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED,
                payAuthsToAssert.get(0).CustomerTokenDeletionStatus__c); 
        Test.stopTest();
    }

    @IsTest
    public static void testDeleteCustomerTokenErrorStatusCode(){
        Test.setMock(HttpCalloutMock.class, new CybersourceCalloutErrorMock());
        Test.startTest();
        List<PaymentAuthorization> payAuths = [SELECT ID, CustomerToken__c, OrderPaymentSummary.OrderSummaryId FROM PaymentAuthorization];
        System.debug('Payment Authorizations to handle: ' + payAuths);
        SOM_Batch_CustomerTokenDeletion.deleteCustomerToken(payAuths);
        List<PaymentAuthorization> payAuthsToAssert = [SELECT ID, CustomerTokenDeletionStatus__c FROM PaymentAuthorization];
        System.assertEquals(SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR,
                payAuthsToAssert.get(0).CustomerTokenDeletionStatus__c); 
        Test.stopTest();
    }

    public static void createCybersourceSettings(){
        CybersourceSettings__c cybSettings = new CybersourceSettings__c();
        cybSettings.Host__c              = 'apitest.cybersource.com';
        cybSettings.MerchantId__c        = 'rimowa_eu';
        cybSettings.MerchantKeyId__c     = 'eec3d419-e07d-4cc0-8b0c-dbb5fdcc27eb';
        cybSettings.MerchantSecretKey__c = 'DgMctxVdd7QpPDXDPfsu0OxwYn5MBXjnK/LT+gASClY=';

        insert cybSettings;
    }

    global class CybersourceCalloutMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(204);
            return res;
        }
    }

    global class CybersourceCalloutErrorMock implements HttpCalloutMock {
        global HttpResponse respond(HttpRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(401);
            return res;
        }
    }
}