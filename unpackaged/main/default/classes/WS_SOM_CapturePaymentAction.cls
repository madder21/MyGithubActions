global with sharing class WS_SOM_CapturePaymentAction {

    @InvocableMethod(label='Capture Payment' description='Capture Payment for the specified fulfillmentOrder Id' callout=true)
    global static List<CapturePaymentActionResponse> capturePayment(List<CapturePaymentActionRequest> requests){
        List<CapturePaymentActionResponse> responseWrapper = new List<CapturePaymentActionResponse>();
        map<String,List<FulfillmentOrderLineItem>> mapFulfillOrdertems = new map<String,List<FulfillmentOrderLineItem>>();
        map<String,FulfillmentOrder> mapFulfillOrder = new map<String,FulfillmentOrder>();
        map<String,paymentAuthorization> mapPaymentAuthoriz = new map<String,paymentAuthorization>();
        set<Id> fulfillmentOrderIds = new set<Id>();
        set<Id> OriginalOrderIds = new set<Id>();
        CapturePaymentActionResponse response              = new CapturePaymentActionResponse();


        for(CapturePaymentActionRequest request:requests){
            fulfillmentOrderIds.add(request.fulfillmetOrderId);
        }

        //Get Fulfillment Order
        FulfillmentOrder[] fulfillmentOrder = [ SELECT Id, OrderSummary.OriginalOrderId, OrderSummary.CurrencyIsoCode,OrderSummary.OrderNumber, 
                                               OrderSummary.BillingCountry, OrderSummary.OrderedDate, FulfilledToCountry, 
                                              (SELECT Id, Quantity, UnitPrice, TotalAmount, TotalTaxAmount, Product2.Name, Product2.ProductCode,Product2.StockKeepingUnit
                                               FROM FulfillmentOrderLineItems) 
                                               FROM FulfillmentOrder WHERE FulfillmentOrder.Capture_Status__c= :SOM_Constants.FULFILLMENT_ORDER_TO_CAPTURE_STATUS 
                                               AND Id IN:fulfillmentOrderIds
                                              ];

                                                                                            

        if (fulfillmentOrder != null && !fulfillmentOrder.isEmpty()) {
            for(FulfillmentOrder fo:fulfillmentOrder){
                OriginalOrderIds.add(fo.OrderSummary.OriginalOrderId);
                mapFulfillOrder.put(fo.Id,fo);
                mapFulfillOrdertems.put(fo.Id,fo.FulfillmentOrderLineItems);
            }
       }

       PaymentAuthorization[] paymentAuthorization = [SELECT Id, PaymentMethodId, PaymentMethod.ImplementorType,
       customerToken__c, GatewayRefNumber, orderRequestID__c, authorizationRequestId__c,PaymentGroup.SourceObjectId  
       FROM PaymentAuthorization 
       WHERE PaymentGroup.SourceObjectId IN :OriginalOrderIds
       ORDER BY Date DESC];

       if (paymentAuthorization != null && !paymentAuthorization.isEmpty()) {
        for(PaymentAuthorization pa:paymentAuthorization){
            mapPaymentAuthoriz.put(pa.PaymentGroup.SourceObjectId,pa);
        }
       }
    
        for(CapturePaymentActionRequest request:requests){   
            try {
                //check fulfillmentOrder
                if (mapFulfillOrdertems.get(request.fulfillmetOrderId) != null) {
                    //Get Payment Authorization
                    if (mapPaymentAuthoriz.get(mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OriginalOrderId) !=null) {
                        //Get OrderItems
                        FulfillmentOrderLineItem[] orderItems = mapFulfillOrdertems.get(request.fulfillmetOrderId);              
                        PaymentRequest capturePaymentRequest  = new PaymentRequest();
                        OrderInformation orderInformation     = new OrderInformation();
                        //Create lineItems
                        List<lineItem> lineItems = getLineItems(orderItems);
                        Double totalAmount       = getTotalAmount(lineItems);
                        //Create AmountDetails
                        AmountDetails amountDetails   = new AmountDetails();
                        amountDetails.amount_currency = mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.CurrencyIsoCode;
                        amountDetails.totalAmounts    = String.valueOf(totalAmount);
                        //Create ClientReferenceInformation
                        ClientReferenceInformation clientReferenceInformation = new ClientReferenceInformation();
                        clientReferenceInformation.code = mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OrderNumber;
                        Sales_Channel_Mapping__mdt salesChannelMapping = [SELECT ChannelId__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c = :mapFulfillOrder.get(request.fulfillmetOrderId).FulfilledToCountry];
                        If (salesChannelMapping != null) {
                            clientReferenceInformation.channelId = salesChannelMapping.ChannelId__c;
                        }
                        orderInformation.amountDetails                   = amountDetails;
                        orderInformation.lineItems                       = lineItems;
                        capturePaymentRequest.clientReferenceInformation = clientReferenceInformation;
                        capturePaymentRequest.orderInformation           = orderInformation;
                        capturePaymentRequest.token                      = RimowaCapturePayment__c.getOrgDefaults().Token__c;
                        capturePaymentRequest.authorizationDateTimeUtc   = mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OrderedDate;
                        capturePaymentRequest.omsOrderId                 = mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OrderNumber;
                        //Payment info
                        PaymentMethodInfo paymentMethodInfo  = getPaymentMethodCode(mapPaymentAuthoriz.get(mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OriginalOrderId));
                        capturePaymentRequest.paymentMethod  = paymentMethodInfo.paymentMethodId;
                        capturePaymentRequest.creditCardType = paymentMethodInfo.cardType;
                        //Authorization info
                        capturePaymentRequest.customerToken          = mapPaymentAuthoriz.get(mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OriginalOrderId).customerToken__c;
                        capturePaymentRequest.paypalOrderRequestId   = mapPaymentAuthoriz.get(mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OriginalOrderId).orderRequestID__c;
                        if (SOM_Constants.DIGITAL_WALLET_TYPE_PAYPAL.equalsIgnoreCase(paymentMethodInfo.type) || capturePaymentRequest.creditCardType == null) {
                            capturePaymentRequest.authorizationRequestId = mapPaymentAuthoriz.get(mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OriginalOrderId).authorizationRequestId__c;
                        } else {
                            capturePaymentRequest.authorizationRequestId = mapPaymentAuthoriz.get(mapFulfillOrder.get(request.fulfillmetOrderId).OrderSummary.OriginalOrderId).GatewayRefNumber;
                        } 
                        //Generate json object
                        JSONGenerator generator = JSON.createGenerator(true);
                        generator.writeObject(capturePaymentRequest);
                        String requestAsString = generator.getAsString();
                        if (requestAsString != null) {
                            requestAsString = requestAsString.replace(SOM_Constants.AMOUNT_CURRENCY, SOM_Constants.CAPTURE_CURRENCY_ATTRIBUTE);
                        }
                        System.debug(requestAsString);
                        //make http callout
                        Http http = new Http();
                        HttpRequest httpRequest = new HttpRequest();
                        httpRequest.setEndpoint(SOM_Constants.CAPTURE_CALLOUT_ENDPOINT);
                        httpRequest.setMethod('POST');
                        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
                        httpRequest.setBody(requestAsString);
                        HttpResponse httpResponse = http.send(httpRequest);
                        System.debug(httpResponse.getBody());
                        if (httpResponse.getStatusCode() == 200) {
                            //Read http response
                            Map<String, Object> httpResponseMap = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
                            response.settlementTransactionId = httpResponseMap.get('settlementTransactionId') != null ? String.valueOf(httpResponseMap.get('settlementTransactionId')) : null;
                            response.decision                = String.valueOf(httpResponseMap.get('decision'));
                            response.reasonCode              = Integer.valueOf(httpResponseMap.get('reasonCode'));
                            response.reconciliationId        = httpResponseMap.get('reconciliationId') != null ? String.valueOf(httpResponseMap.get('reconciliationId')) : null;
                            response.authorizationCode       = httpResponseMap.get('authorizationCode') != null ? String.valueOf(httpResponseMap.get('authorizationCode')) : null;
                            response.amount                  = totalAmount;
                            response.isSucces                = true;
                            response.errorMessage            = httpResponseMap.get('errorDescription') != null ? String.valueOf(httpResponseMap.get('errorDescription')) : null;
                        } else {
                            response.isSucces     = false;
                            response.errorMessage = 'The status code returned was not expected: ' + httpResponse.getStatusCode() + ' ' + httpResponse.getStatus();
                        }
                    } else {
                        System.debug('Payment Authorization is empty, FulfillmentOrderId: ' + request.fulfillmetOrderId);
                        response.isSucces     = false;
                        response.errorMessage = 'Payment Authorization is empty, FulfillmentOrderId: ' + request.fulfillmetOrderId;
                    }
                } else {
                    System.debug('Fulfilment Order is not valid: ' + request.fulfillmetOrderId);
                    response.isSucces     = false;
                    response.errorMessage = 'Fulfilment Order is not valid: ' + request.fulfillmetOrderId;
                }
            } catch(System.QueryException ex) {
                System.debug(ex.getMessage());
                System.debug(ex.getStackTraceString());
                response.isSucces     = false;
                response.errorMessage = ex.getMessage();
            }
        }
        responseWrapper.add(response);
        
        return responseWrapper;
    }

    global static List<LineItem> getLineItems(FulfillmentOrderLineItem[] orderItems){
        List<lineItem> lineItems = new List<LineItem>();
        for (Integer i=0;i<orderItems.size();i++) {
            LineItem lineItem    = new LineItem();
            lineItem.productCode = orderItems[i].Product2.ProductCode;
            lineItem.productName = orderItems[i].Product2.Name;
            lineItem.productSKU  = orderItems[i].Product2.StockKeepingUnit;
            lineItem.quantity    = orderItems[i].Quantity.intValue();
            lineItem.taxAmount   = orderItems[i].TotalTaxAmount * orderItems[i].Quantity.intValue();
            lineItem.totalAmount = orderItems[i].TotalAmount;
            lineItem.unitPrice   = orderItems[i].TotalAmount / orderItems[i].Quantity.intValue();
            lineItems.add(lineItem);
        }

        return lineItems;
    }

    global static PaymentMethodInfo getPaymentMethodCode(PaymentAuthorization paymentAuthorization){
        PaymentMethodInfo paymentMethodInfo = new PaymentMethodInfo();
        //Set payment method id
        if (SOM_Constants.CARD_PAYMENT_METHOD.equalsIgnoreCase(paymentAuthorization.PaymentMethod.ImplementorType)) {
            CardPaymentMethod cardPaymentMethod = [SELECT RI_PaymentMethodId__c, CardType FROM CardPaymentMethod WHERE Id = :paymentAuthorization.PaymentMethodId];
            paymentMethodInfo.paymentMethodId = cardPaymentMethod.RI_PaymentMethodId__c;
            paymentMethodInfo.cardType        = cardPaymentMethod.CardType;

            return paymentMethodInfo;
        } 
        if (SOM_Constants.DIGITAL_WALLET.equalsIgnoreCase(paymentAuthorization.PaymentMethod.ImplementorType)) {
            DigitalWallet digitalWallet = [SELECT RI_PaymentMethodId__c, Type FROM DigitalWallet WHERE Id = :paymentAuthorization.PaymentMethodId];
            paymentMethodInfo.paymentMethodId = digitalWallet.RI_PaymentMethodId__c;
            paymentMethodInfo.type            = digitalWallet.Type;

            return paymentMethodInfo;
        }

        return paymentMethodInfo;
    }

    global static Double getTotalAmount(List<LineItem> lineItems){
        Double totalAmount = 0;
        for (LineItem lineItem : lineItems) {
            totalAmount += lineItem.totalAmount;
        }

        return totalAmount;
    }

    global with sharing class PaymentMethodInfo {
        public String paymentMethodId;
        public String cardType;
        public String type;
    }

    //ClientReferenceInformation
    global with sharing class ClientReferenceInformation {
        public String code;
        public String channelId;
    }

    //AmountDetails
    global with sharing class AmountDetails {
        public String totalAmounts;
        public String amount_currency;
    }
    
    //LineItem
    global with sharing class LineItem {
        public String productCode;
        public String productName;
        public String productSKU;
        public Integer quantity;
        public Double unitPrice;
        public Double totalAmount; 
        public Double taxAmount;
    }

    //OrderInformation
    global with sharing class OrderInformation {
        public AmountDetails amountDetails;
        public List<LineItem> lineItems;
    }

    //PaymentRequest
    global with sharing class PaymentRequest {
        public ClientReferenceInformation clientReferenceInformation;
        public OrderInformation orderInformation;
        public String authorizationRequestId;
        public Datetime authorizationDateTimeUtc;
        public String paymentMethod;
        public String omsOrderId;
        public String token;
        public String creditCardType;
        public String customerToken;
        public String paypalOrderRequestId;
    }

    //capture payment action request
    global with sharing class CapturePaymentActionRequest{
        @InvocableVariable(required=true)
        global ID fulfillmetOrderId;
    }

    //capture payment action result
    global with sharing class CapturePaymentActionResponse{
        @InvocableVariable
        global String  settlementTransactionId;
        @InvocableVariable
        global String  decision;
        @InvocableVariable
        global Integer reasonCode;
        @InvocableVariable
        global String  authorizationCode;
        @InvocableVariable
        global String  reconciliationId;
        @InvocableVariable
        global Double  amount;
        @InvocableVariable
        global Boolean isSucces;
        @InvocableVariable
        global String  errorMessage;
    }
}