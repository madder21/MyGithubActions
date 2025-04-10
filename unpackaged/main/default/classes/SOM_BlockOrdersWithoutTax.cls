global with sharing class SOM_BlockOrdersWithoutTax {
    
    @InvocableMethod(label='Block Orders Without Tax' description='Block Orders Without Tax' )
    global static void SOM_BlockOrdersWithoutTax(List<List<SOM_RequestBlockOrdersWithoutTax>> Requests){
        String OrderIdRecord;
        try{
        Map<String, List<Map<String, String>>> RequestsMap = new Map<String, List<Map<String, String>>>();
        Map<String, String>   EmailBodyConfigs = new Map<String,String>();
        for(List<SOM_RequestBlockOrdersWithoutTax> listID : Requests){
            for(SOM_RequestBlockOrdersWithoutTax redId : listID){
                if (!RequestsMap.containsKey(redId.orderId) ) {
                    RequestsMap.put(redId.orderId, new List<Map<String, String>>());
                }
                Map<String, String> recordData = new Map<String, String>();
                recordData.put('RecordId', redId.RecordId);
                recordData.put('OrderReferenceNumber', redId.OrderReferenceNumber);
                RequestsMap.get(redId.orderId).add(recordData);
            }  
        }
        OrgWideEmailAddress owa = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE /*Address = 'noreply@rimowa.com' OR*/ Address = 'maha.meghras@viseo.com'  LIMIT 1];
        List<AddressToBlockOrdersWithoutTax__mdt> EmailBody = [ SELECT Email__c, Value__c, DeveloperName FROM AddressToBlockOrdersWithoutTax__mdt];
        for (AddressToBlockOrdersWithoutTax__mdt Body : EmailBody) {
            if(!EmailBodyConfigs.containsKey(Body.DeveloperName) && Body.DeveloperName != SOM_Constants.ADDRESS){
                EmailBodyConfigs.put(Body.DeveloperName, Body.Value__c);
            } else if(!EmailBodyConfigs.containsKey(Body.DeveloperName) && Body.DeveloperName == SOM_Constants.ADDRESS){
                EmailBodyConfigs.put(Body.DeveloperName, Body.Email__c);
            }
        }
        
        
        String bodyMessage = EmailBodyConfigs.get(SOM_Constants.INTRODUCTION);
        for (String orderId:RequestsMap.keySet()) {
            OrderIdRecord = orderId;
            bodyMessage += EmailBodyConfigs.get(SOM_Constants.ORDER) + '&nbsp;' + orderId + '<br/>';
            Boolean isFirstOrderRefNum = true;            
            for(Map<String, String> recordData : RequestsMap.get(orderId)){
                if (isFirstOrderRefNum) {
                    bodyMessage += EmailBodyConfigs.get(SOM_Constants.ORDERREFERENCENUMBER) + '&nbsp;' + recordData.get('OrderReferenceNumber') + '<br/>';
                    isFirstOrderRefNum = false;
                }
                bodyMessage += EmailBodyConfigs.get(SOM_Constants.fieldRate1) + '&nbsp;' + createRecordIdLink(recordData.get('RecordId')) + '&nbsp;' + EmailBodyConfigs.get(SOM_Constants.fieldRate2);
            }
        }
        
        bodyMessage += EmailBodyConfigs.get(SOM_Constants.CLOSING);
        bodyMessage += EmailBodyConfigs.get(SOM_Constants.REGARDS);
        sendEmail(EmailBodyConfigs.get(SOM_Constants.ADDRESS), owa, bodyMessage);
        Logs.debug('Block Orders Without Tax', 'SOM_BlockOrdersWithoutTax', 'SOM_BlockOrdersWithoutTax', '', '', OrderIdRecord);
        Logs.info('Block Orders Without Tax', 'SOM_BlockOrdersWithoutTax', 'SOM_BlockOrdersWithoutTax', '', '', OrderIdRecord);    
            
        }catch(Exception e){
            Logs.error(e,'SOM_BlockOrdersWithoutTax','SOM_BlockOrdersWithoutTax','','',OrderIdRecord);   
        }
        
        
    }
    
    public static void sendEmail(String EmailUser, OrgWideEmailAddress owa, String bodyMessage){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setOrgWideEmailAddressId(owa.id);
        String subject ='Orders Without Tax';
        message.setSubject(subject);
        list<string> toAddresses = new list<string>();
        toAddresses.add(EmailUser);
        message.setToAddresses(toAddresses);
        message.setHtmlBody(bodyMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
    }
    
    public static String createRecordIdLink(Id RecordId) {
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        String RecordIdLink = baseUrl + '/' + RecordId;
        String hyperlink = '<a href="' + RecordIdLink + '">' + RecordId + '</a>';
        return hyperlink;
    }
    
}