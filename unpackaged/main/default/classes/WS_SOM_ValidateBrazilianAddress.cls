global with sharing class WS_SOM_ValidateBrazilianAddress {
    
    @InvocableMethod(label='Validate Brazilian Address' description='Validate Brazilian Address' callout=true)
    global static List<AutomaticResponse> ValidateBrazilianAddress(List<String> requests){
        String request                = requests.get(0);
        List<AutomaticResponse> responseWrapper = new List<AutomaticResponse>();
        AutomaticResponse response              = new AutomaticResponse();
        String result;
        
        try {
            //make http callout
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:BrazilianAddress/'+request+'/json');
            httpRequest.setMethod('GET');
            httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
            HttpResponse httpResponse = http.send(httpRequest);
            if (httpResponse.getStatusCode() == 200 ) {
                //Read http response

                Map<String, Object> httpResponseMap 	  = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
                response.cep  		  = String.valueOf(httpResponseMap.get('cep'));
                response.logradouro              		  = String.valueOf(httpResponseMap.get('logradouro'));
                response.complemento             		  = String.valueOf(httpResponseMap.get('complemento'));
                response.unidade        				  = String.valueOf(httpResponseMap.get('unidade'));
                response.bairro        		  = String.valueOf(httpResponseMap.get('bairro'));
                response.localidade        		  = String.valueOf(httpResponseMap.get('localidade'));
                response.uf                  		  = String.valueOf(httpResponseMap.get('uf'));
                response.ibge                 = String.valueOf(httpResponseMap.get('ibge'));
                response.gia                = String.valueOf(httpResponseMap.get('gia'));
                response.ddd      = String.valueOf(httpResponseMap.get('ddd'));
                response.siafi                	  = String.valueOf(httpResponseMap.get('siafi'));
            }
            
            result = httpResponse.getBody();
            responseWrapper.add(response);
            Logs.debug('Validate Brazilian Address','WS_SOM_ValidateBrazilianAddress','ValidateBrazilianAddress',request,result);   
            Logs.info('Validate Brazilian Address','WS_SOM_ValidateBrazilianAddress','ValidateBrazilianAddress',request,result);   
            
        }catch(Exception e) {
            Logs.error(e,'WS_SOM_ValidateBrazilianAddress','ValidateBrazilianAddress',request,result);   
        }
            return responseWrapper;
    }
        
    global with sharing class AutomaticResponse{
        @InvocableVariable
        public String   cep;
        @InvocableVariable
        public String       logradouro;
        @InvocableVariable
        public String   complemento; //OK or KO
        @InvocableVariable
        public String   unidade;
        @InvocableVariable
        public String   bairro; 
        @InvocableVariable
        public String   localidade;
        @InvocableVariable
        public String  uf;
        @InvocableVariable
        public String   ibge; 
        @InvocableVariable
        public String   gia;
        @InvocableVariable
        public String   ddd;
        @InvocableVariable
        public String   siafi;
        
        
    }
}