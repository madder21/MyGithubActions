global with sharing class SOM_CreateInvoicePDFFileAction {

    @Future(callout=true)
    global static void CreateInvoicePDFFileAction(List<Id> invoiceId){
        List<Attachment> Listattachment = new List<Attachment>();
        List<Invoice> listInvoices = new List<Invoice>();
        List<CorrectiveInvoice__c> listCinvoices = new List<CorrectiveInvoice__c>();
        PageReference page;
        String OrderCountry;

        map<Id,invoice> mapInvoices = new map<Id,invoice>([SELECT Id, DocumentNumber, InvoiceNumber__c, 
                                                                (SELECT Id, OrderSummary.OrderNumber, OrderSummaryId, FulfilledToCountry 
                                                                        FROM FulfillmentOrders) 
                                                                FROM Invoice 
                                                                WHERE Id IN :invoiceId]);

        map<Id,CorrectiveInvoice__c> mapCorrectiveInvoice = new map<Id,CorrectiveInvoice__c>([SELECT Id, Name, OriginalInvoiceId__c FROM CorrectiveInvoice__c
                                                                                                 WHERE Id IN:invoiceId]
        
                                                                                                );  
                                                                                       
        set<Id> originalInvoiceIds = new set<Id>();
        if(mapCorrectiveInvoice !=null){
            for(CorrectiveInvoice__c cInvoice:mapCorrectiveInvoice.values()){
                originalInvoiceIds.add(cInvoice.OriginalInvoiceId__c);
            }
        }  
                                                                                        
                                                                                            
        map<Id,Invoice> maporiginalInvoiceIds = new map<Id,invoice>([SELECT Id, DocumentNumber, InvoiceNumber__c,
                                                                         (SELECT Id, OrderSummary.OrderNumber, OrderSummaryId, FulfilledToCountry 
                                                                          FROM FulfillmentOrders) 
                                                                    FROM Invoice WHERE Id in :originalInvoiceIds]);
       
        if(!mapInvoices.isEmpty()){
            for(Id inv:mapInvoices.keySet()){
                Attachment attachment = new Attachment();
                attachment.Name = getInvoiceName(mapInvoices.get(inv).InvoiceNumber__c, mapInvoices.get(inv).FulfillmentOrders.get(0).OrderSummary.OrderNumber);
                OrderCountry    = mapInvoices.get(inv).FulfillmentOrders.get(0).FulfilledToCountry;
                listInvoices.add(new invoice(Id = inv,PDFGenerationStatus__c = SOM_Constants.PDF_GENERATION_STATUS_GENERATED));

                if(OrderCountry == 'AE') page = new PageReference('/apex/SOM_InvoiceArabicDocument');
                else page = new PageReference('/apex/SOM_InvoiceDocument');
                page.getParameters().put('invoiceId', inv);
                page.getParameters().put('template', OrderCountry);

                if(Test.isRunningTest()) { 
                    attachment.Body = blob.valueOf('Unit.Test');
                } else {
                    attachment.Body = page.getContent();
                }
                attachment.ParentId   = inv;
                attachment.IsPrivate  = false;
                Listattachment.add (attachment);
            }

            update listInvoices;
            Insert Listattachment;
            

        }

        if(!mapCorrectiveInvoice.isEmpty()){
            for(Id inv:mapCorrectiveInvoice.keySet()){
                CorrectiveInvoice__c correctiveInvoice = mapCorrectiveInvoice.get(inv);
                Attachment attachment = new Attachment();                
                attachment.Name = getInvoiceName(mapCorrectiveInvoice.get(inv).Name, maporiginalInvoiceIds.get(correctiveInvoice.OriginalInvoiceId__c).FulfillmentOrders.get(0).OrderSummary.OrderNumber);
                OrderCountry    = maporiginalInvoiceIds.get(correctiveInvoice.OriginalInvoiceId__c).FulfillmentOrders.get(0).FulfilledToCountry;
                listCinvoices.add(new CorrectiveInvoice__c(Id = inv,PDFGenerationStatus__c = SOM_Constants.PDF_GENERATION_STATUS_GENERATED));
            
                if(OrderCountry == 'AE') page = new PageReference('/apex/SOM_InvoiceArabicDocument');
                else page = new PageReference('/apex/SOM_InvoiceDocument');
                page.getParameters().put('invoiceId', inv);
                page.getParameters().put('template', OrderCountry);

                if(Test.isRunningTest()) { 
                    attachment.Body = blob.valueOf('Unit.Test');
                } else {
                    attachment.Body = page.getContent();
                }
                attachment.ParentId   = inv;
                attachment.IsPrivate  = false;
                Listattachment.add (attachment);
            }

            update listCinvoices;  
            Insert Listattachment;

        }   


    }

    global static String getInvoiceName(String invoiceNumber, String orderNumber){
        return 'Invoice_'+ orderNumber +'_'+ invoiceNumber+'.pdf';
    }

}