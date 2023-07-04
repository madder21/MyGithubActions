/**
 * @author AbdelKhalek Saidi
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class is utilized within the flow to divide a string into multiple substrings using a comma-separated format
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/
public with sharing class ConvertStringToStringCollection {
    
    @invocableMethod(label='Convert Comma-separated-values to String Collection'
                     description='Converts a Comma-separated-values string (eg, from a field) to a String Collection' 
                     category= 'Utilities')
    public static List<Response> execute (List<Request> requests) {

        List<Response> responseList = new List<Response>();
        for (Request curRequest : requests) {
            Response response = new Response();
            response.stringCollection = curRequest.csvString?.split(curRequest.delimiter);
            responseList.add(response);
        }

        return responseList;
    }

    public class Request {
        @invocableVariable(label='Input String' description='Input' required=true)
        public String csvString;
        
        @invocableVariable(label='Delimiter' description='Delimiter string; defaults to comma (,)' required=true)
        public String delimiter;
    }

    public class Response {
        @invocableVariable(label='String Collection' description='Collection variable to store output')
        public List<String> stringCollection;

    }

    
}