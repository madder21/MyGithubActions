global with sharing class WS_SOM_OrderSummary_CapturePaymentAction {


    @InvocableMethod(label='OrderSummary Capture Payment' description='Capture Payment for the specified OrderSummary Id' callout=true)
    global static List<CapturePaymentActionResponse> orderSummaryCapturePayment(List<CapturePaymentActionRequest> requests){
        CapturePaymentActionRequest request                = requests.get(0);
        Id orderSummaryId                              = request.orderSummaryId;
        List<CapturePaymentActionResponse> responseWrapper = new List<CapturePaymentActionResponse>();
        CapturePaymentActionResponse response              = new CapturePaymentActionResponse();
        try {
            //Get Fullfilment Order
            OrderSummary [] orderSumm = [SELECT Id, OriginalOrderId, CurrencyIsoCode, OrderNumber, BillingCountry, CaptureStatus__c, OrderedDate, 
                                                    (SELECT Id, Quantity, UnitPrice, TotalAmtWithTax, TotalTaxAmount, Product2.Name, Product2.ProductCode, 
                                                    Product2.StockKeepingUnit FROM OrderItemSummaries),(SELECT Id, DeliverToCountry FROM OrderDeliveryGroupSummaries)
                                                    FROM OrderSummary 
                                                    WHERE CaptureStatus__c= :SOM_Constants.ORDER_TO_CAPTURE_STATUS AND Id= :orderSummaryId];
            //check orderSummary
            if (orderSumm != null && !orderSumm.isEmpty()) {
                //Get Payment Authorization
                PaymentAuthorization[] paymentAuthorization = [SELECT Id, PaymentMethodId, PaymentMethod.ImplementorType, customerToken__c, GatewayRefNumber, orderRequestID__c, authorizationRequestId__c FROM PaymentAuthorization WHERE PaymentGroup.SourceObjectId = :orderSumm[0].OriginalOrderId ORDER BY Date DESC LIMIT 1];
                if (paymentAuthorization != null && !paymentAuthorization.isEmpty()) {
                    //Get OrderItems
                    OrderItemSummary[] orderItems = orderSumm[0].OrderItemSummaries;              
                    PaymentRequest capturePaymentRequest = new PaymentRequest();
                    OrderInformation orderInformation    = new OrderInformation();
                    //Create lineItems
                    List<lineItem> lineItems = getLineItems(orderItems);
                    Double totalAmount       = getTotalAmount(lineItems);
                    //Create AmountDetails
                    AmountDetails amountDetails   = new AmountDetails();
                    amountDetails.amount_currency = orderSumm[0].CurrencyIsoCode;
                    amountDetails.totalAmounts    = String.valueOf(totalAmount);
                    //Create ClientReferenceInformation
                    ClientReferenceInformation clientReferenceInformation = new ClientReferenceInformation();
                    clientReferenceInformation.code = orderSumm[0].OrderNumber;
                    Sales_Channel_Mapping__mdt salesChannelMapping = [SELECT ChannelId__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c = :orderSumm[0].OrderDeliveryGroupSummaries[0].DeliverToCountry];
                    If (salesChannelMapping != null) {
                        clientReferenceInformation.channelId = salesChannelMapping.ChannelId__c;
                    }
                    orderInformation.amountDetails                   = amountDetails;
                    orderInformation.lineItems                       = lineItems;
                    capturePaymentRequest.clientReferenceInformation = clientReferenceInformation;
                    capturePaymentRequest.orderInformation           = orderInformation;
                    capturePaymentRequest.token                      = RimowaCapturePayment__c.getOrgDefaults().Token__c;
                    capturePaymentRequest.authorizationDateTimeUtc   = orderSumm[0].OrderedDate;
                    capturePaymentRequest.omsOrderId                 = orderSumm[0].OrderNumber;
                    //Payment info
                    PaymentMethodInfo paymentMethodInfo  = getPaymentMethodCode(paymentAuthorization[0]);
                    capturePaymentRequest.paymentMethod  = paymentMethodInfo.paymentMethodId;
                    capturePaymentRequest.creditCardType = paymentMethodInfo.cardType;
                    //Authorization info
                    capturePaymentRequest.customerToken          = paymentAuthorization[0].customerToken__c;
                    capturePaymentRequest.paypalOrderRequestId   = paymentAuthorization[0].orderRequestID__c;
                    if (SOM_Constants.DIGITAL_WALLET_TYPE_PAYPAL.equalsIgnoreCase(paymentMethodInfo.type) || capturePaymentRequest.creditCardType == null) {
                        capturePaymentRequest.authorizationRequestId = paymentAuthorization[0].authorizationRequestId__c;
                    } else {
                        capturePaymentRequest.authorizationRequestId = paymentAuthorization[0].GatewayRefNumber;
                    } 
                    //Generate json object
                    JSONGenerator generator = JSON.createGenerator(true);
                    generator.writeObject(capturePaymentRequest);
                    String requestAsString = generator.getAsString();
                    if (requestAsString != null) {
                        requestAsString = requestAsString.replace(SOM_Constants.AMOUNT_CURRENCY, SOM_Constants.CAPTURE_CURRENCY_ATTRIBUTE);
                    }
                    //make http callout
                    Http http = new Http();
                    HttpRequest httpRequest = new HttpRequest();
                    httpRequest.setEndpoint(SOM_Constants.CAPTURE_CALLOUT_ENDPOINT);
                    httpRequest.setMethod('POST');
                    httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
                    httpRequest.setBody(requestAsString);
                    HttpResponse httpResponse = http.send(httpRequest);
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
                    response.isSucces     = false;
                    response.errorMessage = 'Payment Authorization is empty, orderSummaryId: ' + orderSummaryId;
                }
            } else {
                response.isSucces     = false;
                response.errorMessage = 'Order Summary is not valid: ' + orderSummaryId;
            }
        } catch(Exception e) {
            response.isSucces     = false;
            response.errorMessage = e.getMessage();   
        }

        responseWrapper.add(response);
        
        return responseWrapper;
    }

    global static List<LineItem> getLineItems(OrderItemSummary[] orderItems){
        List<lineItem> lineItems = new List<LineItem>();
        for (Integer i=0;i<orderItems.size();i++) {
            LineItem lineItem    = new LineItem();
            lineItem.productCode = orderItems[i].Product2.ProductCode;
            lineItem.productName = orderItems[i].Product2.Name;
            lineItem.productSKU  = orderItems[i].Product2.StockKeepingUnit;
            lineItem.quantity    = orderItems[i].Quantity.intValue();
            lineItem.taxAmount   = orderItems[i].TotalTaxAmount * orderItems[i].Quantity.intValue();
            lineItem.totalAmount = orderItems[i].TotalAmtWithTax;
            lineItem.unitPrice   = orderItems[i].TotalAmtWithTax / orderItems[i].Quantity.intValue();
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
        global ID orderSummaryId;
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