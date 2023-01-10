global with sharing class SOM_ConfirmOrder_Response {
    @AuraEnabled
    global String orderSummaryNumber;
    @AuraEnabled
    global String status;
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String errorMessage;
    
}