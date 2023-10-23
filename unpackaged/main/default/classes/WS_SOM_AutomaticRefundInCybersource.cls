global with sharing class WS_SOM_AutomaticRefundInCybersource {
    
    @InvocableMethod(label='Automatic Refund In Cybersource' description='Automatic Refund In Cybersource' callout=true)
    global static List<AutomaticRefundInCybersourceResponse> AutomaticRefundInCybersource(List<AutomaticRefundInCybersourceRequest> requests){
        AutomaticRefundInCybersourceRequest request                = requests.get(0);
        AutomaticRefundInCybersourceCCRequest requestCC        = new AutomaticRefundInCybersourceCCRequest();
        AutomaticRefundInCybersourcePPLRequest requestPPL        = new AutomaticRefundInCybersourcePPLRequest();
        List<AutomaticRefundInCybersourceResponse> responseWrapper = new List<AutomaticRefundInCybersourceResponse>();
        AutomaticRefundInCybersourceResponse response              = new AutomaticRefundInCybersourceResponse();
        Refund Ref = [select id, Amount from Refund where Id =: request.RefundId];
        try {
            if (request.RefundMethod == 'CC'){
                
                requestCC.url = request.url;
                requestCC.merchantId = request.merchantId;
                requestCC.Password = request.Password;
                requestCC.RefundMethod = request.RefundMethod;
                requestCC.merchantReferenceCode = request.merchantReferenceCode;
                requestCC.amount_currency = request.amount_currency;
                requestCC.grandTotalAmount = String.valueOf(Ref.Amount);
                requestCC.captureRequestID = request.captureRequestID;
            }else if (request.apPaymentType == 'PPL'){
                requestPPL.url = request.url;
                requestPPL.merchantId = request.merchantId;
                requestPPL.Password = request.Password;
                requestPPL.apPaymentType = request.apPaymentType;
                requestPPL.merchantReferenceCode = request.merchantReferenceCode;
                requestPPL.amount_currency = request.amount_currency;
                requestPPL.grandTotalAmount = String.valueOf(Ref.Amount);
                requestPPL.refundRequestID = request.refundRequestID;
            }
            else if (request.apPaymentType == 'KLI'){
                requestPPL.url = request.url;
                requestPPL.merchantId = request.merchantId;
                requestPPL.Password = request.Password;
                requestPPL.apPaymentType = request.apPaymentType;
                requestPPL.merchantReferenceCode = request.merchantReferenceCode;
                requestPPL.amount_currency = request.amount_currency;
                requestPPL.grandTotalAmount = String.valueOf(Ref.Amount);
                requestPPL.refundRequestID = request.refundRequestID;
            }
            //Generate json object
            JSONGenerator generator = JSON.createGenerator(true);
            generator.writeObject(requestCC);
            String requestAsString = generator.getAsString();
            if (requestAsString != null) {
                requestAsString = requestAsString.replace(SOM_Constants.AMOUNT_CURRENCY, SOM_Constants.CAPTURE_CURRENCY_ATTRIBUTE);
            }
            //make http callout
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint(SOM_Constants.REFUND_CALLOUT_ENDPOINT);
            //httpRequest.setEndpoint('callout:TEST/som-eapi/v1/customers/orders/refunds');
            httpRequest.setMethod('POST');
            httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
            //httpRequest.setHeader('client_id', 'd5b6364c170d4cd395f2ed8c7e66bd78');'{!$Credential.UserName}'
            //httpRequest.setHeader('client_secret', '874C78552485422a9be503E29D50f6bF'); 
            httpRequest.setHeader('client_id', '{!$Credential.UserName}');
            httpRequest.setHeader('client_secret', '{!$Credential.Password}'); 
            httpRequest.setBody(requestAsString);
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200 ) {
                //Read http response
                Map<String, Object> httpResponseMap 	  = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
                response.merchantReferenceCode  		  = String.valueOf(httpResponseMap.get('merchantReferenceCode'));
                response.requestID              		  = String.valueOf(httpResponseMap.get('requestID'));
                response.reasonCode             		  = Integer.valueOf(httpResponseMap.get('reasonCode'));
                response.decision        				  = String.valueOf(httpResponseMap.get('decision'));
                response.amount_currency        		  = request.amount_currency;
                response.requestDateTime        		  = String.valueOf(System.Datetime.now());
                response.amount                  		  = request.grandTotalAmount;
                response.reconciliationID                 = String.valueOf(httpResponseMap.get('reconciliationID'));
                response.authorizationCode                = httpResponseMap.get('authorizationCode') != null ? String.valueOf(httpResponseMap.get('authorizationCode')) : null;
                response.processorResponse                = String.valueOf(httpResponseMap.get('processorResponse'));
                response.paymentNetworkTransactionID      = String.valueOf(httpResponseMap.get('paymentNetworkTransactionID'));
                response.invalidField                	  = String.valueOf(httpResponseMap.get('invalidField'));
            }
        }catch(Exception e) {
            System.debug('e.getMessage()' + e.getMessage() );
        }
        responseWrapper.add(response);
        System.debug('responseWrapper' + responseWrapper);
        return responseWrapper;
    }
    
    
    global with sharing class AutomaticRefundInCybersourceCCRequest{
        @InvocableVariable
        public String                            url; 
        @InvocableVariable
        public String                            merchantId;
        @InvocableVariable
        public String                            Password;
        @InvocableVariable
        public String                            RefundMethod;
        @InvocableVariable
        public String                            merchantReferenceCode;
        @InvocableVariable
        public String                            amount_currency; 
        @InvocableVariable
        public String                           grandTotalAmount;
        @InvocableVariable
        public String                            captureRequestID;
    }
    
    global with sharing class AutomaticRefundInCybersourcePPLRequest{
        @InvocableVariable
        public String                            url; 
        @InvocableVariable
        public String                            merchantId;
        @InvocableVariable
        public String                            Password;
        @InvocableVariable
        public String                            merchantReferenceCode;
        @InvocableVariable
        public String                            amount_currency; 
        @InvocableVariable
        public String                           grandTotalAmount;
        @InvocableVariable
        public String                            refundRequestID;
        @InvocableVariable
        public String                            apPaymentType;                
    }
    
    global with sharing class AutomaticRefundInCybersourceKLIRequest{
        @InvocableVariable
        public String                            url; 
        @InvocableVariable
        public String                            merchantId;
        @InvocableVariable
        public String                            Password;
        @InvocableVariable
        public String                            merchantReferenceCode;
        @InvocableVariable
        public String                            amount_currency; 
        @InvocableVariable
        public String                           grandTotalAmount;
        @InvocableVariable
        public String                            refundRequestID;
        @InvocableVariable
        public String                            apPaymentType;                
    }
    
    global with sharing class AutomaticRefundInCybersourceRequest{
        @InvocableVariable
        public String                            url; 
        @InvocableVariable
        public String                            merchantId;
        @InvocableVariable
        public String                            Password;
        @InvocableVariable
        public String                            RefundMethod;
        @InvocableVariable
        public String                            merchantReferenceCode;
        @InvocableVariable
        public String                            amount_currency; 
        @InvocableVariable
        public String                           grandTotalAmount;
        @InvocableVariable
        public String                            captureRequestID;
        @InvocableVariable
        public String                            refundRequestID;
        @InvocableVariable
        public String                            apPaymentType; 
        @InvocableVariable
        public String   						 RefundId;
    }
    
    global with sharing class AutomaticRefundInCybersourceResponse{
        @InvocableVariable
        public String   merchantReferenceCode;
        @InvocableVariable
        public String       requestID;
        @InvocableVariable
        public String   decision; //OK or KO
        @InvocableVariable
        public Integer   reasonCode;
        @InvocableVariable
        public String   amount_currency; 
        @InvocableVariable
        public String   requestDateTime;
        @InvocableVariable
        public String  amount;
        @InvocableVariable
        public String   reconciliationID; 
        @InvocableVariable
        public String   authorizationCode;
        @InvocableVariable
        public String   processorResponse;
        @InvocableVariable
        public String   paymentNetworkTransactionID;
        @InvocableVariable
        public String   invalidField;
        
        
    }
}