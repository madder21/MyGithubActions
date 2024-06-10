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
*/
public with sharing class SFAnonymizationProcess {
    
    @InvocableMethod(label='SF Synchronization Process')
    public static void initAnonymizationProcess(List<SFAnonymizationProcessWrapper> flowInputs) {
		SFAnonymizationProcessWrapper wrapper = flowInputs[0];
        List<String> objectList = wrapper.objectList.split(',');
        System.debug('wrapper :'+wrapper);
        List<Id> clientIds = wrapper.clientIdStr.split(wrapper.separator);
        List<Id> confObjIdList = new List<Id>();
        Map<String, List<String>> mapObjectAndFields = new Map<String, List<String>>();
        List<AnonymizationSFProcess__mdt> retrievedConfig = [SELECT Id, AnonymizationObject__c, LookupField__c, AnonymizationObject__r.DeveloperName, ExecutionOrder__c, AnonymizationObject__r.isCustomObject__c
                                                             FROM AnonymizationSFProcess__mdt WHERE AnonymizationObject__r.DeveloperName IN: objectList];
        System.debug('retrievedConfig :'+retrievedConfig);
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
        System.debug('mapObjLookupFieldName :'+mapObjLookupFieldName);
        for(AnonymizationField__mdt field : [SELECT Id, AnonymizationObject__c, DeveloperName, AnonymizationObject__r.DeveloperName, AnonymizationObject__r.isCustomObject__c, isCustomField__c
                                              FROM AnonymizationField__mdt 
                                              WHERE AnonymizationObject__r.DeveloperName IN: mapObjLookupFieldNameTmp.keySet()]) {
            System.debug('field.DeveloperName : '+field.DeveloperName);
			System.debug('field.DeveloperName : '+field.isCustomField__c);
			String fieldName = field.isCustomField__c?field.DeveloperName.split('_')[1] + '__c' : field.DeveloperName.split('_')[1];
            String objectName = field.AnonymizationObject__r.isCustomObject__c?field.AnonymizationObject__r.DeveloperName+'__c':field.AnonymizationObject__r.DeveloperName;
        	if(mapObjectAndFields.containsKey(objectName)){
            	mapObjectAndFields.get(objectName).add(fieldName);                                       
            }else {
            	List<String> fieldList = new List<String>();
                fieldList.add(fieldName);
                mapObjectAndFields.put(objectName, fieldList);
            }                                 
        }
        
        System.debug('mapObjectAndFields : '+mapObjectAndFields);
        Map<String, String> retrievedSOQLQueriesMap = SOQLBuilder.buildSOQLQueriesMap(mapObjectAndFields, mapObjLookupFieldName, clientIds);
        System.debug('retrievedSOQLQueriesMap :'+retrievedSOQLQueriesMap);
        List<sObject> objectRecordsMap = SOQLBuilder.getClientDataToBeAnonymized(retrievedSOQLQueriesMap);
        System.debug('objectRecordsMap :'+objectRecordsMap);
        List<sObject> updateObjList = SOQLBuilder.pushInQueue(mapObjectAndFields, objectRecordsMap, mapObjLookupFieldName, wrapper.timeStamp);
        System.debug('updateObjList :'+updateObjList);
        System.enqueueJob(new SFAnonymizationProcessJob(updateObjList));
    }

}