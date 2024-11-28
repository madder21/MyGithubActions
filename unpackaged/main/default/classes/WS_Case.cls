@RestResource(urlMapping='/Cases/*')
global with sharing class WS_Case {

    @HttpPost
    global static void caseCreation() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String theJsonString = req.requestBody.toString();
        Map<String, Object> theJsonObject = (Map<String, Object>) JSON.deserializeUntyped(theJsonString);
        List<WS_Case__mdt> fieldMappings = [SELECT Json_Field__c, API_Name_Field__c FROM WS_Case__mdt];
        String hubOrigin = '';
        system.debug('^^^^ 1: hubOrigin ' + hubOrigin);
		hubOrigin = getHubOrigin(theJsonObject);
        system.debug('^^^^ 2: hubOrigin ' + hubOrigin);
        system.debug('^^^^ 3: getHubOrigin(theJsonObject) ' + getHubOrigin(theJsonObject));
        
        // LOG INITIALIZATION
        Log__c myLog = new Log__c();
        myLog.Class_Name__c = 'WS_Case';
        myLog.Method__c = 'caseCreation';
        myLog.Request__c = theJsonString;

        Case newCase = new Case();
        newCase.CurrencyIsoCode = 'EUR';
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        newCase.Hub_Origin__c = hubOrigin;
        
		if (fieldMappings.size() > 0){
            for (WS_Case__mdt mapping : fieldMappings) {
                String jsonFieldName = mapping.Json_Field__c;
                String salesforceFieldName = mapping.API_Name_Field__c;
                
                if (theJsonObject.containsKey(jsonFieldName)) {
                    String fieldValue = (String)theJsonObject.get(jsonFieldName);
                    newCase.put(salesforceFieldName, fieldValue);
                }
            }
        }

        JSONGenerator body = JSON.createGenerator(true);
        body.writeStartArray();
        body.writeStartObject();
        try{
            insert newCase;
            
            body.writeStringField('Status:', 'Success');
            if (!Test.isRunningTest() && newCase.Id != null) 
                body.writeStringField('CaseId:', newCase.Id); 
        } 
        catch (Exception e){
            
            body.writeStringField('Status:', 'Failed');
            body.writeObjectField('ErrorMessage:', e.getMessage());
            myLog.Response__c = body.getAsString();
            myLog.Error_Message__c = e.getMessage();
            myLog.Has_Error__c = true;
        }
        body.writeEndObject();
        body.writeEndArray();
        res.responseBody = Blob.valueOf(body.getAsString());
        
        myLog.Response__c = body.getAsString();
        insert myLog;
    }
    
    public static String getHubOrigin(Map<String, Object> objMap) {
        String webCountry = (String) objMap.get('WebCountry__c');
        String activity = (String) objMap.get('csc_activity__c');
        String region = (String) objMap.get('Region__c');
        String hubOrigin;
        if (webCountry == null || activity == null)
            return '';
        hubOrigin = (webCountry == 'US' && activity == 'CC' && region != null) 
                    ? (webCountry + region + activity).replaceAll(' |-', '')
                    : (webCountry + activity).replaceAll(' |-', '');

        system.debug('***** hubOrigin: ' + hubOrigin);
        
        Hub_Origin__mdt[] hubOrigins = [SELECT Label FROM Hub_Origin__mdt WHERE DeveloperName = :hubOrigin LIMIT 1];
		system.debug('***** hubOrigins: ' + hubOrigins);
        system.debug('***** hubOrigins[0].Label: ' + hubOrigins[0].Label);
        
        return (hubOrigins.isEmpty()) ? '' : hubOrigins[0].Label;
    }

    public static String removeSpaces(String inputString) {
        return inputString.replaceAll(' ', '');
    }
}