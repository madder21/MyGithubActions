public class SOM_InvoiceTriggerHandler extends BaseTriggerHandler {

    private List<Invoice> newList;
    private List<Invoice> oldList;

    public SOM_InvoiceTriggerHandler() {
        oldList = (List<Invoice>)Trigger.old;
        newList = (List<Invoice>)Trigger.new;
    }
    
    protected override void beforeUpdate(){
             SOM_InvoiceHelper.updateInvoiceTimezoneDate(newList);
    }
}
