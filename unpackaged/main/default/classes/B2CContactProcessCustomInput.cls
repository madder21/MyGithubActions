public class B2CContactProcessCustomInput {
    @AuraEnabled @InvocableVariable
	public String SubscriptionName;
    @AuraEnabled @InvocableVariable
    public String CaptureSource;
    @AuraEnabled @InvocableVariable
   	public String CaptureContactPointType;
    @AuraEnabled @InvocableVariable
   	public String CustomContactPointType;
    @AuraEnabled @InvocableVariable
   	public String BackInStockSubscriptionSKU;
    @AuraEnabled @InvocableVariable
   	public String Company;
    @AuraEnabled @InvocableVariable
   	public Boolean EmailConsent;
    @AuraEnabled @InvocableVariable
    public String SaleChannel;
    @AuraEnabled @InvocableVariable
    public String Store;
    @AuraEnabled @InvocableVariable
    public String Warehouse;
    //should delete this field
    //@AuraEnabled @InvocableVariable
    //public Id CommSubscriptionChannelTypeId;
}