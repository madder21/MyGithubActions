public class VerificationRequest {
    
    @AuraEnabled @InvocableVariable
    public String email;
    @AuraEnabled @InvocableVariable
    public Id accountId;
    @AuraEnabled @InvocableVariable
    public String DoubleOptInHash;

}