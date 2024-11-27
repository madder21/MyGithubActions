/**
* @author Ulrich Madder NDONG NGOMO
* @date June,3rd 2024
* @Type Apex Class
*****************************************************************************************************************************************************************
* @description This class contains an invocable method used to remove client data according to the business requirements
***************************************************************************************************************************************************************** 
* @Version : 
* Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
* 0.0		|2024/06/03			|.UNNM		|.					|Original version
* 1.0		|2024/10/09			|.UNNM		|.					|Remove System debug statements
*/
public with sharing class SuppressionSFProcess {
    /**
     * @description: This function is called from SFDC_ClientAnonymization flow in order to remove client data
     * 
     * inputs: 
     * 			- timeStamp: current time stamp
     * 			- clientIdStr: list of Client Ids
     * 			- separator: the delimiter defined to get each Ids from a string
     * 			- objectList: List of sObject
	 */
    @InvocableMethod(label='SF Suppression Process')
    public static void initSuppressionProcess(List<SFAnonymizationProcessWrapper> flowInputs) {
        
        SFAnonymizationProcessWrapper wrapper = flowInputs[0];
        List<String> objectList = wrapper.objectList.split(',');
        List<Id> clientIds = wrapper.clientIdStr.split(wrapper.separator);
        List<Id> confObjIdList = new List<Id>();
        List<SuppressionSFProcess__mdt> retrievedConfig = [SELECT Id, AnonymizationObject__c, LookupField__c, AnonymizationObject__r.DeveloperName, AnonymizationObject__r.isCustomObject__c
                                                           FROM SuppressionSFProcess__mdt WHERE AnonymizationObject__r.DeveloperName IN: objectList];
        Map<String, String> mapObjLookupFieldName = new Map<String, String>();
        for(SuppressionSFProcess__mdt config : retrievedConfig) {
            if(config.AnonymizationObject__r.isCustomObject__c){
                mapObjLookupFieldName.put(config.AnonymizationObject__r.DeveloperName+'__c', config.LookupField__c);                
            }else {
                mapObjLookupFieldName.put(config.AnonymizationObject__r.DeveloperName, config.LookupField__c);
            }
        }
        Map<String, String> retrievedSOQLQueriesMap = SOQLBuilder.buildSOQLQueriesMap(mapObjLookupFieldName, clientIds);
        List<sObject> objectRecords = SOQLBuilder.getClientDataToBeAnonymized(retrievedSOQLQueriesMap);
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
        //QueueableUtil.enqueueJob(new ManageRGPDObject_CTL(objList));
        QueueableUtil.enqueueJob(new ManageRGPDObject_CTL(accList)); 
        delete objList;        
    }

}