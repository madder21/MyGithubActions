/**
* @author Ulrich Madder NDONG NGOMO
* @date June,3rd 2024
* @Type Apex Class
*****************************************************************************************************************************************************************
* @description This class contains the methods used to get data that should be anonymized and all the anonymization part.
***************************************************************************************************************************************************************** 
* @Version : 
* Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
* 0.0		|2024/06/03			|.UNNM		|.					|Original version					
*/
public with sharing class SOQLBuilder {
    
    /*
     * @method 	: buildSOQLQueriesMap
     * @description : This method is used to generate a Map which contains a key, an object name with its related SOQL query as a value
     * @param	: mapObjectAndFields
     * @param : mapObjLookupFieldName
     * @param : clientIds
     * @return	: Map<String, String>
	 */

    public static Map<String, String> buildSOQLQueriesMap(Map<String, List<String>> mapObjectAndFields, Map<String, String> mapObjLookupFieldName, List<Id> clientIds){
        Map<String, String> soqlQueriesMap = new Map<String, String>();
        for(String objName : mapObjLookupFieldName.keySet()){
            String fieldsQuery = mapObjectAndFields.containsKey(objName)?'Id, '+String.join(mapObjectAndFields.get(objName), ', '): 'Id';
            String quotedAccountIds = '\'' + String.join(clientIds, '\',\'') + '\'';
            String soqlQuery = 'SELECT '+fieldsQuery + ' FROM ' + objName + ' WHERE ' + mapObjLookupFieldName.get(objName)+' IN (' + quotedAccountIds + ')';
        	soqlQueriesMap.put(objName, soqlQuery);
        }
        return soqlQueriesMap;        
    }
    
    public static Map<String, String> buildSOQLQueriesMap(Map<String, String> mapObjLookupFieldName, List<Id> clientIds){
        Map<String, String> soqlQueriesMap = new Map<String, String>();
        for(String objName : mapObjLookupFieldName.keySet()){
            String quotedAccountIds = '\'' + String.join(clientIds, '\',\'') + '\'';
            String soqlQuery = 'SELECT Id FROM ' + objName + ' WHERE ' + mapObjLookupFieldName.get(objName)+' IN (' + quotedAccountIds + ')';
        	soqlQueriesMap.put(objName, soqlQuery);
        }
        return soqlQueriesMap;        
    }
    
    public static List<sObject> getClientDataToBeAnonymized(Map<String, String> retrievedSOQLQueriesMap) {
        List<sObject> globalList = new List<sObject>();
        Map<String, List<sObject>> recordPerObject = new Map<String, List<sObject>>();
        for(String objName : retrievedSOQLQueriesMap.keySet()) {
            String query = retrievedSOQLQueriesMap.get(objName);
            List<sObject> currentRecordList = Database.query(query);
            recordPerObject.put(objName, currentRecordList);
            globalList.addAll(currentRecordList);
        }
        return globalList;
    }
    
    public static List<sObject> pushInQueueWithUsualVal(SFAnonymizationPushInQueueWrapper wrapper) {
    	List<sObject> objectToBeUpdate = new List<sObject>();
        for(sObject obj : wrapper.globalList) {
            String objectAPIName = obj.Id.getSObjectType().getDescribe().getName();
            SObjectType r = ((SObject)(Type.forName('Schema.'+objectAPIName).newInstance())).getSObjectType();
            DescribeSObjectResult d = r.getDescribe();
            for(String fieldName : wrapper.mapObjectAndFields.get(objectAPIName)) {
                String fieldType = String.valueOf(d.fields.getMap().get(fieldName).getDescribe().getType());
                switch on fieldType {
                	When 'EMAIL' {
                        obj.put(fieldName, 'XXXXXXXXXX@XXX.XXX');
                    }
                    When 'INTEGER' {
                        obj.put(fieldName, '9999999999');
                    }
                    When else {
                        obj.put(fieldName, 'XXXXXXXXXX');
                    }
                }                
            }
			objectToBeUpdate.add(obj);            
        }        
        return objectToBeUpdate;
    }
    
    public static List<sObject> pushInQueue(SFAnonymizationPushInQueueWrapper wrapper) {
        List<sObject> objectToBeUpdate = new List<sObject>();
        Map<Id, Long> accountTimestampMap = new Map<Id, Long>();
        for(sObject obj : wrapper.globalList) {
            Long tmp = accountTimestampMap.containsKey(obj.Id)?accountTimestampMap.get(obj.Id): wrapper.timeStamp;
            accountTimestampMap.put(obj.Id, tmp);
            String objectAPIName = obj.Id.getSObjectType().getDescribe().getName();
            for(String fieldName : wrapper.mapObjectAndFields.get(objectAPIName)) {
                if(fieldName.contains('mail') && obj.get(fieldName)<>null) {
                	String emailFieldValue = tmp+'@'+tmp+'.'+tmp;
                    obj.put(fieldName, emailFieldValue); 
				}else if(obj.get(fieldName)<>null) {
					obj.put(fieldName, wrapper.timeStamp); 
				}
			}
            tmp+=1;
			objectToBeUpdate.add(obj);
        }
        return objectToBeUpdate;
    }
}