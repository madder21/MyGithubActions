trigger SOM_InvoiceAfterInsertUpdate on Invoice (before update) {    
    for (Invoice invN : Trigger.New) {
        SOM_InvoiceManagement.UpdateInvoicesNumber(invN,Trigger.OldMap.get(invN.Id));  
    }        
}