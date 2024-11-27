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

        if(params.containsKey('type')) {
            String type = params.get('type');

            if(type == 'gift') {
                return getGifts(userStore);
            }
            else if(type == 'event') {
                return getEvents(userStore);
            }
        }
        
        return new ConfigWrapper(getPicklists(params), getMappings(), getActiveSOQL(), getClientNotes(), getEmailTemplatesFields(),
                                getSAs(), getGlobalSAs(), getUserInfos(), getGifts(userStore), getEvents(userStore), 
                                getCallOutreachReasons(), getListOrder(), getProductColors(), getProductCollections(),
                                getProductMaterials(), getProductSizes(), getAvailableEmailTemplateLanguages(),
                                getEmailTemplateCategories(), getPersonalEmailTemplateSignature(), getNotificationSettings());
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
                                                    ' FROM Note__c WHERE Client__c IN (' + clientQuery + ') AND IsDeleted__c = FALSE ORDER BY LastModifiedDate DESC');
    }
  
    public List<Map<String,Object>> getEmailTemplatesFields(){
        List<CLT_EmailTemplateField__mdt> fields = [
            SELECT Id,Object__c,FieldWrapperName__c,StringToReplace__c,Label,AvailableForPersonalTemplates__c,Position__c
            FROM CLT_EmailTemplateField__mdt 
            WHERE Active__c = TRUE
        ];
        List<Map<String,Object>> mappingFields = new List<Map<String,Object>>();
        
        for(CLT_EmailTemplateField__mdt field: fields) {
            mappingFields.add(new Map<String,Object>{
                'id' => field.Id,
                'object' => field.Object__c,
                'field' => field.FieldWrapperName__c,
                'strToReplace' => field.StringToReplace__c,
                'label' => field.Label,
                'personalTemplateAvailable' => field.AvailableForPersonalTemplates__c,
                'position' => field.Position__c
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

    public List<String> getAvailableEmailTemplateLanguages() {
        List<String> availableEmailTemplatesLanguages = new List<String>();

        String userEmailLanguage = Test.isRunningTest() ? 'EN;' : 'EN;' + CLT_Utils.getMyUser().Email_templates__c;
        List<String> langConditions = new List<String>();
        for(string emailLang : userEmailLanguage.split('\\;')){
            langConditions.add('Name LIKE \'' + emailLang.trim() + ' %\'');
        }

        String query = 'SELECT DeveloperName FROM Folder WHERE Type = \'Email\' AND Name != \'Sharing Templates\' AND (' + String.join(langConditions, ' OR ') + ')';
        
        Utils.addCustomHeader('QUERY', query, RestContext.request);
        
        for(Folder f : Database.query(query)) {
            String langLabel = f.DeveloperName.contains('_') ? f.DeveloperName.substringBeforeLast('_').replace('_',' ') : '';
            if(!String.isEmpty(langLabel) && !availableEmailTemplatesLanguages.contains(langLabel)) {
                availableEmailTemplatesLanguages.add(langLabel);
            }
        }

        return availableEmailTemplatesLanguages;
    }

    public List<Object> getEmailTemplateCategories() {
        List<Map<String, Object>> emailTemplatesCategories = new List<Map<String, Object>>();
        String lang = UserInfo.getLanguage();
        Set<String> categoryMdtFields = Schema.SObjectType.CLT_EmailTemplateCategory__mdt.fields.getMap().keySet();
        if(!categoryMdtFields.contains(lang.toLowerCase() + '_category__c')) {
            lang = 'en_US';
        }

        String categoriesQuery = 'SELECT ' + (lang != 'en_US' ? lang + '_category__c,' : '') + 
            'en_US_category__c,Id,Position__c FROM CLT_EmailTemplateCategory__mdt';

        Utils.addCustomHeader('QUERY', categoriesQuery, RestContext.request);

        for(CLT_EmailTemplateCategory__mdt etc : Database.query(categoriesQuery)) {
            emailTemplatesCategories.add(new Map<String, Object> {
                'label' => etc.get(lang + '_category__c') != null ? (String)etc.get(lang + '_category__c') : (String)etc.get('en_US_category__c'),
                'value' => (String)etc.get('en_US_category__c'),
                'id' => (String)etc.get('Id')
            });
        }

        return emailTemplatesCategories;
    }

    public Map<String, Map<String, Object>> getPersonalEmailTemplateSignature(){
        Map<String, Map<String, Object>> personalEmailTemplateSignature = new Map<String, Map<String, Object>>();
        String defaultUserLanguage = 'English';
        User connectedUser = CLT_Utils.getMyUser();
        String userEmailLanguage = Test.isRunningTest() ? 'EN;' : 'EN;' + connectedUser.Email_templates__c;

        List<CLT_PersonalEmailTemplateSignature__mdt> persoEmailTemplateSignatures = [SELECT Language__c,UserLanguage__c,Type__c,Signature__c
                                                                                    FROM CLT_PersonalEmailTemplateSignature__mdt
                                                                                    WHERE LanguageCode__c IN :userEmailLanguage.split(';')];
        if(persoEmailTemplateSignatures.size() > 0) {
            for(CLT_PersonalEmailTemplateSignature__mdt persoEmailTemplateSignature : persoEmailTemplateSignatures) {
                if(!personalEmailTemplateSignature.containsKey(persoEmailTemplateSignature.Language__c)) {
                    personalEmailTemplateSignature.put(persoEmailTemplateSignature.Language__c, new Map<String, Object>());
                    if((persoEmailTemplateSignature.UserLanguage__c.split(';')).contains(connectedUser.LanguageLocaleKey)) {
                        defaultUserLanguage = persoEmailTemplateSignature.Language__c;
                    }
                }
                personalEmailTemplateSignature.get(persoEmailTemplateSignature.Language__c).put(persoEmailTemplateSignature.Type__c, persoEmailTemplateSignature.Signature__c);
            }
        }

        if(personalEmailTemplateSignature.containsKey(defaultUserLanguage)) {
            personalEmailTemplateSignature.get(defaultUserLanguage).put('isDefault', true);
        }

        return personalEmailTemplateSignature;
    }

    public List<Map<String, Object>> getNotificationSettings() {
        String mutedNotifField = [SELECT MutedNotifications__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].MutedNotifications__c;
        Map<String, Object> userMutedNotifications = !String.isEmpty(mutedNotifField) ? (Map<String, Object>)JSON.deserializeUntyped(mutedNotifField) :new Map<String, Object>();
        List<Map<String, Object>> wrapperList = CLT_Utils_Mapping.getStandardWrapperList('CLT_NotificationManagement__mdt', 'NotificationManagement', 'FROM CLT_NotificationManagement__mdt WHERE Muted__c = FALSE AND CanBeMuteByCA__c = TRUE');
        for(Map<String, Object> wrapped : wrapperList) {
            if(userMutedNotifications.containsKey((String)wrapped.get('id'))) {
                String endMutedDateStr = (String)userMutedNotifications.get((String)wrapped.get('id'));
                List<String> mutedDateStringList = (endMutedDateStr).split('-');
                Date endMutedDate = (Date.newInstance(Integer.valueOf(mutedDateStringList[0]), Integer.valueOf(mutedDateStringList[1]), Integer.valueOf(mutedDateStringList[2])));
                if(Date.today() < endMutedDate) {
                    wrapped.put('activated', false);
                    wrapped.put('endMutedDate', endMutedDateStr);
                }
                else {
                    wrapped.put('activated', true);
                }              
            }
            else {
                wrapped.put('activated', true);
            }
        }
        
        return wrapperList;
    }
    public class ConfigWrapper{
        public List<CLT_UtilsPicklist.PicklistWrapper> picklists {get; set;}
        public List<Map<String, Object>> mappings {get; set;}
        public List<Map<String, String>> queries {get;set;}
        public List<Map<String, Object>> clientNotes {get;set;}
        public List<Map<String, Object>> emailTemplatesFields {get;set;}
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
        public List<String> availableEmailTemplatesLanguages {get; set;}
        public List<Object> emailTemplateCategories {get; set;}
        public Map<String, Map<String, Object>> personalEmailTemplateSignature {get; set;}
        public List<Map<String, Object>> notificationSettings {get; set;}

        //Constructor
        public ConfigWrapper(list<CLT_UtilsPicklist.PicklistWrapper> picklists, List<Map<String, Object>> mappings, List<Map<String,String>> queries,
                        List<Map<String, Object>> clientNotes, List<Map<String,Object>> emailTemplatesFields, List<Map<String, Object>> SAs,
                        List<Map<String, Object>> globalSAs, Map<String,object> userInfos, List<Map<String, Object>> gifts,
                        List<Map<String, Object>> events, List<callOutreachReasonsWrapper> callOutreachReasons, 
                        List<Map<String, Object>> listsOrder, List<String> productColors, List<String> productCollections,
                        List<String> productMaterials, List<String> productSizes, List<String> availableEmailTemplatesLanguages,
                        List<Object> emailTemplateCategories, Map<String, Map<String, Object>> personalEmailTemplateSignature,
                        List<Map<String, Object>> notificationSettings){
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
            this.availableEmailTemplatesLanguages = availableEmailTemplatesLanguages;
            this.emailTemplateCategories = emailTemplateCategories;
            this.personalEmailTemplateSignature = personalEmailTemplateSignature;
            this.notificationSettings = notificationSettings;
        }
    } 
}