public class Logs {
    
    public static void error(Exception e, String LOG_CLASS_NAME,String Method, String Request, String Response){
            
            Log__c log = new Log__c();
                log.Class_Name__c       = 'Class: '+LOG_CLASS_NAME+', Method: '+Method;
            log.Has_Error__c        = true;
            log.Error_Message__c    = e.getMessage();
            log.LineNumber__c    	= e.getLineNumber();
            log.LogLevel__c    		= 'error';
            System.debug('>>>>>>>>>>>>>>>first num'+ e.getLineNumber());
            /*String line2 = e.getStackTraceString().split('\n')[1];
Pattern patt = Pattern.compile('([a-z0-9_.]+): line (\\d+)');
Matcher match = patt.matcher(line2);
match.find();
log.LineNumber__c    	= Integer.valueOf(match.group(2));
System.debug('<<<<<<<<<<second num'+ Integer.valueOf(match.group(2)));*/
            
            insert log;
    }
        
        public static void debug(String message, String LOG_CLASS_NAME, String Method, String Request, String Response){
            List <LogLevel__mdt> LogLevel = [SELECT Id, Level__c FROM LogLevel__mdt];
            if (LogLevel[0].Level__c == 'debug'){
                
                Log__c log = new Log__c();
                log.Class_Name__c       = 'Class: '+LOG_CLASS_NAME+', Method: '+Method;
                log.Has_Error__c        = false;
                log.Debug_message__c    = message; 
                log.LogLevel__c    		= 'debug';
                
                insert log;
            }
        }
        
        public static void info(String message, String LOG_CLASS_NAME, String Method, String Request, String Response){
            List <LogLevel__mdt> LogLevel = [SELECT Id, Level__c FROM LogLevel__mdt];
            if (LogLevel[0].Level__c == 'info'){
                Log__c log = new Log__c();
                log.Class_Name__c       = 'Class: '+LOG_CLASS_NAME+', Method: '+Method;
                log.Has_Error__c        = false;
                log.Debug_message__c    = message; 
                log.LogLevel__c    		= 'info';
                //method name
                
                insert log;
            }
        }
        
        
    }