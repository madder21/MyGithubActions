/**
* @author Ulrich Madder NDONG NGOMO
* @date June,3rd 2024
* @Type Apex Class
*****************************************************************************************************************************************************************
* @description This class contains an invocable method used to anonymize client data according to the business requirements
***************************************************************************************************************************************************************** 
* @Version : 
* Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
* 0.0		|2024/06/03			|.UNNM		|.					|Original version
* 1.0		|2024/06/03			|.UNNM		|.					|Original version
*/
public with sharing class SFAnonymizationProcess {
    
    @InvocableMethod(label='SF Anonymization Process')
    public static void initAnonymizationProcess(List<SFAnonymizationProcessWrapper> flowInputs) {
		SFAnonymizationProcessWrapper wrapper = flowInputs[0];
        List<String> objectList = wrapper.objectList.split(',');
        List<Id> clientIds = wrapper.clientIdStr.split(wrapper.separator);
        List<Id> confObjIdList = new List<Id>();
        List<sObject> updateObjList = new List<sObject>();
        Map<String, List<String>> mapObjectAndFields = new Map<String, List<String>>();
        List<AnonymizationSFProcess__mdt> retrievedConfig = [SELECT Id, AnonymizationObject__c, LookupField__c, AnonymizationObject__r.DeveloperName, ExecutionOrder__c, AnonymizationObject__r.isCustomObject__c
                                                             FROM AnonymizationSFProcess__mdt WHERE AnonymizationObject__r.DeveloperName IN: objectList];
        Map<String, String> mapObjLookupFieldName = new Map<String, String>();
        Map<String, String> mapObjLookupFieldNameTmp = new Map<String, String>();
        for(AnonymizationSFProcess__mdt config : retrievedConfig) {
            mapObjLookupFieldNameTmp.put(config.AnonymizationObject__r.DeveloperName, config.LookupField__c);
            
            if(config.AnonymizationObject__r.isCustomObject__c){
                mapObjLookupFieldName.put(config.AnonymizationObject__r.DeveloperName+'__c', config.LookupField__c);                
            }else {
                mapObjLookupFieldName.put(config.AnonymizationObject__r.DeveloperName, config.LookupField__c);
            }
        }
        for(AnonymizationField__mdt field : [SELECT Id, AnonymizationObject__c, DeveloperName, AnonymizationObject__r.DeveloperName, AnonymizationObject__r.isCustomObject__c, isCustomField__c, Suffix__c
                                              FROM AnonymizationField__mdt 
                                              WHERE AnonymizationObject__r.DeveloperName IN: mapObjLookupFieldNameTmp.keySet()]) {
            String suffix = field.Suffix__c<>null?field.Suffix__c: '';
			String fieldName = field.DeveloperName.split('_')[1] + suffix;
            String objectName = field.AnonymizationObject__r.isCustomObject__c?field.AnonymizationObject__r.DeveloperName+'__c':field.AnonymizationObject__r.DeveloperName;
        	if(mapObjectAndFields.containsKey(objectName)){
            	mapObjectAndFields.get(objectName).add(fieldName);                                       
            }else {
            	List<String> fieldList = new List<String>();
                fieldList.add(fieldName);
                mapObjectAndFields.put(objectName, fieldList);
            }                                 
        }
        Map<String, String> retrievedSOQLQueriesMap = SOQLBuilder.buildSOQLQueriesMap(mapObjectAndFields, mapObjLookupFieldName, clientIds);
        List<sObject> objectRecordsMap = SOQLBuilder.getClientDataToBeAnonymized(retrievedSOQLQueriesMap);
        SFAnonymizationPushInQueueWrapper pushQWrapper = new SFAnonymizationPushInQueueWrapper();
		pushQWrapper.mapObjectAndFields = mapObjectAndFields;   
        pushQWrapper.globalList = objectRecordsMap;
        pushQWrapper.mapObjLookupFieldName = mapObjLookupFieldName;
        
        if(wrapper.timeStamp<>null) {
            pushQWrapper.timeStamp = wrapper.timeStamp;
            updateObjList = SOQLBuilder.pushInQueue(pushQWrapper);
        }else {
            updateObjList = SOQLBuilder.pushInQueueWithUsualVal(pushQWrapper);
        }
        System.enqueueJob(new SFAnonymizationProcessJob(updateObjList));
    }

}