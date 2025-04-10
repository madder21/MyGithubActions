public class Logs {
    
    public static void error(Exception e, String LOG_CLASS_NAME,String Method, String Request, String Response, String relatedToId ){
        
        Log__c log = new Log__c();
        
        log.Class_Name__c       = 'Class: '+LOG_CLASS_NAME+', Method: '+Method;
        log.Has_Error__c        = true;
        log.Error_Message__c    = e.getMessage();
        log.LineNumber__c    	= e.getLineNumber();
        log.LogLevel__c    		= 'error';
        log.Request__c    		= Request;
        log.Response__c    		= Response;
        log.relatedToId__c      = relatedToId;
        insert log;
    }
    
    public static void debug(String message, String LOG_CLASS_NAME, String Method, String Request, String Response , String relatedToId){
        List <LogLevel__mdt> LogLevel = [SELECT Id, Level__c FROM LogLevel__mdt];
        if (LogLevel[0].Level__c == 'debug' || Test.isRunningTest() ){
            
            Log__c log = new Log__c();
            log.Class_Name__c       = 'Class: '+LOG_CLASS_NAME+', Method: '+Method;
            log.Has_Error__c        = false;
            log.Debug_message__c    = message; 
            log.LogLevel__c    		= 'debug';
            log.Request__c    		= Request;
            log.Response__c    		= Response;
            log.relatedToId__c      = relatedToId;
            
            insert log;
        }
    }
    
    public static void info(String message, String LOG_CLASS_NAME, String Method, String Request, String Response , String relatedToId){
        List <LogLevel__mdt> LogLevel = [SELECT Id, Level__c FROM LogLevel__mdt];
        if (LogLevel[0].Level__c == 'info' || Test.isRunningTest() ){
            Log__c log = new Log__c();
            log.Class_Name__c       = 'Class: '+LOG_CLASS_NAME+', Method: '+Method;
            log.Has_Error__c        = false;
            log.Debug_message__c    = message; 
            log.LogLevel__c    		= 'info';
            log.Request__c    		= Request;
            log.Response__c    		= Response;
            log.relatedToId__c      = relatedToId;
            
            insert log;
        }
    }
    
    
}