//@RestResource(urlMapping='/ddc/config')
public with sharing class DDC_Config_WS implements BL_Rest_Router_Factory.DispatchableGET {
    
    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getAllConfig(null);
    }

    /**
     * Get all config data
     */
    private static Map<String, Object> getAllConfig(Map<String, String> pathParams){
        List<DDC_Config__mdt> configs = [
            SELECT Key__c, Value__c, Type__c
            FROM DDC_Config__mdt
        ];

        Map<String,Object> mapConfigs = new Map<String,Object>();
        for(DDC_Config__mdt config : configs){

            Object value = convert(config.Type__c, config.Value__c);

            // sub object in wrapper
            if (config.Key__c.contains('.')) {
                getChild(config.Key__c, value, mapConfigs);
            }
            else {
                mapConfigs.put(config.Key__c, value);
            }
        }

        return mapConfigs;
    }

    /**
     * Recursive function to build JSON child object
     */
    private static void getChild(String key, Object value, Map<String,Object> parent){
        String childName = key.substringBefore('.');
        Object child = parent.get(childName);

        Map<String,Object> childMap;
        if(child == null){
            childMap = new Map<String,Object>();
        }
        else {
            childMap = (Map<String,Object>) child;
        }

        // RECURSSION
        String childAttribute = key.substringAfter('.');
        if(childAttribute.contains('.')){
            getChild(childAttribute, value, childMap);
        }
        else {
            childMap.put(childAttribute, value);
        }

        parent.put(childName, childMap);
    }

    /**
     * Convert string to defined type
     */
    private static Object convert(String fieldType, Object value) {
        if(fieldType != null){
            String lowFieldType = fieldType.ToLowerCase();
            if (lowFieldType.ToLowerCase() == 'date')
                value = Date.valueOf(String.valueOf(value));

            else if (lowFieldType == 'double')
                value = Double.valueOf(value);

            else if (lowFieldType == 'integer')
                value = Integer.valueOf(value);

            else if (lowFieldType == 'base64')
                value = Blob.valueOf(String.valueOf(value));

            else if (lowFieldType == 'boolean')
                value = Boolean.valueOf(value);

            else if (lowFieldType == 'json') {
                value = JSON.deserializeUntyped(String.valueOf(value));
            }
        }

        return value;
    }
}