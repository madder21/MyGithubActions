/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 05-30-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
public with sharing class SOM_OCI_LocationAvailability {

    @InvocableVariable @AuraEnabled
    public String location;

    @InvocableVariable @AuraEnabled
    public List<SOM_OCI_InventoryRecord> ociInventoryRecords;
}