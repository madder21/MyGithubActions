/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 05-09-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
public with sharing class WS_ClientKPIUTL {
    
    public static List<Database.SaveResult> upsertClientSources(List<ClientSource__c> sources, String clientID) {
        
        System.debug('*** sources ***: '+sources);
        System.debug('*** clientID ***: '+clientID);
        Map<String, List<ClientSource__c>> clientSourceBySourceMap = new Map<String, List<ClientSource__c>>();
        List<ClientSource__c> srcListToBeUpdated = new List<ClientSource__c>();
        List<ClientSource__c> srcListToBeCreated = new List<ClientSource__c>();
        Database.SaveResult[] srList;
        // Get the SObject describe result
		Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('ClientSourceFields__c').getDescribe();
        Map<String, SObjectField> fieldsMap = describeResult.fields.getMap();
        
        List<ClientSource__c> retrievedClientSources = [SELECT Id, Client__c, Source__c, SourceCode__c, SourceCreationDate__c, SourceLastUpdateDate__c
                                                        FROM ClientSource__c WHERE Client__c =: clientID];
        System.debug('*** retrievedClientSources ***: '+retrievedClientSources);
        for(ClientSource__c src : retrievedClientSources) {
            if(clientSourceBySourceMap.containsKey(src.Source__c)) {
                clientSourceBySourceMap.get(src.Source__c).add(src);
            }else {
                List<ClientSource__c> clientSourceList = new List<ClientSource__c>();
                clientSourceList.add(src);
                clientSourceBySourceMap.put(src.Source__c, clientSourceList);
            }
        }
        System.debug('*** clientSourceBySourceMap ***: '+clientSourceBySourceMap);
        for(ClientSource__c src : sources) {
            System.debug('*** src ***: '+src);
            if(clientSourceBySourceMap.containsKey(src.Source__c)) {
                for(ClientSource__c clientSource : clientSourceBySourceMap.get(src.Source__c)) {
                    Boolean isExisted = (src.Source__c == clientSource.Source__c) 
                        && (src.SourceCode__c == clientSource.SourceCode__c)?true : false;
                    if(isExisted) {
                        clientSource.SourceCreationDate__c = src.SourceCreationDate__c;
                        clientSource.SourceLastUpdateDate__c = src.SourceLastUpdateDate__c;
                        srcListToBeUpdated.add(clientSource);
                    }
                } 
            }else {
                src.Client__c = clientID;
                srcListToBeCreated.add(src);
            }
            
        }
        
        if(!srcListToBeUpdated.isEmpty()) {
            System.debug('*** srcListToBeUpdated ***: '+srcListToBeUpdated);
            srList = Database.update(srcListToBeUpdated);
            System.debug('*** srList ***: '+srList);
        }
        if(!srcListToBeCreated.isEmpty()) {
            System.debug('*** srcListToBeCreated ***: '+srcListToBeCreated);
            srList = Database.insert(srcListToBeCreated);
            System.debug('*** srList ***: '+srList);
        }
        return srList;
    }
    
    public static List<Database.SaveResult> upsertClientAddresses(List<ClientAddress__c> addresses, String clientID) {
        
        Map<String, ClientAddress__c> clientAddressBySourceMap = new Map<String, ClientAddress__c>();
        List<ClientAddress__c> addrListToBeUpdated = new List<ClientAddress__c>();
        List<ClientAddress__c> addrListToBeCreated = new List<ClientAddress__c>();
        Database.SaveResult[] srList;
        Boolean isAlreadyExisted = false;
        // Get the SObject describe result
		Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('ClientAddressFields__c').getDescribe();
        Map<String, SObjectField> fieldsMap = describeResult.fields.getMap();
        
        List<ClientAddress__c> retrievedClientAddresses = [SELECT Id, Address1__c, Address2__c, Address3__c, City__c, Country__c,
                                                           PostalCode__c, State__c, AddressTypology__c, IsValid__c 
                                                           FROM ClientAddress__c WHERE Client__c =: clientID];
        System.debug('*** retrievedClientAddresses ***: '+retrievedClientAddresses);
        for(ClientAddress__c receivedAddr : addresses) {
            if(!retrievedClientAddresses.isEMpty()) {
            	for(ClientAddress__c addr : retrievedClientAddresses) {
                    System.debug('*** current addr ***: '+addr);
                    System.debug('*** current receivedAddr ***: '+receivedAddr);
                    isAlreadyExisted = (receivedAddr.Address1__c == addr.Address1__c) && (receivedAddr.Address2__c == addr.Address2__c) 
                        && (receivedAddr.Address3__c == addr.Address3__c) && (receivedAddr.City__c == addr.City__c) && (receivedAddr.Country__c == addr.Country__c) 
                        && (receivedAddr.PostalCode__c == addr.PostalCode__c) && (receivedAddr.State__c == addr.State__c) && (receivedAddr.AddressTypology__c == addr.AddressTypology__c) 
                        && (receivedAddr.IsValid__c == addr.IsValid__c)? true : false;
                    System.debug('*** isAlreadyExisted ***: '+isAlreadyExisted);
                    if(isAlreadyExisted)break;
                }
                if(!isAlreadyExisted) {
                	receivedAddr.Client__c = clientID;
                   	addrListToBeCreated.add(receivedAddr);
                }
            }else {
                receivedAddr.Client__c = clientID;
            	addrListToBeCreated.add(receivedAddr);
        	}
        }
        
        if(!addrListToBeCreated.isEmpty()) {
            System.debug('*** addrListToBeCreated ***: '+addrListToBeCreated);
            srList = Database.insert(addrListToBeCreated);
        }
        
        
        return srList;
    }
    
    public static void upsertClientDetails(Account acc) {
    	List<Store__c> retrievedStore = acc.OriginStore__pr!=null?[SELECT Id FROM Store__c WHERE SourceStoreId__c =: acc.OriginStore__pr.SourceStoreId__c]: null;
        System.debug('*** retrievedStore ***: '+retrievedStore);
        List<Store__c> retrievedPreferredStore = acc.PreferredStore__pr!=null?[SELECT Id FROM Store__c WHERE SourceStoreId__c =: acc.PreferredStore__pr.SourceStoreId__c] : null;
        System.debug('*** retrievedPreferredStore ***: '+retrievedPreferredStore);
        List<Store__c> retrievedMainStore = acc.MainStore__pr!=null?[SELECT Id FROM Store__c WHERE SourceStoreId__c =: acc.MainStore__pr.SourceStoreId__c] : null;
        System.debug('*** retrievedMainStore ***: '+retrievedMainStore);
        acc.OriginStore__pc = (retrievedStore!=null && !retrievedStore.isEmpty())?retrievedStore[0].Id : null;
        acc.MainStore__pc = (retrievedMainStore!=null && !retrievedMainStore.isEmpty())?retrievedMainStore[0].Id : null;
        acc.PreferredStore__pc = (retrievedPreferredStore!=null && !retrievedPreferredStore.isEmpty())?retrievedPreferredStore[0].Id : null;
        acc.OriginStore__pr = null;
        acc.MainStore__pr = null;
        acc.PreferredStore__pr = null;
        System.debug('*** acc ***: '+acc);
        update acc; 
    }

}