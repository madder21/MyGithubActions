global with sharing class SOM_BatchAnonymization_2 implements Database.Batchable<Sobject>, Database.Stateful {

    List<String> orderIds = new List<String>();

    String  stringOperator  = SOM_Constants.STRING_OPERATOR_ANONYMIZATION;
    String  emailOperator   = SOM_Constants.EMAIL_OPERATOR_ANONYMIZATION ;
    Integer integerOperator = SOM_Constants.INTEGER_OPERATOR_ANONYMIZATION ;

    List<String> cls = new List<String>();
    List<String> orderPaymentSummaryIds = new List<String>();
    List<String> paymentMethodIds = new List<String>();
    List<sObject> objectsToUpdate = new List<sObject>();
    Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
    Map<String, String> objectClientId = new Map<String, String>();
    PrivacyRequest__c privacyReq = new PrivacyRequest__c();
    Boolean nextBatch = true;

    public SOM_BatchAnonymization_2(List<String> orderIdList, List<String> paymentMethodIdsList, List<String> orderPaymentSummaryIdsList, Map<String, String> objectClientIdMap, Map<String, List<String>> orderSummaryNumbersMap, List<String> clients) {
        orderIds                = orderIdList;
        paymentMethodIds        = paymentMethodIdsList;
        orderPaymentSummaryIds  = orderPaymentSummaryIdsList;
        objectClientId          = objectClientIdMap;
        orderSummaryNumbers     = orderSummaryNumbersMap;
        cls                     = clients;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AccountId, Name, BillingPostalCode, BillingStreet, BillingEmailAddress, BillingPhoneNumber, BillingContactFirstName__c, '
        +'BillingContactLastName__c, (SELECT Id, DeliverToStreet, DeliverToPostalCode, PhoneNumber, EmailAddress, CLICKCOLLECT_pickup_email__c, '
        +'CLICKCOLLECT_pickup_phone__c, CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c FROM OrderDeliveryGroups) '
        +'FROM Order WHERE Id IN :orderIds';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Order> relatedOrders){
        for(Order ord : relatedOrders){
            ord.Name                       = stringOperator;
            ord.BillingPostalCode          = stringOperator;
            ord.BillingStreet              = stringOperator;
            ord.BillingEmailAddress        = emailOperator;
            ord.BillingPhoneNumber         = stringOperator;
            ord.BillingContactFirstName__c = stringOperator;
            ord.BillingContactLastName__c  = stringOperator;
            objectsToUpdate.add(ord);
            objectClientId.put(ord.Id, ord.AccountId);
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
        try {
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
        }
    }

    global void finish(Database.BatchableContext BC){
        
        if(nextBatch == true){
            SOM_BatchAnonymization_3 nextBatch = new SOM_BatchAnonymization_3(paymentMethodIds, orderPaymentSummaryIds, objectClientId, orderSummaryNumbers, cls);
            database.executebatch(nextBatch);
        } 
    }
}