global with sharing class SOM_ErrorMessageBrazilianAddress {
    
    @InvocableMethod(label='Error Message Brazilian Address' description='Error Message Brazilian Address' callout=true)
    global static List<List<SOM_ResponseErrorMessageBrazilianAddress>> ErrorMessageBrazilianAddress(List<List<SOM_RequestErrorMessageBrazilianAddress>> requests){
        //Requests request                = requests.get(0);
        List<SOM_RequestErrorMessageBrazilianAddress>		ReqsTest		= new List<SOM_RequestErrorMessageBrazilianAddress>();
        List<String>		RecordOSids		= new List<String>();
        List<String>		RecordODGSids	= new List<String>();
        List<List<SOM_ResponseErrorMessageBrazilianAddress>> responsesWrappers = new List<List<SOM_ResponseErrorMessageBrazilianAddress>>();
        String sObjName ;
        map<Id,OrderSummary> 	mapOs		= new map<Id,OrderSummary>();
        map<Id,OrderDeliveryGroupSummary> 	mapODGs		= new map<Id,OrderDeliveryGroupSummary>();
        for(List<SOM_RequestErrorMessageBrazilianAddress> Req1 : requests){
            for(SOM_RequestErrorMessageBrazilianAddress Req2 : Req1){
                ReqsTest.add(Req2);
                sObjName = (Req2.RecordId).getSObjectType().getDescribe().getName();
                if(sObjName == SOM_Constants.ORDER_SUMMARY_NAME){
                    RecordOSids.add(Req2.RecordId);
                }else if(sObjName == SOM_Constants.ORDER_DELIVERY_GROUP_SUMMARY_NAME){
                    RecordODGSids.add(Req2.RecordId);
                }
            } 
        }
        
        AddressValidationRules__mdt validationRules = [SELECT StreetRegex__c, StreetNumberRegex__c, PhoneNumberRegex__c FROM AddressValidationRules__mdt WHERE DeveloperName = 'AddressValidationRules_BR' LIMIT 1];
        List<OrderSummary> OrderSummaries = [ Select Id, BillingPostalCode, BillingStreet, RI_Neighborhood__c, BillingCity, BillingState, BillingPhoneNumber, StreetNumber__c from OrderSummary Where Id IN :RecordOSids ];
        List<OrderDeliveryGroupSummary> ODGSummaries = [ Select Id, DeliverToPostalCode, DeliverToStreet, RI_Neighborhood__c, DeliverToCity, DeliverToState ,PhoneNumber ,StreetNumber__c from OrderDeliveryGroupSummary Where Id IN :RecordODGSids ];
        for(OrderSummary os : OrderSummaries){
            if(os.Id != null)
            mapOs.put(os.Id,os);
        }
        for(OrderDeliveryGroupSummary odgs : ODGSummaries){
            if(odgs.Id != null)
            mapODGs.put(odgs.Id,odgs);
        }
        List<SOM_ResponseErrorMessageBrazilianAddress> responseWrapper = new List<SOM_ResponseErrorMessageBrazilianAddress>();
        try {
            for(SOM_RequestErrorMessageBrazilianAddress Req : ReqsTest){
        		SOM_ResponseErrorMessageBrazilianAddress response              = new SOM_ResponseErrorMessageBrazilianAddress();
                sObjName = (Req.RecordId).getSObjectType().getDescribe().getName();
                String ErrorDescription = '';
                String ValidationErrorDescription = '';
                
                String PostalCode, Street, RI_Neighborhood, City, State ,Streetnumber,Phonenumber;
                
                if(sObjName == SOM_Constants.ORDER_SUMMARY_NAME){
                    OrderSummary OS = mapOs.get(Req.RecordId);
                    PostalCode 		= OS.BillingPostalCode;
                    Street 			= OS.BillingStreet;
                    RI_Neighborhood = OS.RI_Neighborhood__c;
                    City 			= OS.BillingCity;
                    State			= OS.BillingState;
                    Streetnumber 	= OS.StreetNumber__c;
                	Phonenumber		= OS.BillingPhoneNumber;
                    
                }else if(sObjName == SOM_Constants.ORDER_DELIVERY_GROUP_SUMMARY_NAME){
                    OrderDeliveryGroupSummary ODGS = mapODGs.get(Req.RecordId);
                    Street 			= ODGS.DeliverToStreet;
                    RI_Neighborhood = ODGS.RI_Neighborhood__c;
                    City 			= ODGS.DeliverToCity;
                    State			= ODGS.DeliverToState;
                    PostalCode 		= ODGS.DeliverToPostalCode;
                    Streetnumber	= ODGS.StreetNumber__c;
                    Phonenumber		= ODGS.PhoneNumber;
                }
                
                if(UPPER(Req.cep)  != UPPER(PostalCode) ){
                    ErrorDescription = SOM_Constants.ZIP;
                }
                if(!String.isEmpty(Street)) {
                    if(!Pattern.matches(validationRules.StreetRegex__c, Street)){
                		ValidationErrorDescription = ValidationErrorDescription + SOM_Constants.STREETADDRESSERROR ;
            		}
                }
                if(String.isEmpty(Street)) {
                ValidationErrorDescription = ValidationErrorDescription + SOM_Constants.STREETEMPTYERROR ;
            	}
                if (!String.isEmpty(Phonenumber)) {
                	if (!Pattern.matches(validationRules.PhoneNumberRegex__c, Phonenumber)) {
                    	ValidationErrorDescription = ValidationErrorDescription + SOM_Constants.PHONENUMBERERROR ;
                    }
                }
           		if (String.isEmpty(RI_Neighborhood)) {
                ValidationErrorDescription = ValidationErrorDescription + SOM_Constants.NEIGHBERHOODERROR ;
           		}
                if (!String.isEmpty(Streetnumber) ) {
                    if(!Pattern.matches(validationRules.StreetNumberRegex__c, Streetnumber)){
                		ValidationErrorDescription = ValidationErrorDescription + SOM_Constants.STREETNUMBERERROR ;
            		}
                }
                if(UPPER(Req.localidade) != UPPER(City) ){
                    ErrorDescription = ErrorDescription + SOM_Constants.CITY;
                }
                if(UPPER(Req.uf) != UPPER(State) ){
                    ErrorDescription = ErrorDescription + SOM_Constants.STATE;
                }
                response.ErrorMessageDescription = ErrorDescription;
                response.ValidationErrorMessageDescription = ValidationErrorDescription;
                response.ReqId = Req.RecordId;
                responseWrapper.add(response);
                responsesWrappers.add(responseWrapper);
                
                //Logs.debug('ErrorMessage Brazilian Address','SOM_ErrorMessageBrazilianAddress','ErrorMessageBrazilianAddress','','');   
                //Logs.info('ErrorMessage Brazilian Address','SOM_ErrorMessageBrazilianAddress','ErrorMessageBrazilianAddress','','');   
            } 
        }catch(Exception e) {
            Logs.error(e,'SOM_ErrorMessageBrazilianAddress','ErrorMessageBrazilianAddress','','', requests.get(0).get(0).RecordId);   
        }
        return responsesWrappers;
    }
    
    
    public static String UPPER(String str) {
        if(!String.isBlank(str)){
            String strReplace = (str).replace('à', 'a').replace('ç', 'c').replace('õ', 'o').replace('â','a').replace('á', 'a').replace('ã', 'a').replace('ê', 'e').replace('é', 'e').replace('è', 'e').replace('í','i').replace('ô', 'o').replace('ó', 'o').replace('ú', 'u').replace('û', 'u').toUpperCase();
            Return strReplace;
        }else{
            return str; 
        }
    } 
    
    
    
}