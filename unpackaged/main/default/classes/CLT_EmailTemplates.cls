public with sharing class CLT_EmailTemplates implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
   
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){
        Boolean newVersion = params.get('isNew') == 'true' ? true : false;    
        //String emailLanguage = CLT_Utils.getMyUser().EmailLanguages__c + ';English';
        String emailLanguage = Test.isRunningTest() ? 'EN;' : 'EN;' + CLT_Utils.getMyUser().Email_templates__c;
        list<String> emailLanguages = emailLanguage.split('\\;');
        system.debug('emailLanguages: ' + emailLanguages);
        Map<String, CLT_FieldsMapping__mdt> fieldsMapping = CLT_Utils_Mapping.getMappingObjectDict('EmailTemplate', 'EmailTemplate', 'SFFieldPath__c');
        system.debug('fieldsMapping :' + fieldsMapping);

        if (newVersion) {
            return new Map<String, Object> {
                'emailTemplates' => getEmailTemplates(emailLanguages, newVersion),
                'sharingTemplates' => getSharingTemplates(emailLanguages, fieldsMapping)
            };
        }
        else {
            return new Map<String, Object> {
                'emailTemplates' => getEmailTemplates(emailLanguages, fieldsMapping)
            };
        }
    }

    public List<Object> getEmailTemplates(list<String> emailLanguages, Boolean newVersion) {
        String defaultCategory = 'Other';
        Map<String, Object> userCategoriesMap = getUserCategoriesMap(defaultCategory);

        String langCondition = '';
        for(string emailLang : emailLanguages){
            String language = emailLang.trim();
            langCondition += ' Folder_Name__c LIKE \'' + language + ' %\' OR';
        }
        langCondition = langCondition.removeEnd('OR');

        String query = 'SELECT Category__c,JSON__c,Email_Template_Id__c FROM CLT_Email_Template__c WHERE ('+ langCondition +') AND Is_Active__c = TRUE ORDER BY Category__c';

        Set<String> emailTemplatesIds = new Set<String>();
        Map<String, List<CLT_Email_Template__c>> cltEmailTemplatesMap = new Map<String, List<CLT_Email_Template__c>>();
        for(CLT_Email_Template__c cltEmailTemplate : Database.query(query)) {
            if(String.isEmpty(cltEmailTemplate.Category__c)) {
                cltEmailTemplate.Category__c = defaultCategory;
            }
            if(!cltEmailTemplatesMap.containsKey(cltEmailTemplate.Category__c)) {
                cltEmailTemplatesMap.put(cltEmailTemplate.Category__c, new List<CLT_Email_Template__c>());
            }
            cltEmailTemplatesMap.get(cltEmailTemplate.Category__c).add(cltEmailTemplate);
            emailTemplatesIds.add(cltEmailTemplate.Email_Template_Id__c);
        }

        Map<Id, List<Object>> emailTemplateImages = getEmailTemplatesImages(emailTemplatesIds);

        defaultCategory = (String)userCategoriesMap.get('Default');
        userCategoriesMap.remove('Default');

        List<Map<String, Object>> emailTemplatesList = new List<Map<String, Object>>();
        for(String category : cltEmailTemplatesMap.keySet()) {

            Map<String, Object> categoryWrapper = new Map<String, Object>();
            String currentCategory = userCategoriesMap.containsKey(category) ? category : defaultCategory;
            Map<String, Object> currentCategoryMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(userCategoriesMap.get(currentCategory)));
            List<Map<String, Object>> templatesList = new List<Map<String, Object>>();
            String langCategory = (String)currentCategoryMap.get('name');

            for(CLT_Email_Template__c cltEmailTemplate : cltEmailTemplatesMap.get(category)) {
                Map<String, Object> jsonWrapper = (Map<String, Object>)JSON.deserializeUntyped(cltEmailTemplate.JSON__c);
                jsonWrapper.put('images', emailTemplateImages.get(cltEmailTemplate.Email_Template_Id__c));
                jsonWrapper.put('reason', currentCategory);
                templatesList.add(jsonWrapper);
            }
            categoryWrapper.put('templates', templatesList);
            categoryWrapper.putAll(currentCategoryMap);
            emailTemplatesList.add(categoryWrapper);
        }
        return emailTemplatesList;
    }

    public Map<String, Object> getUserCategoriesMap(String defaultCategory) {
        Map<String, CLT_FieldsMapping__mdt> emailTemplateCategoryFieldsMapping = CLT_Utils_Mapping.getMappingObjectDict('CLT_EmailTemplateCategory__mdt', 'EmailTemplateCategory', 'SFFieldPath__c');
        system.debug('emailTemplateCategoryFieldsMapping :' + emailTemplateCategoryFieldsMapping);
        String categoriesQuery = CLT_Utils_Mapping.getQueryString(emailTemplateCategoryFieldsMapping, ',Id,IsDefault__c FROM CLT_EmailTemplateCategory__mdt');

        String lang = UserInfo.getLanguage();
        Set<String> categoryMdtFields = Schema.SObjectType.CLT_EmailTemplateCategory__mdt.fields.getMap().keySet();
        if(!categoryMdtFields.contains(lang + '_category__c')) {
            lang = 'en_US';
        }

        Map<String, Object> categoriesMap = new Map<String, Object>();

        Boolean defaultExists = false;
        for(CLT_EmailTemplateCategory__mdt etc : Database.query(categoriesQuery)) {
            String category = (String)etc.get('en_US_category__c');
            String userLangCategory = etc.get(lang + '_category__c') != null ? (String)etc.get(lang + '_category__c') : category;
            String categoryId = etc.Id;

            categoriesMap.put(category, new Map<String,String> {'name' => userLangCategory, 'id' => categoryId});

            if(etc.IsDefault__c) {
                defaultCategory = etc.en_US_Category__c;
                defaultExists = true;
            }
        }

        if(!defaultExists){
            categoriesMap.put(defaultCategory, new Map<String,String> {'name' => defaultCategory, 'id' => 'unknown'});
        }

        categoriesMap.put('Default', defaultCategory);
        return categoriesMap;
    }

    public Map<Id, List<Object>> getEmailTemplatesImages(Set<String> emailTemplatesIds) {
        Map<Id, List<Object>> emailTemplatesImages = new Map<Id, List<Object>>();
        for(Template_Images__c ti : [SELECT Id, Email_Template_Id__c, Image_1__c, Image_2__c, Image_3__c, Image_4__c
                                        FROM Template_Images__c 
                                        WHERE Email_Template_Id__c IN :emailTemplatesIds]) {
            if(!emailTemplatesImages.containsKey(ti.Email_Template_Id__c)) {
                emailTemplatesImages.put(ti.Email_Template_Id__c, new List<Object>());
            }
            for(Integer i=1 ; i<=4 ; i++) {
                String image = (String)ti.get('Image_' + i + '__c');
                if(!String.isEmpty(image)) {
                    emailTemplatesImages.get(ti.Email_Template_Id__c).add(image);
                }
            }
        }

        return emailTemplatesImages;
    }

    public List<Object> getEmailTemplates(list<String> emailLanguages, Map<String, CLT_FieldsMapping__mdt> fieldsMapping){
        List<Map<String, Object>> wrapperList = new List<Map<String, Object>>();

        String langCondition = '';
        for(string emailLang : emailLanguages){
             String language = emailLang.trim();
//langCondition += ' Folder.DeveloperName LIKE \'' + emailLang + '%\' OR';
            langCondition += ' Folder.Name LIKE \'' + language + ' %\' OR';
        }
        langCondition = langCondition.removeEnd('OR');  

        String query =  ',Folder.Name FROM EmailTemplate WHERE ('+ langCondition +') AND IsActive = TRUE';
        system.debug(query);
       
        for(SObject item : Database.query(CLT_Utils_Mapping.getQueryString(fieldsMapping, query))){
            Map<String, Object> itemWrapper = CLT_Utils_Mapping.getItemWrapper(fieldsMapping, item);

            string folderName = String.valueOf(item.getSObject('Folder').get('DeveloperName'));
            list<String> folderNameItems = folderName.split('\\_');
            /*string folderName = String.valueOf(item.getSObject('Folder').get('Name'));
            list<String> folderNameItems = folderName.split(' ');*/
           
            string htmlBody = String.valueOf(itemWrapper.get('htmlValue'));  
            Boolean isEmail =  folderName.toUpperCase().contains('EMAIL');
            Boolean isPostal =  folderName.toUpperCase().contains('POSTAL');

            itemWrapper.put('lang', folderNameItems.size() > 0 ? folderNameItems[0] : '');
            itemWrapper.put('type', isEmail ? 'Email' : isPostal ? 'Postal' : 'InstantMessage');
           
            if(isEmail && String.isNotEmpty(htmlBody)){
                itemWrapper.put('body', htmlBody);
            }

            wrapperList.add(itemWrapper);      
        }

        return wrapperList;
    }

    public Map<String,Object> getSharingTemplates(list<String> emailLanguages, Map<String, CLT_FieldsMapping__mdt> fieldsMapping){
        Map<String,Object> wrapperMap = new Map<String,Object>();

        String langCondition = '';
        for(string emailLang : emailLanguages){
             String language = emailLang.trim();
            langCondition += ' Name LIKE \'' + language + '%\' OR';
        }
        langCondition = langCondition.removeEnd('OR');  

        String query =  ' FROM EmailTemplate '+
                        'WHERE Folder.DeveloperName =\'Sharing_Templates\' AND ('+ langCondition +') AND IsActive = TRUE';
        system.debug(query);
       
        for(SObject item : Database.query(CLT_Utils_Mapping.getQueryString(fieldsMapping, query))){
            Map<String, Object> itemWrapper = CLT_Utils_Mapping.getItemWrapper(fieldsMapping, item);

            string templateName = String.valueOf(itemWrapper.get('devName'));
            list<String> templateNameItems = templateName.split('_');
           
            itemWrapper.put('lang', templateNameItems.size() > 0 ? templateNameItems[0] : '');

            wrapperMap.put(String.valueOf(itemWrapper.get('lang')), itemWrapper);
        }

        return wrapperMap;
    }
}