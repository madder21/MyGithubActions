@RestResource(urlMapping = '/ddc/v0/*')
global with sharing class DDC_WS_Router implements BL_Rest_Router_Factory.Routable {

    @HTTPGet
	global static void doGET() {
		execute(BL_Rest_Router_Factory.RequestType.HTTPGET);
	}

	@HTTPPOST
	global static void doPOST() {
		execute(BL_Rest_Router_Factory.RequestType.HTTPPOST);
	}
	@HTTPPATCH
	global static void doPATCH() {
		execute(BL_Rest_Router_Factory.RequestType.HTTPPATCH);
	}
	@HTTPPUT
	global static void doPUT() {
		execute(BL_Rest_Router_Factory.RequestType.HTTPPUT);
	}
	@HTTPDELETE
	global static void doDELETE() {
		execute(BL_Rest_Router_Factory.RequestType.HTTPDELETE);
	}

	global static BL_Rest_Router_Factory.RouterMapping getRouter() {
		return new DDC_WS_Router_Mapping();
	}

	global static void execute(BL_Rest_Router_Factory.RequestType requestType) {
		RestRequest request = RestContext.request;
		request.addHeader('Time', String.valueOf(datetime.now().getTime()));
		String requestURI = getPathSuffix(request);
        
        RestResponse response = RestContext.response;
		response.addHeader('Content-Type','application/json');
		Object responseData = null;

		BL_Rest_Router_Factory.Route currentRoute = null;

        try{

			currentRoute = BL_Rest_Router_Utils.getController(requestURI, getRouter().getRoutes());
			// BL_EasyLogs.setPersistentLog(currentRoute.className);

			switch on requestType {
				when HTTPGET {	
					BL_Rest_Router_Factory.DispatchableGET dClass = (BL_Rest_Router_Factory.DispatchableGET) Type.forName(currentRoute.className).newInstance(); 
					responseData = dClass.executeGET(BL_Rest_Router_Utils.getPathParameters(requestURI, currentRoute.path),request.params);
				}	
				when HTTPPOST {	
					BL_Rest_Router_Factory.DispatchablePOST dClass = (BL_Rest_Router_Factory.DispatchablePOST) Type.forName(currentRoute.className).newInstance(); 	
					responseData = dClass.executePOST(BL_Rest_Router_Utils.getPathParameters(requestURI, currentRoute.path), request.params, BL_Rest_Router_Utils.getRequestBody(request));
				}
				when HTTPPATCH {
					BL_Rest_Router_Factory.DispatchablePATCH dClass = (BL_Rest_Router_Factory.DispatchablePATCH) Type.forName(currentRoute.className).newInstance(); 		
					responseData = dClass.executePATCH(BL_Rest_Router_Utils.getPathParameters(requestURI, currentRoute.path), request.params, BL_Rest_Router_Utils.getRequestBody(request));
				}
				when HTTPPUT {
					BL_Rest_Router_Factory.DispatchablePUT dClass = (BL_Rest_Router_Factory.DispatchablePUT) Type.forName(currentRoute.className).newInstance(); 		
					responseData = dClass.executePUT(BL_Rest_Router_Utils.getPathParameters(requestURI, currentRoute.path), request.params, BL_Rest_Router_Utils.getRequestBody(request));
				}
				when HTTPDELETE {
					BL_Rest_Router_Factory.DispatchableDELETE dClass = (BL_Rest_Router_Factory.DispatchableDELETE) Type.forName(currentRoute.className).newInstance(); 
					responseData = dClass.executeDELETE(BL_Rest_Router_Utils.getPathParameters(requestURI, currentRoute.path), request.params, BL_Rest_Router_Utils.getRequestBody(request));
				}
			}
            
            response.statusCode = 200;
            response.responseBody = Blob.valueOf(JSON.serialize(responseData, true));
        } catch(Exception ex) {
			BL_Rest_Router_Utils.handleException(ex, response);
			//BL_EasyLogs.setErrorLog(ex);
        }
        response.addHeader('Time', String.valueOf(datetime.now().getTime()));
        system.debug('request**' + request);
        system.debug('response**' + response);
        //CLT_Utils.createLog(currentRoute.className, request, response);
		//BL_EasyLogs.insertPersistentLog();
	}

	global static String getPathSuffix(RestRequest request) {
        String start = '/ddc/v0';
        return request.requestURI.substring(request.requestURI.indexOf(start) + start.length());
    }

}