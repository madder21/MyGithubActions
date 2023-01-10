public with sharing class CLT_Utils_Mapping {

    public static List<CLT_FieldsMapping__mdt> getMappingByObjectTitle(String objectTitle){
        return  [
            SELECT SFFieldPath__c, Wrapper_Field_Name__c, Object_Name__c, Object_Title__c, Save_to_SF__c,
                Send_to_Clienteling_App__c, getPicklistLabel__c, IsCurrency__c
            FROM CLT_FieldsMapping__mdt
            WHERE Object_Title__c = :objectTitle
        ];
    }

    public static Map<String, CLT_FieldsMapping__mdt> getMappingObjectDict(String objectName ,String objectTitle, String key){
        Map<String, CLT_FieldsMapping__mdt> result = new Map<String, CLT_FieldsMapping__mdt>();

        SObjectType schemaType = Schema.getGlobalDescribe().get(objectName);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        for(CLT_FieldsMapping__mdt mappingItem : getMappingByObjectTitle(objectTitle)){
            String keyValue = String.valueOf(mappingItem.get(key));

            if (fields.get(keyValue) != null && fields.get(keyValue).getDescribe().isAccessible() == true || keyValue.contains('.')){
                if (!result.containsKey(keyValue)){
                    result.put(keyValue, mappingItem);
                }
            } else{
                system.debug('***********' + keyValue + ' is not valid Field  ************');
            }

        }

        return result;
    }

    public static String getQueryString(String objectName, String objectTitle, String query){
        Map<String, CLT_FieldsMapping__mdt> fieldsMapping = getMappingObjectDict(objectName, objectTitle, 'SFFieldPath__c');
        return getQueryString(fieldsMapping, query);
    }

    public static String getQueryString(Map<String, CLT_FieldsMapping__mdt> fieldsMapping, String query){
       return getQueryString(fieldsMapping, query, false);
    }


    public static String getQueryString(Map<String, CLT_FieldsMapping__mdt> fieldsMapping, String query, Boolean getFieldsOnly){
        List<String> queryFields = new List<String>();
        for(String key : fieldsMapping.keySet()){
            CLT_FieldsMapping__mdt mapping = fieldsMapping.get(key);
            queryFields.add(key);
            if(mapping.IsCurrency__c){
                queryFields.add('convertCurrency(' + key + ') ' + key + 'Converted');
            }
            else if(mapping.getPicklistLabel__c){
                queryFields.add('toLabel(' + key + ')' + mapping.Wrapper_Field_Name__c + 'Label');
            }
        }
        if (getFieldsOnly){
            return String.join(queryFields,', ');
        }
        String queryString = 'SELECT ' + String.join(queryFields,', ') + ' ' + query;
        System.debug(queryString);
        return queryString;
    }

    public static List<Map<String, Object>> getStandardWrapperList(String objectName, String objectTitle, String query){
        List<Map<String, Object>> wrapperList = new List<Map<String, Object>>();
        Map<String, CLT_FieldsMapping__mdt> fieldsMapping = getMappingObjectDict(objectName, objectTitle, 'SFFieldPath__c');
        if(query == null){
            query = ' FROM '+objectName;
        }
        for(SObject item : Database.query(getQueryString(fieldsMapping, query))){
            wrapperList.add(getItemWrapper(fieldsMapping, item));
        }

        return wrapperList;
    }

    public static List<Map<String, Object>> getStandardWrapperListFromObjectList(String objectName, String objectTitle, List<SObject> objectList ){
        List<Map<String, Object>> wrapperList = new  List<Map<String, Object>>();

        Map<String, CLT_FieldsMapping__mdt> fieldsMapping = getMappingObjectDict(objectName, objectTitle, 'SFFieldPath__c');

        for(SObject item : objectList){
            wrapperList.add(getItemWrapper(fieldsMapping, item));
        }

        return wrapperList;
    }

    public static Map<String, Object> getItemWrapper(Map<String, CLT_FieldsMapping__mdt> fieldsMapping, SObject item){
        Map<String, Object> result = new  Map<String, Object>();

        for(String sfField : fieldsMapping.keySet()){
            String wrapperFieldName =  fieldsMapping.get(sfField).Wrapper_Field_Name__c;
            boolean getPicklistLabel =  fieldsMapping.get(sfField).getPicklistLabel__c;
            Object value = getValue(item, sfField);

            if (fieldsMapping.get(sfField).IsCurrency__c == true){
                result.put(wrapperFieldName + 'Original', value);
                result.put(wrapperFieldName , getValue(item, sfField + 'Converted'));
                system.debug(result);
            } else if(value != null) {
                result.put(wrapperFieldName, value);
            }

            if(getPicklistLabel){
                result.put(wrapperFieldName + 'Label', item.get(wrapperFieldName + 'Label'));
            }

        }

        return result;
    }

    public static object getValue(sObject objectItem, String fields){
        list <String> fieldsList = fields.split('\\.');

        for(integer index = 0; index < fieldsList.size(); index++){
            if (index < (fieldsList.size() -1) ){
                objectItem = objectItem.getSObject(fieldsList[index]);
            }else if (objectItem != null){
                return objectItem.get(fieldsList[index]);
            }
        }
        return null;
    }


    public static String getFieldsListString(String objectName, String objectTitle){
        Map<String, CLT_FieldsMapping__mdt> fieldsMapping = getMappingObjectDict(objectName, objectTitle, 'SFFieldPath__c');
        return getQueryString(fieldsMapping, '', true);
    }


    public static List<Map<String, Object>> getMapObjectsByWrapperItems(String objectName, String objectTitle, List<Object> wrapperItems) {
        List<CLT_FieldsMapping__mdt> objectMapping = getMappingByObjectTitle(objectTitle);
        List<Map<String, Object>> mapObjects = new List<Map<String, Object>>();

        for(Object wrapperItem : wrapperItems) {
            Map<String, Object> wrapperItemMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(wrapperItem));
            Set<String> wrapperItemMapKeys = wrapperItemMap.keySet();
            Map<String, Object> mapObject = new Map<String, Object>();

            for(CLT_FieldsMapping__mdt fieldMapping : objectMapping) {
                if(fieldMapping.Save_to_SF__c && !fieldMapping.SFFieldPath__c.contains('.') && wrapperItemMapKeys.contains(fieldMapping.Wrapper_Field_Name__c)) {
                    mapObject.put(fieldMapping.SFFieldPath__c, wrapperItemMap.get(fieldMapping.Wrapper_Field_Name__c));
                }
            }
            
            fixMapObject(objectName, mapObject);
            mapObjects.add(mapObject);
        }

        return mapObjects;
    }


    //Genereic Function to create Sobject Instance using Map<String, Object>  

    static void fixMapObject(String objectName, Map<String, Object> mapObject) {
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();

        for(String fieldName : mapObject.keySet()) {

            if (r.fields.getMap().keySet().contains(fieldName.toLowerCase())) {
                Schema.DisplayType fieldType = getFieldType(fieldName, objectName);

                if (fieldType == Schema.DisplayType.Date)
                    mapObject.put(fieldName, mapObject.get(fieldName) == ''  || mapObject.get(fieldName) == null ? null : Date.valueOf(String.valueOf(mapObject.get(fieldName))));

                else if(fieldType == Schema.DisplayType.DateTime)
                    mapObject.put(fieldName, mapObject.get(fieldName) == '' || mapObject.get(fieldName) == null ? null : (DateTime)Json.deserialize('"'+(String)mapObject.get(fieldName)+'"', DateTime.class));

                else if (fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.Currency)
                    mapObject.put(fieldName, mapObject.get(fieldName) == '' || mapObject.get(fieldName) == null ? null : Decimal.valueOf(String.valueOf(mapObject.get(fieldName))));

                else if (fieldType == Schema.DisplayType.Double)
                    mapObject.put(fieldName, Double.valueOf(mapObject.get(fieldName)));

                else if (fieldType == Schema.DisplayType.Integer)
                    mapObject.put(fieldName, Integer.valueOf(mapObject.get(fieldName)));

                else if (fieldType == Schema.DisplayType.Base64)
                    mapObject.put(fieldName, Blob.valueOf(String.valueOf(mapObject.get(fieldName))));
            }

        }
    }    

    //Genereric function to get Field Type using fieldName

    static Schema.DisplayType getFieldType(String fieldName, String objectName) {
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult r = t.getDescribe();

        if (r.fields.getMap().get(fieldName) == null) {
            return null;
        }
        Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();

        return f.getType();
    }
}