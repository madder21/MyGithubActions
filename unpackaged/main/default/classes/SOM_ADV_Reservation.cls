public with sharing class SOM_ADV_Reservation {
    
    @AuraEnabled @InvocableVariable
    public String orderSummaryId;
    
    @AuraEnabled @InvocableVariable
    public String orderItemSummaryId;
    
    @AuraEnabled @InvocableVariable
    public String locationId;
    
    @AuraEnabled @InvocableVariable
    public String locationGroupId;
    
    @AuraEnabled @InvocableVariable
    public String locationIdentifier;
        
    @AuraEnabled @InvocableVariable
    public String locationName;
    
    @AuraEnabled @InvocableVariable
    public String stockKeepingUnit;
    
    @AuraEnabled @InvocableVariable
    public String productName;
    
    @AuraEnabled @InvocableVariable
    public String errorCode;
    
    @AuraEnabled @InvocableVariable
    public Boolean reservationCompleted;
    
    @AuraEnabled @InvocableVariable
    public Boolean reservationImpossible;
    
    @AuraEnabled @InvocableVariable
    public String reservationPartiallyCompleted;
    
    @AuraEnabled @InvocableVariable
    public Integer quantityRequested;
    
    @AuraEnabled @InvocableVariable
    public Integer quantityAvailable;
      
    @AuraEnabled @InvocableVariable
    public Integer quantityReserved;
    
    @AuraEnabled @InvocableVariable
    public Integer quantityUnavailable;    
    
    @AuraEnabled @InvocableVariable
    public String locationType;
    
    @AuraEnabled @InvocableVariable
    public Integer quantityAlreadyAllocated;   
    
    @AuraEnabled @InvocableVariable
    public Integer OCI_OnHand;
    
    @AuraEnabled @InvocableVariable
    public Integer OCI_ATF;
    
    @AuraEnabled @InvocableVariable
    public Integer OCI_ATO;
    
    @AuraEnabled @InvocableVariable
    public Integer OCI_Reservations;
    
    @AuraEnabled @InvocableVariable
    public Integer OCI_Safety;
    
    //no-arguments Constructor 
    public SOM_ADV_Reservation(){}











}