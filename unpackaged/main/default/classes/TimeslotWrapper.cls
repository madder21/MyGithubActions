public with sharing class TimeslotWrapper {
	@InvocableVariable @AuraEnabled
	public List<Integer> timeslotIds;
	@InvocableVariable @AuraEnabled
	public Integer merchantId;
	@InvocableVariable @AuraEnabled
	public String ownerType;
	@InvocableVariable @AuraEnabled
	public Integer staffId;
	@InvocableVariable @AuraEnabled
	public String type;
	@InvocableVariable @AuraEnabled
	public String startOn;
	@InvocableVariable @AuraEnabled
	public String endOn;
	@InvocableVariable @AuraEnabled
	public Boolean canModify;
	@InvocableVariable @AuraEnabled
	public String description;
	@InvocableVariable @AuraEnabled
	public String availabilityTags;
    @InvocableVariable @AuraEnabled
    public Boolean allDay;

}