public with sharing class TimeslotWrapper {
	@InvocableVariable @AuraEnabled
	public Integer id;
	@InvocableVariable @AuraEnabled
	public Integer merchantId;
	@InvocableVariable @AuraEnabled
	public String ownerType;
	@InvocableVariable @AuraEnabled
	public Integer staffId;
	@InvocableVariable @AuraEnabled
	public String type;
	@InvocableVariable @AuraEnabled
	public Datetime startOn;
	@InvocableVariable @AuraEnabled
	public Datetime endOn;
	@InvocableVariable @AuraEnabled
	public Boolean canModify;
	@InvocableVariable @AuraEnabled
	public String description;
	@InvocableVariable @AuraEnabled
	public String availabilityTags;

}