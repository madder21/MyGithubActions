global with sharing class SOM_BatchAnonymization_5 implements Database.Batchable<Sobject>, Database.Stateful {

    String  stringOperator  = SOM_Constants.STRING_OPERATOR_ANONYMIZATION;
    String  emailOperator   = SOM_Constants.EMAIL_OPERATOR_ANONYMIZATION ;
    Integer integerOperator = SOM_Constants.INTEGER_OPERATOR_ANONYMIZATION ;
    String  Fulfilled       = SOM_Constants.ORDER_SUMMARY_FULFILLED;
    String  Canceled        = SOM_Constants.ORDER_SUMMARY_CANCELED;

    List<String> orderIds = new List<String>();
    
    String currentUserEmail = UserInfo.getUserEmail();
    List<String> cls = new List<String>();
    List<String> orderPaymentSummaryIds = new List<String>();
    List<String> paymentMethodIds = new List<String>();
    List<sObject> objectsToUpdate = new List<sObject>();
    Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
    Map<String, String> objectClientId = new Map<String, String>();
    PrivacyRequest__c privacyReq = new PrivacyRequest__c();
    List<PrivacyRequest__c> privacyRequestsToInsert = new List<PrivacyRequest__c>();
    List<Account> clientsToBeUpdated = new List<Account>();
    List<Invoice> InvoiceToBeUpdated = new List<Invoice>();
    Boolean isSuccess = true;

    public SOM_BatchAnonymization_5(List<String> orderIdList, List<String> paymentMethodIdsList, Map<String, String> objectClientIdMap, Map<String, List<String>> orderSummaryNumbersMap, List<String> clients) {
        orderIds                = orderIdList;
        paymentMethodIds        = paymentMethodIdsList;
        objectClientId          = objectClientIdMap;
        orderSummaryNumbers     = orderSummaryNumbersMap;
        cls                     = clients;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AccountId, PaymentMethodPostalCode, PaymentMethodStreet FROM DigitalWallet WHERE (Id IN :paymentMethodIds OR AccountId IN :cls)';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<DigitalWallet> relatedDigitalWallet){
        for(DigitalWallet digi : relatedDigitalWallet){
            digi.PaymentMethodPostalCode = stringOperator;
            digi.PaymentMethodStreet     = stringOperator;
            objectsToUpdate.add(digi);
            objectClientId.put(digi.Id, digi.AccountId);
        }
        try {
            Logs.debug('Anonymization process - Batch 5','SOM_BatchAnonymization_5','callBatchAnonymization','','');   
            Logs.info('Anonymization process - Batch 5','SOM_BatchAnonymization_5','callBatchAnonymization','','');   
            if(objectsToUpdate != null && !objectsToUpdate.isEmpty()) {
                objectsToUpdate.sort();
                update objectsToUpdate;
            }
        } catch(DmlException e) {
            isSuccess = false;
            privacyReq.Application__c      = 'SOM';
            privacyReq.AccountId__c        = objectClientId.get(e.getDmlId(0));
            privacyReq.Status__c           = 'Error';
            privacyReq.AnonymizationLog__c = e.getDmlMessage(0);
            insert privacyReq;
            Logs.error(e,'SOM_BatchAnonymization_5','callBatchAnonymization','','');   

        }
    }

    global void finish(Database.BatchableContext BC){
        try {
            Logs.debug('Anonymization process - Batch 5','SOM_BatchAnonymization_5','callBatchAnonymization - finish','','');   
            Logs.info('Anonymization process - Batch 5','SOM_BatchAnonymization_5','callBatchAnonymization - finish','','');   
        if(isSuccess == true){
            List<String> ordSumNumbersToSend = new List<String>();
            for(String clSingle : orderSummaryNumbers.keySet()){
                String anonymLog = string.valueof(orderSummaryNumbers.get(clSingle)).replace('{', '').replace('}', '');
                ordSumNumbersToSend.addAll(orderSummaryNumbers.get(clSingle));
                PrivacyRequest__c privacyReq = new PrivacyRequest__c();
                privacyReq.Application__c      = 'SOM';
                privacyReq.AccountId__c        = clSingle;
                privacyReq.Status__c           = 'Success';
                privacyReq.AnonymizationLog__c = anonymLog;
                privacyRequestsToInsert.add(privacyReq);
            }
            if ( privacyRequestsToInsert != null && !privacyRequestsToInsert.isEmpty()){
                insert privacyRequestsToInsert;
            }
            
            List<Invoice> InvoiceList = [SELECT isCorrectiveInvoiceElligible__c FROM Invoice where BillingAccountId IN :cls];
            for(Invoice Inv : InvoiceList){
                Inv.isCorrectiveInvoiceElligible__c  = false;
                InvoiceToBeUpdated.add(Inv);
            }
            update InvoiceToBeUpdated;
            
            String anonymLogToSend = string.valueof(ordSumNumbersToSend).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
            List<OrderSummary> nonAnomizedListOS = [SELECT Id, Status, OrderNumber, OriginalOrderId FROM OrderSummary WHERE Status NOT IN (:Fulfilled, :Canceled) AND AccountId IN :cls];
            List<Order> nonAnomizedOrderList = [SELECT Id, Status FROM Order WHERE Id NOT IN :orderIds and Status != 'Activated' AND AccountId IN :cls];
            List<String> nonAnonymOrdNumbers = new List<String>();
            
            for(OrderSummary ord : nonAnomizedListOS){
                nonAnonymOrdNumbers.add(ord.OrderNumber);
                orderIds.add(ord.OriginalOrderId);
            }
            if(!(nonAnomizedListOS.size() > 0) && !(nonAnomizedOrderList.size() > 0)){
                for(Account cli : [SELECT Id, isPurged__c FROM Account WHERE Id IN :cls]){
                    cli.isPurged__c = true;
                    clientsToBeUpdated.add(cli);
                }
                update clientsToBeUpdated;
            }
            
            String nonAnonymLogToSend = string.valueof(nonAnonymOrdNumbers).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
                
                SOM_BatchAnonymization_6 nextBatch = new SOM_BatchAnonymization_6(orderIds, objectClientId, cls, anonymLogToSend, nonAnonymLogToSend);
                database.executebatch(nextBatch);
            } 
        }catch(Exception e){
            Logs.error(e,'SOM_BatchAnonymization_5','BatchAnonymization - finish','','');   
        }  
    }

}