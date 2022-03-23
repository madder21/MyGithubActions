/*
 * Created by israel on 11/3/2019.
 */
global class Utils_Log {

	global static RestRequest createRequest(){
		RestRequest request = RestContext.request;
		request.addHeader('Time', String.valueOf(datetime.now().getTime()));
		return request;
	}


	global static RestResponse createResponse(){
		RestResponse response = RestContext.response;
		response.addHeader('Content-Type','application/json');
		return response;
	}
    


	global static void createLog(string objectService, RestRequest request, RestResponse response){
		response.addHeader('Time', String.valueOf(datetime.now().getTime()));
		CLT_Utils.createLog(objectService, request, response);
	}

}