@RestResource(urlMapping='/retail/*')
global with sharing class CLT_WS_RetailApp{

	@HttpPost
	global static Void postItem() {
		RestRequest request = Utils_Log.createRequest();
        RestResponse response = Utils_Log.createResponse();

		String objectService = getObjectService(request);
		Map<String,Object> requestBody = getRequestBody(request);

		//response.addHeader('Content-Type','application/json');

		if(objectService != null){
			List<dependency_injection_class__mdt> classNameList = [ SELECT Class_Name__c
					FROM dependency_injection_class__mdt
					WHERE DeveloperName =: objectService];
			if(classNameList.size() > 0){
				try{
					CLT_RetailInterface clientellingWS = (CLT_RetailInterface)Type.forName(classNameList[0].Class_Name__c).newInstance();
					Object responseData = clientellingWS.retrievePost(request.params, requestBody);
					response.statusCode = 200;
					response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, Object> {
					'text' => 'Success',
					'data' => responseData
					}));
					System.debug(JSON.serialize(responseData));
				}
				catch(Exception ex){
					handleException(ex,response);
				}
			}
            Utils_Log.createLog(objectService, request, response);
		}
	}

	@HttpGet
	global static Void getItem(){
		RestRequest request = Utils_Log.createRequest();
        RestResponse response = Utils_Log.createResponse();
		String objectService = getObjectService(request);

		//response.addHeader('Content-Type','application/json');


		if(objectService != null){
			List<dependency_injection_class__mdt> classNameList = [ SELECT Class_Name__c
					FROM dependency_injection_class__mdt
					WHERE DeveloperName =: objectService ];
			if(classNameList.size() > 0){
				try{
					CLT_RetailInterface clientellingWS = (CLT_RetailInterface)Type.forName(classNameList[0].Class_Name__c).newInstance();
					Object objectList = clientellingWS.retrieveGet(request.params);

					response.statusCode = 200;
					response.responseBody = Blob.valueOf(JSON.serialize(objectList));
				}
				catch(Exception ex){
					handleException(ex,response);		
				}
			}
            Utils_Log.createLog(objectService, request, response);
		}
	}

	@HttpDelete
	global static Void deleteItem(){
		RestRequest request = Utils_Log.createRequest();
        RestResponse response = Utils_Log.createResponse();

		String objectService = getObjectService(request);

		//response.addHeader('Content-Type','application/json');


		if(objectService != null){
			List<dependency_injection_class__mdt> classNameList = [ SELECT Class_Name__c
					FROM dependency_injection_class__mdt
					WHERE DeveloperName =: objectService ];
			if(classNameList.size() > 0){
				try{
					CLT_RetailInterface clientellingWS = (CLT_RetailInterface)Type.forName(classNameList[0].Class_Name__c).newInstance();
					Object objectList = clientellingWS.retrieveDelete(request.params);

					response.statusCode = 200;
					response.responseBody = Blob.valueOf(JSON.serialize(objectList));
				}
				catch(Exception ex){
					handleException(ex,response);	
				}
			}
		}
	}

	global static Map<String,Object> getRequestBody(RestRequest request){
		Map<String,Object> body = new Map<String,Object>();
		if (request.requestBody != null) {
			body = (Map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());
		}

		return body;
	}

	global static string getObjectService(RestRequest request){
		return request.requestURI.substring(request.requestURI.lastIndexOf('/') + 1);
	}
    
    global static void handleException(Exception ex,Restresponse response){
        response.statusCode = 400;

        response.responseBody = Blob.valueOf(JSON.serialize(new Map<String, String>{'Error Message' => ex.getMessage(),
                                                                                   'Stack Trace' => ex.getStackTraceString(),
                                                                                   'Is Custom Exception' => String.valueOf(ex instanceof CLT_Utils.Custom_Exception)}));
    }
}