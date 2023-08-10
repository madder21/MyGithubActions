public class SOM_InvoiceTriggerHandler extends BaseTriggerHandler {
    private List<Invoice> newList;
    private List<Invoice> oldList;

    public SOM_InvoiceTriggerHandler() {
        oldList = (List<Invoice>)Trigger.old;
        newList = (List<Invoice>)Trigger.new;
    }
    
    protected override void beforeUpdate(){
        List<Invoice> newListWithEmptyDate = new List<Invoice>();
        for(Invoice singleInv : newList){
            if(singleInv.Invoice_Timezone_Date__c == null){
                newListWithEmptyDate.add(singleInv);
            }
        } 
        if(newListWithEmptyDate != null && !newListWithEmptyDate.isEmpty()){
            SOM_InvoiceHelper.updateInvoiceTimezoneDate(newListWithEmptyDate);
        }
    }
}
