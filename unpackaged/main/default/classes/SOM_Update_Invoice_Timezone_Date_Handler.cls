public with sharing class SOM_Update_Invoice_Timezone_Date_Handler extends BaseTriggerHandler {

    private List<Invoice> newList;
    private List<Invoice> oldList;

    public SOM_Update_Invoice_Timezone_Date_Handler() {
        oldList = (List<Invoice>)Trigger.old;
        newList = (List<Invoice>)Trigger.new;
    }
    
    protected override void beforeUpdate(){
             SOM_Update_Invoice_Timezone_Date_Helper.updateInvoiceTimezoneDate(newList);
    }
}