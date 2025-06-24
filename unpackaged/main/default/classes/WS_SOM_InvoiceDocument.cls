@RestResource(urlMapping='/InvoiceDocument/*')
global with sharing class WS_SOM_InvoiceDocument {

    @HttpDelete
    global static void doDelete() {
        System.debug('call Delete');
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        
        try{
        Id invoiceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        String sObjName = (invoiceId).getSObjectType().getDescribe().getName();
        String OrderSummaryId, FulfilledToCountry;    
        List<Attachment> attachment  = [SELECT Id FROM Attachment WHERE ParentId = :invoiceId LIMIT 1];
            
        if (sObjName == SOM_Constants.INVOICE_SOBJECT_TYPE_NAME){	//Invoice Attachment
        	List<FulfillmentOrder> FOListInvoice  = [SELECT Id,FulfillmentOrder.FulfilledToCountry,OrderSummaryId FROM FulfillmentOrder WHERE InvoiceId = :invoiceId LIMIT 1];
            OrderSummaryId 		= FOListInvoice[0].OrderSummaryId ;
            FulfilledToCountry  = FOListInvoice[0].FulfilledToCountry ;
        }else if(sObjName == SOM_Constants.CREDIT_MEMO_SOBJECT_TYPE_NAME){	//CreditMemo Attachment
        	List<CreditMemo> CreditMemoList  = [SELECT Id,ReferenceEntityId FROM CreditMemo WHERE Id = :invoiceId LIMIT 1];
            OrderSummaryId = CreditMemoList[0].ReferenceEntityId ;
        }else if(OrderSummaryId == null && FulfilledToCountry ==null ){
            res.statusCode = 404;  
        }
        List<OrderPaymentSummary> orderPaymentList = [SELECT Id, Method, OrderSummaryId FROM OrderPaymentSummary WHERE OrderSummaryId = :OrderSummaryId ];        
            if (attachment != null && !attachment.isEmpty()) {
                delete attachment.get(0);
                if ( sObjName == SOM_Constants.CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME || (sObjName == SOM_Constants.INVOICE_SOBJECT_TYPE_NAME &&
                !(orderPaymentList[0].Method == SOM_Constants.CASH_ON_DELIVERY && FulfilledToCountry == SOM_Constants.JP_COUNTRY_CODE))) {
                    
                    triggerEmailGeneration(invoiceId);
                }
            } else {
                res.statusCode = 404;
            }
            
            
        Logs.debug('doDelete Operation', 'WS_SOM_InvoiceDocument', 'doDelete', String.valueOf(req), String.valueOf(res),req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
        Logs.info('doDelete Operation', 'WS_SOM_InvoiceDocument', 'doDelete', String.valueOf(req), String.valueOf(res),req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
    } catch (Exception e) {
        Logs.error(e, 'WS_SOM_InvoiceDocument', 'doDelete Operation', 'doDelete processing request: ' + String.valueOf(req), String.valueOf(res),req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
    }
    }
    @HttpGet
    global static void doGet() {
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
     try{
        String invoiceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Attachment> attachment = [SELECT Id, Body, Name FROM Attachment WHERE ParentId = :invoiceId LIMIT 1];
        if (attachment != null && !attachment.isEmpty()) {
            res.responseBody = attachment.get(0).Body;
        } else {
            res.statusCode = 404;
        }
        Logs.debug('doGet Operation', 'WS_SOM_InvoiceDocument', 'doGet', String.valueOf(req), String.valueOf(res),req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
        Logs.info('doGet Operation', 'WS_SOM_InvoiceDocument', 'doGet', String.valueOf(req), String.valueOf(res),req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
    } catch (Exception e) {
        Logs.error(e, 'WS_SOM_InvoiceDocument', 'doGet Operation', 'doDelete processing request: ' + String.valueOf(req), String.valueOf(res),req.requestURI.substring(req.requestURI.lastIndexOf('/')+1));
    }
    }
    
    public static void triggerEmailGeneration(String invoiceId) {
        try {
            // Create Transactional Email Input
            List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> generateTransactionalEmailInputsList = new List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput>();
            SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput generateTransactionalEmailInput = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
            generateTransactionalEmailInput.templateName = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE;
            generateTransactionalEmailInput.recordId = invoiceId;
            generateTransactionalEmailInputsList.add(generateTransactionalEmailInput);
            
            if (!Test.isRunningTest()) {
                SOM_TransactionalEmailHandler.generateTransactionalEmail(generateTransactionalEmailInputsList);
            }
            Logs.debug('triggerEmailGeneration','WS_SOM_InvoiceDocument','monthExport','','', invoiceId);   
            Logs.info('triggerEmailGeneration','WS_SOM_InvoiceDocument','monthExport','','', invoiceId); 
        } catch (Exception e) {
            Logs.error(e, 'WS_SOM_InvoiceDocument', 'triggerEmailGeneration', '','', invoiceId);
        }
    }
}