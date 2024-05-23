/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 20-&0-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@RestResource(urlMapping='/ManageTransactionPayment/*')
global with sharing class WS_TransactionPayment {
    
    @HttpPost
    global static String upsertTransactionPayment() {
        
        RestRequest req = RestContext.request;
        String response = 'Some information are missing';
        System.debug('*** WS_TransactionIPayment - req.requestBody ***: '+req.requestBody);
        
        //Untyped JSON deserialization
        Map<String, Object> jsonMaps = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        String transactionPaymentContent = JSON.serialize(jsonMaps);
        TransactionPayment__c transacPayment = (TransactionPayment__c)JSON.deserialize(transactionPaymentContent, TransactionPayment__c.class);
        System.debug('*** WS_TransactionIPayment - transacPayment ***: '+transacPayment);
        String transactionContent = jsonMaps.containsKey('Transaction__r')?JSON.serialize(jsonMaps.get('Transaction__r')):null;

        if(transactionContent!=null) {
        	Transaction__c transactObj = (Transaction__c)JSON.deserialize(transactionContent, Transaction__c.class);
            response = WS_TransactionPaymentUTL.upsertTransactionPayment(transacPayment, transactObj);
            System.debug('*** WS_TransactionIPayment - transactObj ***: '+transactObj);
        }
        System.debug('*** WS_TransactionIPayment - response ***: '+response);
        return response;
    }

}