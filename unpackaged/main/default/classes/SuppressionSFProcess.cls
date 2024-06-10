public with sharing class SuppressionSFProcess {
    
    @InvocableMethod(label='SF Suppression Process')
    public static void initSuppressionProcess(List<SFAnonymizationProcessWrapper> flowInputs) {
        
        SFAnonymizationProcessWrapper wrapper = flowInputs[0];
        List<String> objectList = wrapper.objectList.split(',');
        System.debug('wrapper :'+wrapper);
        List<Id> clientIds = wrapper.clientIdStr.split(wrapper.separator);
        List<Id> confObjIdList = new List<Id>();
        List<SuppressionSFProcess__mdt> retrievedConfig = [SELECT Id, AnonymizationObject__c, LookupField__c, AnonymizationObject__r.DeveloperName, AnonymizationObject__r.isCustomObject__c
                                                           FROM SuppressionSFProcess__mdt WHERE AnonymizationObject__r.DeveloperName IN: objectList];
        System.debug('retrievedConfig :'+retrievedConfig);
        Map<String, String> mapObjLookupFieldName = new Map<String, String>();
        for(SuppressionSFProcess__mdt config : retrievedConfig) {
            if(config.AnonymizationObject__r.isCustomObject__c){
                mapObjLookupFieldName.put(config.AnonymizationObject__r.DeveloperName+'__c', config.LookupField__c);                
            }else {
                mapObjLookupFieldName.put(config.AnonymizationObject__r.DeveloperName, config.LookupField__c);
            }
        }
        System.debug('mapObjLookupFieldName :'+mapObjLookupFieldName);
        Map<String, String> retrievedSOQLQueriesMap = SOQLBuilder.buildSOQLQueriesMap(mapObjLookupFieldName, clientIds);
        System.debug('retrievedSOQLQueriesMap :'+retrievedSOQLQueriesMap);
        List<sObject> objectRecords = SOQLBuilder.getClientDataToBeAnonymized(retrievedSOQLQueriesMap);
        System.debug('objectRecords :'+objectRecords);
        List<Account> accList = new List<Account>();
        List<sObject> objList = new List<sObject>();
        for(sObject obj: objectRecords) {
            switch on obj {
                When Account acc {
                    accList.add(acc);
                }
                when else {
                    objList.add(obj);
                }
            }
        }
        System.debug('objList :'+objList);
        System.debug('accList :'+accList);
        QueueableUtil.enqueueJob(new ManageRGPDObject_CTL(objList));
        QueueableUtil.enqueueJob(new ManageRGPDObject_CTL(accList));        
    }

}