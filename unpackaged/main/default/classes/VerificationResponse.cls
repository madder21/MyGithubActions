public class VerificationResponse {
    
    @AuraEnabled @InvocableVariable
    public Boolean isValid;
    @AuraEnabled @InvocableVariable
    public String email;
    @AuraEnabled @InvocableVariable
    public Id accountId;
    @AuraEnabled @InvocableVariable
    public String DoubleOptInHash;

}