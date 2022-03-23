public with sharing class CLT_Story implements CLT_RetailInterface{
 
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){   
         return new Map<String, Object> {
        'stories' => getStories(params)
        };

    } 
    
     //Return stories that match the params parameter value
    List<Map<String, Object>> getStories(Map<String, String> params){
        List<Story__c> storiesList = [Select Id, Name, Title__c, Text__c, Accessory_Type__c, Accessory_Sub_Type__c, Product__c, Image__c, Collection__c, CurrencyIsoCode from Story__c];
        return CLT_Utils_Mapping.getStandardWrapperListFromObjectList('Story__c', 'Story', storiesList);
    }
}