/**
 * 
 * @author 
 * @since 
 * @group Log,balink WS General
 */
public class BL_Log {

    public String     mobileTimeZone;
    public String     mobileLanguage;
    public Decimal    requestSize;
    public String     className;
    public String     method;
    public String     userAgent;
    public String     queryParameters;
    public String     request;
    public String     requestHeaders;
    public String     requestURI;
    public String     application;
    public Boolean    hasError;
    public String     stackTrace;
    public String     errorMessage;
    public String     query;
    public String     notes;
    public Decimal    responseSize;
    public String     response;
    public String     sfdcLimits;
    public Decimal    duration;

    public BL_Log() {

    }

    public static SObject toSObject(BL_Log log){
        Schema.SObjectType logType  = Schema.getGlobalDescribe().get(BL_Constants.BL_LOG_NAME);
        SObject logObject = logType.newSObject();
        logObject.put(BL_Constants.BL_LOG_MOBILE_TZ, log.mobileTimeZone);
        logObject.put(BL_Constants.BL_LOG_MOBILE_LANG, log.mobileLanguage);
        logObject.put(BL_Constants.BL_LOG_REQUEST_SIZE, log.requestSize);
        logObject.put(BL_Constants.BL_LOG_CLASSNAME, log.className);
        logObject.put(BL_Constants.BL_LOG_METHOD, log.method);
        logObject.put(BL_Constants.BL_LOG_USER_AGENT, log.userAgent);
        logObject.put(BL_Constants.BL_LOG_QUERY_PARAMS, log.queryParameters);
        logObject.put(BL_Constants.BL_LOG_REQUEST, log.request);
        logObject.put(BL_Constants.BL_LOG_REQUEST_HEADERS, log.requestHeaders);
        logObject.put(BL_Constants.BL_LOG_REQUEST_URI, log.requestURI);
        logObject.put(BL_Constants.BL_LOG_APPLICATION, log.application);
        logObject.put(BL_Constants.BL_LOG_HAS_ERROR, log.hasError == null ? false : log.hasError);
        logObject.put(BL_Constants.BL_LOG_STACK_TRACE, log.stackTrace);
        logObject.put(BL_Constants.BL_LOG_ERROR_MESSAGE, log.errorMessage);
        logObject.put(BL_Constants.BL_LOG_QUERY, log.query);
        logObject.put(BL_Constants.BL_LOG_NOTES, log.notes);
        logObject.put(BL_Constants.BL_LOG_RESPONSE_SIZE, log.responseSize);
        logObject.put(BL_Constants.BL_LOG_RESPONSE, log.response);
        logObject.put(BL_Constants.BL_LOG_SFDC_LIMITS, log.sfdcLimits);
        logObject.put(BL_Constants.BL_LOG_DURATION, log.duration);
        return logObject;
    }
}