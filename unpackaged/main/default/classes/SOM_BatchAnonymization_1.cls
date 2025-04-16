global with sharing class SOM_BatchAnonymization_1 implements Database.Batchable<Sobject>, Database.Stateful {

    String  stringOperator  = SOM_Constants.STRING_OPERATOR_ANONYMIZATION;
    String  emailOperator   = SOM_Constants.EMAIL_OPERATOR_ANONYMIZATION ;
    Integer integerOperator = SOM_Constants.INTEGER_OPERATOR_ANONYMIZATION ;
    String  Fulfilled       = SOM_Constants.ORDER_SUMMARY_FULFILLED;
    String  Canceled        = SOM_Constants.ORDER_SUMMARY_CANCELED;

    List<String> cls = new List<String>();
    List<String> orderIds = new List<String>(); 
    List<String> orderPaymentSummaryIds = new List<String>();
    List<String> paymentMethodIds = new List<String>();
    List<sObject> objectsToUpdate = new List<sObject>();
    Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
    Map<String, String> objectClientId = new Map<String, String>();
    PrivacyRequest__c privacyReq = new PrivacyRequest__c();
    Boolean nextBatch = true;

    @InvocableMethod(label='Call Batch Anonymization' description='Anonymizes the specified clients.')
    public static void callBatchAnonymization(List<String> clientId) {
        List<String> clients = new List<String>();
        clients  = clientId;
        Id jobId = Database.executeBatch(new SOM_BatchAnonymization_1(clients));
    }

    public SOM_BatchAnonymization_1(List<String> clientList) {
        cls = clientList;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, AccountId, OrderNumber, Status, OriginalOrderId, BillingPostalCode, BillingStreet, BillingEmailAddress, '
        +'BillingPhoneNumber, BillingContactFirstName__c, BillingContactLastName__c, (SELECT Id, FullName, PaymentMethodId FROM OrderPaymentSummaries), '
        +'(SELECT Id, FulfilledToName, FulfilledToEmailAddress, FulfilledToPhone, FulfilledToStreet FROM FulfillmentOrders), '
        +'(SELECT Id, DeliverToPostalCode, DeliverToStreet, EmailAddress, PhoneNumber, CLICKCOLLECT_pickup_email__c, CLICKCOLLECT_pickup_phone__c, '
        +'CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c FROM OrderDeliveryGroupSummaries), (SELECT Id, ShipToName, ShipToStreet, '
        +'ShipToPostalCode FROM Shipments) FROM OrderSummary WHERE AccountId IN :cls AND Status IN '
        +'(:Fulfilled, :Canceled)';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<OrderSummary> orderSummaryList){
        for(OrderSummary ordSumm : orderSummaryList){
            ordSumm.BillingPostalCode          = stringOperator;
            ordSumm.BillingStreet              = stringOperator;
            ordSumm.BillingEmailAddress        = emailOperator;
            ordSumm.BillingPhoneNumber         = stringOperator;
            ordSumm.BillingContactFirstName__c = stringOperator;
            ordSumm.BillingContactLastName__c  = stringOperator;
            objectsToUpdate.add(ordSumm);
            objectClientId.put(ordSumm.Id, ordSumm.AccountId);
            if(orderSummaryNumbers.containsKey(ordSumm.AccountId)){
                orderSummaryNumbers.get(ordSumm.AccountId).add(ordSumm.OrderNumber);
            } else{
                List<String> ordNumbs = new List<String>();
                ordNumbs.add(ordSumm.OrderNumber);
                orderSummaryNumbers.put(ordSumm.AccountId, ordNumbs);
            }
            orderIds.add(ordSumm.OriginalOrderId);
            // OrderPaymentSummary
            for(OrderPaymentSummary ordPaySumm : ordSumm.OrderPaymentSummaries){
                ordPaySumm.FullName = stringOperator; 
                objectsToUpdate.add(ordPaySumm);
                objectClientId.put(ordPaySumm.Id, ordSumm.AccountId);
                objectClientId.put(ordPaySumm.PaymentMethodId, ordSumm.AccountId);
                orderPaymentSummaryIds.add(ordPaySumm.Id);
                paymentMethodIds.add(ordPaySumm.PaymentMethodId);
            }
            // FulfillmentOrder
            for(FulfillmentOrder fo : ordSumm.FulfillmentOrders){
                fo.FulfilledToName         = stringOperator;
                fo.FulfilledToEmailAddress = emailOperator;
                fo.FulfilledToPhone        = stringOperator;
                fo.FulfilledToStreet       = stringOperator;
                objectsToUpdate.add(fo);
                objectClientId.put(fo.Id, ordSumm.AccountId);
            }
            // OrderDeliveryGroupSummary
            for(OrderDeliveryGroupSummary ordDelivGrpSumm : ordSumm.OrderDeliveryGroupSummaries){
                ordDelivGrpSumm.DeliverToPostalCode              = stringOperator; 
                ordDelivGrpSumm.EmailAddress                     = emailOperator; 
                ordDelivGrpSumm.PhoneNumber                      = stringOperator; 
                ordDelivGrpSumm.DeliverToStreet                  = stringOperator; 
                ordDelivGrpSumm.CLICKCOLLECT_pickup_email__c     = stringOperator; 
                ordDelivGrpSumm.CLICKCOLLECT_pickup_phone__c     = stringOperator; 
                ordDelivGrpSumm.CLICKCOLLECT_pickup_firstName__c = stringOperator; 
                ordDelivGrpSumm.CLICKCOLLECT_pickup_lastName__c  = stringOperator; 
                objectsToUpdate.add(ordDelivGrpSumm);
                objectClientId.put(ordDelivGrpSumm.Id, ordSumm.AccountId);
            }
            // Shipment
            for(Shipment ship : ordSumm.Shipments){
                ship.ShipToName       = stringOperator;
                ship.ShipToStreet     = stringOperator;
                objectsToUpdate.add(ship);
                objectClientId.put(ship.Id, ordSumm.AccountId);
            }
        }

        try {
            Logs.debug('Anonymization process - Batch 1','SOM_BatchAnonymization_1','callBatchAnonymization','','',cls[0]);   
            Logs.info('Anonymization process - Batch 1','SOM_BatchAnonymization_1','callBatchAnonymization','','',cls[0]);   
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
            Logs.error(e,'SOM_BatchAnonymization_1','callBatchAnonymization','','',cls[0]);   
        }
    }

    global void finish(Database.BatchableContext BC){
        try {
            Logs.debug('Anonymization process - Batch 1','SOM_BatchAnonymization_1','callBatchAnonymization - finish','','',cls[0]);   
            Logs.info('Anonymization process - Batch 1','SOM_BatchAnonymization_1','callBatchAnonymization - finish','','',cls[0]);   
           
            if(nextBatch == true){
                SOM_BatchAnonymization_2 nextBatch = new SOM_BatchAnonymization_2(orderIds, paymentMethodIds, orderPaymentSummaryIds, objectClientId, orderSummaryNumbers, cls);
                database.executebatch(nextBatch);
            }
        }catch(Exception e){
            Logs.error(e,'SOM_BatchAnonymization_1','BatchAnonymization - finish','','',cls[0]);   
        }  
        
    }
}