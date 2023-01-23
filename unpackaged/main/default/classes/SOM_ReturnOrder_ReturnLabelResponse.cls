/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
global with sharing class SOM_ReturnOrder_ReturnLabelResponse {
    
    @AuraEnabled
    public String returnOrderId;
    @AuraEnabled
    public String returnOrdertStatus;
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String errorMessage;
}