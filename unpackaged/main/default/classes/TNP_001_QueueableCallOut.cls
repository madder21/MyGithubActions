public class TNP_001_QueueableCallOut implements Queueable,Database.AllowsCallouts{
    
public String jsonGenerated;  
public String CLASS_NAME = 'TNP_001_QueueableCallOut' ;  
    public TNP_001_QueueableCallOut(String jsonGenerated){
        this.jsonGenerated = jsonGenerated;  
    }
    
    public void execute(QueueableContext context) {
           String METHOD_NAME = 'sendRequest' ;
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'jsonGenerated'+jsonGenerated);         
        Http http=new http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        AccountAPI__c apiAccount = AccountAPI__c.getInstance('Account Api');
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'apiAccount'+apiAccount); 
        String  endPoint = apiAccount.EndPoint__c;
        String method = apiAccount.Method__c;
        req.setEndpoint(endPoint);
        req.setMethod(method);
        req.setHeader('Content-Type',apiAccount.Content_Type__c);
        req.setHeader('client_id', apiAccount.Client_Id__c);
        req.setHeader('client_secret', apiAccount.Client_secret__c);
        //req.setHeader('Accept', apiAccount.Accept__c);
        req.setBody(jsonGenerated);
        res = http.send(req);
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'result : '+res);  
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'result Body : '+res.getBody());
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
       
    }
    
}