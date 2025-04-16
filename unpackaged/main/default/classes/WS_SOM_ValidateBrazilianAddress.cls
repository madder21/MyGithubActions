global with sharing class WS_SOM_ValidateBrazilianAddress {
    
    @InvocableMethod(label='Validate Brazilian Address' description='Validate Brazilian Address' callout=true)
    global static List<List<SOM_BrazilianAutomaticResponse>> ValidateBrazilianAddress(List<List<SOM_BrazilianRequest>> Requests){
        //String request                = requests.get(0);
        List<SOM_BrazilianRequest>		Reqs		= Requests[0];
        List<SOM_BrazilianRequest>		ReqsTest		= new List<SOM_BrazilianRequest>() ;
        for(List<SOM_BrazilianRequest> Req1 : Requests){
            for(SOM_BrazilianRequest Req2 : Req1){
                ReqsTest.add(Req2);
            } 
        }
        List<SOM_BrazilianAutomaticResponse> responseWrapper = new List<SOM_BrazilianAutomaticResponse>();
        List<List<SOM_BrazilianAutomaticResponse>> responsesWrappers = new List<List<SOM_BrazilianAutomaticResponse>>();
        
        String result;
        try {
            for( SOM_BrazilianRequest Req : ReqsTest){
            String ZCode = Req.ZipCode;
            SOM_BrazilianAutomaticResponse response              = new SOM_BrazilianAutomaticResponse();
            //make http callout
            Http http = new Http();
            HttpRequest httpRequest = new HttpRequest();
            httpRequest.setEndpoint('callout:BrazilianAddress/'+ZCode+'/json');
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
                response.Identifier                	  = Req.Identifier;
            }
            result = httpResponse.getBody();
            responseWrapper.add(response);
            //Logs.debug('Validate Brazilian Address','WS_SOM_ValidateBrazilianAddress','ValidateBrazilianAddress',ZCode,result);   
            //Logs.info('Validate Brazilian Address','WS_SOM_ValidateBrazilianAddress','ValidateBrazilianAddress',ZCode,result);   
            
            responsesWrappers.add(responseWrapper);
        	}
        }catch(Exception e) {
            Logs.error(e,'WS_SOM_ValidateBrazilianAddress','ValidateBrazilianAddress',Reqs[0].ZipCode + Reqs[0].Identifier,result, Reqs[0].Identifier);   
        }
            return responsesWrappers;
    }
    
}