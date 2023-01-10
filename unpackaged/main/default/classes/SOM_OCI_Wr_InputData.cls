/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 06-01-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
public with sharing class SOM_OCI_Wr_InputData {
    
    
    @InvocableVariable @AuraEnabled
    public List<SOM_OCI_ProductLine> ociProductLines;

    @InvocableVariable @AuraEnabled
    public List<SOM_OCI_LocationAvailability> ociLocationAvailabilities;

    @InvocableVariable @AuraEnabled
    public String returnOrderNumber;

   

    
}