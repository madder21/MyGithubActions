public class SFMCCallOut {
    

private static SFMCCredentials__mdt DevproCredentials = SFMCCredentials__mdt.getInstance('Devpro');
private static String MARKETING_CLOUD_SOAP_URL = DevproCredentials.MARKETING_CLOUD_SOAP_URL__c;
private static String MARKETING_CLOUD_AUTH_URL = DevproCredentials.MARKETING_CLOUD_AUTH_URL__c;
private static String MARKETING_CLOUD_CLIENT_ID = DevproCredentials.MARKETING_CLOUD_CLIENT_ID__c;
private static String MARKETING_CLOUD_CLIENT_SECRET = DevproCredentials.MARKETING_CLOUD_CLIENT_SECRET__c;

@Future (callout=true)
public static void calloutAllsubscriber (List<String> listSubscriberKey){

    //Retreive token SFMC
    performUpdateSubStatus(listSubscriberKey);

}

private static String ACCESS_TOKEN = 'access_token';
    // this function make a simple Post Callout to a specific endpoint  
    public static String getCalloutSOAP(String endPoint, String soapBody){
    Http h = new Http();
    HttpRequest r = new HttpRequest();
    r.setTimeout(60000);
    r.setEndpoint(endPoint);  
    r.setMethod('GET');
    r.setHeader('Content-type','application/json');    
    r.setBody(soapBody);   
    if (!Test.isRunningTest()){
        HttpResponse res = h.send(r);
        return res.getBody();

    } else return 'ok'; 

}
    
// this function is used to get an access token that is used in the callout
 
public static String getMarketingCloudOAuthToken(){
   
         String responseBody = getCalloutSOAP(
        MARKETING_CLOUD_AUTH_URL,
        JSON.serialize( new Map<String, String>{
            'client_id' => MARKETING_CLOUD_CLIENT_ID,
            'client_secret' => MARKETING_CLOUD_CLIENT_SECRET,
                'grant_type'=>'client_credentials'
        } )
    );
    if(!Test.isRunningTest()){

        return ((Map<String, String>) JSON.deserialize(responseBody, Map<String, String>.class)).get(ACCESS_TOKEN); 

    }else return 'AccessTokent';
  
    
    }
  
    // this function make a Soap Callout to a spicific endpoint 
    private static String makeHTTPXMLPost(String endPoint, String soapBody){
    Http h = new Http();
    HttpRequest r = new HttpRequest();
    r.setTimeout(60000);
    r.setEndpoint(endPoint);  
    r.setMethod('POST');
    
    r.setHeader('Content-type','text/xml');    
    r.setHeader('charset','UTF-8'); 
    r.setBody(soapBody); 
    if (!Test.isRunningTest()){
        HttpResponse s = h.send(r);
       
        if(s.getStatusCode()!=200){
                   
        }
       	System.debug(s.getStatus());
    return s.getBody();

    }else return 'ok';   
    
}
    
    //this function update the status of a subscriber through a Soap Callout 
    public static String performUpdateSubStatus(List<String> listSubscribekeys){
        String subcriberToUpdateEvl ='' ; 

        for (String idSubscriber : listSubscribekeys){
            subcriberToUpdateEvl += 
            '<Objects xsi:type="Subscriber">'+
                '<SubscriberKey>'+idSubscriber+'</SubscriberKey>'+
                '<Status>Active</Status>'+
                '<Action>Update</Action>'+
            '</Objects>';
        }
        
        
    String soapEnvelopeTemplate = '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
        '<s:Header>'+
            '<a:Action s:mustUnderstand="1">Update</a:Action>'+
            '<a:MessageID>urn:uuid:7e0cca04-57bd-4481-864c-6ea8039d2ea0</a:MessageID>'+
            '<a:ReplyTo>'+
                '<a:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</a:Address>'+
            '</a:ReplyTo>'+
            '<a:To s:mustUnderstand="1">'+MARKETING_CLOUD_SOAP_URL+'</a:To>'+
            '<fueloauth>'+getMarketingCloudOAuthToken()+'</fueloauth>'+
        '</s:Header>'+
        '<s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">'+
        '<UpdateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
        subcriberToUpdateEvl +
    '</UpdateRequest>'+
    '</s:Body>'+
    '</s:Envelope>';

    System.debug('SFMCCallout ::: soapEnveloppe ' + soapEnvelopeTemplate );
     
    return makeHTTPXMLPost( MARKETING_CLOUD_SOAP_URL, soapEnvelopeTemplate );
   }
}