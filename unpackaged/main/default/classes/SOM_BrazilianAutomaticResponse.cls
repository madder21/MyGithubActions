global class SOM_BrazilianAutomaticResponse {
        @AuraEnabled @InvocableVariable
        public String   Identifier;
        @AuraEnabled @InvocableVariable
        public String   cep;
        @AuraEnabled @InvocableVariable
        public String       logradouro;
        @AuraEnabled @InvocableVariable
        public String   complemento; //OK or KO
        @AuraEnabled @InvocableVariable
        public String   unidade;
        @AuraEnabled @InvocableVariable
        public String   bairro; 
        @AuraEnabled @InvocableVariable
        public String   localidade;
        @AuraEnabled @InvocableVariable
        public String  uf;
        @AuraEnabled @InvocableVariable
        public String   ibge; 
        @AuraEnabled @InvocableVariable
        public String   gia;
        @AuraEnabled @InvocableVariable
        public String   ddd;
        @AuraEnabled @InvocableVariable
        public String   siafi;
		@AuraEnabled @InvocableVariable
        public String   erro;
}