global with sharing class SOM_BatchAnonymization_4 implements Database.Batchable<Sobject>, Database.Stateful  {

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

    public SOM_BatchAnonymization_4(List<String> orderIdList, List<String> paymentMethodIdsList, Map<String, String> objectClientIdMap, Map<String, List<String>> orderSummaryNumbersMap, List<String> clients) {
        orderIds                = orderIdList;
        paymentMethodIds        = paymentMethodIdsList;
        objectClientId          = objectClientIdMap;
        orderSummaryNumbers     = orderSummaryNumbersMap; 
        cls                     = clients;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AccountId, Status, CardHolderFirstName, CardHolderLastName, PaymentMethodAddress, PaymentMethodPostalCode, PaymentMethodStreet FROM CardPaymentMethod WHERE Id IN :paymentMethodIds';
        List<CardPaymentMethod> inactiveCardPaymentMethod = [SELECT Id, AccountId, Status, CardHolderName, CardHolderFirstName, CardHolderLastName, PaymentMethodAddress, PaymentMethodPostalCode, PaymentMethodStreet FROM CardPaymentMethod WHERE Id IN :paymentMethodIds];
        List<sObject> objectsToUpdate1 = new List<sObject>();
        for(CardPaymentMethod cardPayMeth : inactiveCardPaymentMethod){
            cardPayMeth.Status = 'InActive';
            objectsToUpdate1.add(cardPayMeth);
        }
        Database.SaveResult [] updateResult1 = Database.update(objectsToUpdate1, false);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CardPaymentMethod> relatedCardPaymentMethod){
        
        try {
            Logs.debug('Anonymization process - Batch 4','SOM_BatchAnonymization_4','callBatchAnonymization','','');   
            Logs.info('Anonymization process - Batch 4','SOM_BatchAnonymization_4','callBatchAnonymization','','');   
            for(CardPaymentMethod cardPayMeth : relatedCardPaymentMethod){
                cardPayMeth.CardHolderFirstName     = stringOperator;
                cardPayMeth.CardHolderLastName      = stringOperator;
                cardPayMeth.PaymentMethodPostalCode = stringOperator;
                cardPayMeth.PaymentMethodStreet     = stringOperator;
                cardPayMeth.CardHolderName          = stringOperator;
                objectsToUpdate.add(cardPayMeth);
                objectClientId.put(cardPayMeth.Id, cardPayMeth.AccountId);
            }
            if(objectsToUpdate != null && !objectsToUpdate.isEmpty()) {
                objectsToUpdate.sort();
                Database.SaveResult [] updateResult = Database.update(objectsToUpdate, false);
            }
        } catch(DmlException e) {
            nextBatch = false;
            privacyReq.Application__c      = 'SOM';
            privacyReq.AccountId__c        = objectClientId.get(e.getDmlId(0));
            privacyReq.Status__c           = 'Error';
            privacyReq.AnonymizationLog__c = e.getDmlMessage(0);
            insert privacyReq;
            Logs.error(e,'SOM_BatchAnonymization_4','callBatchAnonymization','','');   
        }
    }

    global void finish(Database.BatchableContext BC){
        try {
            Logs.debug('Anonymization process - Batch 4','SOM_BatchAnonymization_4','callBatchAnonymization - finish','','');   
            Logs.info('Anonymization process - Batch 4','SOM_BatchAnonymization_4','callBatchAnonymization - finish','','');   
            if(nextBatch == true){
                SOM_BatchAnonymization_5 nextBatch = new SOM_BatchAnonymization_5(orderIds,paymentMethodIds, objectClientId, orderSummaryNumbers, cls);
                database.executebatch(nextBatch);
            } 
        }catch(Exception e){
            Logs.error(e,'SOM_BatchAnonymization_4','BatchAnonymization - finish','','');   
        }  
    }
}