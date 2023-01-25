global with sharing class SOM_CreateInvoicePDFFileAction {

    @InvocableMethod(label='Create Invoice PDF File' description='Create Invoice PDF file for the specified Invoice Id')
    global static void CreateInvoicePDFFileAction(List<Id> invoiceId){
        Attachment attachment = new Attachment();
        PageReference page;
        String OrderCountry;
        if(Schema.Invoice.SObjectType == invoiceId.get(0).getSobjectType()){
            Invoice invoice = [SELECT Id, DocumentNumber, InvoiceNumber__c, (SELECT Id, OrderSummary.OrderNumber, OrderSummaryId, FulfilledToCountry FROM FulfillmentOrders) FROM Invoice WHERE Id = :invoiceId.get(0)];
            attachment.Name = getInvoiceName(invoice.InvoiceNumber__c, invoice.FulfillmentOrders.get(0).OrderSummary.OrderNumber);
            OrderCountry = invoice.FulfillmentOrders.get(0).FulfilledToCountry;
            invoice.PDFGenerationStatus__c = SOM_Constants.PDF_GENERATION_STATUS_GENERATED;
            update invoice;
        } else if(Schema.CorrectiveInvoice__c.SObjectType == invoiceId.get(0).getSobjectType()){
            CorrectiveInvoice__c cInvoice = [SELECT Id, Name, OriginalInvoiceId__c FROM CorrectiveInvoice__c WHERE Id = :invoiceId.get(0)];
            Invoice invoice = [SELECT Id, DocumentNumber, InvoiceNumber__c, (SELECT Id, OrderSummary.OrderNumber, OrderSummaryId, FulfilledToCountry FROM FulfillmentOrders) FROM Invoice WHERE Id = :cInvoice.OriginalInvoiceId__c];
            attachment.Name = getInvoiceName(cInvoice.Name, invoice.FulfillmentOrders.get(0).OrderSummary.OrderNumber);
            OrderCountry = invoice.FulfillmentOrders.get(0).FulfilledToCountry;
            cInvoice.PDFGenerationStatus__c = SOM_Constants.PDF_GENERATION_STATUS_GENERATED;
            update cInvoice;
        }
        if(OrderCountry == 'AE') page = new PageReference('/apex/SOM_InvoiceArabicDocument');
        else page = new PageReference('/apex/SOM_InvoiceDocument');
        page.getParameters().put('invoiceId', invoiceId.get(0));
        page.getParameters().put('template', OrderCountry);

        if(Test.isRunningTest()) { 
            attachment.Body = blob.valueOf('Unit.Test');
          } else {
            attachment.Body = page.getContent();
          }
       
        attachment.IsPrivate  = false;
        attachment.ParentId   = invoiceId.get(0);

        insert attachment;
    }

    global static String getInvoiceName(String invoiceNumber, String orderNumber){
        return 'Invoice_'+ orderNumber +'_'+ invoiceNumber+'.pdf';
    }

}