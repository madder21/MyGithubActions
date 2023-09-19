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
        String clientSourceContent = JSON.serialize(jsonMaps.get('client_Sources'));
        System.debug('*** accountContent clientSourceContent ***:  '+clientSourceContent);
        String clientAddressesContent = JSON.serialize(jsonMaps.get('client_Adresses'));
        String accountContent = JSON.serialize(jsonMaps.get('client'));
        System.debug('*** accountContent ***:  '+accountContent);
        
        //Parse objects: account, client source/address
        List<ClientSource__c> clientSourceList = (List<ClientSource__c>)JSON.deserialize(clientSourceContent, List<ClientSource__c>.class);
        List<ClientAddress__c> clientAddressList = (List<ClientAddress__c>)JSON.deserialize(clientAddressesContent, List<ClientAddress__c>.class);
        Account accToBeUpdated = (Account)JSON.deserialize(accountContent, Account.class);
        System.debug('*** clientSourceList ***:  '+clientSourceList[0].SourceLastUpdateDate__c);
        String ClientID = (String)jsonMaps.get('Client__c');
        
        WS_ClientKPIUTL.upsertClientDetails(accToBeUpdated);
        Database.SaveResult[] sourceResponse = !clientSourceList.isEmpty()?WS_ClientKPIUTL.upsertClientSources(clientSourceList, ClientID):null;
        Database.SaveResult[] addressResponse = !clientAddressList.isEmpty()?WS_ClientKPIUTL.upsertClientAddresses(clientAddressList, ClientID) : null;
        String response = JSON.serialize(sourceResponse) + JSON.serialize(addressResponse);
        //String response = JSON.serialize(addressResponse);
        return response;
    }
}