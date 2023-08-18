global with sharing class SOM_ConfirmInvoiceId_Response {
    @AuraEnabled
    global String invoiceId;
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String errorMessage;
    
}