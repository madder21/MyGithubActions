/**
 * @author Jeremy Martiano
 * @since March 2019
 * @description Class to record in BL_Log__c object the web service requests and responses
 * @group balink Webservices General
 */
public  class BL_WS_Log {

    public static BL_Log log = new BL_Log();
    public static string logName = '';
    private static DateTime startTime;
   
    //Initiate log Session for a REST WebService Call 
    public static void setPersistentLog(String className, String application) {
        try {
            RestRequest request = RestContext.request;
            log.mobileTimeZone = request.headers.get('TimeZone') != null ? request.headers.get('TimeZone') : '';
            log.mobileLanguage = request.headers.get('Accept-Language');
            log.requestSize = request.requestBody.size() / 1000.0;
            log.className = className;
            log.method = string.valueOf(request.httpMethod);
            log.userAgent = request.headers.get('User-Agent');
            log.queryParameters = request.params.size() > 0 ? String.valueOf(request.params) : '';
            log.request = request.requestBody.toString();
            log.requestHeaders = BL_HTTP_Utils.getHttpHeaderRequestString(request);
            log.requestURI = request.requestURI;
            log.application = application;
            startTime = System.now();
            system.debug('LOG' + log);
        } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    /**
     * 
     * @param e the exception to log
     * @description add exception information to the log record
     */
    public static void setErrorLogException(Exception e) {
        try {
            log.hasError = true;
            log.stackTrace = e.getStackTraceString();
            log.errorMessage = e.getMessage();
        } catch(Exception e2){
            BL_UTILS.logError(e2.getStackTraceString() + '\n' + e2.getMessage());
        }
    }

    /**
     * 
     * @param query the query to log
     * @param useCaseLabel the label of the use case that generated the query
     * @description add query information to the log record
     */
    public static void addLogQuery(String query, String useCaseLabel) {
        try {
            if( log!= null && String.isEmpty(log.query)){
                log.query = '';
            }
            log.query +=  (String.isEmpty(useCaseLabel) ? '' : 'Use Case: ' + useCaseLabel + ' --> ' ) + query +'\n\n';
            BL_utils.log('executeQuery' , query);
        } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    /**
     * 
     * @param Title the title to record before the notes
     * @param notes the content of the notes to record
     * @description add notes information to the log record
     */
    public static void addLogNotes(string Title,object notes) {
        try {
            if( log!= null && String.isEmpty(log.notes)){
                log.notes = '';
            }
            log.notes += '**** ' + Title + '****\n';
            log.notes +=  notes  +'\n\n';
        } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }
    /**
     * 
     * @param notes the content of the notes to record
     * @description add notes information to the log record
     */
    public static void addLogNotes(string notes) {
        try {
            if( log!= null && String.isEmpty(log.notes)){
                log.notes = '';
            }
            log.notes += '\n\n' + notes + '\n\n';
           } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    /**
     * 
     * @returns `Map<String,Object>`
     * @description returns the error information from the log to be used as a response for the web service
     */
    public static Map<String,Object> getErrorMessage() {
        try { 
            BL_AppSettings settings = BL_AppSettings.currentAppSettings;
            boolean isReturnFullError =  boolean.valueOf(settings.isReturnFullError);
            return new Map<String,Object>{
                 'error' => new Map<String,Object>{ // use BL_WS_ResponseError
                             'message'    => log.errorMessage + (isReturnFullError? '\n' + log.stackTrace : ''),
                             'logId'      => logName 
                            }
          };
        } catch(Exception e2){
            BL_UTILS.logError(e2.getStackTraceString() + '\n' + e2.getMessage());
        }
        return null;
    }

    public static void insertPersistentLog() {
        try {
            BL_AppSettings settings = BL_AppSettings.currentAppSettings;
            boolean isLogActive =  boolean.valueOf(settings.isLogActive);
            boolean isImmediate =  boolean.valueOf(settings.isImmediateLog);
            
            if (isLogActive == false) {
                return;
            }
            closePersistentLog();
            if(isImmediate){
                insert BL_Log.toSObject(log);
            } else {
                AsyncInsert(JSON.serialize(log));
            }
        } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    //Inserting Log with error will be done synchronously in order to send to the caller the log ID
    public static void insertPersistentLogWithError() {
        try {
            closePersistentLog();
            SObject newLog = BL_Log.toSObject(log);
            insert newLog;
            String soqlQuery = 'Select name FROM ' + BL_Constants.BL_LOG_NAME + ' WHERE id = \'' + newLog.get('id') + '\'';
            List<SObject> logs = database.query(soqlQuery);
            logName = (String)logs[0].get('name');
        } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    public static void insertPersistentLogWithError(Exception ex) {
        try {
            setErrorLogException(ex);
            closePersistentLog();            
            SObject newLog = BL_Log.toSObject(log);
            insert newLog;
            String soqlQuery = 'Select name FROM ' + BL_Constants.BL_LOG_NAME + ' WHERE id = \'' + newLog.get('id') + '\'';
            List<SObject> logs = database.query(soqlQuery);
            logName = (String)logs[0].get('name');
        } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    @TestVisible
    private static void asyncInsertPersistemtLog() {
        try {
            BL_AppSettings settings = BL_AppSettings.currentAppSettings;
            boolean isLogActive = (settings == null) ? false : boolean.valueOf(settings.isLogActive);

            if (isLogActive == false) {
                return;
            }
            closePersistentLog(); 
            AsyncInsert(JSON.serialize(log));
        } catch(Exception e){
            BL_UTILS.logError(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }
    @future
    private static void AsyncInsert(String JSONdata) {
        BL_Log log = (BL_Log)JSON.deserialize(JSONdata, BL_log.Class);
        insert BL_Log.toSObject(log);
    }

    //Close Log Session and populate all relevant fields before inserting the new log record
    @TestVisible
    private static void closePersistentLog() {
        RestResponse response = RestContext.response;
        string responseBody = response.responseBody == null ? 'null' : response.responseBody.toString();
        responseBody = (responseBody != null && responseBody.length() > 131000) ? responseBody.abbreviate(131000) : responseBody;

        log.responseSize = response.responseBody == null ? 0 : response.responseBody.size() / 1000.0;
        log.response = responseBody;
        log.sfdcLimits = BL_Utils.getCurrentOrgLimits();
        log.query = (log.query != null && log.query.length() > 131000) ? log.query.abbreviate(131000) : log.query;
        log.duration = Decimal.valueOf(system.now().getTime() - startTime.getTime()) / 1000;
    }
}