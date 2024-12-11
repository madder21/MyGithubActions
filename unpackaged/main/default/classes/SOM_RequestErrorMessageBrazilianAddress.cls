global with sharing class SOM_RequestErrorMessageBrazilianAddress {
    
        @AuraEnabled @InvocableVariable
        public String   cep;
        @AuraEnabled @InvocableVariable
        public String       logradouro;
        @AuraEnabled @InvocableVariable
        public String   bairro; 
        @AuraEnabled @InvocableVariable
        public String   localidade;
        @AuraEnabled @InvocableVariable
        public String  uf;
        @AuraEnabled @InvocableVariable
        public Id   RecordId;        
    
    
    //no-arguments Constructor 
    public SOM_RequestErrorMessageBrazilianAddress(){}


}