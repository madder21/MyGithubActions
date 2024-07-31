global with sharing class SOM_BatchAnonymization_6 implements Database.Batchable<Sobject>, Database.Stateful {
    
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
    List<String> orderNumbers = new List<String>();
    List<String> ordSumNumbersToSend = new List<String>();
    List<String> nonAnonymOrdNumbers = new List<String>();
    Map<String, String> objectClientId = new Map<String, String>();
    PrivacyRequest__c privacyReq = new PrivacyRequest__c();
    List<PrivacyRequest__c> privacyRequestsToInsert = new List<PrivacyRequest__c>();
    List<Account> clientsToBeUpdated = new List<Account>();
    List<Invoice> InvoiceToBeUpdated = new List<Invoice>();
    Boolean isSuccess = true;
    
    String anonymLogToSendOS, nonAnonymLogToSendOS;
    
    public SOM_BatchAnonymization_6(List<String> orderIdList, Map<String, String> objectClientIdMap, List<String> clients, String anonymLogToSend, String nonAnonymLogToSend) {
        orderIds                = orderIdList;
        objectClientId          = objectClientIdMap;
        cls                     = clients;
        anonymLogToSendOS		= anonymLogToSend;
        nonAnonymLogToSendOS	= nonAnonymLogToSend;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AccountId, Name,OrderNumber, Status, BillingPostalCode, BillingStreet, BillingEmailAddress, BillingPhoneNumber, BillingContactFirstName__c, '
            +'BillingContactLastName__c, (SELECT Id, DeliverToStreet, DeliverToPostalCode, PhoneNumber, EmailAddress, CLICKCOLLECT_pickup_email__c, '
            +'CLICKCOLLECT_pickup_phone__c, CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c FROM OrderDeliveryGroups) '
            +'FROM Order WHERE Id NOT IN :orderIds and (AccountId IN :cls) and RelatedOrderId = null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Order> relatedOrders){
        for(Order ord : relatedOrders){
            if(ord.Status != 'Activated'){
                nonAnonymOrdNumbers.add(ord.OrderNumber);
            }else{
                ord.Name                       = stringOperator;
                ord.BillingPostalCode          = stringOperator;
                ord.BillingStreet              = stringOperator;
                ord.BillingEmailAddress        = emailOperator;
                ord.BillingPhoneNumber         = stringOperator;
                ord.BillingContactFirstName__c = stringOperator;
                ord.BillingContactLastName__c  = stringOperator;
                objectsToUpdate.add(ord);
                objectClientId.put(ord.Id, ord.AccountId);
                orderNumbers.add(ord.OrderNumber);
                // OrderDeliveryGroup
                for(OrderDeliveryGroup ordDelivGrp : ord.OrderDeliveryGroups){
                    ordDelivGrp.DeliverToStreet                  = stringOperator;
                    ordDelivGrp.DeliverToPostalCode              = stringOperator;
                    ordDelivGrp.PhoneNumber                      = stringOperator;
                    ordDelivGrp.EmailAddress                     = emailOperator;
                    ordDelivGrp.CLICKCOLLECT_pickup_email__c     = stringOperator;
                    ordDelivGrp.CLICKCOLLECT_pickup_phone__c     = stringOperator;
                    ordDelivGrp.CLICKCOLLECT_pickup_firstName__c = stringOperator;
                    ordDelivGrp.CLICKCOLLECT_pickup_lastName__c  = stringOperator;
                    objectsToUpdate.add(ordDelivGrp);
                    objectClientId.put(ordDelivGrp.Id, ord.AccountId);
                }
            }
        }
        try {
            Logs.debug('Anonymization process - Batch 6','SOM_BatchAnonymization_6','callBatchAnonymization','','');   
            Logs.info('Anonymization process - Batch 6','SOM_BatchAnonymization_6','callBatchAnonymization','','');   

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
            Logs.error(e,'SOM_BatchAnonymization_6','callBatchAnonymization','','');   
        }
    }
    
    global void finish(Database.BatchableContext BC){
        try {
            Logs.debug('Anonymization process - Batch 6','SOM_BatchAnonymization_6','callBatchAnonymization - finish','','');   
            Logs.info('Anonymization process - Batch 6','SOM_BatchAnonymization_6','callBatchAnonymization - finish','','');   
            if(isSuccess == true){
                String anonymLog = string.valueof(orderNumbers).replace('{', '').replace('}', '');
                PrivacyRequest__c privacyReq = new PrivacyRequest__c();
                privacyReq.Application__c      = 'SOM';
                privacyReq.AccountId__c        = cls[0];
                privacyReq.Status__c           = 'Success';
                privacyReq.AnonymizationLog__c = anonymLog;
                privacyRequestsToInsert.add(privacyReq);
                if ( privacyRequestsToInsert != null && !privacyRequestsToInsert.isEmpty()){
                    insert privacyRequestsToInsert;
                }
                
                // Order
                String anonymLogToSendO = string.valueof(orderNumbers).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
                String nonAnonymLogToSendO = string.valueof(nonAnonymOrdNumbers).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
                
                // Ispurged 
                if((orderIds.size() == 0) && !(nonAnonymOrdNumbers.size() > 0)){
                    for(Account cli : [SELECT Id, isPurged__c FROM Account WHERE Id IN :cls]){
                        cli.isPurged__c = true;
                        clientsToBeUpdated.add(cli);
                    }
                    update clientsToBeUpdated;
                }
                
                String anonymLogToSend;
                if(!String.isBlank(anonymLogToSendO) && !String.isBlank(anonymLogToSendOS)){
                	anonymLogToSend = anonymLogToSendOS +', '+ anonymLogToSendO ;
                }else if(!String.isBlank(anonymLogToSendO) && String.isBlank(anonymLogToSendOS)){
                	anonymLogToSend = anonymLogToSendO ;
                }else if(String.isBlank(anonymLogToSendO) && !String.isBlank(anonymLogToSendOS)){
                	anonymLogToSend = anonymLogToSendOS ;
                }
                
                String nonAnonymLogToSend;
                if(!String.isBlank(nonAnonymLogToSendO) && !String.isBlank(nonAnonymLogToSendOS)){
                	nonAnonymLogToSend = nonAnonymLogToSendOS +', '+ nonAnonymLogToSendO ;
                }else if(!String.isBlank(nonAnonymLogToSendO) && String.isBlank(nonAnonymLogToSendOS)){
                	nonAnonymLogToSend = nonAnonymLogToSendO ;
                }else if(String.isBlank(nonAnonymLogToSendO) && !String.isBlank(nonAnonymLogToSendOS)){
                	nonAnonymLogToSend = nonAnonymLogToSendOS ;
                }

                
                sendEmail(currentUserEmail, anonymLogToSend, nonAnonymLogToSend, cls[0]);
            }
        }catch(Exception e){
            Logs.error(e,'SOM_BatchAnonymization_6','BatchAnonymization - finish','','');   
        }  
    } 
    
    public static void sendEmail(String emailUser, String orderNumbers, String nonAnonymLogToSend, String AccountId){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owa = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'noreply@rimowa.com' OR Address = 'maha.meghras@viseo.com'  LIMIT 1];
        message.setOrgWideEmailAddressId(owa.id);
        String subject ='Anonymization request';
        message.setSubject(subject);
        list<string> toAddresses = new list<string>();
        toAddresses.add(emailUser);
        message.setToAddresses(toAddresses);
        String bodyMessage = 'Hello,<br/> <br/>'+'Please, find below the result of your anonymization request for the following account id : '+AccountId+'.';
        if(!String.isBlank(orderNumbers)){
            bodyMessage += '<br/><br/> Anonymized orders : '+orderNumbers+'.';
        }
        if(!String.isBlank(nonAnonymLogToSend)){
            bodyMessage += '<br/><br/>'+' The following orders were not anonymized as they are not in "Fulfilled", "Canceled" or "Activated" status : '+nonAnonymLogToSend+'.';
        }
        bodyMessage += '<br/> <br/> Best regards, ';
        message.setHtmlBody(bodyMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}