@RestResource(urlMapping='/InvoiceDocument/*')
global with sharing class WS_SOM_InvoiceDocument {

    @HttpDelete
    global static void doDelete() {
        System.debug('call Delete');
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug('2');
        String invoiceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        System.debug('3');
        List<Attachment> attachment  = [SELECT Id FROM Attachment WHERE ParentId = :invoiceId LIMIT 1];
        System.debug('4');
        if (attachment != null && !attachment.isEmpty()) {
            delete attachment.get(0);
            if (!invoiceId.contains(SOM_Constants.CREDIT_MEMO_KEY_PREFIX))
                triggerEmailGeneration(invoiceId);
        } else {
            res.statusCode = 404;
        }
    }

    @HttpGet
    global static void doGet() {
        System.debug('call Get');
        RestRequest req  = RestContext.request;
        RestResponse res = RestContext.response;
        String invoiceId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Attachment> attachment = [SELECT Id, Body, Name FROM Attachment WHERE ParentId = :invoiceId LIMIT 1];
        if (attachment != null && !attachment.isEmpty()) {
            res.responseBody = attachment.get(0).Body;
        } else {
            res.statusCode = 404;
        }
    }

    public static void triggerEmailGeneration(String invoiceId){
        //Create Transactional Email Input
        List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> generateTransactionalEmailInputsList = new List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput>();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput generateTransactionalEmailInput = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        generateTransactionalEmailInput.templateName = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE;
        generateTransactionalEmailInput.recordId     = invoiceId;
        generateTransactionalEmailInputsList.add(generateTransactionalEmailInput);

        SOM_TransactionalEmailHandler.generateTransactionalEmail(generateTransactionalEmailInputsList);
    }
}