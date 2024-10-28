public with sharing class Wr_FOLItoShip {
    
    @InvocableVariable @AuraEnabled
    public Id id;

    @InvocableVariable @AuraEnabled
    public String foliName;

    @InvocableVariable @AuraEnabled
    public Integer qty;

    @InvocableVariable @AuraEnabled
    public Integer qtyAvailableToShip;

    @InvocableVariable @AuraEnabled
    public String productName;

    @InvocableVariable @AuraEnabled
    public String productSKU;

    @InvocableVariable @AuraEnabled
    public String productId;

    @InvocableVariable @AuraEnabled
    public String description;

    @InvocableVariable @AuraEnabled
    public Boolean isSerialized;

    @InvocableVariable @AuraEnabled
    public String osItemId;
    
    @InvocableVariable @AuraEnabled
    public Boolean isSecondHand;
    
    @InvocableVariable @AuraEnabled
    public String MasterSKU;
}