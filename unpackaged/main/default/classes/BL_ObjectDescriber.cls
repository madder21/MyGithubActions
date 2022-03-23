/**
 * @group General Utils
 * @author Shai Fisher, Jeremy Martiano
 * @since March 2020
 * @group balink General
 * @description class to get objects info from schema
 */
public with sharing class BL_ObjectDescriber {

    private class ObjectDescriberException extends Exception {}

    private static Map<String,SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        private set;
    }

    private static Map<String,Map<String,Schema.SObjectField>> objectsFieldsDescribeMap {
        get {
            if (objectsFieldsDescribeMap == null) {
                objectsFieldsDescribeMap = new Map<String,Map<String,Schema.SObjectField>>();
            }
            return objectsFieldsDescribeMap;
        }
        private set;
    }

    /**
     * @param objectName name of the object (e.g. Account, Client__c, BL_UseCase__mdt)
     * @returns boolean
     * @description Checks if there is SObject with a given name
     */
    public static Boolean isValidObject(String objectName) {
        return globalDescribe.containsKey(objectName);
    }

    /**
     * @param objectName name of the object
     * @returns `DescribeSObjectResult`
     * @description Gets object describe from schema
     * @exception ObjectDescriberException
     */
    public static Schema.DescribeSObjectResult getObjectDescribe(String objectName) {
        if (!isValidObject(objectName)) {
            throw new ObjectDescriberException('Unknown object: ' + objectName);
        }
        return globalDescribe.get(objectName).getDescribe();
    }

    /**
     * @returns List of sobjects API names
     * @description Gets available Sobject names, excluding unaccessible or sharing objects
     */
    public static List<String> getObjectNames() {
        List<String> objectNames = new List<String>();
        for (SObjectType objType : globalDescribe.values()) {
            DescribeSObjectResult objDescribe = objType.getDescribe();
            if (objDescribe.isQueryable() 
                    && objDescribe.isAccessible() 
                    && (objDescribe.isCreateable() || objDescribe.isCustom())
                    && !objDescribe.getName().endsWith('Share')
                    ) {
                objectNames.add(objDescribe.getName());
            }
        }
        return objectNames;
    }

    /**
     * @param objectName name of the object
     * @returns `SObjectField` map by field name
     * @description Returns fields describe for given object. Stores the result in static global map
     * @exception ObjectDescriberException
     */
    public static Map<String,Schema.SObjectField> getFields(String objectName) {
        if (!isValidObject(objectName)) {
            throw new ObjectDescriberException('Unknown object: ' + objectName);
        }
        if (!objectsFieldsDescribeMap.containsKey(objectName)) {
            objectsFieldsDescribeMap.put(objectName, getObjectDescribe(objectName).fields.getMap());
        }
        return objectsFieldsDescribeMap.get(objectName);
    }
    
    /**
     * @param objectName name of the object
     * @param fieldName name of the field
     * @returns boolean
     * @description Checks if field exists. supports complex field (Parent__r.Field__c)
     * @exception ObjectDescriberException
     */
    public static Boolean isValidField(String objectName, String fieldName) {
        if (!isValidObject(objectName)) {
            throw new ObjectDescriberException('Unknown object: ' + objectName);
        }

        // simple field
        if (!(fieldName.contains('.'))) {
            return getFields(objectName).containsKey(fieldName);
        }

        // complex field
        integer count = fieldname.countMatches('.');
        string fnameafter = fieldName;
        string fnamebefore = fieldName;
        string objname = objectName;
        While(count > 0){
            if(fnameafter.contains('.')){
                fnamebefore = fnameafter.substringBefore('.');
                fnameafter = fnameafter.substringAfter('.');
                if(fnamebefore.endsWith('__r') || fnamebefore.endsWith('__pr') ){
                    fnamebefore = fnamebefore.removeEnd('r');
                    fnamebefore = fnamebefore + 'c';
                }
                else{
                    fnamebefore = fnamebefore + 'Id';
                }
                if (!isValidField(objname, fnamebefore)){
                    return false;
                }
                objname = BL_ObjectDescriber.getReferenceTargetObjectName(objname, fnamebefore);
            }
            count--;
        }
        return getFields(objname).containsKey(fnameafter);
    }

    /**
     * @param objectName name of the object
     * @param fieldName name of the field
     * @returns 'DescribeFieldResult'
     * @description Gets specific field describe from schema
     * @exception ObjectDescriberException
     */
    public static Schema.DescribeFieldResult getFieldDescribe(String objectName, String fieldName) {
        Map<String,Schema.SObjectField> fieldsMap = getFields(objectName);
        if (fieldsMap.containsKey(fieldName)) {
            return fieldsMap.get(fieldName).getDescribe();
        }
        if (fieldName.contains('.')) {
            String referenceField = fieldName.substringBefore('.');
            if (referenceField.endsWith('__r') || referenceField.endsWith('__pr')) {
                // custom object
                referenceField = referenceField.removeEnd('r') + 'c';
            } else {
                // standard object
                referenceField = referenceField + 'Id';
            }
            if (isValidField(objectName, referenceField)) {
                String referenceObjectName = getReferenceTargetObjectName(objectName, referenceField);
                String secondLevelField = fieldName.substringAfter('.');    // may also contain '.'
                return getFieldDescribe(referenceObjectName, secondLevelField);
            }
        }
        return null;
    }

    /**
     * @param objectName name of the object
     * @param fieldName name of the field
     * @returns Field type as string
     * @description Gets specific field type from schema
     */
    public static String getFieldType(String objectName, String fieldName) {
        if (!isValidObject(objectName)) {
            return null;
        }
        Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(objectName, fieldName);
        if (fieldDescribe != null) {
            return fieldDescribe.getType().name();
        }
        return null;
    }

    /**
     * @param objectName name of the object
     * @param fieldName name of the field
     * @returns string
     * @description Gets target object name of lookup field
     */
    public static String getReferenceTargetObjectName(String objectName, String fieldName) {
        Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(objectName, fieldName);
        return fieldDescribe.getReferenceTo().get(0).getDescribe().getName();
    }

    /**
     * @param objectItem sobject instance
     * @param fields name of the field, may be complex (e.g. Account__c.Name)
     * @returns Object
     * @description Gets value from field in specific record
     */
    public static Object getValue(SObject objectItem, String fields) {
        list <String> fieldsList = fields.split('\\.');

        for(Integer index = 0; index < fieldsList.size(); index++) {
            if (index < (fieldsList.size() -1) &&  objectItem != null) {
                objectItem = objectItem.getSObject(fieldsList[index]);
            }else if (objectItem != null) {
                return objectItem.get(fieldsList[index]);
            }
        }
        return null;
    }

    /**
     * @param objectItem sobject instance
     * @param field name of the field
     * @returns List of SObjects
     * @description Gets childs list from record
     */
    public static SObject[] getInnerQueryValue(SObject objectItem, String field) {
       return objectItem.getSObjects(field);
    }

    //Genereic Function to create Sobject Instance using Map<String, Object>  
    /*public static void fixMapObject(String objectName, Map<String, Object> mapObject) {
        Map<String,Schema.SObjectField> fieldsMap = getFields(objectName);
        for(String fieldName : mapObject.keySet()) {

            if (fieldsMap.containsKey(fieldName.toLowerCase())) {
                Schema.DisplayType fieldType = getSchemaFieldType(fieldName, objectName);

                if (fieldType == Schema.DisplayType.Date) {
                    mapObject.put(fieldName, mapObject.get(fieldName) == ''  || mapObject.get(fieldName) == null ? null : Date.valueOf(String.valueOf(mapObject.get(fieldName))));
                }
                else if(fieldType == Schema.DisplayType.DateTime) {
                    mapObject.put(fieldName, mapObject.get(fieldName) == '' || mapObject.get(fieldName) == null ? null : (DateTime)Json.deserialize('"'+(String)mapObject.get(fieldName)+'"', DateTime.class));
                }
                else if (fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.Currency) {
                    mapObject.put(fieldName, mapObject.get(fieldName) == '' || mapObject.get(fieldName) == null ? null : Decimal.valueOf(String.valueOf(mapObject.get(fieldName))));
                }
                else if (fieldType == Schema.DisplayType.Double) {
                    mapObject.put(fieldName, Double.valueOf(mapObject.get(fieldName)));
                }
                else if (fieldType == Schema.DisplayType.Integer) {
                    mapObject.put(fieldName, Integer.valueOf(mapObject.get(fieldName)));
                }
                else if (fieldType == Schema.DisplayType.Base64) {
                    mapObject.put(fieldName, Blob.valueOf(String.valueOf(mapObject.get(fieldName))));
                }
            }
        }
    }  */
    
    /**
     * @param csMap Map<String,Object> object
     * @param objectName name of the object
     * @returns SObject
     * @description Converts Map<String,Object> to SObject
     */
    public static SObject createSObject(Map<String,Object> csMap, String objectName){
        SObject sObj = (SObject) Type.forName(objectName).newInstance();
        Map<String,Schema.SObjectField> fieldsMap = getFields(objectName);

        for(String key : csMap.keySet()){
            if (fieldsMap.containsKey(key.toLowerCase())){
                Schema.DisplayType fieldType = getSchemaFieldType(objectName, key);

                if (fieldType == Schema.DisplayType.Date)
                    sObj.put(key, csMap.get(key) == ''  || csMap.get(key) == null ? null : Date.valueOf(String.valueOf(csMap.get(key))));

                else if(fieldType == Schema.DisplayType.DateTime)
                    sObj.put(key, csMap.get(key) == '' || csMap.get(key) == null ? null : (DateTime)Json.deserialize('"'+(String)csMap.get(key)+'"', DateTime.class));

                else if (fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.Currency)
                    sObj.put(key, csMap.get(key) == '' || csMap.get(key) == null ? null : Decimal.valueOf(String.valueOf(csMap.get(key))));

                else if (fieldType == Schema.DisplayType.Double)
                    sObj.put(key, Double.valueOf(csMap.get(key)));

                else if (fieldType == Schema.DisplayType.Integer)
                    sObj.put(key, Integer.valueOf(csMap.get(key)));

                else if (fieldType == Schema.DisplayType.Base64)
                    sObj.put(key, Blob.valueOf(String.valueOf(csMap.get(key))));

                else
                    sObj.put(key, csMap.get(key));
            }
        }
        return sObj;
    }

    /**
     * @param objectName name of the object
     * @param fieldName name of the field
     * @returns Schema.DisplayType (enum)
     * @description Gets field type
     */
    public static Schema.DisplayType getSchemaFieldType(String objectName, String fieldName) {
        Schema.DescribeFieldResult fieldDescribe = getFieldDescribe(objectName, fieldName);
        return fieldDescribe.getType();
    }

    /**
     * @param id SF Id
     * @param objectName SObject name
     * @returns boolean
     * @description Checks if Id is of specific SObject type
     */
    public static Boolean isIdOfType(Id id, String objectName) {
        if (id == null) {
            return false;
        }
        return Id.getSObjectType() == globalDescribe.get(objectName);
    }

    public static Schema.DescribeFieldResult getRelationshipFieldDescribe(String objectName, String relatedChildName){
        List<Schema.ChildRelationship> C = getObjectDescribe(objectName).getChildRelationships();
        for(Schema.ChildRelationship cc : C){
            if(cc.getRelationshipName() == relatedChildName){
                return cc.getField().getDescribe();
            }
        }
        return null;
    }

    public static List<Option> getPicklistOptions(String objectName, String fieldName) {
        return getPicklistOptions(objectName, fieldName, null);
    }

    /*
     * Gets picklist options as label-value
     * @param objectName
     * @param fieldName
     * @param recordTypeDevName - if empty, returns all
     */
    public static List<Option> getPicklistOptions(String objectName, String fieldName, String recordTypeDevName) {
        if (String.isNotEmpty(recordTypeDevName)) {
            return getOptionsForRecordType(objectName, fieldName, recordTypeDevName);
        }
        Schema.DescribeFieldResult fieldResult = getFieldDescribe(objectName, fieldName);
        List<Schema.PicklistEntry> ples = fieldResult.getPicklistValues();

        List<Option> options = new List<Option>();
        for (Schema.PicklistEntry ple : ples) {
            options.add(new Option(ple));
        }
        return options;
    }

    /*
     * Gets available picklist values for record type
     * Callout for UiApi
     */
    private static List<Option> getOptionsForRecordType(String objectName, String fieldName, String recordTypeDevName) {
        List<Object> plEntriesObjects = BL_MetadataManager.getPicklistValuesByRecordType(objectName, fieldName, recordTypeDevName);
        String plEntriesObjectsJson = Json.serialize(plEntriesObjects);
        return (List<Option>) Json.deserialize(plEntriesObjectsJson, List<Option>.class);
    }

    /*
     * Inner class for picklist option
     */
    public class Option {
        public String value;
        public String label;

        public Option(Schema.PicklistEntry ple) {
            this.value = ple.getValue();
            this.label = ple.getLabel();
        }
    }
    
}