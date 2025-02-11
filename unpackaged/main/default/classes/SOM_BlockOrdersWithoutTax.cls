global with sharing class SOM_BlockOrdersWithoutTax {
    
    @InvocableMethod(label='Block Orders Without Tax' description='Block Orders Without Tax' )
    global static void SOM_BlockOrdersWithoutTax(List<List<SOM_RequestBlockOrdersWithoutTax>> Requests){
        Map<String, List<String>> RequestsMap = new Map<String, List<String>>();
        Map<String, String>   EmailBodyConfigs = new Map<String,String>();
        for(List<SOM_RequestBlockOrdersWithoutTax> listID : Requests){
            for(SOM_RequestBlockOrdersWithoutTax redId : listID){
                if (!RequestsMap.containsKey(redId.orderId)) {
                    RequestsMap.put(redId.orderId, new List<String>());
                }
                RequestsMap.get(redId.orderId).add(redId.RecordId);                   
            }  
        }
        OrgWideEmailAddress owa = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'noreply@rimowa.com'/* OR Address = 'maha.meghras@viseo.com' */ LIMIT 1];
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
            bodyMessage += EmailBodyConfigs.get(SOM_Constants.ORDER) + '&nbsp;' + orderId + '<br/>';
            for(String RecordId:RequestsMap.get(orderId)){
                bodyMessage += EmailBodyConfigs.get(SOM_Constants.fieldRate1) + '&nbsp;' + RecordId + '&nbsp;' + EmailBodyConfigs.get(SOM_Constants.fieldRate2);
            }
        }
        
        bodyMessage += EmailBodyConfigs.get(SOM_Constants.CLOSING);
        bodyMessage += EmailBodyConfigs.get(SOM_Constants.REGARDS);
        sendEmail(EmailBodyConfigs.get(SOM_Constants.ADDRESS), owa, bodyMessage);
        
        
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
    
}
