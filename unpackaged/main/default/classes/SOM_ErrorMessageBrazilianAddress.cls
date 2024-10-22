global with sharing class SOM_ErrorMessageBrazilianAddress {
    
    @InvocableMethod(label='Error Message Brazilian Address' description='Error Message Brazilian Address' callout=true)
    global static List<AutomaticResponse> ErrorMessageBrazilianAddress(List<Requests> requests){
        Requests request                = requests.get(0);
        List<AutomaticResponse> responseWrapper = new List<AutomaticResponse>();
        AutomaticResponse response              = new AutomaticResponse();
        try {
            
            String sObjName = (request.RecordId).getSObjectType().getDescribe().getName();
            String ErrorDescription = '';
            
            String PostalCode, Street, RI_Neighborhood, City, State;
			
            if(sObjName == SOM_Constants.ORDER_SUMMARY_NAME){
                OrderSummary OS = [ Select Id, BillingPostalCode, BillingStreet, RI_Neighborhood__c, BillingCity, BillingState from OrderSummary Where Id =: (request.RecordId)];
                PostalCode 		= OS.BillingPostalCode;
                Street 			= OS.BillingStreet;
                RI_Neighborhood = OS.RI_Neighborhood__c;
                City 			= OS.BillingCity;
                State			= OS.BillingState;

            }else if(sObjName == SOM_Constants.ORDER_DELIVERY_GROUP_SUMMARY_NAME){
                OrderDeliveryGroupSummary ODGS = [ Select Id, DeliverToPostalCode, DeliverToStreet, RI_Neighborhood__c, DeliverToCity, DeliverToState from OrderDeliveryGroupSummary Where Id =: (request.RecordId)];
                PostalCode 		= ODGS.DeliverToPostalCode;
                Street 			= ODGS.DeliverToStreet;
                RI_Neighborhood = ODGS.RI_Neighborhood__c;
                City 			= ODGS.DeliverToCity;
                State			= ODGS.DeliverToState;
            }
            
            
            if(UPPER(request.cep)  != UPPER(PostalCode) ){
                ErrorDescription = SOM_Constants.ZIP;
            }
            if(UPPER(request.logradouro) != UPPER(Street) ){
                ErrorDescription = ErrorDescription + SOM_Constants.STREET;
            }
            if(UPPER(request.bairro) != UPPER(RI_Neighborhood) ){
                ErrorDescription = ErrorDescription + SOM_Constants.NEIGHBORHOOD;
            }if(UPPER(request.localidade) != UPPER(City) ){
                ErrorDescription = ErrorDescription + SOM_Constants.CITY;
            }
            if(UPPER(request.uf) != UPPER(State) ){
                ErrorDescription = ErrorDescription + SOM_Constants.STATE;
            }
            
            response.ErrorMessageDescription = ErrorDescription;
            responseWrapper.add(response);
            
            Logs.debug('ErrorMessage Brazilian Address','SOM_ErrorMessageBrazilianAddress','ErrorMessageBrazilianAddress','','');   
            Logs.info('ErrorMessage Brazilian Address','SOM_ErrorMessageBrazilianAddress','ErrorMessageBrazilianAddress','','');   
            
        }catch(Exception e) {
            Logs.error(e,'SOM_ErrorMessageBrazilianAddress','ErrorMessageBrazilianAddress','','');   
        }
            return responseWrapper;
    }
    
    
    public static String UPPER(String str) {
        if(!String.isBlank(str)){
    		String strReplace = (str).replace('à', 'a').replace('ç', 'c').replace('â','a').replace('á', 'a').replace('ã', 'a').replace('ê', 'e').replace('é', 'e').replace('è', 'e').replace('í','i').replace('ô', 'o').replace('ó', 'o').replace('ú', 'u').replace('û', 'u').toUpperCase();
        	Return strReplace;
        }else{
            return str; 
        }
    } 
        
    global with sharing class Requests{
        @InvocableVariable
        public String   cep;
        @InvocableVariable
        public String       logradouro;
        @InvocableVariable
        public String   bairro; 
        @InvocableVariable
        public String   localidade;
        @InvocableVariable
        public String  uf;
        @InvocableVariable
        public Id   RecordId;        
        
    }

    global with sharing class AutomaticResponse{
        @InvocableVariable
        public String   ErrorMessageDescription;        
    }
    
}