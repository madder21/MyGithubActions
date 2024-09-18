public without sharing class SOM_TransactionalEmailHandler {
    
    @InvocableMethod(label='Generate Transactional Email' description='Generate a Transactional Email record to send an email by SFMC')
    public static void generateTransactionalEmail(List<SOM_GenerateTransactionalEmailInput> generateTransactionalEmailInputs){
        Boolean CheckIsGlobalE = checkIsGlobalE(generateTransactionalEmailInputs[0].recordId);
        Map<String, Set<String>> inputByTemplateMap = new Map<String, Set<String>>();
        List<TransactionalEmail__c> transactionalEmailsToPersist = new List<TransactionalEmail__c>();
        for(SOM_GenerateTransactionalEmailInput generateTransactionalEmailInput:generateTransactionalEmailInputs) {
            if (inputByTemplateMap.containsKey(generateTransactionalEmailInput.templateName)) {
                inputByTemplateMap.get(generateTransactionalEmailInput.templateName).add(generateTransactionalEmailInput.recordId);
                continue;
            }
            inputByTemplateMap.put(
                generateTransactionalEmailInput.templateName, 
                new Set<String> {generateTransactionalEmailInput.recordId}
            );
        }
        System.debug('map templates :::: ' + inputByTemplateMap);
        if (!CheckIsGlobalE){
            for (String templateName:inputByTemplateMap.keySet()) {
                if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION) {
                    transactionalEmailsToPersist.addAll(generateShipmentConfirmationTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE) {
                    transactionalEmailsToPersist.addAll(generateInvoiceTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CREATED) {
                    transactionalEmailsToPersist.addAll(generateOrderTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_RECEIVED) {
                    transactionalEmailsToPersist.addAll(generateReturnReceptionTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_READY_FOR_PICKUP) {
                    transactionalEmailsToPersist.addAll(generateOrderReadyForPickupTransactionalEmails(inputByTemplateMap.get(templateName)));
                }else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_CREATED) {
                    transactionalEmailsToPersist.addAll(generateReturnOrderCreationTransactionalEmails(inputByTemplateMap.get(templateName)));
                }else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_CONFIRMATION) {
                    transactionalEmailsToPersist.addAll(generateRefundValidationTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_ON_MISSING_PRODUCT) {
                    transactionalEmailsToPersist.addAll(generateRefundWithoutCreditMemoTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CANCELED) {
                    transactionalEmailsToPersist.addAll(generateOrderCanceledTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_ORDER_CC_AUTOMATIC_CANCEL) {
                    transactionalEmailsToPersist.addAll(generateOrderCCAutomaticCancellationTransactionalEmails(inputByTemplateMap.get(templateName)));
                } else if (templateName == SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CC_REMINDER) {
        			System.debug('generateOrderCCReminderTransactionalEmails >>>>>>>>>> if 1');
                    transactionalEmailsToPersist.addAll(generateOrderCCReminderTransactionalEmails(inputByTemplateMap.get(templateName)));
        			System.debug('generateOrderCCReminderTransactionalEmails >>>>>>>>>>>>>>>if 2');
                }else {
                    System.debug('Template name: ' + templateName + ' is not supported.');
                }
                System.debug('transactionalEmailsToPersist :::: ' + transactionalEmailsToPersist);
            }
        }
        if (!transactionalEmailsToPersist.isEmpty()) insert transactionalEmailsToPersist;
    }
    
    /**
* -Email triggering on shipment confirmation
*/
    public static List<TransactionalEmail__c> generateShipmentConfirmationTransactionalEmails(Set<String> recordIds) {
        Map<Id, SOM_ShipmentConfirmationTemplateContent> shipmentConfirmationTemplateContentsMap = new Map<Id, SOM_ShipmentConfirmationTemplateContent>();
        Map<Id, List<String>> trackingNumberByFOId = new Map<Id, List<String>>();
        String emailOfClient = null ;
        Map<Id, SOM_Additional_Shipment_Details> shipmentDetailsByFOId = new Map<Id, SOM_Additional_Shipment_Details>();
        
        List<TransactionalEmail__c> shipmentTransactionalEmailsList = new List<TransactionalEmail__c>();
        Map<Id, Shipment> shipments = new Map<Id, Shipment>([SELECT Id, FulfillmentOrderId, OrderSummaryId,FulfillmentOrder.FulfilledToCountry, FulfillmentOrder.OrderSummary.AccountId,FulfillmentOrder.OrderSummary.Account.PersonEmail,FulfillmentOrder.OrderSummary.BillingEmailAddress , FulfillmentOrder.OrderSummary.OrderNumber, 
                                                             FulfillmentOrder.OrderSummary.SalesChannel.SalesChannelName,FulfillmentOrder.OrderSummary.language__c, ShipToStreet, Carrier__c, ShippingService__c,
                                                             ShipToCity, ShipToPostalCode, ShipToCountry, ShipToState, shipToName, TrackingNumber 
                                                             FROM Shipment WHERE Id IN :recordIds]);
        for (Shipment ship:shipments.values()) {
            if(emailOfClient == null) {
                emailOfClient = ship.FulfillmentOrder.OrderSummary.BillingEmailAddress;
            }
            if(!shipmentDetailsByFOId.containsKey(ship.FulfillmentOrderId)){
                SOM_Additional_Shipment_Details shipmentDetails = new SOM_Additional_Shipment_Details();
                shipmentDetails.orderSummaryId = ship.OrderSummaryId;
                shipmentDetails.accountId      = ship.FulfillmentOrder.OrderSummary.AccountId;
                shipmentDetails.deliveryCount  = ship.FulfillmentOrder.FulfilledToCountry;
                //shipmentDetails.lang  		   = ship.FulfillmentOrder.OrderSummary.language__c;
                //shipmentDetails.lang  		   = ship.FulfillmentOrder.OrderSummary.language__c != null ? ship.FulfillmentOrder.OrderSummary.language__c : generateLanguageSiteLabel(ship.FulfillmentOrder.FulfilledToCountry);
                shipmentDetailsByFOId.put(ship.FulfillmentOrderId, shipmentDetails);
            }
            if (shipmentConfirmationTemplateContentsMap.containsKey(ship.FulfillmentOrderId) && (!trackingNumberByFOId?.get(ship.FulfillmentOrderId).contains(ship.TrackingNumber))) {
                SOM_Shipment_Data shipmentData = new SOM_Shipment_Data();
                shipmentData.trackingNumber  = ship.TrackingNumber;
                shipmentData.carrier         = ship.Carrier__c;
                shipmentData.shippingService = ship.ShippingService__c;
                shipmentConfirmationTemplateContentsMap.get(ship.FulfillmentOrderId).shipments.add(shipmentData);
                trackingNumberByFOId.put(ship.FulfillmentOrderId, new List<String>{ship.TrackingNumber});
                continue;
            }
            SOM_ShipmentConfirmationTemplateContent shipmentConfirmationTemplateContent = new SOM_ShipmentConfirmationTemplateContent();
            shipmentConfirmationTemplateContent.channel            = ship.FulfillmentOrder.OrderSummary.SalesChannel.SalesChannelName;
            shipmentConfirmationTemplateContent.orderNumber        = ship.FulfillmentOrder.OrderSummary.OrderNumber;
            shipmentConfirmationTemplateContent.deliveryStreet     = ship.ShipToStreet;
            shipmentConfirmationTemplateContent.deliveryCity       = ship.ShipToCity;
            //shipmentConfirmationTemplateContent.deliveryCountry    = generateCountryMappingLabel(ship.ShipToCountry); 
            shipmentConfirmationTemplateContent.deliveryCountry    = generateCountryMappingLabel(ship.FulfillmentOrder.OrderSummary.language__c, ship.ShipToCountry); 
            shipmentConfirmationTemplateContent.deliveryName       = ship.shipToName;
            shipmentConfirmationTemplateContent.deliveryPostalCode = ship.ShipToPostalCode;
            shipmentConfirmationTemplateContent.deliveryState      = ship.ShipToState;
            
            SOM_Shipment_Data shipmentData = new SOM_Shipment_Data();
            shipmentData.trackingNumber  = ship.TrackingNumber;
            shipmentData.carrier         = ship.Carrier__c;
            shipmentData.shippingService = ship.ShippingService__c;
            shipmentConfirmationTemplateContent.shipments.add(shipmentData);
            
            shipmentConfirmationTemplateContentsMap.put(ship.FulfillmentOrderId, shipmentConfirmationTemplateContent);
            trackingNumberByFOId.put(ship.FulfillmentOrderId, new List<String>{ship.TrackingNumber});
        }
        
        for (Id fulfillmentOrderId : shipmentConfirmationTemplateContentsMap.keySet()) {
            TransactionalEmail__c shipmentTransactionalEmail = new TransactionalEmail__c();
            shipmentTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION;
            shipmentTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            shipmentTransactionalEmail.OrderSummary__c = shipmentDetailsByFOId.get(fulfillmentOrderId).OrderSummaryId;
            shipmentTransactionalEmail.Client__c       = shipmentDetailsByFOId.get(fulfillmentOrderId).accountId;
            shipmentTransactionalEmail.EmailContent__c = JSON.serializePretty(shipmentConfirmationTemplateContentsMap.get(fulfillmentOrderId), true);
            shipmentTransactionalEmail.Email__c        = emailOfClient;
            shipmentTransactionalEmail.CountrySite__c  = shipmentDetailsByFOId.get(fulfillmentOrderId).deliveryCount;
            //shipmentTransactionalEmail.LanguageSite__c  = shipmentDetailsByFOId.get(fulfillmentOrderId).lang;
            shipmentTransactionalEmailsList.add(shipmentTransactionalEmail);
        }
        
        return shipmentTransactionalEmailsList;
    }
    
    public static List<TransactionalEmail__c> generateInvoiceTransactionalEmails(Set<String> recordIds) {
        List<String> invoiceNumbers = new List<String>();
        List<Id> cInvoiceIds = new List<Id>();
        List<Id> invoiceIds  = new List<Id>();
        Map<String,String> mapInvCI = new Map<String,String>();
        Map<String,String> mapInvCIids = new Map<String,String>();
        Map<String,String> mapBccInvoiceEmail = new Map<String,String>();
        
        String InvoiceDocumentMulesoftEndpoint = [SELECT MasterLabel, Value__c, Template__c FROM SOM_Invoice_Setting__mdt WHERE Template__c = :'URL'].Value__c;
        
        for(Id recId : recordIds){
            if(recId.getSObjectType().getDescribe().getName() == SOM_Constants.CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME){
                cInvoiceIds.add(recId);
            }
            else if(recId.getSObjectType().getDescribe().getName() == SOM_Constants.INVOICE_SOBJECT_TYPE_NAME){
                invoiceIds.add(recId);
            }
        }
        if(!cInvoiceIds.isEmpty()){
            List<CorrectiveInvoice__c> cInvs = [SELECT Id, Name, OriginalInvoice__c FROM CorrectiveInvoice__c WHERE Id IN :cInvoiceIds];
            for(CorrectiveInvoice__c cInv : cInvs){
                invoiceNumbers.add(cInv.OriginalInvoice__c);
                mapInvCI.put(cInv.OriginalInvoice__c,cInv.Name);
                mapInvCIids.put(cInv.OriginalInvoice__c,cInv.Id);
                
                
            }
            List<Invoice> invs = [SELECT Id,InvoiceNumber__c FROM Invoice WHERE InvoiceNumber__c IN :invoiceNumbers];
            for(Invoice inv : invs){
                invoiceIds.add(inv.Id);
            }
            
        } 
        
        List<TransactionalEmail__c> invoiceTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<FulfillmentOrder> fulfillmentOrders = [SELECT Id, OrderSummary.OrderNumber, OrderSummary.SalesChannel.SalesChannelName, 
                                                    OrderSummary.AccountId, OrderSummary.Account.Salutation,OrderSummary.Account.PersonEmail,OrderSummary.BillingEmailAddress , OrderSummary.BillingContactFirstName__c, OrderSummary.BillingContactLastName__c, 
                                                    OrderSummary.BillingCity, OrderSummary.BillingState,OrderSummary.language__c, OrderSummary.BillingCountry, OrderSummary.BillingPostalCode, OrderSummary.BillingStreet, 
                                                    FulfilledToCountry, FulfilledToCity, FulfilledToState, FulfilledToName, FulfilledToPostalCode, 
                                                    FulfilledToStreet,Invoice.InvoiceNumber__c, Invoice.CurrencyIsoCode, Invoice.TotalAmountWithTax 
                                                    FROM FulfillmentOrder WHERE Invoice.Id IN :invoiceIds];
        list<Sales_Channel_Mapping__mdt> bccInvoiceEmailsList = [SELECT bcc_Invoice_Email__c, Zone__c  FROM Sales_Channel_Mapping__mdt WHERE bcc_Invoice_Email__c != null AND bcc_Invoice_Email__c !=''];
        for(Sales_Channel_Mapping__mdt SalesChannelRec : bccInvoiceEmailsList ){
            mapBccInvoiceEmail.put(SalesChannelRec.Zone__c,SalesChannelRec.bcc_Invoice_Email__c);
        }
        for (FulfillmentOrder fullOrder:fulfillmentOrders) {
            SOM_InvoiceTemplateContent invoiceTemplateContent = new SOM_InvoiceTemplateContent();
            invoiceTemplateContent.orderNumber      = fullOrder.OrderSummary.OrderNumber;
            invoiceTemplateContent.channel          = fullOrder.OrderSummary.SalesChannel.SalesChannelName;
            invoiceTemplateContent.orderCivility    = fullOrder.OrderSummary.Account.Salutation;
            invoiceTemplateContent.billingFirstName = fullOrder.OrderSummary.BillingContactFirstName__c;
            invoiceTemplateContent.billingLastName  = fullOrder.OrderSummary.BillingContactLastName__c;
            invoiceTemplateContent.billingCity      = fullOrder.OrderSummary.BillingCity;
            invoiceTemplateContent.billingState     = fullOrder.OrderSummary.BillingState;
            //invoiceTemplateContent.billingCountry   = generateCountryMappingLabel(fullOrder.OrderSummary.BillingCountry);
            //ship.FulfillmentOrder.OrderSummary.language__c != null ? ship.FulfillmentOrder.OrderSummary.language__c : generateLanguageSiteLabel(ship.FulfillmentOrder.FulfilledToCountry);
            invoiceTemplateContent.billingCountry   = generateCountryMappingLabel(fullOrder.OrderSummary.language__c  , fullOrder.OrderSummary.BillingCountry);
            invoiceTemplateContent.billingStreet    = fullOrder.OrderSummary.BillingStreet;
            invoiceTemplateContent.billingZipcode   = fullOrder.OrderSummary.BillingPostalCode;
            invoiceTemplateContent.deliveryName     = fullOrder.FulfilledToName;
            invoiceTemplateContent.deliveryCity     = fullOrder.FulfilledToCity;
            invoiceTemplateContent.deliveryState    = fullOrder.FulfilledToState;
            invoiceTemplateContent.deliveryZipcode  = fullOrder.FulfilledToPostalCode;
            //invoiceTemplateContent.deliveryCountry  = generateCountryMappingLabel(fullOrder.FulfilledToCountry);
            invoiceTemplateContent.deliveryCountry  = generateCountryMappingLabel(fullOrder.OrderSummary.language__c , fullOrder.FulfilledToCountry);
            invoiceTemplateContent.deliveryStreet   = fullOrder.FulfilledToStreet;
            invoiceTemplateContent.invoiceAmount    = fullOrder.Invoice.TotalAmountWithTax;
            invoiceTemplateContent.invoiceCurrency  = fullOrder.Invoice.CurrencyIsoCode;
            invoiceTemplateContent.invoiceNumber    = mapInvCI.containsKey(fullOrder.Invoice.InvoiceNumber__c) ? mapInvCI.get(fullOrder.Invoice.InvoiceNumber__c) : fullOrder.Invoice.InvoiceNumber__c;
            //invoiceTemplateContent.invoiceURL       = System.Label.Invoice_Url_Prefix +'/'+ (mapInvCI.containsKey(fullOrder.Invoice.InvoiceNumber__c) ? mapInvCI.get(fullOrder.Invoice.InvoiceNumber__c) : fullOrder.Invoice.InvoiceNumber__c);
            invoiceTemplateContent.invoiceURL       = mapInvCI.containsKey(fullOrder.Invoice.InvoiceNumber__c) ? (InvoiceDocumentMulesoftEndpoint+'/'+mapInvCIids.get(fullOrder.Invoice.InvoiceNumber__c)) : (InvoiceDocumentMulesoftEndpoint+'/'+fullOrder.Invoice.Id) ;
                
                TransactionalEmail__c invoiceTransactionalEmail = new TransactionalEmail__c();
            invoiceTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE;
            invoiceTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            invoiceTransactionalEmail.OrderSummary__c = fullOrder.OrderSummary.Id;
            invoiceTransactionalEmail.Client__c       = fullOrder.OrderSummary.AccountId;
            invoiceTransactionalEmail.EmailContent__c = JSON.serializePretty(invoiceTemplateContent, true);
            invoiceTransactionalEmail.Email__c        = fullOrder.OrderSummary.BillingEmailAddress;
            invoiceTransactionalEmail.CountrySite__c  = fullOrder.FulfilledToCountry;
            invoiceTransactionalEmail.bccEmail__c	  = mapBccInvoiceEmail.get(fullOrder.FulfilledToCountry);
            //invoiceTransactionalEmail.LanguageSite__c = fullOrder.OrderSummary.language__c != null ? fullOrder.OrderSummary.language__c : generateLanguageSiteLabel(fullOrder.FulfilledToCountry);
            
            invoiceTransactionalEmailsList.add(invoiceTransactionalEmail);
        }
        
        return invoiceTransactionalEmailsList;
        }
    
    /**
* @description Method to generate Order Transactional Email
* @author BADER EDDINE ELKHAL | 06-10-2022 
* @param recordIds 
* @return List<TransactionalEmail__c> 
**/
    public static List<TransactionalEmail__c> generateOrderTransactionalEmails(Set<String> recordIds) {
        List<TransactionalEmail__c> orderTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<OrderSummary> orderSummaries = [SELECT Id, OrderNumber , OrderedDate, SalesChannel.SalesChannelName, 
                                             BillingContactFirstName__c, BillingContactLastName__c, BillingState, BillingStreet, BillingPostalCode,tech_os_store_shipping_method__c, 
                                             BillingCity, BillingCountry, TotalAmount, TotalTaxAmount,language__c, GrandTotalAmount, AccountId,Account.PersonEmail, CurrencyIsoCode,BillingEmailAddress ,
                                             (SELECT Id,StockKeepingUnit,Name,LineNumber,Product2.ImageURL__c, Product2.ImageUrl1__c, ReservedAtLocationId, ReservedAtLocation.Name, Quantity, TotalLineAmount, Description, IsPreOrder__c, PreOrder_message__c,Type 
                                              FROM OrderItemSummaries ORDER BY LineNumber ASC),
                                             (SELECT Id,DeliverToCountry, CLICKCOLLECT_StoreName__c, DeliverToCity, DeliverToState, DeliverToStreet, DeliverToPostalCode, DeliverToName 
                                              FROM OrderDeliveryGroupSummaries)
                                             FROM OrderSummary WHERE Id IN :recordIds];
        //List<Schema.Location> StoreLocation = [Select Id from Location where LocationType =: SOM_Constants.STORE ];
        String ReservedAtLocation = '';
        Map<String, String> EmailStoreMap = new Map<String, String>();
        List<Store__c> StoreLocation = [Select Id,SourceStoreId__c, Email__c from Store__c ];
        for(Store__c Store:StoreLocation) {
            EmailStoreMap.put(Store.SourceStoreId__c,Store.Email__c);
        }
        for (OrderSummary orderSumm : orderSummaries) {
            SOM_OrderConfirmationTemplateContent orderTemplateContent = new SOM_OrderConfirmationTemplateContent();
            orderTemplateContent.billingCity      = orderSumm.BillingCity;
            //orderTemplateContent.billingCountry   = generateCountryMappingLabel(orderSumm.BillingCountry);
            orderTemplateContent.billingCountry   = generateCountryMappingLabel(orderSumm.language__c , orderSumm.BillingCountry);
            orderTemplateContent.billingFirstName = orderSumm.BillingContactFirstName__c;
            orderTemplateContent.billingLastName  = orderSumm.BillingContactLastName__c;
            orderTemplateContent.billingStreet    = orderSumm.BillingStreet;
            orderTemplateContent.billingZipcode   = orderSumm.BillingPostalCode;
            if(orderSumm.BillingState == null){
                orderTemplateContent.billingState = '';
            }else{
                orderTemplateContent.billingState     = orderSumm.BillingState;
            }
            orderTemplateContent.channel          = orderSumm.SalesChannel.SalesChannelName;
            orderTemplateContent.orderDate        = orderSumm.OrderedDate;
            orderTemplateContent.orderNumber      = orderSumm.OrderNumber;
            orderTemplateContent.subtotal         = orderSumm.TotalAmount;
            orderTemplateContent.tax              = orderSumm.TotalTaxAmount.setScale(2);
            orderTemplateContent.total            = orderSumm.GrandTotalAmount;
            orderTemplateContent.currencyCode     = orderSumm.CurrencyIsoCode;
            
            /*if(orderSumm.SalesChannel.SalesChannelName == 'CEGID'){
orderTemplateContent.orderType		  = 'StoreToWeb';
}else if(orderSumm.SalesChannel.SalesChannelName == 'Rimowa') {
if( orderSumm.tech_os_store_shipping_method__c > 0)
orderTemplateContent.orderType		  = 'C&C';
else if ( orderSumm.tech_os_store_shipping_method__c == 0)
orderTemplateContent.orderType		  = 'Ecom';
}*/
            
            if(!orderSumm.OrderDeliveryGroupSummaries?.isEmpty()){
                orderTemplateContent.deliveryCity    = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCity;
                //orderTemplateContent.deliveryCountry = generateCountryMappingLabel(orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry);
                orderTemplateContent.deliveryCountry = generateCountryMappingLabel(orderSumm.language__c , orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry);
                orderTemplateContent.deliveryName    = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToName;
                orderTemplateContent.deliveryStreet  = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToStreet;
                orderTemplateContent.deliveryZipcode = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToPostalCode;
                if(orderSumm.OrderDeliveryGroupSummaries[0].DeliverToState == null) {
                    orderTemplateContent.deliveryState = '';
                }
                else{
                    orderTemplateContent.deliveryState   = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToState;
                }
                
                if(orderSumm.SalesChannel.SalesChannelName == SOM_Constants.SALES_CHANNEL_RIMOWA && orderSumm.tech_os_store_shipping_method__c > 0){
                    orderTemplateContent.PickupStoreName = orderSumm.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_StoreName__c ;
                    //orderTemplateContent.PickupStoreName = 'orderSumm.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_StoreName__c' ;
                }/*else{
orderTemplateContent.PickupStoreName = '';
}*/
                
            }
            orderTemplateContent.items = new List<Order_Item>();
            
            
            if(!orderSumm.OrderItemSummaries?.isEmpty()){
                for(OrderItemSummary orderItemSumm : orderSumm.OrderItemSummaries){
                    Order_Item lineItem = new Order_Item();
                    lineItem.sku             = orderItemSumm.StockKeepingUnit;
                    lineItem.name            = orderItemSumm.Name;
                    lineItem.description     = orderItemSumm.Description;
                    lineItem.isPreorder      = orderItemSumm.IsPreOrder__c;
                    lineItem.amount          = orderItemSumm.TotalLineAmount;
                    lineItem.quantity        = orderItemSumm.Quantity;
                    lineItem.preorderMessage = orderItemSumm.PreOrder_message__c;
                    //lineItem.imageURL		 = orderItemSumm.Product2.ImageURL__c;
                    lineItem.imageURL		 = orderItemSumm.Product2.ImageUrl1__c != null ? orderItemSumm.Product2.ImageUrl1__c : orderItemSumm.Product2.ImageURL__c;
                    if(orderItemSumm.Type == SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT){
                    	ReservedAtLocation	 = orderItemSumm.ReservedAtLocation.Name;
                    }
                    //lineItem.isCC 			 = orderItemSumm.Tech_IsCC__c;
                    
                    /*Schema.Location location = (Schema.Location) orderItemSumm.ReservedAtLocation;
System.debug('Location' +  location );
if(location.LocationType == SOM_Constants.STORE ) {
lineItem.isCC = true;
}
else{
lineItem.isCC = false;
}*/
                    
                    orderTemplateContent.items.add(lineItem);
                    
                } 
            }
            TransactionalEmail__c orderTransactionalEmail = new TransactionalEmail__c();
            orderTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CREATED;
            orderTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            orderTransactionalEmail.OrderSummary__c = orderSumm.Id;
            orderTransactionalEmail.Client__c       = orderSumm.AccountId;
            orderTransactionalEmail.EmailContent__c = JSON.serializePretty(orderTemplateContent, true);
            orderTransactionalEmail.Email__c        = orderSumm.BillingEmailAddress;
            orderTransactionalEmail.CountrySite__c  = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry;
            
            if(orderSumm.SalesChannel.SalesChannelName == SOM_Constants.SALES_CHANNEL_RIMOWA && orderSumm.tech_os_store_shipping_method__c > 0) {
            	orderTransactionalEmail.bccEmail__c  	= EmailStoreMap.get(ReservedAtLocation);
            }            
            orderTransactionalEmailsList.add(orderTransactionalEmail);
        }
        return orderTransactionalEmailsList;
    }
    
    public static List<TransactionalEmail__c> generateReturnReceptionTransactionalEmails(Set<String> recordIds) {
        List<TransactionalEmail__c> returnTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<ReturnOrder> returnOrders = [SELECT Id,ReturnOrderNumber,OrderSummaryId, OrderSummary.language__c,OrderSummary.BillingContactFirstName__c,OrderSummary.BillingContactLastName__c,OrderSummary.OrderNumber, OrderSummary.SalesChannel.SalesChannelName, AccountId,OrderSummary.Account.PersonEmail,OrderSummary.BillingEmailAddress ,
                                          (SELECT Id,Product2.StockKeepingUnit,Product2.ImageURL__c, Product2.ImageUrl1__c, QuantityReceived, TotalAmount, Description, CurrencyIsoCode 
                                           FROM ReturnOrderLineItems)
                                          FROM ReturnOrder WHERE Id IN :recordIds];
        
        List<String> osIds = new List<String>();
        for (ReturnOrder retOrder : returnOrders) {
            osIds.add(retOrder.OrderSummaryId);
        }
        
        Map<Id, OrderSummary> orderSummariesMap = new Map<Id, OrderSummary>([SELECT Id, (SELECT Id,DeliverToCountry, CLICKCOLLECT_StoreName__c, DeliverToCity, DeliverToState, DeliverToStreet, DeliverToPostalCode, DeliverToName 
                                                                                         FROM OrderDeliveryGroupSummaries) FROM OrderSummary WHERE Id IN :osIds]);
        
        for (ReturnOrder retOrder : returnOrders) {
            SOM_ReturnRecievedTemplateContent returnTemplateContent = new SOM_ReturnRecievedTemplateContent();
            returnTemplateContent.returnOrderNumber = retOrder.ReturnOrderNumber;
            returnTemplateContent.orderNumber       = retOrder.OrderSummary.OrderNumber;
            returnTemplateContent.channel           = retOrder.OrderSummary.SalesChannel.SalesChannelName;
            returnTemplateContent.billingFirstName  = retOrder.OrderSummary.BillingContactFirstName__c;
            returnTemplateContent.billingLastName   = retOrder.OrderSummary.BillingContactLastName__c;
            
            if(!retOrder.ReturnOrderLineItems?.isEmpty()){
                for(ReturnOrderLineItem returnLineItem : retOrder.ReturnOrderLineItems){
                    Return_Line_Item lineItem = new Return_Line_Item();
                    lineItem.name     = returnLineItem.Description;
                    lineItem.sku      = returnLineItem.Product2.StockKeepingUnit;
                    lineItem.quantity = Integer.valueOf(returnLineItem.QuantityReceived);
                    lineItem.amount   = returnLineItem.TotalAmount;
                    lineItem.currencyCode = returnLineItem.CurrencyIsoCode;
                    //lineItem.imageURL		 = returnLineItem.Product2.ImageURL__c;
                    lineItem.imageURL		 = returnLineItem.Product2.ImageUrl1__c != null ? returnLineItem.Product2.ImageUrl1__c : returnLineItem.Product2.ImageURL__c;
                    returnTemplateContent.items.add(lineItem);
                } 
            }
            
            TransactionalEmail__c returnTransactionalEmail = new TransactionalEmail__c();
            returnTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_RECEIVED;
            returnTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            returnTransactionalEmail.OrderSummary__c = retOrder.OrderSummary.Id;
            returnTransactionalEmail.Client__c       = retOrder.AccountId;
            returnTransactionalEmail.EmailContent__c = JSON.serializePretty(returnTemplateContent, true);
            returnTransactionalEmail.Email__c        = retOrder.OrderSummary.BillingEmailAddress;
            returnTransactionalEmail.CountrySite__c  = orderSummariesMap.get(retOrder.OrderSummaryId).OrderDeliveryGroupSummaries[0].DeliverToCountry;
            //returnTransactionalEmail.LanguageSite__c  = retOrder.OrderSummary.language__c != null ? retOrder.OrderSummary.language__c : generateLanguageSiteLabel(orderSummariesMap.get(retOrder.OrderSummaryId).OrderDeliveryGroupSummaries[0].DeliverToCountry) ;
            
            returnTransactionalEmailsList.add(returnTransactionalEmail);
        }
        return returnTransactionalEmailsList;
    }
    
    public static List<TransactionalEmail__c> generateOrderReadyForPickupTransactionalEmails(Set<String> recordIds) {
        
        List<TransactionalEmail__c> OrderReadyForPickupTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<OrderSummary> orderSummaries = [SELECT Id, language__c, OrderNumber, OrderedDate, SalesChannel.SalesChannelName, 
                                             BillingContactFirstName__c, BillingContactLastName__c, BillingStreet, BillingPostalCode, 
                                             BillingCity, BillingCountry, AccountId,Account.PersonEmail,BillingEmailAddress , tech_os_store_shipping_method__c,
                                             (SELECT Id, ReservedAtLocationId, ReservedAtLocation.Name,Type 
                                              FROM OrderItemSummaries where Type ='Order Product'),                                             
                                             (SELECT Id, DeliverToCountry, DeliverToCity, CLICKCOLLECT_StoreName__c,CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c, DeliverToStreet, DeliverToPostalCode, DeliverToName , STORE_OPENING_FR__c, STORE_OPENING_MO__c, STORE_OPENING_SA__c, STORE_OPENING_SU__c, STORE_OPENING_TH__c, STORE_OPENING_TU__c, STORE_OPENING_WE__c
                                              FROM OrderDeliveryGroupSummaries), (SELECT Id, FulfilledFromLocation.Name FROM FulfillmentOrders)
                                             FROM OrderSummary WHERE Id IN :recordIds];
        
        Map<String, String> EmailStoreMap = new Map<String, String>();
        List<Store__c> StoreLocation = [Select Id,SourceStoreId__c, Email__c from Store__c ];
        for(Store__c Store:StoreLocation) {
            EmailStoreMap.put(Store.SourceStoreId__c,Store.Email__c);
        }
        C_C_order_Cancellation_and_Reminder__mdt CC_Setting = [SELECT nbrOfDaysBeforeCancellation__c, nbrOfDaysBeforeReminder__c FROM C_C_order_Cancellation_and_Reminder__mdt];
        
        
        for (OrderSummary orderSum:orderSummaries) {
            /*DateTime TE_Created_Date		 = System.now().addDays(Integer.valueOf(CC_Setting.nbrOfDaysBeforeReminder__c));
            DateTime TE_Cancellation_Date 	 = System.now().addDays(Integer.valueOf(CC_Setting.nbrOfDaysBeforeCancellation__c));
            //DateTime dt = DateTime.parse((dt1).format());
            String str_Created_Date 		 = (TE_Created_Date).format('yyyy-MM-dd\'T\'HH:mm:ss');
            String str_Cancellation_Date	 = (TE_Cancellation_Date).format('yyyy-MM-dd\'T\'HH:mm:ss');
            
            DateTime resultCreated_Date = DateTime.ValueofGmt(str_Created_Date.replace('T', ' ')); 
            DateTime resultCancellation_Date = DateTime.ValueofGmt(str_Cancellation_Date.replace('T', ' ')); 
			
            orderSum.TE_Created_Date__c 	 = resultCreated_Date;
            orderSum.TE_Cancellation_Date__c = resultCancellation_Date;*/
            
            orderSum.TE_Created_Date__c 	 = System.now().addDays(Integer.valueOf(CC_Setting.nbrOfDaysBeforeReminder__c));
            orderSum.TE_Cancellation_Date__c = System.now().addDays(Integer.valueOf(CC_Setting.nbrOfDaysBeforeCancellation__c));

            
            SOM_OrderReadyForPickupTemplateContent orderReadyForPickupTemplateContent = new SOM_OrderReadyForPickupTemplateContent();
            PickUpAddress adress = new PickUpAddress();
            PickupSchedule sched = new PickupSchedule();
            PickupInformation pickupInfo = new PickupInformation();
            orderReadyForPickupTemplateContent.orderDate        = orderSum.OrderedDate;
            orderReadyForPickupTemplateContent.orderNumber      = orderSum.OrderNumber;
            orderReadyForPickupTemplateContent.channel          = orderSum.SalesChannel.SalesChannelName;
            orderReadyForPickupTemplateContent.storeCode        = orderSum.FulfillmentOrders[0].FulfilledFromLocation.Name;
            
            if(!orderSum.OrderDeliveryGroupSummaries?.isEmpty()){
                adress.city       = orderSum.OrderDeliveryGroupSummaries[0].DeliverToCity;
                adress.country    = generateCountryMappingLabel(orderSum.language__c , orderSum.OrderDeliveryGroupSummaries[0].DeliverToCountry);
                adress.name       = orderSum.OrderDeliveryGroupSummaries[0].DeliverToName;
                adress.street     = orderSum.OrderDeliveryGroupSummaries[0].DeliverToStreet;
                adress.postalCode = orderSum.OrderDeliveryGroupSummaries[0].DeliverToPostalCode;
                adress.PickupStoreName = orderSum.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_StoreName__c ;
                
                orderReadyForPickupTemplateContent.pickupAddress = adress;
                sched.storeOpMO   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_MO__c;
                sched.storeOpTU   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_TU__c;
                sched.storeOpWE   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_WE__c;
                sched.storeOpTH   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_TH__c;
                sched.storeOpFR   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_FR__c;
                sched.storeOpSA   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_SA__c;
                sched.storeOpSU   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_SU__c;
                orderReadyForPickupTemplateContent.pickupSchedule =sched;
                
                pickupInfo.firstName   = orderSum.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_pickup_firstName__c;
                pickupInfo.lastName   = orderSum.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_pickup_lastName__c;
                orderReadyForPickupTemplateContent.pickupInformation =pickupInfo;
            }
                        
            TransactionalEmail__c pickUpTransactionalEmail = new TransactionalEmail__c();
            pickUpTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_READY_FOR_PICKUP;
            pickUpTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            pickUpTransactionalEmail.OrderSummary__c = orderSum.Id;
            pickUpTransactionalEmail.Client__c       = orderSum.AccountId;
            pickUpTransactionalEmail.EmailContent__c = JSON.serializePretty(orderReadyForPickupTemplateContent, true);
            pickUpTransactionalEmail.Email__c        = orderSum.BillingEmailAddress;
            pickUpTransactionalEmail.CountrySite__c  = orderSum.OrderDeliveryGroupSummaries[0].DeliverToCountry;
            //pickUpTransactionalEmail.LanguageSite__c = orderSum.language__c != null ? orderSum.language__c : generateLanguageSiteLabel(orderSum.OrderDeliveryGroupSummaries[0].DeliverToCountry);
            if(orderSum.SalesChannel.SalesChannelName == SOM_Constants.SALES_CHANNEL_RIMOWA && orderSum.tech_os_store_shipping_method__c > 0) {
            	pickUpTransactionalEmail.bccEmail__c  	= EmailStoreMap.get(orderSum.OrderItemSummaries[0].ReservedAtLocation.Name);
            }            

            OrderReadyForPickupTransactionalEmailsList.add(pickUpTransactionalEmail);
            
        }
        Update orderSummaries;
        return OrderReadyForPickupTransactionalEmailsList;
        
    }
    
	public static List<TransactionalEmail__c> generateOrderCCAutomaticCancellationTransactionalEmails(Set<String> recordIds) {
        
        List<TransactionalEmail__c> OrderCCAutomaticCancellationTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<OrderSummary> orderSummaries = [SELECT Id, language__c, OrderNumber, OrderedDate, SalesChannel.SalesChannelName, 
                                             BillingContactFirstName__c, BillingContactLastName__c, BillingStreet, BillingPostalCode, 
                                             BillingCity, BillingCountry, AccountId,Account.PersonEmail,BillingEmailAddress , tech_os_store_shipping_method__c,
                                             (SELECT Id, ReservedAtLocationId, ReservedAtLocation.Name,Type, OriginalOrderItem.TotalLineAmount, StockKeepingUnit,
                                              Name, CurrencyIsoCode, QuantityOrdered, Product2.ImageURL__c, Product2.ImageUrl1__c
                                              FROM OrderItemSummaries where Type ='Order Product'),                                             
                                             (SELECT Id, DeliverToCountry, DeliverToCity, CLICKCOLLECT_StoreName__c,CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c, DeliverToStreet, DeliverToPostalCode, DeliverToName , STORE_OPENING_FR__c, STORE_OPENING_MO__c, STORE_OPENING_SA__c, STORE_OPENING_SU__c, STORE_OPENING_TH__c, STORE_OPENING_TU__c, STORE_OPENING_WE__c
                                              FROM OrderDeliveryGroupSummaries), (SELECT Id, FulfilledFromLocation.Name FROM FulfillmentOrders),
                                             (SELECT Id, CreatedDate FROM TransactionalEmails__r where Template__c ='OrderReadyForPickup')
                                             FROM OrderSummary WHERE Id IN :recordIds];
        
        Map<String, String> EmailStoreMap = new Map<String, String>();
        Map<String, String> PhoneStoreMap = new Map<String, String>();
        List<Store__c> StoreLocation = [Select Id,SourceStoreId__c, Email__c,Phone__c from Store__c ];
        for(Store__c Store:StoreLocation) {
            EmailStoreMap.put(Store.SourceStoreId__c,Store.Email__c);
            PhoneStoreMap.put(Store.SourceStoreId__c,Store.Phone__c);
        }

        for (OrderSummary orderSum:orderSummaries) {
            SOM_OrderCCAutomaticCancellationTemplateContent orderCCAutomaticCancellationTemplateContent = new SOM_OrderCCAutomaticCancellationTemplateContent();
            PickUpAddress adress = new PickUpAddress();
            PickupSchedule sched = new PickupSchedule();
            orderCCAutomaticCancellationTemplateContent.orderDate        		= orderSum.OrderedDate;
            orderCCAutomaticCancellationTemplateContent.orderNumber      		= orderSum.OrderNumber;
            orderCCAutomaticCancellationTemplateContent.storePhone       		= PhoneStoreMap.get(orderSum.OrderItemSummaries[0].ReservedAtLocation.Name);
            orderCCAutomaticCancellationTemplateContent.storeEmail       		= EmailStoreMap.get(orderSum.OrderItemSummaries[0].ReservedAtLocation.Name);
            orderCCAutomaticCancellationTemplateContent.orderAcceptanceDate     = orderSum.TransactionalEmails__r[0].CreatedDate;
            
            orderCCAutomaticCancellationTemplateContent.items = new List<Order_Item>();
            
            if(!orderSum.OrderItemSummaries?.isEmpty()){
                for(OrderItemSummary orderItemSumm : orderSum.OrderItemSummaries){
                    Order_Item lineItem = new Order_Item();
                    lineItem.sku             = orderItemSumm.StockKeepingUnit;
                    lineItem.name            = orderItemSumm.Name;
            		lineItem.currencyCode    = orderItemSumm.CurrencyIsoCode;
                    lineItem.amount          = orderItemSumm.OriginalOrderItem.TotalLineAmount;
                    lineItem.quantity        = orderItemSumm.QuantityOrdered;
                    lineItem.imageURL		 = orderItemSumm.Product2.ImageUrl1__c != null ? orderItemSumm.Product2.ImageUrl1__c : orderItemSumm.Product2.ImageURL__c;
                    orderCCAutomaticCancellationTemplateContent.items.add(lineItem);
                    
                } 
            }
            
            if(!orderSum.OrderDeliveryGroupSummaries?.isEmpty()){
                adress.city       = orderSum.OrderDeliveryGroupSummaries[0].DeliverToCity;
                adress.country    = generateCountryMappingLabel(orderSum.language__c , orderSum.OrderDeliveryGroupSummaries[0].DeliverToCountry);
                adress.name       = orderSum.OrderDeliveryGroupSummaries[0].DeliverToName;
                adress.street     = orderSum.OrderDeliveryGroupSummaries[0].DeliverToStreet;
                adress.postalCode = orderSum.OrderDeliveryGroupSummaries[0].DeliverToPostalCode;
                adress.PickupStoreName = orderSum.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_StoreName__c ;
                
                orderCCAutomaticCancellationTemplateContent.pickupAddress = adress;
                sched.storeOpMO   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_MO__c;
                sched.storeOpTU   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_TU__c;
                sched.storeOpWE   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_WE__c;
                sched.storeOpTH   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_TH__c;
                sched.storeOpFR   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_FR__c;
                sched.storeOpSA   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_SA__c;
                sched.storeOpSU   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_SU__c;
                orderCCAutomaticCancellationTemplateContent.pickupSchedule = sched;
                
            }
                        
            TransactionalEmail__c CCAutomaticCancellationTransactionalEmail = new TransactionalEmail__c();
            CCAutomaticCancellationTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_ORDER_CC_AUTOMATIC_CANCEL;
            CCAutomaticCancellationTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            CCAutomaticCancellationTransactionalEmail.OrderSummary__c = orderSum.Id;
            CCAutomaticCancellationTransactionalEmail.Client__c       = orderSum.AccountId;
            CCAutomaticCancellationTransactionalEmail.EmailContent__c = JSON.serializePretty(orderCCAutomaticCancellationTemplateContent, true);
            CCAutomaticCancellationTransactionalEmail.Email__c        = orderSum.BillingEmailAddress;
            CCAutomaticCancellationTransactionalEmail.CountrySite__c  = orderSum.OrderDeliveryGroupSummaries[0].DeliverToCountry;
            CCAutomaticCancellationTransactionalEmail.bccEmail__c     = EmailStoreMap.get(orderSum.OrderItemSummaries[0].ReservedAtLocation.Name);
            
            OrderCCAutomaticCancellationTransactionalEmailsList.add(CCAutomaticCancellationTransactionalEmail);
            
        }
        return OrderCCAutomaticCancellationTransactionalEmailsList;
        
    }

	public static List<TransactionalEmail__c> generateOrderCCReminderTransactionalEmails(Set<String> recordIds) {
        
        List<TransactionalEmail__c> OrderCCAutomaticCancellationTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<OrderSummary> orderSummaries = [SELECT Id, language__c, OrderNumber, OrderedDate, SalesChannel.SalesChannelName, 
                                             BillingContactFirstName__c, BillingContactLastName__c, BillingStreet, BillingPostalCode, 
                                             BillingCity, BillingCountry, AccountId,Account.PersonEmail,BillingEmailAddress , tech_os_store_shipping_method__c,
                                             (SELECT Id, ReservedAtLocationId, ReservedAtLocation.Name,Type 
                                              FROM OrderItemSummaries where Type ='Order Product'),                                             
                                             (SELECT Id, DeliverToCountry, DeliverToCity, CLICKCOLLECT_StoreName__c,CLICKCOLLECT_pickup_firstName__c, CLICKCOLLECT_pickup_lastName__c, DeliverToStreet, DeliverToPostalCode, DeliverToName , STORE_OPENING_FR__c, STORE_OPENING_MO__c, STORE_OPENING_SA__c, STORE_OPENING_SU__c, STORE_OPENING_TH__c, STORE_OPENING_TU__c, STORE_OPENING_WE__c
                                              FROM OrderDeliveryGroupSummaries), (SELECT Id, FulfilledFromLocation.Name FROM FulfillmentOrders),
                                             (SELECT Id, CreatedDate FROM TransactionalEmails__r where Template__c ='OrderReadyForPickup' )
                                             FROM OrderSummary WHERE Id IN :recordIds];
        
        Map<String, String> EmailStoreMap = new Map<String, String>();
        Map<String, String> PhoneStoreMap = new Map<String, String>();
        List<Store__c> StoreLocation = [Select Id,SourceStoreId__c, Email__c,Phone__c from Store__c ];
        for(Store__c Store:StoreLocation) {
            EmailStoreMap.put(Store.SourceStoreId__c,Store.Email__c);
            PhoneStoreMap.put(Store.SourceStoreId__c,Store.Phone__c);
        }
        
        C_C_order_Cancellation_and_Reminder__mdt CC_Setting = [SELECT nbrOfDaysBeforeCancellation__c, nbrOfDaysBeforeReminder__c FROM C_C_order_Cancellation_and_Reminder__mdt];
        
        for (OrderSummary orderSum:orderSummaries) {
            //orderSum.TE_Created_Date__c 	 = orderSum.TransactionalEmails__r[0].CreatedDate + CC_Setting.nbrOfDaysBeforeReminder__c;
            //orderSum.TE_Cancellation_Date__c = orderSum.TransactionalEmails__r[0].CreatedDate + CC_Setting.nbrOfDaysBeforeCancellation__c;
            SOM_OrderCC_ReminderTemplateContent orderCCReminderTemplateContent = new SOM_OrderCC_ReminderTemplateContent();
            PickUpAddress adress = new PickUpAddress();
            PickupSchedule sched = new PickupSchedule();
            PickupInformation pickupInfo = new PickupInformation();
            orderCCReminderTemplateContent.lastDayBeforeCancellation   	= orderSum.TransactionalEmails__r[0].CreatedDate + CC_Setting.nbrOfDaysBeforeCancellation__c;
            orderCCReminderTemplateContent.orderNumber      			= orderSum.OrderNumber;
            orderCCReminderTemplateContent.storePhone       			= PhoneStoreMap.get(orderSum.OrderItemSummaries[0].ReservedAtLocation.Name);
            orderCCReminderTemplateContent.storeEmail       			= EmailStoreMap.get(orderSum.OrderItemSummaries[0].ReservedAtLocation.Name);
            orderCCReminderTemplateContent.orderAcceptanceDate     		= orderSum.TransactionalEmails__r[0].CreatedDate;
            
            if(!orderSum.OrderDeliveryGroupSummaries?.isEmpty()){
                adress.city       = orderSum.OrderDeliveryGroupSummaries[0].DeliverToCity;
                adress.country    = generateCountryMappingLabel(orderSum.language__c , orderSum.OrderDeliveryGroupSummaries[0].DeliverToCountry);
                adress.name       = orderSum.OrderDeliveryGroupSummaries[0].DeliverToName;
                adress.street     = orderSum.OrderDeliveryGroupSummaries[0].DeliverToStreet;
                adress.postalCode = orderSum.OrderDeliveryGroupSummaries[0].DeliverToPostalCode;
                adress.PickupStoreName = orderSum.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_StoreName__c ;
                
                orderCCReminderTemplateContent.pickupAddress = adress;
                sched.storeOpMO   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_MO__c;
                sched.storeOpTU   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_TU__c;
                sched.storeOpWE   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_WE__c;
                sched.storeOpTH   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_TH__c;
                sched.storeOpFR   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_FR__c;
                sched.storeOpSA   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_SA__c;
                sched.storeOpSU   = orderSum.OrderDeliveryGroupSummaries[0].STORE_OPENING_SU__c;
                orderCCReminderTemplateContent.pickupSchedule = sched;
                
                pickupInfo.firstName   = orderSum.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_pickup_firstName__c;
                pickupInfo.lastName   = orderSum.OrderDeliveryGroupSummaries[0].CLICKCOLLECT_pickup_lastName__c;
                orderCCReminderTemplateContent.pickupInformation =pickupInfo;

                
            }
                        
            TransactionalEmail__c CCReminderTransactionalEmail = new TransactionalEmail__c();
            CCReminderTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CC_REMINDER;
            CCReminderTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_DRAFT;
            CCReminderTransactionalEmail.OrderSummary__c = orderSum.Id;
            CCReminderTransactionalEmail.Client__c       = orderSum.AccountId;
            CCReminderTransactionalEmail.EmailContent__c = JSON.serializePretty(orderCCReminderTemplateContent, true);
            CCReminderTransactionalEmail.Email__c        = orderSum.BillingEmailAddress;
            CCReminderTransactionalEmail.CountrySite__c  = orderSum.OrderDeliveryGroupSummaries[0].DeliverToCountry;

            OrderCCAutomaticCancellationTransactionalEmailsList.add(CCReminderTransactionalEmail);
            
        }
        Update orderSummaries;
        return OrderCCAutomaticCancellationTransactionalEmailsList;
        
    }
    
    public static List<TransactionalEmail__c> generateReturnOrderCreationTransactionalEmails(Set<String> recordIds) {
        List<TransactionalEmail__c> returnTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<ReturnOrder> returnOrders = [SELECT Id, OrderSummary.OrderNumber, OrderSummary.language__c, OrderSummary.SalesChannel.SalesChannelName,OrderSummary.BillingContactLastName__c,OrderSummary.BillingContactFirstName__c,
                                          OrderSummaryId,AccountId,OrderSummary.Account.PersonEmail,OrderSummary.BillingEmailAddress  FROM ReturnOrder WHERE Id IN :recordIds];
        
        List<String> osIds = new List<String>();
        for (ReturnOrder retOrder : returnOrders) {
            osIds.add(retOrder.OrderSummaryId);
        }
        
        Map<Id, OrderSummary> orderSummariesMap = new Map<Id, OrderSummary>([SELECT Id, (SELECT Id,DeliverToCountry, CLICKCOLLECT_StoreName__c, DeliverToCity, DeliverToState, DeliverToStreet, DeliverToPostalCode, DeliverToName 
                                                                                         FROM OrderDeliveryGroupSummaries) FROM OrderSummary WHERE Id IN :osIds]);
        
        for (ReturnOrder retOrder : returnOrders) {
            SOM_ReturnOrderCreatedTemplateContent returnCreationTemplateContent = new SOM_ReturnOrderCreatedTemplateContent();
            returnCreationTemplateContent.orderNumber       = retOrder.OrderSummary.OrderNumber;
            returnCreationTemplateContent.channel           = retOrder.OrderSummary.SalesChannel.SalesChannelName;
            returnCreationTemplateContent.billingFirstName  = retOrder.OrderSummary.BillingContactFirstName__c;
            returnCreationTemplateContent.billingLastName   = retOrder.OrderSummary.BillingContactLastName__c;
            
            TransactionalEmail__c returnCreationTransactionalEmail = new TransactionalEmail__c();
            returnCreationTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_CREATED;
            returnCreationTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            returnCreationTransactionalEmail.OrderSummary__c = retOrder.OrderSummaryId;
            returnCreationTransactionalEmail.Client__c       = retOrder.AccountId;
            returnCreationTransactionalEmail.EmailContent__c = JSON.serializePretty(returnCreationTemplateContent, true);
            returnCreationTransactionalEmail.Email__c        = retOrder.OrderSummary.BillingEmailAddress;
            returnCreationTransactionalEmail.CountrySite__c  = orderSummariesMap.get(retOrder.OrderSummaryId).OrderDeliveryGroupSummaries[0].DeliverToCountry ;
            //returnCreationTransactionalEmail.LanguageSite__c = retOrder.OrderSummary.language__c != null ? retOrder.OrderSummary.language__c : generateLanguageSiteLabel(orderSummariesMap.get(retOrder.OrderSummaryId).OrderDeliveryGroupSummaries[0].DeliverToCountry);
            
            returnTransactionalEmailsList.add(returnCreationTransactionalEmail);
        }
        return returnTransactionalEmailsList;
    }
    
    public static List<TransactionalEmail__c> generateRefundValidationTransactionalEmails(Set<String> recordIds) {
        List<TransactionalEmail__c> refundValidationTransactionalEmailsList = new List<TransactionalEmail__c>();
        Set<String> orderSummaryIdsList                                     = new Set<String>();
        Set<Id> CreditMemoIds                                                                               = new Set<Id>();
        Map<Id, OrderSummary> orderSummariesById  = new Map<Id, OrderSummary>();
        
        
        List<CreditMemo> creditMemos = [SELECT Id, Refund__c, Refund__r.CurrencyIsoCode, Refund__r.Amount,CreditDate, CreditMemoNumber, ReferenceEntityId, CurrencyIsoCode, 
                                        (SELECT Id, TaxRate, RelatedLine.RelatedLine.ReferenceEntityItemId, RelatedLine.RelatedLine.Product2.ImageURL__c , RelatedLine.RelatedLine.Product2.ImageUrl1__c, RelatedLine.RelatedLine.Product2.Name, 
                                         RelatedLine.RelatedLine.CurrencyIsoCode, RelatedLine.AdjustmentAmountWithTax, RelatedLine.AdjustmentTaxAmount, RelatedLine.AdjustmentAmount,
                                         RelatedLine.ChargeAmountWithTax, RelatedLine.ChargeTaxAmount, RelatedLine.ChargeAmount,RelatedLine.ReturnOrderLineItem__r.QuantityReceived,
                                         RelatedLine.RelatedLine.Product2.StockKeepingUnit, RelatedLine.RelatedLine.Name, ReturnOrderLineItem__c, Product2.StockKeepingUnit, 
                                         ReturnOrderLineItem__r.QuantityReceived,
                                         RelatedLine.Product2.Name,RelatedLine.Product2.ImageURL__c,RelatedLine.Product2.ImageUrl1__c, RelatedLine.Product2.StockKeepingUnit,RelatedLine.CurrencyIsoCode,
                                         Product2.Name, ChargeTaxAmount,Product2.ImageURL__c,Product2.ImageUrl1__c, ChargeAmount, ChargeAmountWithTax , CurrencyIsoCode, TYPEOF RelatedLine.ReferenceEntityItem
                                         WHEN OrderItemSummary THEN Id,TaxRate__c END
                                         FROM CreditMemoLines WHERE Type = :SOM_Constants.INVOICE_LINE_TYPE_TAX) 
                                        FROM CreditMemo WHERE Refund__c IN :recordIds];
        if(!creditMemos?.isEmpty()){
            for(CreditMemo creditMemoItem : creditMemos){
                CreditMemoIds.add(creditMemoItem.Id);
            }
        }
        
        
        System.debug('CreditMemoIds' + CreditMemoIds);
        
        if(creditMemos?.isEmpty()){
            return refundValidationTransactionalEmailsList;
        }
        for(CreditMemo creditNote : creditMemos){
            if(creditNote.ReferenceEntityId != null) orderSummaryIdsList.add(creditNote.ReferenceEntityId);
        }
        if(!orderSummaryIdsList.isEmpty()){
            for(OrderSummary orderSumm : [SELECT Id,OrderNumber, AccountId, BillingContactFirstName__c, BillingContactLastName__c, BillingCity, BillingCountry, BillingPostalCode,
                                          BillingStreet, SalesChannel.SalesChannelName,Account.PersonEmail,language__c,BillingEmailAddress ,
                                          (SELECT Id, DeliverToCountry, DeliverToCity, DeliverToStreet, DeliverToPostalCode, DeliverToName FROM OrderDeliveryGroupSummaries), 
                                          (SELECT Id, invoiceNumber__c FROM Invoices WHERE Status =: SOM_Constants.INVOICE_POSTED) 
                                          FROM OrderSummary WHERE Id IN : orderSummaryIdsList]){
                                              orderSummariesById.put(orderSumm.Id, orderSumm);                                        
                                          }
        } 
        OrderItemSummary TaxRatee  = [Select TaxRate__c FROM OrderItemSummary  WHERE OrderSummaryId IN : orderSummaryIdsList limit 1];
        for (CreditMemo creditNote : creditMemos){
            if(!orderSummariesById.containsKey(creditNote.ReferenceEntityId)){
                continue;
            }
            SOM_RefundValidationTemplateContent refundValidationTemplateContent = new SOM_RefundValidationTemplateContent();
            OrderSummary orderSumm = orderSummariesById.get(creditNote.ReferenceEntityId);
            if(orderSumm.Invoices?.isEmpty() || orderSumm.OrderDeliveryGroupSummaries?.isEmpty()){
                continue;
            }
            refundValidationTemplateContent.billingCity      = orderSumm.BillingCity;
            //refundValidationTemplateContent.billingCountry   = generateCountryMappingLabel(orderSumm.BillingCountry);
            refundValidationTemplateContent.billingCountry   = generateCountryMappingLabel(orderSumm.language__c , orderSumm.billingCountry);
            refundValidationTemplateContent.billingStreet    = orderSumm.BillingStreet;
            refundValidationTemplateContent.billingZipcode   = orderSumm.BillingPostalCode;
            refundValidationTemplateContent.billingFirstName = orderSumm.BillingContactFirstName__c;
            refundValidationTemplateContent.billingLastName  = orderSumm.BillingContactLastName__c;
            refundValidationTemplateContent.channel          = orderSumm.SalesChannel.SalesChannelName;
            refundValidationTemplateContent.creditNoteNumber = creditNote.CreditMemoNumber;
            refundValidationTemplateContent.creditNoteDate   = creditNote.CreditDate;
            refundValidationTemplateContent.orderNumber      = orderSumm.OrderNumber;
            refundValidationTemplateContent.refundAmount     = creditNote.Refund__r.Amount;
            refundValidationTemplateContent.refundCurrency   = creditNote.Refund__r.CurrencyIsoCode;
            refundValidationTemplateContent.deliveryCity     = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCity;
            //refundValidationTemplateContent.deliveryCountry  = generateCountryMappingLabel(orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry);
            refundValidationTemplateContent.deliveryCountry  = generateCountryMappingLabel(orderSumm.language__c , orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry );
            refundValidationTemplateContent.deliveryName     = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToName;
            refundValidationTemplateContent.deliveryStreet   = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToStreet;
            refundValidationTemplateContent.deliveryZipcode  = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToPostalCode;
            refundValidationTemplateContent.invoiceNumber    = orderSumm.Invoices[0].InvoiceNumber__c;       
            if(!creditNote.CreditMemoLines?.isEmpty()){
                for(CreditMemoLine creditMemoLine : creditNote.CreditMemoLines){
                    SOM_RefundedItems lineItem = new SOM_RefundedItems();
                    
                    
                    if(creditMemoLine.RelatedLine.RelatedLine != null){
                        lineItem.name         = creditMemoLine.RelatedLine.RelatedLine.Product2.Name;
                        lineItem.sku          = creditMemoLine.RelatedLine.RelatedLine.Product2.StockKeepingUnit;
                        lineItem.currencyCode = creditMemoLine.RelatedLine.RelatedLine.CurrencyIsoCode;
                        //lineItem.imageURL                = creditMemoLine.RelatedLine.RelatedLine.Product2.ImageURL__c;
                        lineItem.imageURL                = creditMemoLine.RelatedLine.RelatedLine.Product2.ImageUrl1__c != null ? creditMemoLine.RelatedLine.RelatedLine.Product2.ImageUrl1__c : creditMemoLine.RelatedLine.RelatedLine.Product2.ImageURL__c;
                    } else{
                        lineItem.name         = creditMemoLine.RelatedLine.Product2.Name;
                        lineItem.sku          = creditMemoLine.RelatedLine.Product2.StockKeepingUnit;
                        lineItem.currencyCode = creditMemoLine.RelatedLine.CurrencyIsoCode;
                        //lineItem.imageURL                = creditMemoLine.RelatedLine.Product2.ImageURL__c;
                        lineItem.imageURL                = creditMemoLine.RelatedLine.Product2.ImageUrl1__c != null ? creditMemoLine.RelatedLine.Product2.ImageUrl1__c : creditMemoLine.RelatedLine.Product2.ImageURL__c;
                    }
                    
                    
                    
                    lineItem.quantity     = Integer.valueOf(creditMemoLine.RelatedLine.ReturnOrderLineItem__r.QuantityReceived);
                    if(creditMemoLine.RelatedLine.ChargeAmount != null){
                        lineItem.subtotal     = creditMemoLine.RelatedLine.ChargeAmount?.setScale(2);
                        lineItem.tax          = creditMemoLine.RelatedLine.ChargeTaxAmount?.setScale(2);
                        lineItem.total        = creditMemoLine.RelatedLine.ChargeAmountWithTax?.setScale(2);
                    }else if(creditMemoLine.RelatedLine.ChargeAmount == null){
                        lineItem.subtotal     = creditMemoLine.RelatedLine.AdjustmentAmount?.setScale(2);
                        lineItem.tax          = creditMemoLine.RelatedLine.AdjustmentTaxAmount?.setScale(2);
                        lineItem.total        = creditMemoLine.RelatedLine.AdjustmentAmountWithTax?.setScale(2);
                    } 
                    lineItem.taxRate          =TaxRatee.TaxRate__c;
                    
                    /*if (creditMemoLine.RelatedLine.ReferenceEntityItem instanceof OrderItemSummary) {
OrderItemSummary item = (OrderItemSummary) creditMemoLine.RelatedLine.ReferenceEntityItem;
lineItem.taxRate = item.TaxRate__c;
}*/
                    refundValidationTemplateContent.refundedItems.add(lineItem);
                } 
            }
            TransactionalEmail__c refundValidationTransactionalEmail = new TransactionalEmail__c();
            refundValidationTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_CONFIRMATION;
            refundValidationTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            refundValidationTransactionalEmail.OrderSummary__c = creditNote.ReferenceEntityId;
            refundValidationTransactionalEmail.Client__c       = orderSumm.AccountId;
            refundValidationTransactionalEmail.EmailContent__c = JSON.serializePretty(refundValidationTemplateContent, true);
            refundValidationTransactionalEmail.Email__c        = orderSumm.BillingEmailAddress;
            refundValidationTransactionalEmail.CountrySite__c  = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry;
            //refundValidationTransactionalEmail.LanguageSite__c = orderSumm.language__c != null ? orderSumm.language__c : generateLanguageSiteLabel(orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry);
            
            refundValidationTransactionalEmailsList.add(refundValidationTransactionalEmail);
        }
        return refundValidationTransactionalEmailsList;
    }
    
    
    public static List<TransactionalEmail__c> generateRefundWithoutCreditMemoTransactionalEmails(Set<String> recordIds) {
        List<TransactionalEmail__c> transactionalEmails = new List<TransactionalEmail__c>();
        List<Refund> refunds = [SELECT ID, Amount, 	ValidationDate__c, CurrencyIsoCode, OrderPaymentSummary.OrderSummaryId FROM Refund WHERE Id IN :recordIds];
        List<Id> orderSummaryIds = new List<Id>();
        for (Refund refund:refunds) {
            orderSummaryIds.add(refund.OrderPaymentSummary.OrderSummaryId);
        }
        //get data
        Map<Id, OrderSummary> orderSummaryMap = new Map<Id, OrderSummary>([SELECT Id,OrderNumber, AccountId,Account.PersonEmail,BillingEmailAddress , BillingContactFirstName__c, BillingContactLastName__c, BillingCity, BillingCountry, BillingPostalCode,
                                                                           BillingStreet,BillingState, SalesChannel.SalesChannelName, language__c,
                                                                           (SELECT Id, DeliverToCountry, DeliverToCity, DeliverToStreet, DeliverToPostalCode, DeliverToState, DeliverToName FROM OrderDeliveryGroupSummaries), 
                                                                           (SELECT Id, invoiceNumber__c FROM Invoices WHERE Status = :SOM_Constants.INVOICE_POSTED),
                                                                           (SELECT Id, Product2.StockKeepingUnit, Product2.Name, Product2.ImageURL__c,Product2.ImageUrl1__c, CurrencyIsoCode, QuantityCanceled, TaxRate__c, OriginalOrderItem.Quantity, OriginalOrderItem.UnitPrice, OriginalOrderItem.TotalTaxAmount, 
                                                                            OriginalOrderItem.TotalAmtWithTax FROM OrderItemSummaries WHERE QuantityCanceled > 0) FROM OrderSummary WHERE Id IN :orderSummaryIds]);
        for (Refund refund:refunds) {
            SOM_RefundWithoutCreditMemoTemplateContent refundWithoutCreditMemoEmail = new SOM_RefundWithoutCreditMemoTemplateContent();
            refundWithoutCreditMemoEmail.refundAmount   = refund.Amount;
            refundWithoutCreditMemoEmail.refundCurrency = refund.CurrencyIsoCode;
            refundWithoutCreditMemoEmail.refundDate     = refund.ValidationDate__c;
            OrderSummary orderSum = orderSummaryMap.get(refund.OrderPaymentSummary.OrderSummaryId);
            refundWithoutCreditMemoEmail.orderNumber = orderSum.OrderNumber;
            refundWithoutCreditMemoEmail.billingFirstName = orderSum.BillingContactFirstName__c;
            refundWithoutCreditMemoEmail.billingLastName  = orderSum.BillingContactLastName__c;
            refundWithoutCreditMemoEmail.billingCity      = orderSum.BillingCity;
            //refundWithoutCreditMemoEmail.billingCountry   = generateCountryMappingLabel(orderSum.BillingCountry);
            refundWithoutCreditMemoEmail.billingCountry   = generateCountryMappingLabel(orderSum.language__c, orderSum.billingCountry);
            refundWithoutCreditMemoEmail.billingStreet    = orderSum.BillingStreet;
            refundWithoutCreditMemoEmail.billingState     = orderSum.BillingState;
            refundWithoutCreditMemoEmail.billingZipcode   = orderSum.BillingPostalCode;
            refundWithoutCreditMemoEmail.deliveryCity     = orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToCity;
            //refundWithoutCreditMemoEmail.deliveryCountry  = generateCountryMappingLabel(orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToCountry);
            refundWithoutCreditMemoEmail.deliveryCountry  = generateCountryMappingLabel(orderSum.language__c , orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToCountry);
            refundWithoutCreditMemoEmail.deliveryName     = orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToName;
            refundWithoutCreditMemoEmail.deliveryState    = orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToState;
            refundWithoutCreditMemoEmail.deliveryStreet   = orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToStreet;
            refundWithoutCreditMemoEmail.deliveryZipcode  = orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToPostalCode;
            if (orderSum.invoices != null && !orderSum.invoices.isEmpty())
                refundWithoutCreditMemoEmail.invoiceNumber = orderSum.invoices.get(0).invoiceNumber__c;
            refundWithoutCreditMemoEmail.channel = orderSum.SalesChannel.SalesChannelName;
            for (OrderItemSummary orderItemSum:orderSum.OrderItemSummaries) {
                SOM_RefundedItems item = new SOM_RefundedItems();
                item.currencyCode      = orderItemSum.CurrencyIsoCode;
                item.name              = orderItemSum.Product2.Name;
                item.quantity          = Integer.valueOf(orderItemSum.QuantityCanceled);
                item.sku               = orderItemSum.Product2.StockKeepingUnit;
                item.taxRate           = orderItemSum.TaxRate__c;
                item.subtotal          = orderItemSum.OriginalOrderItem.UnitPrice * orderItemSum.QuantityCanceled;
                item.tax               = ((orderItemSum.OriginalOrderItem.TotalTaxAmount/orderItemSum.OriginalOrderItem.Quantity) * orderItemSum.QuantityCanceled).setScale(2); 
                item.total             = ((orderItemSum.OriginalOrderItem.TotalAmtWithTax/orderItemSum.OriginalOrderItem.Quantity) * orderItemSum.QuantityCanceled).setScale(2); 
                //item.imageURL	   	   = orderItemSum.Product2.ImageURL__c;
                item.imageURL	   	   = orderItemSum.Product2.ImageUrl1__c != null ? orderItemSum.Product2.ImageUrl1__c : orderItemSum.Product2.ImageURL__c;
                refundWithoutCreditMemoEmail.items.add(item);
            }
            
            TransactionalEmail__c refundWithoutCreditEmail = new TransactionalEmail__c();
            refundWithoutCreditEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_ON_MISSING_PRODUCT;
            refundWithoutCreditEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            refundWithoutCreditEmail.OrderSummary__c = orderSum.Id;
            refundWithoutCreditEmail.Client__c       = orderSum.AccountId;
            refundWithoutCreditEmail.Email__c        = orderSum.BillingEmailAddress;
            refundWithoutCreditEmail.EmailContent__c = JSON.serializePretty(refundWithoutCreditMemoEmail, true);
            refundWithoutCreditEmail.CountrySite__c  = orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToCountry;
            //refundWithoutCreditEmail.LanguageSite__c = orderSum.language__c != null ? orderSum.language__c : generateLanguageSiteLabel(orderSum.OrderDeliveryGroupSummaries.get(0).DeliverToCountry);
            
            transactionalEmails.add(refundWithoutCreditEmail);
        }
        
        return transactionalEmails;
    } 
    
    
        /**
* @description Method to generate Order Canceled Transactional Email
* @author MEGHRAS Maha | 04-06-2024 
* @param recordIds 
* @return List<TransactionalEmail__c> 
**/
    public static List<TransactionalEmail__c> generateOrderCanceledTransactionalEmails(Set<String> recordIds) {
        List<TransactionalEmail__c> orderTransactionalEmailsList = new List<TransactionalEmail__c>();
        List<OrderSummary> orderSummaries = [SELECT Id, OrderNumber , OrderedDate, SalesChannel.SalesChannelName, OriginalOrder.GrandTotalAmount,OriginalOrder.TotalTaxAmount,OriginalOrder.TotalAmount,
                                             BillingContactFirstName__c, BillingContactLastName__c, BillingState, BillingStreet, BillingPostalCode,tech_os_store_shipping_method__c, 
                                             BillingCity, BillingCountry, TotalAmount, TotalTaxAmount,language__c, GrandTotalAmount, AccountId,Account.PersonEmail, CurrencyIsoCode,BillingEmailAddress ,
                                             (SELECT Id,StockKeepingUnit,Name,LineNumber,Product2.ImageURL__c, Product2.ImageUrl1__c, ReservedAtLocationId, Quantity,QuantityCanceled, TotalLineAmount, Description, 
                                              IsPreOrder__c, PreOrder_message__c,CurrencyIsoCode,UnitPrice, OriginalOrderItem.TotalLineAmount, ReservedAtLocation.Name
                                              FROM OrderItemSummaries where Type ='Order Product' ORDER BY LineNumber ASC),
                                             (SELECT Id,DeliverToCountry, CLICKCOLLECT_StoreName__c, DeliverToCity, DeliverToState, DeliverToStreet, DeliverToPostalCode, DeliverToName 
                                              FROM OrderDeliveryGroupSummaries)
                                             FROM OrderSummary WHERE Id IN :recordIds];
        
        Map<String, String> EmailStoreMap = new Map<String, String>();
        List<Store__c> StoreLocation = [Select Id,SourceStoreId__c, Email__c,Phone__c from Store__c ];
        for(Store__c Store:StoreLocation) {
            EmailStoreMap.put(Store.SourceStoreId__c,Store.Email__c);
        }

        
        for (OrderSummary orderSumm : orderSummaries) {
            SOM_OrderCanceledTemplateContent orderTemplateContent = new SOM_OrderCanceledTemplateContent();
            orderTemplateContent.orderNumber      = orderSumm.OrderNumber;
            orderTemplateContent.subtotal         = orderSumm.OriginalOrder.TotalAmount;
            orderTemplateContent.tax              = orderSumm.OriginalOrder.TotalTaxAmount.setScale(2);
            orderTemplateContent.total            = orderSumm.OriginalOrder.GrandTotalAmount;
            //orderTemplateContent.currencyCode     = orderSumm.CurrencyIsoCode;
            if(orderSumm.SalesChannel.SalesChannelName == SOM_Constants.SALES_CHANNEL_CEGID){
                orderTemplateContent.storeLocator         = STW_URL__c.getOrgDefaults().STW_URL__c+orderSumm.BillingCountry.toLowerCase()+'/'+orderSumm.language__c.toLowerCase()+'/'+SOM_Constants.STORELOCATOR_URL;
                //orderTemplateContent.storeLocator		  = SOM_Constants.Rimowa_URL+orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry+'/'+orderSumm.language__c+'/'+'storelocator';
                }
            orderTemplateContent.items = new List<Order_Item>();
            
            
            if(!orderSumm.OrderItemSummaries?.isEmpty()){
                for(OrderItemSummary orderItemSumm : orderSumm.OrderItemSummaries){
                    Order_Item lineItem = new Order_Item();
                    lineItem.sku             = orderItemSumm.StockKeepingUnit;
                    lineItem.name            = orderItemSumm.Name;
            		lineItem.currencyCode    = orderItemSumm.CurrencyIsoCode;
                    lineItem.amount          = orderItemSumm.OriginalOrderItem.TotalLineAmount;
                    lineItem.quantity        = orderItemSumm.QuantityCanceled;
                    lineItem.imageURL		 = orderItemSumm.Product2.ImageUrl1__c != null ? orderItemSumm.Product2.ImageUrl1__c : orderItemSumm.Product2.ImageURL__c;
                    orderTemplateContent.items.add(lineItem);
                    
                } 
            }
            
            TransactionalEmail__c orderTransactionalEmail = new TransactionalEmail__c();
            orderTransactionalEmail.Template__c     = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CANCELED;
            orderTransactionalEmail.Status__c       = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND;
            orderTransactionalEmail.OrderSummary__c = orderSumm.Id;
            orderTransactionalEmail.Client__c       = orderSumm.AccountId;
            orderTransactionalEmail.EmailContent__c = JSON.serializePretty(orderTemplateContent, true);
            orderTransactionalEmail.Email__c        = orderSumm.BillingEmailAddress;
            orderTransactionalEmail.CountrySite__c  = orderSumm.OrderDeliveryGroupSummaries[0].DeliverToCountry;
            if(orderSumm.SalesChannel.SalesChannelName == SOM_Constants.SALES_CHANNEL_RIMOWA && orderSumm.tech_os_store_shipping_method__c > 0) {
            	orderTransactionalEmail.bccEmail__c  	= EmailStoreMap.get(orderSumm.OrderItemSummaries[0].ReservedAtLocation.Name);
            }          
            
            orderTransactionalEmailsList.add(orderTransactionalEmail);
        }
        return orderTransactionalEmailsList;
    }

    
    public static String generateCountryMappingLabel(String LanguageISOcode, String CountryIso) {
        try {
            if (LanguageISOcode == null || LanguageISOcode == ''){
                List<CountryMapping__mdt> listMet = [SELECT MasterLabel, LanguageISOcode__c,CountryLabel__c FROM CountryMapping__mdt WHERE DefaultCountryLabel__c =: true AND CoutryISOcode__c =: CountryIso];
                if(!listMet.isEmpty())
                    return listMet[0].CountryLabel__c;
                else
                    return CountryIso;
            } else{
                List<CountryMapping__mdt> listMet = [SELECT MasterLabel, LanguageISOcode__c,CountryLabel__c FROM CountryMapping__mdt WHERE LanguageISOcode__c = :LanguageISOcode AND CoutryISOcode__c =: CountryIso];
                if(!listMet.isEmpty())
                    return listMet[0].CountryLabel__c;
                else
                    return CountryIso;
            }
        } catch (Exception e) {
            return CountryIso ;
        }
    } 
    
    public static Boolean checkIsGlobalE (Id recordId) {
        Boolean Check = false;
        if(recordId.getSObjectType().getDescribe().getName() == SOM_Constants.CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME){
            CorrectiveInvoice__c  cInvoice = [SELECT Id,OriginalInvoiceId__c  FROM CorrectiveInvoice__c WHERE Id = :recordId];
			return Check = [SELECT id , IsGlobalE__c,(SELECT id , OrderDeliveryMethod.isHomeDelivery__c FROM OrderDeliveryGroupSummaries LIMIT 1) 
                                             FROM OrderSummary 
                                             WHERE 
                                             ID IN (SELECT ReferenceEntityId FROM invoice WHERE Id =: cInvoice.OriginalInvoiceId__c)].IsGlobalE__c;

         }else if(recordId.getSObjectType().getDescribe().getName() == SOM_Constants.INVOICE_SOBJECT_TYPE_NAME){
          	return Check = [SELECT id , IsGlobalE__c,(SELECT id , OrderDeliveryMethod.isHomeDelivery__c FROM OrderDeliveryGroupSummaries LIMIT 1) 
                                             FROM OrderSummary 
                                             WHERE 
                                             ID IN (SELECT ReferenceEntityId FROM invoice WHERE Id =: recordId)].IsGlobalE__c;

         }else if(recordId.getSObjectType().getDescribe().getName() == SOM_Constants.SHIPMENT_SOBJECT_TYPE_NAME){
        	 return Check = [SELECT  FulfillmentOrder.OrderSummary.IsGlobalE__c FROM Shipment WHERE Id =: recordId].FulfillmentOrder.OrderSummary.IsGlobalE__c;             
         }else if(recordId.getSObjectType().getDescribe().getName() == SOM_Constants.ORDER_SUMMARY_SOBJECT_TYPE_NAME){
        	 return Check = [SELECT  IsGlobalE__c FROM OrderSummary WHERE Id =: recordId].IsGlobalE__c;
         }else if(recordId.getSObjectType().getDescribe().getName() == SOM_Constants.RETURN_ORDER_SOBJECT_TYPE_NAME){
        	 return Check = [SELECT OrderSummary.IsGlobalE__c FROM ReturnOrder WHERE Id =: recordId].OrderSummary.IsGlobalE__c;
         }else if(recordId.getSObjectType().getDescribe().getName() == SOM_Constants.REFUND_SOBJECT_TYPE_NAME){
        	 return Check = [SELECT  OrderPaymentSummary.OrderSummary.IsGlobalE__c FROM Refund WHERE Id =: recordId].OrderPaymentSummary.OrderSummary.IsGlobalE__c;
         }
        return false;
    } 
    
    /*public static String generateLanguageSiteLabel(String CountryLabel) {
        try {
            if (CountryLabel != null && CountryLabel != ''){
        		List<CountryMapping__mdt> listMet = [SELECT DefaultCountryLabel__c ,CountryLabel__c,LanguageISOcode__c FROM CountryMapping__mdt WHERE DefaultCountryLabel__c =: true AND CoutryISOcode__c =: CountryLabel];
                if(!listMet.isEmpty())
                    return listMet[0].LanguageISOcode__c;
                else
                    return CountryLabel;
            } else{
                return 'Language';
            }
        } catch (Exception e) {
            return 'Language' ;
        }
    } */
    
    public class SOM_GenerateTransactionalEmailInput{
        @InvocableVariable(label='Template Name' description='Template of the email' required=true)
        public String templateName;
        @InvocableVariable(label='Record Id' description='Record Id generating the email' required=true)
        public String recordId; //record Id generating the email(shipment, invoice, orderSummary... etc).
    }
    
    public class SOM_InvoiceTemplateContent{
        public String orderNumber;
        public String channel;
        public String orderCivility;
        public String billingFirstName;
        public String billingLastName;
        public String billingStreet;
        public String billingZipcode;
        public String billingCity;
        public String billingState;
        public String billingCountry;
        public String deliveryName;
        public String deliveryStreet;
        public String deliveryZipcode;
        public String deliveryCity;
        public String deliveryState;
        public String deliveryCountry;
        public String invoiceNumber;
        public Decimal invoiceAmount;
        public String invoiceCurrency;
        public String invoiceURL; 
    }
    
    public class SOM_ShipmentConfirmationTemplateContent {
        public String orderNumber;
        public String channel;
        public String deliveryName;
        public String deliveryStreet;
        public String deliveryPostalCode;
        public String deliveryCity;
        public String deliveryCountry;
        public String deliveryState;
        public List<SOM_Shipment_Data> shipments;
        
        public SOM_ShipmentConfirmationTemplateContent(){
            this.shipments = new List<SOM_Shipment_Data>();
        }
    }
    public class SOM_Shipment_Data {   
        public String trackingNumber;
        public String carrier;
        public String shippingService;
    }
    
    public class SOM_Additional_Shipment_Details {   
        public String orderSummaryId;
        public String accountId;
        public String deliveryCount;
    }
    
    public class SOM_OrderCanceledTemplateContent{
        public String storeLocator;
        public String orderNumber;
        public Decimal subtotal;
        public Decimal tax;
        public Decimal total;
        public String currencyCode;	
        public List<Order_Item> items;
        public SOM_OrderCanceledTemplateContent(){
            this.items = new List<Order_Item>();
        }
    }
    
    public class SOM_OrderConfirmationTemplateContent{
        public String orderNumber;
        public Datetime orderDate;
        public String channel;
        public String billingFirstName;
        public String billingLastName;
        public String billingStreet;
        public String billingZipcode;
        public String billingCity;
        public String billingCountry;
        public String billingState;
        public String currencyCode;	
        public String deliveryName;
        public String deliveryStreet;
        public String deliveryZipcode;
        public String deliveryCity;
        public String deliveryCountry;
        public String deliveryState;
        public String PickupStoreName;
        //public String orderType;
        public Decimal subtotal;
        public Decimal tax;
        public Decimal total;
        public List<Order_Item> items;
        public SOM_OrderConfirmationTemplateContent(){
            this.items = new List<Order_Item>();
        }
    }
    
    public class Order_Item{
        public String sku;
        public String name;
        public Decimal quantity;
        public Decimal amount;
        public String description;
        public Boolean isPreorder;
        //public Boolean isCC;
        public String preorderMessage;
        public String imageURL;
        public String currencyCode;	
    }
    
    public class SOM_ReturnRecievedTemplateContent{
        public String orderNumber;	
        public String channel;	
        public String returnOrderNumber;
        public String billingFirstName;
        public String billingLastName;
        public List<Return_Line_Item> items;
        public SOM_ReturnRecievedTemplateContent(){
            this.items = new List<Return_Line_Item>();
        }
    }
    
    public class Return_Line_Item {
        public String sku;	
        public String name;	
        public Integer quantity;	
        public Decimal amount;	
        public String currencyCode;	
        public String imageURL;	
        
    }
    
    public class SOM_OrderCC_ReminderTemplateContent{
        public Datetime lastDayBeforeCancellation;
        public String orderNumber;
        public Datetime orderAcceptanceDate;
        public PickUpAddress pickupAddress;
        public PickupSchedule pickupSchedule; 
        public String storePhone;   
        public String storeEmail;
        public PickupInformation pickupInformation;
        
    }
    
    public class SOM_OrderCCAutomaticCancellationTemplateContent{
        public Datetime orderDate;
        public String orderNumber;
        public Datetime orderAcceptanceDate;
        public PickUpAddress pickupAddress;
        public PickupSchedule pickupSchedule; 
        public String storePhone;   
        public String storeEmail;  
        public List<Order_Item> items;
        public SOM_OrderCCAutomaticCancellationTemplateContent(){
            this.items = new List<Order_Item>();
        }
    }
    
    public class SOM_OrderReadyForPickupTemplateContent{
        public Datetime orderDate;
        public String orderNumber;
        public String channel;
        public PickUpAddress pickupAddress;
        public PickupSchedule pickupSchedule; 
        public PickupInformation pickupInformation; 
        public String storeCode;      
        
    }
    
    public class PickupInformation{
        public String firstName;
        public String lastName;
    }
    
    public class PickUpAddress{
        public String city;
        public String country;
        public String name;
        public String street;
        public String postalCode;
        public String PickupStoreName;
    }
    
    public class PickupSchedule{
        public String storeOpMO;
        public String storeOpTU;
        public String storeOpWE;
        public String storeOpTH;
        public String storeOpFR;
        public String storeOpSA;
        public String storeOpSU;
    }
    
    public class SOM_ReturnOrderCreatedTemplateContent{
        public String orderNumber;	
        public String channel;	
        public String billingFirstName;	
        public String billingLastName;	
    }
    
    public class SOM_RefundValidationTemplateContent{
        public String billingFirstName;
        public String billingLastName;
        public String billingStreet;
        public String billingZipcode;
        public String billingCity;
        public String billingCountry;
        public String channel;
        public String creditNoteNumber;
        public Date creditNoteDate;
        public String deliveryName;
        public String deliveryStreet;
        public String deliveryZipcode;
        public String deliveryCity;
        public String deliveryCountry;
        public String invoiceNumber;
        public String orderNumber;
        public Decimal refundAmount;
        public String  refundCurrency;
        public SOM_RefundedItems[] refundedItems;
        public SOM_RefundValidationTemplateContent(){
            this.refundedItems = new List<SOM_RefundedItems>();
        }
    }
    
    class SOM_RefundedItems {
        public String sku;
        public String name;
        public Integer quantity;
        public Decimal subtotal;
        public Decimal tax;
        public Decimal taxRate;
        public Decimal total;
        public String currencyCode;
        public String imageURL;
    } 
    
    public class SOM_RefundWithoutCreditMemoTemplateContent{
        public String orderNumber;
        public String channel;
        public String invoiceNumber;
        public String billingFirstName;
        public String billingLastName;
        public String billingStreet;
        public String billingZipcode;
        public String billingCity;
        public String billingState;
        public String billingCountry;
        public String deliveryName;
        public String deliveryStreet;
        public String deliveryZipcode;
        public String deliveryState;
        public String deliveryCity;
        public String deliveryCountry;
        public Datetime refundDate;
        public String refundCurrency;
        public Decimal             refundAmount;
        public SOM_RefundedItems[] items;
        
        public SOM_RefundWithoutCreditMemoTemplateContent(){
            this.items = new List<SOM_RefundedItems>();
        }
    }
    
}
