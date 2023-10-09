/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 05-09-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@RestResource(urlMapping='/ClientKPI/*')
global with sharing class WS_ClientKPI {
    
    @HttpPost
    global static String upsertClientInformation() {
        RestRequest req = RestContext.request;
        System.debug('*** req.requestBody ***: '+req.requestBody);
        
        //Untyped JSON deserialization
        Map<String, Object> jsonMaps = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        System.debug('*** jsonMaps ***:  '+jsonMaps.get('Client__c'));
        
        //Serialization account, client source/address
        String clientSourceContent = jsonMaps.containsKey('client_Sources')?JSON.serialize(jsonMaps.get('client_Sources')):null;
        System.debug('*** accountContent clientSourceContent ***:  '+clientSourceContent);
        String clientAddressesContent = jsonMaps.containsKey('client_Adresses')?JSON.serialize(jsonMaps.get('client_Adresses')) : null;
        String accountContent = JSON.serialize(jsonMaps.get('client'));
        System.debug('*** accountContent ***:  '+accountContent);
        String response = '';
        String ClientID = (String)jsonMaps.get('Client__c');
        //Parse objects: account, client source/address
        if(clientSourceContent!=null) {
        	List<ClientSource__c> clientSourceList = (List<ClientSource__c>)JSON.deserialize(clientSourceContent, List<ClientSource__c>.class);
            Database.SaveResult[] sourceResponse = !clientSourceList.isEmpty()?WS_ClientKPIUTL.upsertClientSources(clientSourceList, ClientID):null;
            response += JSON.serialize(sourceResponse);
        }
        if(clientAddressesContent!=null) {
        	List<ClientAddress__c> clientAddressList = (List<ClientAddress__c>)JSON.deserialize(clientAddressesContent, List<ClientAddress__c>.class);
            Database.SaveResult[] addressResponse = !clientAddressList.isEmpty()?WS_ClientKPIUTL.upsertClientAddresses(clientAddressList, ClientID) : null;
            response += JSON.serialize(addressResponse);
        }
       
        Account accToBeUpdated = (Account)JSON.deserialize(accountContent, Account.class);        
        WS_ClientKPIUTL.upsertClientDetails(accToBeUpdated);
        return response;
    }
}