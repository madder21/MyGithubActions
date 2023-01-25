public with sharing class SOM_DateConvertionInput{
    @InvocableVariable @AuraEnabled
    public String targetTimeZone;

    @InvocableVariable @AuraEnabled
    public DateTime dateToConvert;
}