global with sharing class SOM_Batch_CustomerTokenDeletion implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{

    private static final String RELATIVE_PATH = '/tms/v2/customers/';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Datetime lastModifiedDateFilter = Datetime.now() - Integer.valueOf(System.Label.Order_Last_Modified_Date_Filter);
        return Database.getQueryLocator([SELECT ID, CustomerToken__c, OrderPaymentSummary.OrderSummaryId FROM PaymentAuthorization 
                        WHERE OrderPaymentSummary.OrderSummary.LastModifiedDate < :lastModifiedDateFilter AND CustomerToken__c != null
                        AND OrderPaymentSummary.OrderSummary.Status IN (:SOM_Constants.ORDER_SUMMARY_FULFILLED, :SOM_Constants.ORDER_SUMMARY_CANCELED) 
                        AND OrderPaymentSummary.Type = :SOM_Constants.CARD_PAYMENT_TYPE_VISA AND PaymentAuthorization.CustomerTokenDeletionStatus__c != :SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED 
                        ORDER BY OrderPaymentSummary.OrderSummary.LastModifiedDate]);
    }

    global void execute(Database.BatchableContext BC, List<PaymentAuthorization> scope) {
        System.debug('********** Enter Batch execute At : '+ System.now());
        if (scope != null && !scope.isEmpty()) {
            deleteCustomerToken(scope);
        } else {
            System.debug('Nothing to delete.');
        }
        System.debug('********** Exit Batch execute At : '+ System.now());
         
    }

    global void finish(Database.BatchableContext BC) {}

    global void execute(SchedulableContext ctx) {
        System.debug('********** Enter Schedule execute At : '+ System.now());
        Database.executeBatch(new SOM_Batch_CustomerTokenDeletion(), 100);
        System.debug('********** Exit Schedule execute At : '+ System.now());
    }

    public static void deleteCustomerToken(List<PaymentAuthorization> paymentAuthorizations){
        Map<Id, PaymentAuthorization> paymentAuthorizationsToUpdate = new Map<Id, PaymentAuthorization>();
        System.debug('Number of tokens to delete: ' + paymentAuthorizations.size());
        String host              = CybersourceSettings__c.getOrgDefaults().Host__c;
        String merchantKeyId     = CybersourceSettings__c.getOrgDefaults().MerchantKeyId__c;
        String merchantSecretKey = CybersourceSettings__c.getOrgDefaults().MerchantSecretKey__c;
        String merchantId        = CybersourceSettings__c.getOrgDefaults().MerchantId__c;
        for (PaymentAuthorization payAuth:paymentAuthorizations) {
            System.debug('---------OrderSummary to handle: ' + payAuth.OrderPaymentSummary.OrderSummaryId);
            try{
                String relativePath    = RELATIVE_PATH+payAuth.CustomerToken__c;
                String currentDatetime = String.valueOf(Datetime.now());
                //Create signature
                String signatureString = 'host: ' + host;
                signatureString += '\n';
                signatureString += 'date: ' + currentDatetime;
                signatureString += '\n';
                signatureString += '(request-target): delete '+relativePath;
                signatureString += '\n';
                signatureString += 'v-c-merchant-id: '+merchantId;
                //Encrypt signature using HmacSHA256 algorithm
                Blob signatureEncodedBlob     = Crypto.generateMac('HmacSHA256', Blob.valueOf(signatureString), EncodingUtil.base64Decode(merchantSecretKey));
                String signatureEncodedBase64 = EncodingUtil.base64Encode(signatureEncodedBlob);
        
                //Create http signature
                String signatureHeaderValue = 'keyid="'+merchantKeyId+'"';
                signatureHeaderValue += ', algorithm="HmacSHA256"';
                signatureHeaderValue += ', headers="host date (request-target) v-c-merchant-id"';
                signatureHeaderValue += ', signature="' + signatureEncodedBase64 + '"';

                //Create http request
                Http http = new Http();
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setEndpoint('callout:CybersourceService'+relativePath);
                httpRequest.setMethod('DELETE');
                httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
                httpRequest.setHeader('host', host);
                httpRequest.setHeader('date', currentDatetime);
                httpRequest.setHeader('v-c-merchant-Id', merchantId);
                httpRequest.setHeader('Signature', signatureHeaderValue);
                //Send request
                HttpResponse httpResponse = http.send(httpRequest);
                System.debug('------------Http Response:');
                System.debug(httpResponse.getBody());
                System.debug(httpResponse.getStatusCode());
                if (httpResponse.getStatusCode() == 204) {
                    payAuth.CustomerTokenDeletionStatus__c = SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED;
                } else {
                    payAuth.CustomerTokenDeletionStatus__c = SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR;
                }
            } catch(Exception ex) {
                System.debug('Error while deleting customer token from cybersource.');
                System.debug(ex.getMessage());
                payAuth.CustomerTokenDeletionStatus__c = SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR;
            }
            paymentAuthorizationsToUpdate.put(payAuth.Id, payAuth);
            //break;
        } 
        System.debug('---------Payment authorizations to update.');
        System.debug(paymentAuthorizationsToUpdate);
        //Update payment authorizations
        if (paymentAuthorizationsToUpdate.size() > 0) {
            System.debug('----------Launch updating deletion status.');
            update paymentAuthorizationsToUpdate.values();
        }
    }
}