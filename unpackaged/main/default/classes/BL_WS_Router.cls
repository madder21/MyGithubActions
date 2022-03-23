/**
 * 
 * @author Jeremy Martiano
 * @since March 2019
 * @description Virtual Class required to execute the necessary code to return a response 
 * 		to a web service request and handle an exception
 * @group balink Webservices General
 * 
 */
public virtual class BL_WS_Router {
	
	private static BL_WS_Request currentClass;

	/**
	 * 
	 * @param baseEndpoint the constant part of the web service's path
	 * @param applicationName the name of the application using this web service
	 * @param routesMappingClassName the class which contains the route mapping information
	 * @param userInfosClassName the user info class
	 * @description init the class which implements the specific web service request
	 */
	public static void init(string baseEndpoint, string applicationName, String routesMappingClassName, String userInfosClassName) {
		/** Init router **/
		BL_AppSettings.setAppSettings(applicationName);
		BL_WS_Interfaces.RouterMapping routesMappingClass = (BL_WS_Interfaces.RouterMapping)Type.forName(routesMappingClassName).newInstance();
		BL_UserInfo userInfosClass = (BL_UserInfo)Type.forName(userInfosClassName).newInstance();
		BL_WS_QueryMergeFields.init(userInfosClass.userMergeFields);
		
		/** Get current route **/
		String requestURI = BL_Utils.requestURI(baseEndpoint);
		Map<String, String> route = routesMappingClass.getCurrentRoute(requestURI);
		if(route == null){
			BL_WS_Log.setPersistentLog(requestURI, applicationName);
			throw new BL_Exceptions.RouterException('Bad Request,Source does not Exist');
		}
		BL_WS_Log.setPersistentLog(route.get('className'), applicationName);
		currentClass =  (BL_WS_Request)Type.forName(route.get('className')).newInstance();
		currentClass.init(requestURI, route.get('path'), userInfosClass);
	}


	/**
	 * 
	 * @description execute the class which implements the specific web service request
	 */
	public static void executeRequest(string baseEndpoint, string applicationName, String routesMappingClassName, String userInfosClassName) {
		
        try{
			init(baseEndpoint, applicationName, routesMappingClassName, userInfosClassName);
			Object responseData = null;
			/** Execute **/
			switch on RestContext.request.httpMethod {
				when 'GET' {	
					BL_WS_Interfaces.DispatchableGET dClass;
					try {
						dClass = (BL_WS_Interfaces.DispatchableGET) currentClass; 
					} catch (Exception e){
						 throw new BL_Exceptions.RouterException('INVALID METHOD');
						}
					responseData = dClass.executeGET();			
				}	
				when 'POST' {	
					BL_WS_Interfaces.DispatchablePOST dClass;
					try {
						dClass = (BL_WS_Interfaces.DispatchablePOST) currentClass; 
					} catch (Exception e){
						throw new BL_Exceptions.RouterException('RESOURCE DOES NOT SUPPORT POST METHOD');
					} 	
					responseData = dClass.executePOST();
				}
				when 'PATCH' {
					BL_WS_Interfaces.DispatchablePATCH dClass;
					try {
						dClass = (BL_WS_Interfaces.DispatchablePATCH) currentClass; 
					} catch (Exception e){
						throw new BL_Exceptions.RouterException('RESOURCE DOES NOT SUPPORT PATCH METHOD');
					} 		
					responseData = dClass.executePATCH();
				}
				when 'PUT' {
					BL_WS_Interfaces.DispatchablePUT dClass;
					try {
						dClass = (BL_WS_Interfaces.DispatchablePUT) currentClass; 
					} catch (Exception e){
						throw new BL_Exceptions.RouterException('RESOURCE DOES NOT SUPPORT PUT METHOD');
					} 		
					responseData = dClass.executePUT();
				}
				when 'DELETE' {
					BL_WS_Interfaces.DispatchableDELETE dClass;
					try {
						dClass = (BL_WS_Interfaces.DispatchableDELETE) currentClass; 
					} catch (Exception e){
						throw new BL_Exceptions.RouterException('RESOURCE DOES NOT SUPPORT DELETE METHOD'); 
					} 
					responseData = dClass.executeDELETE();
				}
			}

			RestResponse response = RestContext.response;
			response.addHeader('Content-Type','application/json');
			response.statusCode = 200;
			BL_utils.log('responseData',responseData);
			response.responseBody = Blob.valueOf(JSON.serializePretty(responseData, true));
			system.debug('before BL_WS_Log.insertPersistentLog');
			BL_WS_Log.insertPersistentLog();	
			system.debug('after BL_WS_Log.insertPersistentLog');		
        } catch(Exception ex) {
			handleException(ex);		
			return;	
		}
		//insert log (If no error occured. With Error, log are handled in the Catch)
	}

	private static void handleException(Exception ex) {
		RestResponse response = RestContext.response;
		response.addHeader('Content-Type','application/json');
       
        try{
            throw ex;
        } 
        catch (BL_Exceptions.RouterException ex2) {
            response.statusCode = 404;
        } 
        catch (BL_Exceptions.QueryException ex2) {
            response.statusCode = 400;    
        } 
        catch (BL_Exceptions.CLTException ex2) {
            response.statusCode = 500;    
        } 
        catch (Exception ex2) {
            response.statusCode = 500;
        }
        BL_WS_Log.insertPersistentLogWithError(ex);
        //This is the Place to return error.
        response.responseBody = Blob.valueOf(JSON.serializePretty(BL_WS_Log.getErrorMessage(), true));
	}

	public virtual void initCustomMergeFields(){
		
	}
}