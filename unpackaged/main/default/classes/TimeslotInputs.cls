public with sharing class TimeslotInputs {
    @InvocableVariable @AuraEnabled
    public ClientInputs client;
    @InvocableVariable @AuraEnabled
    public TimeslotWrapper timeSlot;
}