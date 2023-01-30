public with sharing class SOM_Wr_discountItems {
    @AuraEnabled
    public String orderItemSummaryId;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String discountType;
    @AuraEnabled
    public String sku;
    @AuraEnabled
    public Integer discountValue;
    @AuraEnabled
    public String reason;
    @AuraEnabled
    public String amountId;
    @AuraEnabled
    public String percentId;
    @AuraEnabled
    public String discountNote;
    @AuraEnabled
    public Boolean taxType;
    @AuraEnabled
    public Decimal lineTotal;
    @AuraEnabled
    public Decimal taxRate;
    @AuraEnabled
    public Decimal taxValue;
    @AuraEnabled
    public Decimal TotalPrice;
    
}