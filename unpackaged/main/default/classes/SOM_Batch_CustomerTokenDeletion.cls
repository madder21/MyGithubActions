global with sharing class SOM_Batch_CustomerTokenDeletion implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{

    private static final String RELATIVE_PATH             = '/tms/v2/customers/';
    public List<Payment_Methods_Mapping__mdt> PaymentMethods = [SELECT Id, Value__c, Is_Card_Payment_Method__c FROM Payment_Methods_Mapping__mdt WHERE Is_Card_Payment_Method__c=true];
    public Set<String> cardPaymentMethods = new Set<String>();
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        for(Payment_Methods_Mapping__mdt singleMDT : PaymentMethods){
        	cardPaymentMethods.add(singleMDT.Value__c);
    	}
        Datetime lastModifiedDateFilter = Datetime.now() - Integer.valueOf(System.Label.Order_Last_Modified_Date_Filter);
        return Database.getQueryLocator([SELECT ID, CustomerToken__c, OrderPaymentSummary.OrderSummaryId, OrderPaymentSummary.PaymentMethodId FROM PaymentAuthorization 
                        WHERE OrderPaymentSummary.OrderSummary.LastModifiedDate < :lastModifiedDateFilter AND CustomerToken__c != null
                        AND OrderPaymentSummary.OrderSummary.Status IN (:SOM_Constants.ORDER_SUMMARY_FULFILLED, :SOM_Constants.ORDER_SUMMARY_CANCELED) 
                        AND OrderPaymentSummary.Type IN :cardPaymentMethods AND PaymentAuthorization.CustomerTokenDeletionStatus__c != :SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED 
                        ORDER BY OrderPaymentSummary.OrderSummary.LastModifiedDate]);
    }

    global void execute(Database.BatchableContext BC, List<PaymentAuthorization> scope) {
        if (scope != null && !scope.isEmpty()) {
            deleteCustomerToken(scope);
        }
    }

    global void finish(Database.BatchableContext BC) {}

    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new SOM_Batch_CustomerTokenDeletion(), 100);
    }

    public static void deleteCustomerToken(List<PaymentAuthorization> paymentAuthorizations){
        Map<Id, PaymentAuthorization> paymentAuthorizationsToUpdate = new Map<Id, PaymentAuthorization>();
        String host              = CybersourceSettings__c.getOrgDefaults().Host__c;
        String merchantKeyId     = CybersourceSettings__c.getOrgDefaults().MerchantKeyId__c;
        String merchantSecretKey = CybersourceSettings__c.getOrgDefaults().MerchantSecretKey__c;
        String merchantId        = CybersourceSettings__c.getOrgDefaults().MerchantId__c;
        for (PaymentAuthorization payAuth:paymentAuthorizations) {
            try{
                String relativePath    = RELATIVE_PATH+payAuth.CustomerToken__c;
                String currentDatetime = String.valueOf(Datetime.now());
                //Create signature
                String signatureString = 'host: ' + host;
                signatureString += '\n';
                signatureString += 'date: ' + currentDatetime;
                signatureString += '\n';
                signatureString += 'request-target: delete '+relativePath;
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
                if (httpResponse.getStatusCode() == 204) {
                    payAuth.CustomerTokenDeletionStatus__c = SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED;
                } else {
                    payAuth.CustomerTokenDeletionStatus__c = SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR;
                }
            } catch(Exception ex) {
                payAuth.CustomerTokenDeletionStatus__c = SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR;
            }
            paymentAuthorizationsToUpdate.put(payAuth.Id, payAuth);
            //break;
        } 
        //Update payment authorizations
        if (paymentAuthorizationsToUpdate.size() > 0) {
            update paymentAuthorizationsToUpdate.values();
        }
    }
}