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
    
    public static String removeSpaceFromString(String str) {
        String removedSpaceStr = '';
        for(Integer i = 0; i < str.length(); i++) {
            Integer asciiValue = str.charAt(i);
            if(asciiValue <> 160) {
                removedSpaceStr+=str.substring(i, i+1);
            }
        }
        return removedSpaceStr;
    }
    
    public static List<sObject> pushInQueue(Map<String, List<String>> mapObjectAndFields, List<sObject> globalList, Map<String, String> mapObjLookupFieldName, String timeStamp) {
		System.debug('globalList '+globalList);
        List<sObject> objectToBeUpdate = new List<sObject>();
        Map<Id, Long> accountTimestampMap = new Map<Id, Long>();
        Long tmp = Long.valueOf(removeSpaceFromString(timeStamp));
        for(sObject obj : globalList) {
            switch on obj {
                When Account acc {
                    tmp = accountTimestampMap.containsKey(acc.Id)?accountTimestampMap.get(acc.Id):tmp;
                    accountTimestampMap.put(acc.Id, tmp);
                    for(String fieldName : mapObjectAndFields.get('Account')) {
                        System.debug('fieldName '+fieldName);
                        if(fieldName.contains('mail') && acc.get(fieldName)<>null) {
                            String emailFieldValue = tmp+'@'+tmp+'.'+tmp;
                            System.debug('emailFieldValue '+emailFieldValue);
                            acc.put(fieldName, emailFieldValue); 
                        }else if(acc.get(fieldName)<>null) {
                            acc.put(fieldName, timeStamp); 
                        }
                    }
                    tmp+=1;
                    objectToBeUpdate.add(acc);
                }
				When B2CCustomInput__c bc {
                    tmp = accountTimestampMap.containsKey((Id)bc.get(mapObjLookupFieldName.get('B2CCustomInput__c')))?accountTimestampMap.get((Id)bc.get(mapObjLookupFieldName.get('B2CCustomInput__c'))):tmp;
                    accountTimestampMap.put((Id)bc.get(mapObjLookupFieldName.get('B2CCustomInput__c')), tmp);
					for(String fieldName : mapObjectAndFields.get('B2CCustomInput__c')) {
                        if(fieldName <> mapObjLookupFieldName.get('B2CCustomInput__c')){
                            if(fieldName.contains('mail') && bc.get(fieldName)<>null) {
                                String emailFieldValue = tmp+'@'+tmp+'.'+tmp;
                                bc.put(fieldName, emailFieldValue); 
                            }else if(bc.get(fieldName)<>null) {
                                bc.put(fieldName, removeSpaceFromString(tmp.format())); 
                            }
                        }
                    }
                    tmp+=1;
                    objectToBeUpdate.add(bc);
                }
                
                When ClientAddress__c ca {
                    tmp = accountTimestampMap.containsKey((Id)ca.get(mapObjLookupFieldName.get('ClientAddress__c')))?accountTimestampMap.get((Id)ca.get(mapObjLookupFieldName.get('ClientAddress__c'))):tmp;
                    accountTimestampMap.put((Id)ca.get(mapObjLookupFieldName.get('ClientAddress__c')), tmp);
					for(String fieldName : mapObjectAndFields.get('ClientAddress__c')) {
                        if(fieldName <> mapObjLookupFieldName.get('ClientAddress__c')){
                            if(fieldName.contains('mail') && ca.get(fieldName)<>null) {
                                String emailFieldValue = tmp+'@'+tmp+'.'+tmp;
                                ca.put(fieldName, emailFieldValue); 
                            }else if(ca.get(fieldName)<>null) {
                                ca.put(fieldName, removeSpaceFromString(tmp.format())); 
                            }
                        }
                    }
                    tmp+=1;
                    objectToBeUpdate.add(ca);
                }
                
                When ClientSource__c csr {
                    tmp = accountTimestampMap.containsKey((Id)csr.get(mapObjLookupFieldName.get('ClientSource__c')))?accountTimestampMap.get((Id)csr.get(mapObjLookupFieldName.get('ClientSource__c'))):tmp;
                    accountTimestampMap.put((Id)csr.get(mapObjLookupFieldName.get('ClientSource__c')), tmp);
					for(String fieldName : mapObjectAndFields.get('ClientSource__c')) {
                        if(fieldName <> mapObjLookupFieldName.get('ClientSource__c')){
                            if(fieldName.contains('mail') && csr.get(fieldName)<>null) {
                                String emailFieldValue = tmp+'@'+tmp+'.'+tmp;
                                csr.put(fieldName, emailFieldValue); 
                            }else if(csr.get(fieldName)<>null) {
                                csr.put(fieldName, removeSpaceFromString(tmp.format())); 
                            }
                        }
                    }
                    tmp+=1;
                    objectToBeUpdate.add(csr);
                }
                
                When ContactPointTypeConsent cp {
                    tmp = accountTimestampMap.containsKey((Id)cp.get(mapObjLookupFieldName.get('ContactPointTypeConsent')))?accountTimestampMap.get((Id)cp.get(mapObjLookupFieldName.get('ContactPointTypeConsent'))):tmp;
                    accountTimestampMap.put((Id)cp.get(mapObjLookupFieldName.get('ContactPointTypeConsent')), tmp);
					for(String fieldName : mapObjectAndFields.get('ContactPointTypeConsent')) {
                        if(fieldName <> mapObjLookupFieldName.get('ContactPointTypeConsent')){
                            if(fieldName.contains('mail') && cp.get(fieldName)<>null) {
                                String emailFieldValue = tmp+'@'+tmp+'.'+tmp;
                                cp.put(fieldName, emailFieldValue); 
                            }else if(cp.get(fieldName)<>null) {
                                cp.put(fieldName, removeSpaceFromString(tmp.format())); 
                            }
                        }
                    }
                    tmp+=1;
                    objectToBeUpdate.add(cp);
                }
                
                When EmailMessage em {
                    tmp = accountTimestampMap.containsKey((Id)em.get(mapObjLookupFieldName.get('EmailMessage')))?accountTimestampMap.get((Id)em.get(mapObjLookupFieldName.get('EmailMessage'))):tmp;
                    accountTimestampMap.put((Id)em.get(mapObjLookupFieldName.get('EmailMessage')), tmp);
					for(String fieldName : mapObjectAndFields.get('EmailMessage')) {
                        if(fieldName <> mapObjLookupFieldName.get('EmailMessage')){
                            if((fieldName.contains('mail') || fieldName.contains('Address')) && em.get(fieldName)<>null) {
                                String emailFieldValue = tmp+'@'+tmp+'.'+tmp;
                                em.put(fieldName, emailFieldValue); 
                            }else if(em.get(fieldName)<>null) {
                                em.put(fieldName, removeSpaceFromString(tmp.format())); 
                            }
                        }
                    }
                    tmp+=1;
                    objectToBeUpdate.add(em);
                }
            }
        }
        System.debug('*** objectToBeUpdate ***'+objectToBeUpdate);
        return objectToBeUpdate;
    }
}