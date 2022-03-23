global virtual class BL_Rest_Router_Utils {
    global static BL_Rest_Router_Factory.Route getController(String requestURI, Map<String, String> routes) {
        List<String> requestURIList = requestURI.split('/');
        for(String route: routes.keySet()){
            List<String> dispachableURIList = route.split('/');
            Boolean matching = true;
            if (dispachableURIList.size() != requestURIList.size()) {
                matching = false;
            }
            else {
                for (Integer i = 0; i < dispachableURIList.size(); i++) {
                    if (!dispachableURIList.get(i).contains('{') && dispachableURIList.get(i) != requestURIList.get(i)) {
                        matching = false;
                    }
                }
            }

            if(matching) {
                return new BL_Rest_Router_Factory.Route(routes.get(route),route);
            }
            
        }

        throw new BL_Rest_Router_Factory.RouterException(new Map<String, Object> {
            'message'=>'RESOURCE NOT FOUND', 
            'errorCode' => 'RESSOURCE_NOT_FOUND',
            'statusCode' => 404
        });
		
    }
    
    global static Map<String, String> getPathParameters(String requestURI, String dispachableURI) {
		List<String> dispachableURIList = dispachableURI.split('/');
		List<String> requestURIList = requestURI.split('/');
		Map<String, String> result = new Map<String, String>();
		for (Integer i = 0; i < dispachableURIList.size(); i++) {
			if (dispachableURIList.get(i).contains('{')) {
				result.put(dispachableURIList.get(i).subString(1, dispachableURIList.get(i).length()-1), requestURIList.get(i));
			}
		}
		return result;
	}
    
    global static Map < String, Object > getRequestBody(RestRequest request) {
        Map < String, Object > body = new Map < String, Object > ();
        if (request.requestBody != null) {
            system.debug(request.requestBody.toString());
            body = (Map < String, Object > ) JSON.deserializeUntyped(request.requestBody.toString());
        }

        return body;
    }

    global static void handleException(Exception ex, Restresponse response) {
        System.debug('Exception: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
        response.statusCode = 400;
        BL_Rest_Router_Factory.RestResponseError error = new BL_Rest_Router_Factory.RestResponseError (ex.getMessage() + ' ' + ex.getStackTraceString(),ex.getMessage(),null, null);
        try{
            throw ex;
        } catch (BL_Rest_Router_Factory.RouterException ex2) {
            error = new BL_Rest_Router_Factory.RestResponseError (ex2.message + ' ' + ex2.getStackTraceString(), ex2.errorCode, null, ex2.clientMessage);
            if(ex2.statusCode != null){
                response.statusCode = ex2.statusCode;
            }
        } catch (BL_Exceptions.QueryException ex2) {
                error = new BL_Rest_Router_Factory.RestResponseError (ex2.message, ex2.errorMessage, null, null);
        } catch (Exception ex2) {
            if(ex.getTypeName() == 'DmlException') {
                error = new BL_Rest_Router_Factory.RestResponseError (ex.getMessage() + ' ' + ex.getStackTraceString(),'DML_EXCEPTION', ex.getDmlFieldNames(0), null);
            } else {
                error = new BL_Rest_Router_Factory.RestResponseError (ex.getMessage(),'GENERIC_EXCEPTION', null, ex.getMessage());
            }
        }
        
        response.responseBody = Blob.valueOf(JSON.serialize(error, true));
    }

}