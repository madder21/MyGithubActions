public with sharing class CLT_ProductHierarchy implements CLT_RetailInterface{
    
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){
        Map<String, Object> result = new Map<String, Object>();

        list<map<string, object>> categories = getCategories();
        list<map<string, object>> collections = getCollections();
        list<map<string, object>> collectionTranslations = getCollectionTranslations();
        list<map<string, object>> accessoryTypes = getAccessoryTypes();
        list<map<string, object>> accessoryTypeTranslations = getAccessoryTypeTranslations();
        list<map<string, object>> accessorySubTypes = getaccessorySubTypes();
		list<map<string, object>> accessorySubTypeTranslations = getAccessorySubTypeTranslations();
        
		for(map<string, object> collection:collections)
        	System.debug(collection);
        
        
        result.put('categories', categories);
        result.put('collections', collections);
        result.put('collectionTranslations', collectionTranslations);
        result.put('accessoryTypes', accessoryTypes);
        result.put('accessoryTypeTranslations', accessoryTypeTranslations);
        result.put('accessorySubTypes', accessorySubTypes);
        result.put('accessorySubTypeTranslations', accessorySubTypeTranslations);
        system.debug('result: ' + result);
        return result;
    }

    public list<map<string, object>> getCategories(){    
        return CLT_Utils_Mapping.getStandardWrapperList('Category__c', 'Category', 'FROM Category__c');
    }
    
    public list<map<string, object>> getCollections(){
        return CLT_Utils_Mapping.getStandardWrapperList('Collection__c', 'Collection', 'FROM Collection__c');
    }
    
    public list<map<string, object>> getCollectionTranslations(){
        final String userLanguage = UserInfo.getLanguage();
        return CLT_Utils_Mapping.getStandardWrapperList('Collection_Translation__c',
            'CollectionTranslation', 'FROM Collection_Translation__c WHERE Language__c = ' + '\'' +userLanguage+ '\'');
    }

    public list<map<string, object>> getAccessoryTypes(){
        return CLT_Utils_Mapping.getStandardWrapperList('Accessory_Type__c', 'AccessoryType', 'FROM Accessory_Type__c');
    }
    
    public list<map<string, object>> getAccessoryTypeTranslations(){
        final String userLanguage = UserInfo.getLanguage();
        return CLT_Utils_Mapping.getStandardWrapperList('Accessory_type_Translation__c',
        	'AccessoryTypeTranslation', 'FROM Accessory_type_Translation__c WHERE Language__c = ' + '\'' +userLanguage+ '\'');
    }
    
    public list<map<string, object>> getAccessorySubTypes(){
        return CLT_Utils_Mapping.getStandardWrapperList('Accessory_Sub_Type__c', 'AccessorySubType', 'FROM Accessory_Sub_Type__c');
    }
    
    public list<map<string, object>> getAccessorySubTypeTranslations(){
        final String userLanguage = UserInfo.getLanguage();
        return CLT_Utils_Mapping.getStandardWrapperList('Accessory_sub_type_Translation__c',
            'AccessorySubTypeTranslation', 'FROM Accessory_sub_type_Translation__c WHERE Language__c = ' + '\'' +userLanguage+ '\'');
    }
}