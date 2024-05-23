/*
 * Genesys Cloud CX
 * @author Ponin Sor
 * @date 01/2023
 * Custom Behavior on screenpop, saveLog, clickToDial
 */
global with sharing class GenesysCloudCTIExtensions implements
    purecloud.CTIExtension.ClickToDial,
    purecloud.CTIExtension.ScreenPop,
    purecloud.CTIExtension.SaveLog {
                
    // Name of this Salesforce instance
    public static final String TARGET = Label.TargetSalesforce;
    //public static final String TARGET =  DomainParser.parse(System.Url.getOrgDomainUrl()).getMyDomainName();


    public String onClickToDial(String data) {
        
        // Example: Specify On Behalf of Queue, Caller ID and Name for click-to-dial.
        String result = null;
        Map<String, Object> clickToDialData = (Map<String, Object>) JSON.deserializeUntyped(data);
        
        clickToDialData.put('queueId', 'Fake ID');
     
        if(clickToDialData.get('queueId') != null){
           result = JSON.serialize(clickToDialData);
        }
       
        return result;
    }

        
    public String onScreenPop(String data) {
          
        // Example: Find a recent Case record by phone number. if not found, fall back to default screen pop behavior.
        Map<String, Object> screenPopData = (Map<String, Object>) JSON.deserializeUntyped(data);
        Map<String, Object> dataToReturn = new Map<String, Object>(); 
        Map<String, Object> interaction = (Map<String, Object>) screenPopData.get('interaction');
    
        // API request to get Attributes
        String conversationId = (String) interaction.get('id');
        HTTPResponse response = new HTTPResponse();
        if(!Test.isRunningTest()){
             response = purecloud.SDK.Rest.get('/platform/api/v2/conversations/' + conversationId);
        }else{
            String mockResponse ='{"callLog":{ "subject":"Call 30/08/2023 10:52:32", "Customer_Number__c":"+336666666666","Queue__c":"UAT LVMH Ecom UK","Service_Name__c":"LVMH Ecom UK Hub EU","csc_market__c":"","Hub_Origin__c":"EU", "External_Transfert__c":"false", "Call_GUID__c":"e30f2afd-b189-4591-8c9b-7d7949970214","Call_Is_Recorded__c":"true", "Status":"Completed","CallType":"Inbound", "CallObject":"e30f2afd-b189-4591-8c9b-7d7949970214", "Type":"Call", "ActivityDate":"2023-8-30" },"interaction":{ "id":"e30f2afd-b189-4591-8c9b-7d7949970214", "connectedTime":"2023-08-30T08:52:32.533Z","phone":"tel:+336666666666", "name":"Mobile Number, France", "isConnected":true, "isDisconnected":false, "isDone":false,"state":"CONNECTED", "attributes":{ "sf_urlpop":""},"isCallback":false, "isDialer":false, "isChat":false, "isEmail":false, "isMessage":false,"isVoicemail":false, "remoteName":"Mobile Number, France", "recordingState":"active", "displayAddress":"+336666666666","queueName":"UAT LVMH Ecom UK", "ani":"+336666666666","calledNumber":"+336666666666","totalIvrDurationSeconds":4, "direction":"Inbound",  "isInternal":false, "startTime":"2023-08-30T08:52:24.395Z" },"eventName":"interactionChanged","participants":[{"purpose":"customer","attributes":{"BI_TargetSF":"LVMHCS_UAT","Target":"LVMHCS_UAT"}}]}';
            response.setStatus('OK');
            response.setStatusCode(200);
            response.setBody(mockResponse);
        }

        Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
         
        List<Object> participants = (List<Object>) responseJson.get('participants');
          
        Map<String, Object> attributes = new Map<String, Object>();
        Map<String, Object> participant = new Map<String, Object>();
        for(Integer i = 0; i < participants.size(); i++) {
            participant = (Map<String, Object>) participants.get(i);
            if ( ((string) participant.get('purpose')).equalsIgnoreCase('customer') ) {
                attributes = (Map<String, Object>) participant.get('attributes');
                break;
            }
        }
        
        // Find Target attribute
        if ( attributes.containsKey('BI_TargetSF'))
            if ( !((String) attributes.get('Target')).equalsIgnoreCase(GenesysCloudCTIExtensions.TARGET) ) {
                // Participant data 'Target' found but not the one expected
                dataToReturn.put('defaultScreenPop', false);
                return JSON.serialize(dataToReturn);
            }
        
        dataToReturn.put('defaultScreenPop', true);
        return JSON.serialize(dataToReturn);
    }

    public String onSaveLog(String data) {
         
        // Example: Save interaction log as Task record after interaction is disconnected.
        Map<String, Object> saveLogData = (Map<String, Object>) JSON.deserializeUntyped(data);
        Map<String, Object> interaction = (Map<String, Object>) saveLogData.get('interaction');
        
        // API request to get Attributes
        String conversationId = (String) interaction.get('id');
     HTTPResponse response = new HTTPResponse();
        if(!Test.isRunningTest()){
           response = purecloud.SDK.Rest.get('/platform/api/v2/conversations/' + conversationId);
        }else{
            response.setBody('{"callLog":{ "subject":"Call 30/08/2023 10:52:32", "Customer_Number__c":"+336666666666","Queue__c":"UAT LVMH Ecom UK","Service_Name__c":"LVMH Ecom UK Hub EU","csc_market__c":"","Hub_Origin__c":"EU", "External_Transfert__c":"false", "Call_GUID__c":"e30f2afd-b189-4591-8c9b-7d7949970214","Call_Is_Recorded__c":"true", "Status":"Completed","CallType":"Inbound", "CallObject":"e30f2afd-b189-4591-8c9b-7d7949970214", "Type":"Call", "ActivityDate":"2023-8-30" },"interaction":{ "id":"e30f2afd-b189-4591-8c9b-7d7949970214", "connectedTime":"2023-08-30T08:52:32.533Z","phone":"tel:+336666666666", "name":"Mobile Number, France", "isConnected":true, "isDisconnected":false, "isDone":false,"state":"CONNECTED", "attributes":{ "sf_urlpop":""},"isCallback":false, "isDialer":false, "isChat":false, "isEmail":false, "isMessage":false,"isVoicemail":false, "remoteName":"Mobile Number, France", "recordingState":"active", "displayAddress":"+336666666666","queueName":"UAT LVMH Ecom UK", "ani":"+336666666666","calledNumber":"+336666666666","totalIvrDurationSeconds":4, "direction":"Inbound",  "isInternal":false, "startTime":"2023-08-30T08:52:24.395Z" },"eventName":"interactionChanged","participants":[{"purpose":"customer","attributes":{"BI_TargetSF":"LVMHCS_UAT"}}]}');
            response.setStatus('OK');
            response.setStatusCode(200);
        }
        Map<String, Object> responseJson = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
        
        List<Object> participants = (List<Object>) responseJson.get('participants');  
         
        Map<String, Object> attributes = new Map<String, Object>();
        Map<String, Object> participant = new Map<String, Object>();
        for(Integer i = 0; i < participants.size(); i++) {
            participant = (Map<String, Object>) participants.get(i);
            if ( ((string) participant.get('purpose')).equalsIgnoreCase('customer') ) {
                attributes = (Map<String, Object>) participant.get('attributes');
                break;
            }
        }
        
        // Find Target attribute
        if ( attributes.containsKey('BI_TargetSF') )
            if ( !((String) attributes.get('BI_TargetSF')).equalsIgnoreCase(GenesysCloudCTIExtensions.TARGET) ) {
                    // Participant data 'Target' found but not the one expected
                    System.debug(attributes.containsKey('Target'));
                    // return Empty callLogId
                    return '';
            }

        
        // Create/update CallLog as standard behavior
        Map<String, Object> callLog = ( Map<String, Object>) saveLogData.get('callLog');
        //Boolean isDisconnected = (Boolean) interaction.get('isDisconnected');
        String callLogId = '';
        //if (isDisconnected) {
            Task t = (Task) JSON.deserialize(JSON.serialize(callLog), Task.class);
            upsert t;
            callLogId = t.Id;
        //}
        return callLogId; 
    }
        
       
}