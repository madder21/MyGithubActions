global with sharing class SOM_BrazilianRequest {
    
        @AuraEnabled @InvocableVariable
        public String   ZipCode;
        @AuraEnabled @InvocableVariable
        public String   Identifier;
    
    //no-arguments Constructor 
    public SOM_BrazilianRequest(){}


}