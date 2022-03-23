public with sharing class CLT_Config implements CLT_RetailInterface{
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){  
        return new ConfigWrapper(getPicklists(params), getMappings(), getActiveSOQL(), getClientNotes(), getEmailTemplatesFields(), getSAs(), getGlobalSAs(), getUserInfos());
    }

    public List<CLT_UtilsPicklist.PicklistWrapper> getPicklists(Map<String, String> params){
        List<String> picklistNameItems = new list<String>();
        String picklistsNames = params.get('picklists');    
        if(picklistsNames != null){
            picklistNameItems = picklistsNames.split(';');
        }

        return CLT_UtilsPicklist.getPicklists(picklistNameItems);
    }

    public List<Map<String, Object>> getMappings(){
        return CLT_Utils_Mapping.getStandardWrapperList('CLT_FieldsMapping__mdt', 'CLT_FieldsMapping__mdt', 'FROM CLT_FieldsMapping__mdt WHERE Send_to_Clienteling_App__c = true');
    }

    public List<Map<String,String>> getActiveSOQL(){
        List<Map<String,String>> queries = new List<Map<String,String>>();
        
        queries.add(new Map<String,String>{
            'query' => CLT_Utils_Query.getGeneralClientsQuery(),
            'name' => 'Clients',
            'id' => 'clientQuery'
        });   
        return queries;     
    }

    public List<Map<String, Object>> getClientNotes(){
        String clientQuery = 'SELECT Id FROM Account ' + CLT_Utils_Query.getGeneralClientsQuery().substringAfter('FROM Account');
        return CLT_Utils_Mapping.getStandardWrapperList('Note__c','Note',
                                                    ' FROM Note__c WHERE Client__c IN (' + clientQuery + ') ORDER BY LastModifiedDate DESC');
    }
  
    public List<Map<String,String>> getEmailTemplatesFields(){
        List<CLT_EmailTemplateField__mdt> fields = [
            SELECT Id, Object__c, FieldWrapperName__c, StringToReplace__c
            FROM CLT_EmailTemplateField__mdt 
            WHERE Active__c = TRUE
        ];
        List<Map<String,String>> mappingFields = new List<Map<String,String>>();
        
        for(CLT_EmailTemplateField__mdt field: fields) {
            mappingFields.add(new Map<String,String>{
                'id' => field.Id,
                'object' => field.Object__c,
                'field' => field.FieldWrapperName__c,
                'strToReplace' => field.StringToReplace__c
            });
        }
           
        return mappingFields;     
    }

    public  List<Map<String, Object>> getSAs(){  
        string myStoreCode = CLT_Utils.getMyUser().StoreCode__c;

        return CLT_Utils_Mapping.getStandardWrapperList('User', 'User', 'FROM User WHERE storecode__c = \'' + myStoreCode + '\' AND  IsActive = true');
    }

    public  List<Map<String, Object>> getGlobalSAs(){  
        string myStoreCode = CLT_Utils.getMyUser().StoreCode__c;

        return CLT_Utils_Mapping.getStandardWrapperList('User', 'User', 
        'FROM User WHERE storecode__c != \'' + myStoreCode + '\' AND  IsActive = true AND Profile.Name = \'Store User\'');
    }

    public Map<String, Object> getUserInfos(){
        Map<String, Object> resultMapping = CLT_Utils_Mapping.getStandardWrapperList('User', 'User', 'FROM User WHERE Id = \'' + UserInfo.getUserId() + '\'')[0];

        string storeCode = String.valueOf(resultMapping.get('storeCode'));

        system.debug('Store Code:' + storeCode);
        resultMapping.put('allStoreCodes', getAllStoreCodes());
        if(String.IsNotEmpty(storeCode)){
            resultMapping.put('zoneStoreCodes', getZoneStoreCodes(storeCode.substring(0,2)));
            List<Map<String, Object>> storeMappingList = CLT_Utils_Mapping.getStandardWrapperList('store__c', 'Store', 'FROM store__c WHERE SourceStoreId__c = \'' + storeCode + '\'');
            if(storeMappingList.size()  > 0){
                Map<String, Object> storeMapping = storeMappingList[0];
                resultMapping.putAll(storeMapping);
            }
        }
        
        
//        resultMapping.put('contactId', CLT_Utils.getMyContactId());
        return resultMapping;
    }
    
    public Object getZoneStoreCodes(String currentStoreCode) {
        String storeCodes = '';
        List<String> storeTypes = new List<String> {'FSS','SIS','POP', 'ECO'};

        for(Store__c s : [SELECT SourceStoreId__c 
                        FROM Store__c 
                        WHERE SourceStoreId__c LIKE :currentStoreCode+'%' AND Type__c IN: storeTypes AND Closed__c = FALSE]) {
            storeCodes += s.SourceStoreId__c + ';';
        }
        return storeCodes;
    }
    
    public Object getAllStoreCodes() {
        String storeCodes = '';
        List<String> storeTypes = new List<String> {'FSS','SIS','POP', 'ECO'};

        for(Store__c s : [SELECT SourceStoreId__c,Address1__c  
                        FROM Store__c 
                        WHERE Type__c IN: storeTypes AND Closed__c = FALSE]) {
            storeCodes += s.SourceStoreId__c + ';';
        }
        return storeCodes;
    }




    public class ConfigWrapper{
        public List<CLT_UtilsPicklist.PicklistWrapper> picklists {get; set;}
        public List<Map<String, Object>> mappings {get; set;}
        public List<Map<String, String>> queries {get;set;}
        public List<Map<String, Object>> clientNotes {get;set;}
        public List<Map<String, String>> emailTemplatesFields {get;set;}
        public List<Map<String, Object>> SAs {get;set;}
        public List<Map<String, Object>> globalSAs {get;set;}
        public Map<String, Object> userInfos {get;set;}

        //Constructor
        public ConfigWrapper(list<CLT_UtilsPicklist.PicklistWrapper> picklists, List<Map<String, Object>> mappings, List<Map<String,String>> queries, List<Map<String, Object>> clientNotes, List<Map<String,String>> emailTemplatesFields, List<Map<String, Object>> SAs,  List<Map<String, Object>> globalSAs, Map<String,object> userInfos){
            this.picklists = picklists;
            this.mappings = mappings;
            this.queries = queries;
            this.clientNotes = clientNotes;
            this.emailTemplatesFields = emailTemplatesFields;
            this.SAs = SAs;
            this.globalSAs =globalSAs;
            this.userInfos = userInfos;
        }
    } 
}