/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 05-28-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
public with sharing class SOM_OCI_ProductLine {
    
    @InvocableVariable @AuraEnabled
    public String sku;

    @InvocableVariable @AuraEnabled
    public Integer onHandQuantity;

    @InvocableVariable @AuraEnabled
    public String locationId;
}