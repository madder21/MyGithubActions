public with sharing class CLT_Config implements CLT_RetailInterface{
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){  
        User u = [SELECT StoreCode__c FROM User WHERE Id = :UserInfo.getUserId()];
        Store__c userStore = [SELECT Country__c,Region__c FROM Store__c WHERE SourceStoreId__c = :u.StoreCode__c LIMIT 1];
        return new ConfigWrapper(getPicklists(params), getMappings(), getActiveSOQL(), getClientNotes(), getEmailTemplatesFields(),
                                getSAs(), getGlobalSAs(), getUserInfos(), getGifts(userStore), getEvents(userStore), 
                                getCallOutreachReasons(), getListOrder(), getProductColors(), getProductCollections(),
                                getProductMaterials(), getProductSizes());
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

    public List<Map<String, Object>> getGifts(Store__c userStore) {
        String giftQuery = ' FROM Gift__c WHERE (ActiveFrom__c = NULL OR ActiveFrom__c <= TODAY) AND (ActiveUntil__c = NULL OR ActiveUntil__c >= TODAY) ';
        giftQuery += ' AND ((Countries__c = \'\' OR Countries__c INCLUDES (\'' + userStore.Country__c + '\'))) ';
        giftQuery += ' AND ((Region__c = \'\' OR Region__c = \'' + userStore.Region__c + '\')) ';
        giftQuery += ' ORDER BY Name__c';
        return CLT_Utils_Mapping.getStandardWrapperList('Gift__c','Gift__c', giftQuery);
    }

    public List<Map<String, Object>> getEvents(Store__c userStore) {
        String eventQuery = ' FROM Event__c WHERE (ActiveFrom__c = NULL OR ActiveFrom__c <= TODAY) AND (ActiveUntil__c = NULL OR ActiveUntil__c >= TODAY) ';
        eventQuery += ' AND ((Countries__c = \'\' OR Countries__c INCLUDES (\'' + userStore.Country__c + '\'))) ';
        eventQuery += ' AND ((Region__c = \'\' OR Region__c = \'' + userStore.Region__c + '\')) ';
        eventQuery += ' ORDER BY Name__c';
        return CLT_Utils_Mapping.getStandardWrapperList('Event__c','Event__c', eventQuery);
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

    public List<callOutreachReasonsWrapper> getCallOutreachReasons(){
        List<callOutreachReasonsWrapper> callOutreachReasons = new List<callOutreachReasonsWrapper>();
        String lang = UserInfo.getLanguage();
        Set<String> categoryMdtFields = Schema.SObjectType.CLT_EmailTemplateCategory__mdt.fields.getMap().keySet();
        if(!categoryMdtFields.contains(lang.toLowerCase() + '_category__c')) {
            lang = 'en_US';
        }

        String categoriesQuery = 'SELECT ' + (lang != 'en_US' ? lang + '_category__c,' : '') + 'en_US_category__c,Id,Position__c FROM CLT_EmailTemplateCategory__mdt WHERE IsCallOutreach__c = TRUE';

        Utils.addCustomHeader('QUERY', categoriesQuery, RestContext.request);

        for(CLT_EmailTemplateCategory__mdt etc : Database.query(categoriesQuery)) {
            String reason = etc.get(lang + '_category__c') != null ? (String)etc.get(lang + '_category__c') : (String)etc.get('en_US_category__c');
            callOutreachReasons.add(new callOutreachReasonsWrapper(reason, etc.Id, (Integer)etc.Position__c));
        }
        return callOutreachReasons;
    }

    public class callOutreachReasonsWrapper {
        public String label {get; set;}
        public String id {get; set;}
        public Integer position {get; set;}

        //Constructor
        public callOutreachReasonsWrapper(String label, String id, Integer position) {
            this.label = label;
            this.id = id;
            this.position = position;
        }

    }

    public List<Map<String, Object>> getListOrder(){  
        return CLT_Utils_Mapping.getStandardWrapperList('CLT_List_Order__mdt', 'CLT_List_Order__mdt', 'FROM CLT_List_Order__mdt WHERE SectionName__c = \'Tasks Group\'');
    }

    public List<String> getProductColors() {
        List<String> productColors = new List<String>();
        for(AggregateResult ar : [SELECT color_v3__c color FROM Product2 WHERE color_v3__c != NULL GROUP BY color_v3__c]) {
            productColors.add((String)ar.get('color'));
        }
        return productColors;
    }

    public List<String> getProductCollections() {
        List<String> productCollections = new List<String>();
        for(AggregateResult ar : [SELECT model__c collection FROM Product2 WHERE model__c != NULL GROUP BY model__c]) {
            productCollections.add((String)ar.get('collection'));
        }
        return productCollections;
    }

    public List<String> getProductMaterials() {
        List<String> productMaterials = new List<String>();
        for(AggregateResult ar : [SELECT material_v3__c material FROM Product2 WHERE material_v3__c != NULL GROUP BY material_v3__c]) {
            productMaterials.add((String)ar.get('material'));
        }
        return productMaterials;
    }

    public List<String> getProductSizes() {
        List<String> productSizes = new List<String>();
        for(AggregateResult ar : [SELECT size__c size FROM Product2 WHERE size__c != NULL GROUP BY size__c]) {
            productSizes.add((String)ar.get('size'));
        }
        return productSizes;
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
        public List<Map<String, Object>> gifts {get;set;}
        public List<Map<String, Object>> events {get;set;}
        public List<callOutreachReasonsWrapper> callOutreachReasons {get; set;}
        public List<Map<String, Object>> listsOrder {get;set;}
        public List<String> productColors {get;set;}
        public List<String> productCollections {get;set;}
        public List<String> productMaterials {get;set;}
        public List<String> productSizes {get;set;}


        //Constructor
        public ConfigWrapper(list<CLT_UtilsPicklist.PicklistWrapper> picklists, List<Map<String, Object>> mappings, List<Map<String,String>> queries,
                        List<Map<String, Object>> clientNotes, List<Map<String,String>> emailTemplatesFields, List<Map<String, Object>> SAs,
                        List<Map<String, Object>> globalSAs, Map<String,object> userInfos, List<Map<String, Object>> gifts,
                        List<Map<String, Object>> events, List<callOutreachReasonsWrapper> callOutreachReasons, 
                        List<Map<String, Object>> listsOrder, List<String> productColors, List<String> productCollections,
                        List<String> productMaterials, List<String> productSizes){
            this.picklists = picklists;
            this.mappings = mappings;
            this.queries = queries;
            this.clientNotes = clientNotes;
            this.emailTemplatesFields = emailTemplatesFields;
            this.SAs = SAs;
            this.globalSAs =globalSAs;
            this.userInfos = userInfos;
            this.gifts = gifts;
            this.events = events;
            this.callOutreachReasons = callOutreachReasons;
            this.listsOrder = listsOrder;
            this.productColors = productColors;
            this.productCollections = productCollections;
            this.productMaterials = productMaterials;
            this.productSizes = productSizes;
        }
    } 
}