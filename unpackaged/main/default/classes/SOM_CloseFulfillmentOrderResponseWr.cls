global with sharing class SOM_CloseFulfillmentOrderResponseWr {
   
    @AuraEnabled @InvocableVariable
    global List<Id> foIds;
    @AuraEnabled @InvocableVariable
    global List<Id> osIds;
    @AuraEnabled @InvocableVariable
    global Boolean isSuccess;
    @AuraEnabled @InvocableVariable
    global String  errorMessage;

}