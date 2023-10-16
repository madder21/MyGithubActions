/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 03-10-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
public with sharing class WS_AccountUTL {
    
    Public static String CLASS_NAME = 'WS_AccountUTL';
    
    public static HttpRequest buildRequest(String sObjectInstance) {
        HttpRequest req = new HttpRequest();
        AccountAPI__c apiAccount = AccountAPI__c.getInstance(sObjectInstance);
        req.setEndpoint(apiAccount.EndPoint__c);
        req.setMethod(apiAccount.Method__c);
        req.setHeader('Content-Type',apiAccount.Content_Type__c);
        req.setHeader('client_id', apiAccount.Client_Id__c);
        req.setHeader('client_secret', apiAccount.Client_secret__c);
        return req;
    }
    
    public static HttpResponse pushRequest(String jsonContent, String sObjectInstance) {
    
        String METHOD_NAME = 'pushRequest';
        HttpResponse res = new HttpResponse();
        try {
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'jsonContent'+jsonContent);
            HTTP http = new HTTP();
            HttpRequest req = buildRequest(sObjectInstance);
            req.setBody(jsonContent);
            req.setTimeout(2000);
            res = http.send(req);
            System.debug('*** CDP Integration Result ***: '+res);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
        } catch(Exception e) {
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'exception : '+e.getMessage()); 
        }
        return res;
    }
}