global with sharing class SOM_CapturePaymentActionResponseWrapper {
    @AuraEnabled @InvocableVariable
    global String  settlementTransactionId;
    @AuraEnabled @InvocableVariable
    global String  decision;
    @AuraEnabled @InvocableVariable
    global Integer reasonCode;
    @AuraEnabled @InvocableVariable
    global String  authorizationCode;
    @AuraEnabled @InvocableVariable
    global String  reconciliationId;
    @AuraEnabled @InvocableVariable
    global Double  amount;
    @AuraEnabled @InvocableVariable
    global Boolean isSucces;
    @AuraEnabled @InvocableVariable
    global String  errorMessage;
    @AuraEnabled @InvocableVariable
    global String  fulfillmentOrderId;
}