@RestResource(urlMapping='/CaseCreation/*')
global with sharing class WS_Case {

    @HttpPost
    global static void caseCreation() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        String theJsonString = req.requestBody.toString();
        Map<String, Object> theJsonObject = (Map<String, Object>) JSON.deserializeUntyped(theJsonString);
        String hubOrigin = '';

        // LOG INITIALIZATION
        Log__c myLog = new Log__c();
        myLog.Class_Name__c = 'WS_Case';
        myLog.Method__c = 'caseCreation';
        myLog.Request__c = theJsonString;

        hubOrigin = getHubOrigin(theJsonObject);

        Case newCase = new Case();
        newCase.CurrencyIsoCode = 'EUR';
        newCase.Status = 'New';
        newCase.Origin = 'Web';
        if (!String.isEmpty((String) theJsonObject.get('Subject')))
            newCase.Subject = (String) theJsonObject.get('Subject');
        if (!String.isEmpty((String) theJsonObject.get('Description')))
            newCase.Description = (String) theJsonObject.get('Description');
        if (!String.isEmpty((String) theJsonObject.get('Civility__c')))
            newCase.Civility__c = (String) theJsonObject.get('Civility__c');
        if (!String.isEmpty((String) theJsonObject.get('FirstName__c')))
            newCase.FirstName__c = (String) theJsonObject.get('FirstName__c');
        if (!String.isEmpty((String) theJsonObject.get('LastName__c')))
            newCase.LastName__c = (String) theJsonObject.get('LastName__c');
        if (!String.isEmpty((String) theJsonObject.get('CustomerEmail__c'))) {
            newCase.CustomerEmail__c = (String) theJsonObject.get('CustomerEmail__c');
            newCase.SuppliedEmail__c = (String) theJsonObject.get('CustomerEmail__c');
            newCase.SuppliedEmail = (String) theJsonObject.get('CustomerEmail__c');
        }
        if (!String.isEmpty((String) theJsonObject.get('Phone__c')))
            newCase.Phone__c = (String) theJsonObject.get('Phone__c');
        if (!String.isEmpty((String) theJsonObject.get('Productreference__c')))
            newCase.Productreference__c = (String) theJsonObject.get('Productreference__c');
        if (!String.isEmpty((String) theJsonObject.get('WebCountry__c')))
            newCase.WebCountry__c = (String) theJsonObject.get('WebCountry__c');
        if (!String.isEmpty((String) theJsonObject.get('Region__c')))
            newCase.Regional_Hub__c = (String) theJsonObject.get('Region__c');
        if (!String.isEmpty((String) theJsonObject.get('csc_activity__c')))
            newCase.Activity__c = (String) theJsonObject.get('csc_activity__c');
        if (hubOrigin != null)
            newCase.Hub_Origin__c = hubOrigin;

        try {
            insert newCase;
            JSONGenerator body = JSON.createGenerator(true);
            body.writeStartArray();
            body.writeStartObject();
            body.writeStringField('Status:', 'Success');
            body.writeStringField('CaseId:', newCase.Id);
            body.writeObjectField('ErrorMessage:', '');
            body.writeEndObject();
            body.writeEndArray();
            res.responseBody = Blob.valueOf(body.getAsString());

            myLog.Response__c = body.getAsString();
        } catch (Exception e) {
            JSONGenerator body = JSON.createGenerator(true);
            body.writeStartArray();
            body.writeStartObject();
            body.writeStringField('Status:', 'Failed');
            if (newCase.Id != null) {
                body.writeStringField('CaseId:', newCase.Id);
            }
            body.writeStringField('CaseId:', '');
            body.writeObjectField('ErrorMessage:', e.getMessage());
            body.writeEndObject();
            body.writeEndArray();
            res.responseBody = Blob.valueOf(body.getAsString());

            myLog.Response__c = body.getAsString();
            myLog.Error_Message__c = e.getMessage();
            myLog.Has_Error__c = true;
        }
        insert myLog;
    }

    public static String getHubOrigin(Map<String, Object> objMap) {
        String hubOrigin = '';
        if (!String.isEmpty((String) objMap.get('WebCountry__c')) && !String.isEmpty((String) objMap.get('csc_activity__c'))) {
            hubOrigin = removeSpaces((String) objMap.get('WebCountry__c') + (String) objMap.get('csc_activity__c'));
            if ((String) objMap.get('WebCountry__c') == 'US' && (String) objMap.get('csc_activity__c') == 'CC') {
                if (!String.isEmpty((String) objMap.get('Region__c'))) {
                    hubOrigin = removeSpaces((String) objMap.get('WebCountry__c') + (String) objMap.get('Region__c') + (String) objMap.get('csc_activity__c'));
                }
            }
        }
        if (hubOrigin != null) {
            Hub_Origin__mdt[] hubOrigins = [SELECT Id, Label, DeveloperName FROM Hub_Origin__mdt WHERE DeveloperName = :hubOrigin LIMIT 1];
            if (!hubOrigins.isEmpty()) {
                hubOrigin = hubOrigins[0].Label;
            }
        }
        return hubOrigin;
    }

    public static String removeSpaces(String inputString) {
        return inputString.replaceAll(' ', '');
    }
}