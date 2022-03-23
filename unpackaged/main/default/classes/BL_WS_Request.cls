/**
 * 
 * @author Jeremy Martiano 
 * @since March 2020
 * @description The structure of the request from the Custom Rest Webservice
 * @group balink Webservices General
 */
public virtual class BL_WS_Request {
    public RestRequest request;
    public String requestURI;
    public Map<String, String> pathParameters;
    public Map<String, String> queryParams;
    public integer pageSize;
    public integer pageIndex;
    public String queryId;
    public Map < String, Object > requestBody;
    public String path;
    public string resource;
    public BL_UserInfo me;
    public Set<String> supportedQueryParams;
    public string recordId;
    public boolean isStandardRestApiRequired = false;

    /**
     * 
     * @param requestURI The full web service api call with parameters
     * @param path The base path of the web service
     * @param userInfo The user info for this application
     * @description Initialize the parameters and body of the web service call
     */
    public void init(String requestURI, String path, BL_UserInfo userInfo){
        this.request = RestContext.request;
        this.requestURI = requestURI;
        this.path = path;
        this.me = userInfo;
        this.queryParams = this.request.params;
        this.pathParameters = this.getPathParameters();
        this.requestBody = this.getRequestBody();
        this.resource = getResource();
        if(pathParameters!= null){
            recordId = pathParameters.get('id');
        }
        this.checkValidityRequest();
        pageSize                  =  queryParams.containskey('pageSize')  ?  integer.valueOf(queryParams.get('pageSize'))    : null;
        pageIndex                 =  queryParams.containskey('pageIndex') ?  integer.valueOf(queryParams.get('pageIndex'))   : null;  
        queryId                   =  queryParams.containskey('queryId')   ?  (String) queryParams.get('queryId')             : null;  
        isStandardRestApiRequired =  queryParams.containskey('s')         ?  Boolean.valueOf(queryParams.get('s'))           : false;      
    }

    /**
     * 
     * @returns `Map<String, String>`
     * @description Takes the web service api call and breaks it up into the parameters
     */
    private Map<String, String> getPathParameters() {
		List<String> dispachableURIList = this.path.split('/');
		List<String> requestURIList = this.requestURI.split('/');
		Map<String, String> result = new Map<String, String>();
		for (Integer i = 0; i < dispachableURIList.size(); i++) {
			if (dispachableURIList.get(i).contains('{')) {
				result.put(dispachableURIList.get(i).subString(1, dispachableURIList.get(i).length()-1), requestURIList.get(i));
			}
		}
		return result;
    }
    
    private string getResource() {
        list<string> str = requestURI.split('/');
        return str[str.size() - 1];
    }
    /**
     * 
     * @returns `Map <String, Object>`
     * @description Takes the web service call and saves the request body in Map format
     */
    private  Map <String, Object> getRequestBody() {
        try{
            Map <String, Object> body = new Map < String, Object > ();
            if (this.request.requestBody != null && String.isNotEmpty(this.request.requestBody.toString())) {
                body = (Map < String, Object > ) JSON.deserializeUntyped(this.request.requestBody.toString());
            }
            return body;
        } catch (Exception e){
            BL_Utils.log('No Body Error' , e);
        }
        return null;
        
    }
    /**
     * 
     * @returns `List<Object>`
     * @description returns records property as List<Object> if exists
     */
    public List<Object> getRequestRecords() {
        if(this.requestBody.get('records') != null) {
            return (List<Object>) this.requestBody.get('records');
        }
        return null;
    }

    /**
     * 
     * @returns 'Object'
     * @description returns the body as one record Object if exists
     */
    public Object getRequestRecord() {
        if(this.requestBody != null) {
            return (Object) this.requestBody;
        }
        return null;
    }

    /**
     * 
     * @returns `List<Object>`
     * @description returns records property as List<Object> if exists
     */
    public virtual void checkValidityRequest() {
        if(queryParams!= null){
            if(supportedQueryParams!= null){
                for(string param : queryParams.keyset()){
                    if (!supportedQueryParams.contains(param))
                        throw new BL_Exceptions.CLTException('BAD PARAMETERS');
                }
            }

            
            
            if (queryParams.containskey('queryId') && String.isBlank(queryParams.get('queryId'))){
                throw new BL_Exceptions.CLTException('QUERY ID VALUE IS MISSING');
            }

            if (queryParams.containskey('pageIndex') && !queryParams.containskey('pageSize')){
                throw new BL_Exceptions.CLTException('PAGESIZE PARAMETER IS MISSING');
            }

            if (queryParams.containskey('pageIndex')){
                if(String.isBlank(queryParams.get('pageIndex')))
                    throw new BL_Exceptions.CLTException('PAGEINDEX VALUE IS MISSING');
                if(!queryParams.get('pageIndex').isNumeric())
                    throw new BL_Exceptions.CLTException('INVALID PAGEINDEX PARAMETER');
            }
            
            if (queryParams.containskey('pageSize')){
                if(String.isBlank(queryParams.get('pageSize')))
                    throw new BL_Exceptions.CLTException('PAGESIZE VALUE IS MISSING');
                if(!queryParams.get('pageSize').isNumeric())
                    throw new BL_Exceptions.CLTException('INVALID PAGESIZE PARAMETER');
            }

            if (queryParams.containskey('s')){
                if(String.isBlank(queryParams.get('s')))
                    throw new BL_Exceptions.CLTException('S VALUE IS MISSING');
                if(queryParams.get('s').tolowerCase()!= 'true' && queryParams.get('s').tolowerCase()!= 'false')
                    throw new BL_Exceptions.CLTException('INVALID S PARAMETER');
                if(!queryParams.containskey('pageIndex'))    
                    throw new BL_Exceptions.CLTException('MISSING PARAMETER FOR pageIndex METHOD');
                if(!queryParams.containskey('pageSize') && Integer.valueOf(queryParams.containskey('pageSize')) < 200)    
                    throw new BL_Exceptions.CLTException('PAGESIZE SHOULD BE AT LEAST 200');
            }
        }
    }
}