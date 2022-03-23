/**
 * 
 * @author Jeremy Martiano
 * @since March 2020
 * @group Exceptions
 * @group balink  General
 * @description Exception classes 
 */
public class BL_Exceptions {
    
    /**
     * @description base exception class with errorCode, message and errorMessage
     */
    public virtual class BL_Exception extends Exception {
       
        public String errorCode {get;set;}
        public String message {
            get;
            set{
                message = value;
                this.setMessage(value);
            }
        }
        public String errorMessage {get;set;}

        public BL_Exception(String errorCode, String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
            this.errorCode = errorCode;            
        }
        public BL_Exception(String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
        }
    }


    /**
     * @description Exception class for router issues
     */
    public class RouterException extends BL_Exception {
  
        public RouterException(String errorCode, String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
            this.errorCode = errorCode;            
        }
        public RouterException(String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
        }
    }


    /**
     * @description Exception class for clientelling app related issues
     */
    public class CLTException extends BL_Exception {
       
        public CLTException(String errorCode, String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
            this.errorCode = errorCode;            
        }
        public CLTException(String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
        } 
    }



    /**
     * @description Exception class used for EasyQuery related issues
     */
    public class QueryException extends BL_Exception {
        
        public QueryException(String errorCode, String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
            this.errorCode = errorCode;            
        }
        public QueryException(String message, String errorMessage) {
            this.message = message;
            this.errorMessage = errorMessage;
        }   
    }    
}