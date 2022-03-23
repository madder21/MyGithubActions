/**
 * 
 * @author Aliza Reishtein
 * @since March 2020
 * @group General Utils
 * @description Class containing HTTP related utility methods
 */
public class BL_HTTP_Utils {

    public String url;
    public String method;
    public HttpRequest request;
    public HttpResponse response;
    public Map<String,String> responseJsonParsed;
    public Map<String, Object> responseJsonBody;
    public Map<String,String> headers; 
    public Map<String,String> urlParams;
    public static final Http http;
    
    static{
        http = new Http();
    }

    //Initialize the HttpReqest and headers
    public BL_HTTP_Utils(){
        this.request = new HttpRequest();
        this.request.setTimeout(30000);
        this.headers = new Map<String,String>();
    }

    // Set body
    public BL_HTTP_Utils body(String body){
        request.setBody(body);
        return this;
    }

    // Set the url for a get request.
    public BL_HTTP_Utils get(String url){
        set_uri_and_method('GET',url);
        return this;
    }

    //set the url for put request
    public BL_HTTP_Utils put(String url){
       set_uri_and_method('PUT',url);
       return this;      
    }

    //set the url for post request
    public BL_HTTP_Utils post(String url){
       set_uri_and_method('POST',url);
       return this; 
    }

    /*This is special header for DWOCAPI*/
    public BL_HTTP_Utils patch(String url){
       set_uri_and_method('PUT',url);
       return this; 
    }

    // Set the url for delete request
    public BL_HTTP_Utils del(String url){
       set_uri_and_method('DELETE',url);
       return this; 
    }

    // Set the request headers as value - key pair
    public BL_HTTP_Utils header(String key,String value){
        headers.put(key,value);
        return this;
    }

    // add all request headers as map<String,String> value-key
    public BL_HTTP_Utils addHeaders(Map<String,String> allHeaders){
        if(allHeaders == null || allHeaders.isEmpty()) return this;
        headers.putAll(allHeaders);
        return this;
    }

    // Set timeout 
    public BL_HTTP_Utils timeout(Integer timeout){
        request.setTimeout(timeout);
        return this;
    }

    // Set Set Client Certification 
    public BL_HTTP_Utils certificate(String certDevName){
        request.setClientCertificateName(certDevName);
        return this;
    }

    //Sends the request to the endpoint.
    public BL_HTTP_Utils call(){
        if(!headers.isEmpty()){
            for(String key : this.headers.keyset()) {
                request.setHeader(key,headers.get(key));
            }
        }
        if(!Test.isRunningTest()){
            System.debug('REQUEST: ' + request);
            response = http.send(request);
            System.debug('RESPONSE: ' + response);
        }
        else{
            response = new HttpResponse();
        }

        return this;
    }

    //Returns the response
    public HttpResponse getResponse(){
        return this.response;
    }

    // Returns request body
    public String responseBody(){
        return this.response.getBody();
    }

    // Returns the headers.
    public Map<String,String> getHeaders(){
        return this.headers;
    }

    //Returns the status of the response
    public String status(){
        return response.getStatus();
    }

    //Returns the statuscode of the response.
    public Integer statusCode(){
        return response.getStatusCode();
    }
    
    //Private method sets the method and url to the HttpRequest object
    private void set_uri_and_method(String method,String url){
        request.setMethod(method);
        request.setEndpoint(url);
    }

    public Map<String,String> getParameters() {
        if (this.responseJsonParsed == null){
            String body = this.responseBody();
            Map<String,String> resultMap = new Map<String,String>();
            JSONParser parser = JSON.createParser(body);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String key = parser.getText();
                    parser.nextToken();
                    String value = parser.getText();

                    resultMap.put( key, value);
                }
            }
            this.responseJsonParsed = resultMap;
        }
        
        return this.responseJsonParsed;
    }

    public Map<String, Object> getBodyResponse(){
        system.debug(this.responseBody());
        if(this.responseJsonBody == null){
            try{
                this.responseJsonBody = (Map < String, Object > ) JSON.deserializeUntyped(this.responseBody());
            } catch (Exception e){
                try{
                    this.responseJsonBody = new Map<String, Object>();
                    this.responseJsonBody.put('results', (List < Object > ) JSON.deserializeUntyped(this.responseBody()));
                }catch(Exception e2){
                    System.debug(e2.getMessage());
                }
            }
            
        }
        return this.responseJsonBody;
    }

    public static String getBasicAuthentication(String username, String password){
        String payload = username + ':' + password;
        return EncodingUtil.base64Encode(Blob.valueOf(payload));
    }
    
    public static String getHttpHeaderRequestString(RestRequest request){
        string headers = '##### Headers #####';
        for(String key : request.headers.Keyset()){
           	 headers+= '\n' + key + ' : ' + request.headers.get(key) ;
        }
        return headers;
    }

}