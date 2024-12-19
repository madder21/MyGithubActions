global with sharing class SOM_ResponseErrorMessageBrazilianAddress {
    
        @AuraEnabled @InvocableVariable
        public String   ErrorMessageDescription;
        @AuraEnabled @InvocableVariable
        public String   ReqId;
    	@AuraEnabled @InvocableVariable
        public String   ValidationErrorMessageDescription;
    
    
    //no-arguments Constructor 
    public SOM_ResponseErrorMessageBrazilianAddress(){}


}