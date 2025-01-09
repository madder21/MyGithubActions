/**
 * @author (Balink)
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is responsible for handling configuration-related functionalities, including retrieval and management of config settings for R-Client.
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modification	|Modified By	    |Related Jira Ticket	|Description of changes			
 * 1.0		|2024/09/12				|Sarah A.(Balink)	|RCLIENT-1279			|Add of appointment booking settings.
 * 1.1      |18/12/2024             | Sarah A.(Balink)  | RCLIENT-1572          |only Online Appointment Service that are Online should be retruned.					
 */
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
                                getSAs(), getGlobalSAs(), getUserInfos(), getStoreReasons(u.StoreCode__c), getGifts(userStore), getEvents(userStore), 
                                getCallOutreachReasons(), getListOrder(), getProductColors(), getProductCollections(),
                                getProductMaterials(), getProductSizes(), getAvailableEmailTemplateLanguages(),
                                getEmailTemplateCategories(), getPersonalEmailTemplateSignature(), getNotificationSettings(),getAppointmentBookingSettings());
    }

    /*
    * @METHOD 	: getPicklists
    * @DESC 	: Retrieves a list of picklist values based on the provided parameters. The method expects a key 'picklists' in the map, 
    *            which contains the names of picklists separated by semicolons. These picklist names are then passed to a utility method to fetch the actual values.
    * @PARAM 	: Map<String, String> params - A map containing input parameters, where the 'picklists' key holds a semicolon-separated list of picklist names.
    * @RETURN 	: List<CLT_UtilsPicklist.PicklistWrapper> - A list of picklist wrapper objects containing the picklist values for the provided picklist names.
    */
    public List<CLT_UtilsPicklist.PicklistWrapper> getPicklists(Map<String, String> params){
        List<String> picklistNameItems = new list<String>();
        String picklistsNames = params.get('picklists');    
        if(picklistsNames != null){
            picklistNameItems = picklistsNames.split(';');
        }

        return CLT_UtilsPicklist.getPicklists(picklistNameItems);
    }

    /*
    * @METHOD 	: getMappings
    * @DESC 	: Retrieves a list of mappings from the custom metadata type 'CLT_FieldsMapping__mdt'. This method fetches mappings where the field 
    *            'Send_to_Clienteling_App__c' is set to true. It uses a utility method to return the data in a standard wrapper format.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, Object>> - A list of mappings represented as maps of field names to their respective values.
    */
    public List<Map<String, Object>> getMappings(){
        return CLT_Utils_Mapping.getStandardWrapperList('CLT_FieldsMapping__mdt', 'CLT_FieldsMapping__mdt', 'FROM CLT_FieldsMapping__mdt WHERE Send_to_Clienteling_App__c = true');
    }

    /*
    * @METHOD 	: getActiveSOQL
    * @DESC 	: Constructs and returns a list of active SOQL queries with associated metadata such as query name and ID. 
    *            Each query is represented as a map containing the SOQL query string, its name, and an identifier.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, String>> - A list of maps, where each map contains the SOQL query ('query'), its name ('name'), and an ID ('id').
    */
    public List<Map<String,String>> getActiveSOQL(){
        List<Map<String,String>> queries = new List<Map<String,String>>();
        
        queries.add(new Map<String,String>{
            'query' => CLT_Utils_Query.getGeneralClientsQuery(),
            'name' => 'Clients',
            'id' => 'clientQuery'
        });   
        return queries;     
    }

    /*
    * @METHOD 	: getClientNotes
    * @DESC 	: Retrieves a list of client notes by executing a SOQL query that selects notes associated with clients.
    *            The query filters notes that belong to active clients (non-deleted) and orders them by their last modified date in descending order.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, Object>> - A list of maps where each map represents a client note record with fields and values.
    */
    public List<Map<String, Object>> getClientNotes(){
        String clientQuery = 'SELECT Id FROM Account ' + CLT_Utils_Query.getGeneralClientsQuery().substringAfter('FROM Account');
        return CLT_Utils_Mapping.getStandardWrapperList('Note__c','Note',
                                                    ' FROM Note__c WHERE Client__c IN (' + clientQuery + ') AND IsDeleted__c = FALSE ORDER BY LastModifiedDate DESC');
    }
  
    /*
    * @METHOD 	: getEmailTemplatesFields
    * @DESC 	: Retrieves the list of active email template fields from the `CLT_EmailTemplateField__mdt` custom metadata object and 
    *            maps their properties into a list of maps for easier access and use in email template creation.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, Object>> - A list of maps, each containing key-value pairs representing an email template field's metadata.
    */
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

    /*
    * @METHOD 	: getSAs
    * @DESC 	: Retrieves a list of active Users (Sales Associates) whose `StoreCode__c` matches the current user's store code.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, Object>> - A list of maps representing active Users whose store code matches the current user's store code.
    */
    public  List<Map<String, Object>> getSAs(){  
        string myStoreCode = CLT_Utils.getMyUser().StoreCode__c;

        return CLT_Utils_Mapping.getStandardWrapperList('User', 'User', 'FROM User WHERE storecode__c = \'' + myStoreCode + '\' AND  IsActive = true');
    }

    /*
    * @METHOD 	: getGlobalSAs
    * @DESC 	: Retrieves a list of active Users (Store Associates) whose `StoreCode__c` does not match the current user's store code and who have a Profile with the name 'Store User'.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, Object>> - A list of maps representing active Users whose store code is different from the current user's store code and whose Profile is 'Store User'.
    */
    public  List<Map<String, Object>> getGlobalSAs(){  
        string myStoreCode = CLT_Utils.getMyUser().StoreCode__c;

        return CLT_Utils_Mapping.getStandardWrapperList('User', 'User', 
        'FROM User WHERE storecode__c != \'' + myStoreCode + '\' AND  IsActive = true AND Profile.Name = \'Store User\'');
    }

    /*
    * @METHOD 	: getUserInfos
    * @DESC 	: Retrieves user information including store codes and additional related data. It collects details about the current user, their store code, zone store codes, and store mapping based on the user's store code.
    * @PARAM 	: none
    * @RETURN 	: Map<String, Object> - A map containing user information, store codes, and related store data.
    */
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
    
    /*
    * @METHOD 	: getStoreReasons
    * @DESC 	: Appointment booking reasons with their Ids according tothe user's store.
    * @PARAM 	: storeCode: the code of the user's store.
    * @RETURN 	: List<Map<String, Object>> - A list of map containing the label and the Id of each reason, the Id is changing according to the store
    */
    public List<Map<String, Object>> getStoreReasons(String storeCode){
        List<Map<String, Object>> storeReasons = new List<Map<String, Object>>();

        for(AppointmentService__c apptService : [SELECT Name,BooxiId__c 
                                                FROM AppointmentService__c 
                                                WHERE Store__r.SourceStoreId__c = :storeCode AND Status__c = 'Online']) {
            storeReasons.add(new Map<String, Object> {
                'id' => apptService.BooxiId__c,
                'label' => apptService.Name
            });
        }

        return storeReasons;
    }

    /*
    * @METHOD 	: getGifts
    * @DESC 	: Retrieves a list of active gifts based on the provided store's country and region. The gifts are filtered to ensure they are currently active and match the store's location.
    * @PARAM 	: Store__c userStore - The store for which the active gifts are being retrieved.
    * @RETURN 	: List<Map<String, Object>> - A list of maps where each map represents a gift record with its details.
    */
    public List<Map<String, Object>> getGifts(Store__c userStore) {
        String giftQuery = ' FROM Gift__c WHERE (ActiveFrom__c = NULL OR ActiveFrom__c <= TODAY) AND (ActiveUntil__c = NULL OR ActiveUntil__c >= TODAY) ';
        giftQuery += ' AND ((Countries__c = \'\' OR Countries__c INCLUDES (\'' + userStore.Country__c + '\'))) ';
        giftQuery += ' AND ((Region__c = \'\' OR Region__c = \'' + userStore.Region__c + '\')) ';
        giftQuery += ' ORDER BY Name__c';
        return CLT_Utils_Mapping.getStandardWrapperList('Gift__c','Gift__c', giftQuery);
    }

    /*
    * @METHOD 	: getEvents
    * @DESC 	: Retrieves a list of active events for a given store, based on the store's country and region. The method constructs a dynamic SOQL query to filter events that are currently active and match the store's country and region criteria. The results are ordered by the event name.
    * @PARAM 	: Store__c userStore - The store record containing the country and region information to filter events.
    * @RETURN 	: List<Map<String, Object>> - A list of maps where each map represents an event and contains event details.
    */
    public List<Map<String, Object>> getEvents(Store__c userStore) {
        String eventQuery = ' FROM Event__c WHERE (ActiveFrom__c = NULL OR ActiveFrom__c <= TODAY) AND (ActiveUntil__c = NULL OR ActiveUntil__c >= TODAY) ';
        eventQuery += ' AND ((Countries__c = \'\' OR Countries__c INCLUDES (\'' + userStore.Country__c + '\'))) ';
        eventQuery += ' AND ((Region__c = \'\' OR Region__c = \'' + userStore.Region__c + '\')) ';
        eventQuery += ' ORDER BY Name__c';
        return CLT_Utils_Mapping.getStandardWrapperList('Event__c','Event__c', eventQuery);
    }
    
    /*
    * @METHOD 	: getZoneStoreCodes
    * @DESC 	: Retrieves store codes for all stores that have a source store ID starting with the provided `currentStoreCode` and are of specific types (FSS, SIS, POP, ECO) and are not closed. The result is a semicolon-separated string of store codes.
    * @PARAM 	: String currentStoreCode - The store code used as the prefix to filter other store codes.
    * @RETURN 	: Object - A semicolon-separated string of store codes matching the criteria.
    */
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
    
    /*
    * @METHOD 	: getAllStoreCodes
    * @DESC 	: Retrieves all store codes for stores of specified types (FSS, SIS, POP, ECO) that are not closed. The result is a semicolon-separated string of store codes.
    * @PARAM 	: none
    * @RETURN 	: Object - A semicolon-separated string of store codes for stores matching the specified criteria.
    */
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

    /*
    * @METHOD 	: getCallOutreachReasons
    * @DESC 	: Retrieves a list of call outreach reasons from custom metadata records based on the user's language. It checks if a field for the user's language exists in the `CLT_EmailTemplateCategory__mdt` metadata type; if not, it defaults to English. The method constructs and executes a dynamic SOQL query to fetch the relevant metadata records and then maps these records into `callOutreachReasonsWrapper` objects.
    * @PARAM 	: none
    * @RETURN 	: List<callOutreachReasonsWrapper> - A list of `callOutreachReasonsWrapper` objects containing the outreach reasons, metadata record IDs, and positions.
    */
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

    /*
    * @METHOD 	: getListOrder
    * @DESC 	: Retrieves a list of order configurations from the `CLT_List_Order__mdt` custom metadata type where the `SectionName__c` field is equal to 'Tasks Group'. The method uses a utility method to execute the SOQL query and return the results.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, Object>> - A list of maps where each map represents a record from the `CLT_List_Order__mdt` metadata type, containing order configuration details.
    */
    public List<Map<String, Object>> getListOrder(){  
        return CLT_Utils_Mapping.getStandardWrapperList('CLT_List_Order__mdt', 'CLT_List_Order__mdt', 'FROM CLT_List_Order__mdt WHERE SectionName__c = \'Tasks Group\'');
    }

    /*
    * @METHOD 	: getProductColors
    * @DESC 	: Retrieves a list of distinct product colors from the `Product2` object. The method queries for non-null values of the `color_v3__c` field, groups the results by this field, and then collects the unique color values into a list.
    * @PARAM 	: none
    * @RETURN 	: List<String> - A list of distinct product color values.
    */
    public List<String> getProductColors() {
        List<String> productColors = new List<String>();
        for(AggregateResult ar : [SELECT color_v3__c color FROM Product2 WHERE color_v3__c != NULL GROUP BY color_v3__c]) {
            productColors.add((String)ar.get('color'));
        }
        return productColors;
    }

    /*
    * @METHOD 	: getProductCollections
    * @DESC 	: Retrieves a list of distinct product collections from the `Product2` object. The method queries for non-null values of the `model__c` field, groups the results by this field, and then collects the unique collection values into a list.
    * @PARAM 	: none
    * @RETURN 	: List<String> - A list of distinct product collection values.
    */
    public List<String> getProductCollections() {
        List<String> productCollections = new List<String>();
        for(AggregateResult ar : [SELECT model__c collection FROM Product2 WHERE model__c != NULL GROUP BY model__c]) {
            productCollections.add((String)ar.get('collection'));
        }
        return productCollections;
    }

    /*
    * @METHOD 	: getProductMaterials
    * @DESC 	: Retrieves a list of distinct product materials from the `Product2` object. The method queries for non-null values of the `material_v3__c` field, groups the results by this field, and then collects the unique material values into a list.
    * @PARAM 	: none
    * @RETURN 	: List<String> - A list of distinct product material values.
    */
    public List<String> getProductMaterials() {
        List<String> productMaterials = new List<String>();
        for(AggregateResult ar : [SELECT material_v3__c material FROM Product2 WHERE material_v3__c != NULL GROUP BY material_v3__c]) {
            productMaterials.add((String)ar.get('material'));
        }
        return productMaterials;
    }

    /*
    * @METHOD 	: getProductSizes
    * @DESC 	: Retrieves a list of distinct product sizes from the `Product2` object. The method queries for non-null values of the `size__c` field, groups the results by this field, and then collects the unique size values into a list.
    * @PARAM 	: none
    * @RETURN 	: List<String> - A list of distinct product size values.
    */
    public List<String> getProductSizes() {
        List<String> productSizes = new List<String>();
        for(AggregateResult ar : [SELECT size__c size FROM Product2 WHERE size__c != NULL GROUP BY size__c]) {
            productSizes.add((String)ar.get('size'));
        }
        return productSizes;
    }

    /*
    * @METHOD 	: getAvailableEmailTemplateLanguages
    * @DESC 	: Retrieves a list of available email template languages based on the user's email templates settings. The method constructs a dynamic SOQL query to fetch folders of type 'Email' that match the language conditions derived from the user's email templates settings. The method then extracts and returns distinct language labels from the folder names.
    * @PARAM 	: none
    * @RETURN 	: List<String> - A list of available email template language labels.
    */
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

    /*
    * @METHOD 	: getEmailTemplateCategories
    * @DESC 	: Retrieves a list of email template categories from the `CLT_EmailTemplateCategory__mdt` custom metadata type. The method checks if the field for the user's language exists and uses it if available; otherwise, it defaults to English. The method constructs and executes a SOQL query to fetch category details, then maps these details into a list of maps with category labels, values, and IDs.
    * @PARAM 	: none
    * @RETURN 	: List<Object> - A list of maps where each map represents an email template category, including 'label', 'value', and 'id' fields.
    */
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

    /*
    * @METHOD 	: getPersonalEmailTemplateSignature
    * @DESC 	: Retrieves personal email template signatures for the connected user from the `CLT_PersonalEmailTemplateSignature__mdt` custom metadata type. The method checks for signatures that match the user's language settings. If multiple languages are available, it sets the default language based on the user's locale. The method constructs and returns a map where each key is a language code and each value is a map of signature types to their corresponding signatures. It also marks the default user's language signature with an 'isDefault' flag.
    * @PARAM 	: none
    * @RETURN 	: Map<String, Map<String, Object>> - A map where each key is a language code and each value is a map of signature types
    */
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

    /*
    * @METHOD 	: getNotificationSettings
    * @DESC 	: Retrieves the notification settings for the current user, including information about muted notifications. The method first fetches the muted notifications field from the user's record and deserializes it into a map. It then retrieves all active notification settings from the `CLT_NotificationManagement__mdt` custom metadata type that are not muted and can be muted by the user. For each notification, the method checks if it is currently muted based on the user's settings and the end date of the mute period. It updates the status of each notification to indicate whether it is activated or muted and includes the end date if applicable.
    * @PARAM 	: none
    * @RETURN 	: List<Map<String, Object>> - A list of maps where each map represents a notification setting, including its activation status and end mute date if applicable.
    */
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

    /*
    * @METHOD 	: getAppointmentBookingSettings
    * @DESC 	: Appointment booking settings that are saved under CLT_AppointmentBookingSetting__mdt custom metadata.
    * @PARAM 	: none
    * @RETURN 	: Map<String, Object> - A map where each key is the name of the setting and each value is an object of settings that are set in the custom metadata
    */
    public Map<String, Object> getAppointmentBookingSettings(){
        Map<String, Object> appointmentBookingSettings = new Map<String, Object>();

        for(CLT_AppointmentBookingSetting__mdt abSetting : [SELECT DeveloperName,JSON__c FROM CLT_AppointmentBookingSetting__mdt]) {
            appointmentBookingSettings.put(abSetting.DeveloperName, JSON.deserializeUntyped(abSetting.JSON__c));
        }

        return appointmentBookingSettings;
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
        public List<Map<String, Object>> storeReasons {get;set;}
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
        public Map<String, Object> appointmentBookingSettings {get; set;}

        //Constructor
        public ConfigWrapper(list<CLT_UtilsPicklist.PicklistWrapper> picklists, List<Map<String, Object>> mappings, List<Map<String,String>> queries,
                        List<Map<String, Object>> clientNotes, List<Map<String,Object>> emailTemplatesFields, List<Map<String, Object>> SAs,
                        List<Map<String, Object>> globalSAs, Map<String,object> userInfos, List<Map<String, Object>> storeReasons, List<Map<String, Object>> gifts,
                        List<Map<String, Object>> events, List<callOutreachReasonsWrapper> callOutreachReasons, 
                        List<Map<String, Object>> listsOrder, List<String> productColors, List<String> productCollections,
                        List<String> productMaterials, List<String> productSizes, List<String> availableEmailTemplatesLanguages,
                        List<Object> emailTemplateCategories, Map<String, Map<String, Object>> personalEmailTemplateSignature,
                        List<Map<String, Object>> notificationSettings, Map<String, Object> appointmentBookingSettings){
            this.picklists = picklists;
            this.mappings = mappings;
            this.queries = queries;
            this.clientNotes = clientNotes;
            this.emailTemplatesFields = emailTemplatesFields;
            this.SAs = SAs;
            this.globalSAs =globalSAs;
            this.userInfos = userInfos;
            this.storeReasons = storeReasons;
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
            this.appointmentBookingSettings = appointmentBookingSettings;
        }
    } 
}