public with sharing class SOM_Wr_DisplayLineItem {
    
    @AuraEnabled
    public String amountId;
    @AuraEnabled
    public String percentId;
    @AuraEnabled
    public Double ats;
    @AuraEnabled
    public String sku;
    @AuraEnabled
    public Integer quantity;
    @AuraEnabled
    public Integer originalQuantity;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String location;
    @AuraEnabled
    public String productId;
    @AuraEnabled
    public String pbEntryId;
    @AuraEnabled
    public Integer lineNumber;
    @AuraEnabled
    public String roliID;
    @AuraEnabled
    public String skuExchange;
    @AuraEnabled
    public Decimal unitPrice;
    @AuraEnabled
    public Boolean taxType;
    @AuraEnabled
    public Decimal taxRate;
    @AuraEnabled
    public Decimal taxValue;
    @AuraEnabled
    public Decimal lineTotal;
    @AuraEnabled
    public Decimal totalLines;
}