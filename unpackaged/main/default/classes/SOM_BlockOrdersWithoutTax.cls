global with sharing class SOM_BlockOrdersWithoutTax {
    
    @InvocableMethod(label='Block Orders Without Tax' description='Block Orders Without Tax' )
    global static void SOM_BlockOrdersWithoutTax(List<List<SOM_RequestBlockOrdersWithoutTax>> Requests){
        Map<String, List<String>> RequestsMap = new Map<String, List<String>>();
        for(List<SOM_RequestBlockOrdersWithoutTax> listID : Requests){
            for(SOM_RequestBlockOrdersWithoutTax redId : listID){
                if (!RequestsMap.containsKey(redId.orderId)) {
                    RequestsMap.put(redId.orderId, new List<String>());
                }
                RequestsMap.get(redId.orderId).add(redId.RecordId);                   
            }  
        }

        OrgWideEmailAddress owa = [SELECT id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'noreply@rimowa.com'   LIMIT 1];
        AddressToBlockOrdersWithoutTax__mdt classNameList = [ SELECT Email__c FROM AddressToBlockOrdersWithoutTax__mdt limit 1];
        
        String bodyMessage = 'Hello, the field Rate for one or many products is incorrect for the following orders : <br/>  ';
        
        for (String orderId:RequestsMap.keySet()) {
            bodyMessage += '<br/> Order : ' + orderId + '<br/>';
            for(String RecordId:RequestsMap.get(orderId)){
                bodyMessage += 'The field Rate for the Order Product Tax Line Item  : ' + RecordId +' must be different than 0.<br/>';
            }
        }
        
        bodyMessage += '<br/> Please, update the Rate fields with the correct value to be able to create the OrderSummary for this order. <br/>';
        bodyMessage += 'Best regards, <br/>';
        sendEmail(classNameList.Email__c, owa, bodyMessage);
        
        
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