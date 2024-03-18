public class SOM_Anonymization {
    
    @InvocableMethod(label='Anonymyse Client Data' description='Anonymizes the specified clients.')
    Public static void anonymizeClientData(List<String> clientId){
        
        String  stringOperator  = SOM_Constants.STRING_OPERATOR_ANONYMIZATION;
        String  emailOperator   = SOM_Constants.EMAIL_OPERATOR_ANONYMIZATION ;
        Integer integerOperator = SOM_Constants.INTEGER_OPERATOR_ANONYMIZATION ;
        
        String currentUserEmail = UserInfo.getUserEmail();
        
        List<String> orderIds = new List<String>(); 
        List<String> orderPaymentSummaryIds = new List<String>();
        List<String> paymentMethodIds = new List<String>();
        List<sObject> objectsToUpdate = new List<sObject>();
        Map<String, String> orderSummaryNumbers = new Map<String, String>();
        Map<String, String> objectClientId = new Map<String, String>();
        List<PrivacyRequest__c> privacyRequestsToInsert = new List<PrivacyRequest__c>();
        
        try {
            List<OrderSummary> relatedOrderSummaries = [SELECT Id, AccountId, OrderNumber, Status, OriginalOrderId, BillingPostalCode, BillingStreet, BillingEmailAddress, BillingPhoneNumber, BillingContactFirstName__c, BillingContactLastName__c,
                                                       (SELECT Id, FullName, PaymentMethodId FROM OrderPaymentSummaries),
                                                       (SELECT Id, FulfilledToName, FulfilledToEmailAddress, FulfilledToPhone, FulfilledToStreet FROM FulfillmentOrders),
                                                       (SELECT Id, DeliverToPostalCode, DeliverToStreet, EmailAddress, PhoneNumber, CLICKCOLLECT_pickup_email__c, CLICKCOLLECT_pickup_phone__c, CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c FROM OrderDeliveryGroupSummaries),
                                                       (SELECT Id, ShipToName, ShipToStreet FROM Shipments)
                                                       FROM OrderSummary WHERE AccountId IN :clientId AND Status IN ('Fulfilled','Canceled')];
            for(OrderSummary ordSumm : relatedOrderSummaries){
                ordSumm.BillingPostalCode          = stringOperator;
                ordSumm.BillingStreet              = stringOperator;
                ordSumm.BillingEmailAddress        = emailOperator;
                ordSumm.BillingPhoneNumber         = stringOperator;
                ordSumm.BillingContactFirstName__c = stringOperator;
                ordSumm.BillingContactLastName__c  = stringOperator;
                objectsToUpdate.add(ordSumm);
                objectClientId.put(ordSumm.Id, ordSumm.AccountId);
                orderSummaryNumbers.put(ordSumm.Id, ordSumm.OrderNumber);
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
                    ordDelivGrpSumm.DeliverToPostalCode = stringOperator; 
                    ordDelivGrpSumm.EmailAddress                     = emailOperator; 
                    ordDelivGrpSumm.PhoneNumber                      = stringOperator; 
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
            if(orderIds != null && !orderIds.isEmpty()){
                List<Order> relatedOrders = [SELECT Id, AccountId, Name, BillingPostalCode, BillingStreet, BillingEmailAddress, BillingPhoneNumber, BillingContactFirstName__c, BillingContactLastName__c,
                                            (SELECT Id, DeliverToStreet, DeliverToPostalCode, PhoneNumber, EmailAddress, CLICKCOLLECT_pickup_email__c, CLICKCOLLECT_pickup_phone__c, CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c FROM OrderDeliveryGroups)
                                             FROM Order WHERE Id IN :orderIds];
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
            }
            if(orderPaymentSummaryIds != null && !orderPaymentSummaryIds.isEmpty()){
                List<Payment> relatedPayments = [SELECT Id, OrderPaymentSummaryId, Phone, Email FROM Payment WHERE OrderPaymentSummaryId IN :orderPaymentSummaryIds];
                for(Payment pay : relatedPayments){
                    pay.Phone = stringOperator; 
                    pay.Email = emailOperator;
                    objectsToUpdate.add(pay);
                	objectClientId.put(pay.Id, objectClientId.get(pay.OrderPaymentSummaryId));
                }
            }
            if(paymentMethodIds != null && !paymentMethodIds.isEmpty()){
                List<CardPaymentMethod> relatedCardPaymentMethod = [SELECT Id, Status, CardHolderFirstName, CardHolderLastName, PaymentMethodAddress, PaymentMethodPostalCode, PaymentMethodStreet 
                                                                    FROM CardPaymentMethod WHERE Id IN :paymentMethodIds];
                if(relatedCardPaymentMethod != null && !relatedCardPaymentMethod.isEmpty()){
                    for(CardPaymentMethod cardPayMeth : relatedCardPaymentMethod){
                        cardPayMeth.Status                  = 'InActive';
                        cardPayMeth.CardHolderFirstName     = stringOperator;
                        cardPayMeth.CardHolderLastName      = stringOperator;
                        cardPayMeth.PaymentMethodState      = stringOperator;
                        cardPayMeth.PaymentMethodPostalCode = stringOperator;
                        cardPayMeth.PaymentMethodStreet     = stringOperator;
                        objectsToUpdate.add(cardPayMeth);
                    }
                }
                List<DigitalWallet> relatedDigitalWallet = [SELECT Id, PaymentMethodPostalCode, PaymentMethodStreet FROM DigitalWallet WHERE Id IN :paymentMethodIds];
                if(relatedDigitalWallet != null && !relatedDigitalWallet.isEmpty()){
                    for(DigitalWallet digi : relatedDigitalWallet){
                        digi.PaymentMethodPostalCode = stringOperator;
                        digi.PaymentMethodStreet     = stringOperator;
                        objectsToUpdate.add(digi);
                    }
                }
            }
                if (objectsToUpdate != null && !objectsToUpdate.isEmpty()){
                    objectsToUpdate.sort();
                    Database.SaveResult [] updateResult = Database.update(objectsToUpdate, false);
                    Map<String, List<String>> ordSummSuccess = new Map<String, List<String>>();
                    Map<String, Map<String, List<String>>> ordSummFailMap = new Map<String, Map<String, List<String>>>();
                    for (Database.SaveResult sr : updateResult){
                        if(sr.isSuccess() && orderSummaryNumbers.get(sr.getId()) != null) {
                            if(ordSummSuccess.KeySet().contains(objectClientId.get(sr.getId()))){
                                ordSummSuccess.get(objectClientId.get(sr.getId())).add(orderSummaryNumbers.get(sr.getId()));
                            } else {
                                List<String> ordSummNumForClient = new List<String>();
                                ordSummNumForClient.add(orderSummaryNumbers.get(sr.getId()));
                                ordSummSuccess.put(objectClientId.get(sr.getId()), ordSummNumForClient);
                            }
                        }
                        if(!sr.isSuccess()){
                    		List<String> ordSummFail = new List<String>();
                            for(Database.Error err : sr.getErrors()) { 
                                ordSummFail.add(err.getMessage());
                            }
                            if(ordSummFail != null && !ordSummFail.isEmpty()){
                                Map<String, List<String>> objectErrorForClient = new Map<String, List<String>>();
                                objectErrorForClient.put(sr.getId(), ordSummFail);
                                if(ordSummFailMap.KeySet().contains(objectClientId.get(sr.getId()))){
                                	ordSummFailMap.get(objectClientId.get(sr.getId())).put(sr.getId(), ordSummFail);
                            	} else {
                                    Map<String, List<String>> errorForClient = new Map<String, List<String>>();
                                    errorForClient.put(sr.getId(), ordSummFail);
                                	ordSummFailMap.put(objectClientId.get(sr.getId()), errorForClient);
                            	}
                            } 
                        }
                    }
                    if(ordSummSuccess != null && !ordSummSuccess.isEmpty() && (ordSummFailMap == null || ordSummFailMap.isEmpty())){
                        for(String cl : ordSummSuccess.KeySet()){
                            String anonymLog = string.valueof(ordSummSuccess.get(cl)).replace('{', '').replace('}', '');
                            PrivacyRequest__c newPrivRequest = new PrivacyRequest__c();
                            newPrivRequest = insertPrivacyRequest(cl, 'Success', anonymLog);
                            privacyRequestsToInsert.add(newPrivRequest);
                        	sendEmail(currentUserEmail, anonymLog);
                        }
                    }
                    if(ordSummFailMap != null && !ordSummFailMap.isEmpty()){
                        for(String cl : ordSummFailMap.KeySet()){
                            String anonymLog = JSON.serialize(ordSummFailMap.get(cl));
                            PrivacyRequest__c newPrivRequest = new PrivacyRequest__c();
                            newPrivRequest = insertPrivacyRequest(cl, 'Error', anonymLog);
                            privacyRequestsToInsert.add(newPrivRequest);
                        }
                    }
                    if(privacyRequestsToInsert != null && !privacyRequestsToInsert.isEmpty()) insert privacyRequestsToInsert;
            }
		} catch(Exception e) {
            PrivacyRequest__c newPrivRequest = new PrivacyRequest__c();
            newPrivRequest = insertPrivacyRequest(clientId[0], 'Error', e.getMessage());
            insert newPrivRequest;
		}
    }
    
    public static PrivacyRequest__c insertPrivacyRequest(String clientId, String Status, String AnonymizationLog){
        PrivacyRequest__c privacyReq = new PrivacyRequest__c();
        privacyReq.Application__c      = 'SOM';
        privacyReq.AccountId__c        = clientId;
        privacyReq.Status__c           = Status;
        privacyReq.AnonymizationLog__c = AnonymizationLog;
        return privacyReq;
    }
    
    public static void sendEmail(String emailUser, String orderNumbers){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owa = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'maha.meghras@viseo.com' OR Address = 'noreply@rimowa.com' LIMIT 1];
        message.setOrgWideEmailAddressId(owa.id);
        String subject ='Anonymization request';
        message.setSubject(subject);
        list<string> toAddresses = new list<string>();
        toAddresses.add(emailUser);
        message.setToAddresses(toAddresses);
        message.setPlainTextBody(' Anonymized orders : '+orderNumbers);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
}