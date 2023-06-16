trigger SOM_StartCreateInvoicePDFFile on InvoiceCreated__e (after insert) {
    
    list<Id> invoiceId = new list<Id>();
    for(InvoiceCreated__e inv:trigger.new){
        invoiceId.add(inv.Invoice_Id__c);
    }

    if(invoiceId.size()>0){
        SOM_CreateInvoicePDFFileAction.CreateInvoicePDFFileAction(invoiceId);
    }
    
}
