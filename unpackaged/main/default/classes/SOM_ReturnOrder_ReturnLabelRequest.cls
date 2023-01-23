/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 03-29-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
global with sharing class SOM_ReturnOrder_ReturnLabelRequest {
    @AuraEnabled
    public String returnOrderId;
    @AuraEnabled
    public String returnLabelUrl;
    @AuraEnabled
    public String returnTrackingNumber;

}