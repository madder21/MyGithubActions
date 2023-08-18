trigger SOM_InvoiceAfterInsertUpdate on Invoice (before update) {

    set<Id> invoiceIds = new set<Id>();
    For(Invoice invc : Trigger.New)
    {
        SOM_InvoiceManagement.UpdateInvoicesNumber(Trigger.NewMap,Trigger.OldMap);
    }
    
    
    
}