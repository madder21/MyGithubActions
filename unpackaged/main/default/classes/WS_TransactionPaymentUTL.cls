/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 20-&0-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
public with sharing class WS_TransactionPaymentUTL {
    
    public static String upsertTransactionPayment(TransactionPayment__c transacPayment, Transaction__c transact) {
        Transaction__c retrievedTransaction = [SELECT Id, InclTaxAmount__c
                                               FROM Transaction__c 
                                               WHERE SourceTransactionId__c =: transact.SourceTransactionId__c
                                               LIMIT 1
                                              ];
        List<TransactionPayment__c> retrievedTransactionPayment = [SELECT Id, Transaction__c, PaymentMethod__c, Client__c, CurrencyIsoCode,
                                                                   UCRLastUpdateDate__c, UCRCreationDate__c, PaidAmount__c, Transaction__r.InclTaxAmount__c
                                                                   FROM TransactionPayment__c
                                                                   WHERE Transaction__c =: retrievedTransaction.Id
                                                                   AND PaidAmount__c =: transacPayment.PaidAmount__c
                                                                   AND Client__c =: transacPayment.Client__c
                                                                  ];

        Boolean shouldBeInserted = true;
        String status = 'error';
        System.debug('****** retrievedTransactionPayment ******: '+retrievedTransactionPayment); 
        for(TransactionPayment__c tPayment : retrievedTransactionPayment) {
			if(transacPayment.PaidAmount__c == retrievedTransaction.InclTaxAmount__c) {
                shouldBeInserted = false;
			}                                        
		}
        if(shouldBeInserted) {
            status = 'success';
            Database.insert(transacPayment);
        }
        if(!shouldBeInserted) {
            status = 'The record already exists';
        }
        
        Map<String, String> response = new Map<String, String>();
        response.put('Record Id', transacPayment.Id);
        response.put('Status', status);
        return JSON.serialize(response);
    }

}