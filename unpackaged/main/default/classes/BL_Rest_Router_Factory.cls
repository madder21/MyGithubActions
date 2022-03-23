global class BL_Rest_Router_Factory {
    /**
* @description dispatchable
*/
global interface Dispatchable {
    // String getURIMapping(); // e.g. /teams/{teamNumber}/members/{memberId}
}

global interface DispatchableGET extends Dispatchable {
    Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams);
}
global interface DispatchablePOST extends Dispatchable {
    Object executePOST(Map<String, String> pathParameters, Map<String, String> queryParams, Map<String, Object> bodyMap);
}
global interface DispatchablePATCH extends Dispatchable {
    Object executePATCH(Map<String, String> pathParameters, Map<String, String> queryParams, Map<String, Object> bodyMap);
}
global interface DispatchablePUT extends Dispatchable {
    Object executePUT(Map<String, String> pathParameters, Map<String, String> queryParams, Map<String, Object> bodyMap);
}
global interface DispatchableDELETE extends Dispatchable {
    Object executeDELETE(Map<String, String> pathParameters, Map<String, String> queryParams, Map<String, Object> bodyMap);
}

global interface RouterMapping {
    Map<String,String> getRoutes();
}

global interface  Routable {
    RouterMapping getRouter();
    Void execute(RequestType requestType);
    String getPathSuffix(RestRequest request);
    void doGET();
    void doPOST();
    void doPATCH();
    void doPUT();
    void doDELETE();
}

global enum RequestType { HTTPGET, HTTPPOST, HTTPPUT, HTTPDELETE, HTTPPATCH }

global class Route {
    global String className {get; set;}
    global String path {get; set;}

    global Route(String className,String path) {
        this.path = path;
        this.className = className;
    }
}

global class RestResponseObject {
    global Object record {get; set;}

    global RestResponseObject(Object record) {
        this.record = record;
    }
}


global class RestResponseList {
    global Object records {get; set;}
    global Integer totalSize {get; set;}
    global Boolean done {get; set;}
    global String nextUrl {get; set;}
    global String queryId {get; set;}
    global Integer pageSize {get; set;}
    global Integer currentPage {get; set;}

    global RestResponseList(Integer totalSize, Object records, Boolean done, Integer pageSize, Integer currentPage) {
        this.records = records;
        this.totalSize = totalSize;
        this.done = done;
        this.pageSize = pageSize;
        this.currentPage = currentPage;
    }

    global RestResponseList(Map<String, Object> responseBody, Integer pageSize, Integer currentPage) {
        this.records = responseBody.get('records');
        this.totalSize = (Integer) responseBody.get('totalSize');
        this.done = true;
        this.pageSize = pageSize;
        this.currentPage = currentPage;
        if(responseBody.get('nextRecordsUrl') != null) {
            this.queryId = ((String) responseBody.get('nextRecordsUrl')).substringBetween('query/','-');
            this.nextUrl = (String) responseBody.get('nextRecordsUrl');
        }
    }

    global RestResponseList(Integer totalSize, Object records, Boolean done, String nextUrl) {
        this.records = records;
        this.totalSize = totalSize;
        this.done = done;
        this.nextUrl = nextUrl;
    }
}

global class RestResponseError {
    global String message {get; set;}
    global String errorCode {get; set;}
    global String clientMessage {get; set;}
    global String [] fields {get; set;}

    global RestResponseError(String message, String errorCode, List<String> fields, String clientMessage) {
        this.message = message;
        this.errorCode = errorCode;
        this.fields = fields;
        this.clientMessage = clientMessage;
    }
    

}

global class RouterException extends Exception {
    global String errorCode {get;set;}
    global String message {get;set;}
    global String clientMessage {get;set;}
    global Integer statusCode {get;set;}

    global RouterException(Map<String, Object> params) {
        this.message = (String) params.get('message');
        this.clientMessage = (String) params.get('clientMessage');
        this.errorCode = (String) params.get('errorCode');
        this.statusCode = (Integer) params.get('statusCode');
    }

    global RouterException( String errorCode, String message, String clientMessage, Integer statusCode ) {
        this.message = message;
        this.clientMessage = clientMessage;
        this.errorCode = errorCode;
        this.statusCode = statusCode;
    }

    // throw new Router_Factory.RouterException(new Map<String, Object> {
    //     'message'=>'APPOINTMENT BLOU',
    //     'clientMessage' => 'appointmentjshdajdhf ',
    //     'errorCode' => 'HJHJHH_HHHHH'
    // });

}

}