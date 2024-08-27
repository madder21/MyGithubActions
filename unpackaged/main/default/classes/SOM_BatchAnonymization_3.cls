global with sharing class SOM_BatchAnonymization_3 implements Database.Batchable<Sobject>, Database.Stateful {

    String  stringOperator  = SOM_Constants.STRING_OPERATOR_ANONYMIZATION;
    String  emailOperator   = SOM_Constants.EMAIL_OPERATOR_ANONYMIZATION ;
    Integer integerOperator = SOM_Constants.INTEGER_OPERATOR_ANONYMIZATION ;
    
    List<String> orderIds = new List<String>();

    List<String> cls = new List<String>();
    List<String> orderPaymentSummaryIds = new List<String>();
    List<String> paymentMethodIds = new List<String>();
    List<sObject> objectsToUpdate = new List<sObject>();
    Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
    Map<String, String> objectClientId = new Map<String, String>();
    PrivacyRequest__c privacyReq = new PrivacyRequest__c();
    Boolean nextBatch = true;

    public SOM_BatchAnonymization_3(List<String> orderIdList, List<String> paymentMethodIdsList, List<String> orderPaymentSummaryIdsList, Map<String, String> objectClientIdMap, Map<String, List<String>> orderSummaryNumbersMap, List<String> clients) {
        orderIds                = orderIdList;
        paymentMethodIds        = paymentMethodIdsList;
        orderPaymentSummaryIds  = orderPaymentSummaryIdsList;
        objectClientId          = objectClientIdMap;
        orderSummaryNumbers     = orderSummaryNumbersMap;
        cls                     = clients;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, OrderPaymentSummaryId, Phone, Email, paypalCustomerEmail__c FROM Payment WHERE OrderPaymentSummaryId IN :orderPaymentSummaryIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Payment> relatedPayments){
        
        for(Payment pay : relatedPayments){
            pay.Phone                  = stringOperator; 
            pay.Email                  = emailOperator;
            pay.paypalCustomerEmail__c = emailOperator; 
            objectsToUpdate.add(pay);
            objectClientId.put(pay.Id, objectClientId.get(pay.OrderPaymentSummaryId));
        }
        try {
            Logs.debug('Anonymization process - Batch 3','SOM_BatchAnonymization_3','callBatchAnonymization','','');   
            Logs.info('Anonymization process - Batch 3','SOM_BatchAnonymization_3','callBatchAnonymization','','');   
            System.debug('objectsToUpdate :: '+objectsToUpdate);
            if(objectsToUpdate != null && !objectsToUpdate.isEmpty()) {
                objectsToUpdate.sort();
                update objectsToUpdate;
            }
        } catch(DmlException e) {
            nextBatch = false;
            privacyReq.Application__c      = 'SOM';
            privacyReq.AccountId__c        = objectClientId.get(e.getDmlId(0));
            privacyReq.Status__c           = 'Error';
            privacyReq.AnonymizationLog__c = e.getDmlMessage(0);
            insert privacyReq;
            Logs.error(e,'SOM_BatchAnonymization_3','callBatchAnonymization','','');   
        }
    }
    

    global void finish(Database.BatchableContext BC){
        try {
            Logs.debug('Anonymization process - Batch 3','SOM_BatchAnonymization_3','callBatchAnonymization - finish','','');   
            Logs.info('Anonymization process - Batch 3','SOM_BatchAnonymization_3','callBatchAnonymization - finish','','');   
            if(nextBatch == true){
                SOM_BatchAnonymization_4 nextBatch = new SOM_BatchAnonymization_4(orderIds, paymentMethodIds, objectClientId, orderSummaryNumbers, cls);
                database.executebatch(nextBatch);
            } 
        }catch(Exception e){
            Logs.error(e,'SOM_BatchAnonymization_3','BatchAnonymization - finish','','');   
        }  
    }
}
