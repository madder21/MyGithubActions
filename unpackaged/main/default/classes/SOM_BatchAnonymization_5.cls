global with sharing class SOM_BatchAnonymization_5 implements Database.Batchable<Sobject>, Database.Stateful {

    String  stringOperator  = SOM_Constants.STRING_OPERATOR_ANONYMIZATION;
    String  emailOperator   = SOM_Constants.EMAIL_OPERATOR_ANONYMIZATION ;
    Integer integerOperator = SOM_Constants.INTEGER_OPERATOR_ANONYMIZATION ;
    String  Fulfilled       = SOM_Constants.ORDER_SUMMARY_FULFILLED;
    String  Canceled        = SOM_Constants.ORDER_SUMMARY_CANCELED;

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
    Boolean isSuccess = true;

    public SOM_BatchAnonymization_5(List<String> paymentMethodIdsList, Map<String, String> objectClientIdMap, Map<String, List<String>> orderSummaryNumbersMap, List<String> clients) {
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
        }
    }

    global void finish(Database.BatchableContext BC){
        if(isSuccess == true){
            List<String> ordNumbersToSend = new List<String>();
            for(String clSingle : orderSummaryNumbers.keySet()){
                String anonymLog = string.valueof(orderSummaryNumbers.get(clSingle)).replace('{', '').replace('}', '');
                ordNumbersToSend.addAll(orderSummaryNumbers.get(clSingle));
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
            for(Account cli : [SELECT Id, isPurged__c FROM Account WHERE Id IN :cls]){
                cli.isPurged__c = true;
                clientsToBeUpdated.add(cli);
            }
            update clientsToBeUpdated;
            String anonymLogToSend = string.valueof(ordNumbersToSend).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
            List<OrderSummary> nonAnomizedList = [SELECT Id, Status, OrderNumber FROM OrderSummary WHERE Status NOT IN (:Fulfilled, :Canceled) AND AccountId IN :cls];
            List<String> nonAnonymOrdNumbers = new List<String>();
            for(OrderSummary ord : nonAnomizedList){
                nonAnonymOrdNumbers.add(ord.OrderNumber);
            }
            String nonAnonymLogToSend = string.valueof(nonAnonymOrdNumbers).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
            sendEmail(currentUserEmail, anonymLogToSend, nonAnonymLogToSend, clientsToBeUpdated[0].Id);
        } 
    }

    public static void sendEmail(String emailUser, String orderNumbers, String nonAnonymOrderNumbers, String AccountId){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owa = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'maha.meghras@viseo.com' OR Address = 'noreply@rimowa.com' LIMIT 1];
        message.setOrgWideEmailAddressId(owa.id);
        String subject ='Anonymization request';
        message.setSubject(subject);
        list<string> toAddresses = new list<string>();
        toAddresses.add(emailUser);
        message.setToAddresses(toAddresses);
        //message.setPlainTextBody(' Anonymized orders : '+orderNumbers);
        message.setHtmlBody('Hello,<br/> <br/>'+'Please, find below the result of your anonymization request for the following account id : '+AccountId+'. <br/><br/> Anonymized orders : '+orderNumbers+'. <br/><br/>'+' The following orders were not anonymized as they are not in "Fulfilled" or "Canceled" status : '+nonAnonymOrderNumbers+'.<br/> <br/> Best regards,');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}