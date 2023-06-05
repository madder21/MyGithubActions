trigger SOM_StartCreateInvoicePDFFile on InvoiceCreated__e (after insert) {
    System.debug(' -- SOM_StartCreateInvoicePDFFileAction -- : STEP 1');
    
    list<Id> invoiceId = new list<Id>();
    for(InvoiceCreated__e inv:trigger.new){
        invoiceId.add(inv.Invoice_Id__c);
    }
    System.debug(' -- SOM_StartCreateInvoicePDFFileAction -- : '+ trigger.new);

    if(invoiceId.size()>0){
        System.debug(' -- invoiceId -- : '+ invoiceId);
        SOM_CreateInvoicePDFFileAction.CreateInvoicePDFFileAction(invoiceId);
    }
    
}
