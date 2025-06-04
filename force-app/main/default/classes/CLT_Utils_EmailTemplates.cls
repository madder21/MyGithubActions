public with sharing class CLT_Utils_EmailTemplates {
    public static List<object> getPersonalEmailTemplates(Map<String, Object> userCategoriesMap, String defaultCategory) {
        Map<String, List<Map<String, Object>>> cltEmailTemplatesCategoryMap = new Map<String, List<Map<String, Object>>>();
        
        for(Map<String, Object> wrappedCltEmailTemplate : CLT_Utils_Mapping.getStandardWrapperList('CLT_Email_Template__c', 'PersonalEmailTemplates', 'FROM CLT_Email_Template__c WHERE PersonalizedTemplate__c = TRUE AND User__c = \'' + UserInfo.getUserId() + '\' AND Is_Active__c = TRUE ORDER BY Category__c')) {
            if(String.isEmpty((String)wrappedCltEmailTemplate.get('reason'))) {
                wrappedCltEmailTemplate.put('reason', defaultCategory);
            }
            if(!cltEmailTemplatesCategoryMap.containsKey((String)wrappedCltEmailTemplate.get('reason'))) {
                cltEmailTemplatesCategoryMap.put((String)wrappedCltEmailTemplate.get('reason'), new List<Map<String, Object>>());
            }
            cltEmailTemplatesCategoryMap.get((String)wrappedCltEmailTemplate.get('reason')).add(wrappedCltEmailTemplate);
        }

        List<Map<String, Object>> emailTemplatesList = new List<Map<String, Object>>();
        for(String category : cltEmailTemplatesCategoryMap.keySet()) {
            Map<String, Object> categoryWrapper = new Map<String, Object>();
            String currentCategory = userCategoriesMap.containsKey(category) ? category : defaultCategory;
            Map<String, Object> currentCategoryMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(userCategoriesMap.get(currentCategory)));
            List<Map<String, Object>> templatesList = new List<Map<String, Object>>();

            for(Map<String, Object> cltEt : cltEmailTemplatesCategoryMap.get(category)) {
                cltEt.put('reason', currentCategory);
                templatesList.add(cltEt);
            }
            categoryWrapper.put('templates', templatesList);
            categoryWrapper.putAll(currentCategoryMap);
            emailTemplatesList.add(categoryWrapper);
        }

        return emailTemplatesList;
    }

    public static List<Object> getEmailTemplatesV2(list<String> emailLanguages, Map<String, Object> userCategoriesMap, String defaultCategory) {
        List<String> langConditions = new List<String>();
        for(string emailLang : emailLanguages){
            langConditions.add(' Folder_Name__c LIKE \'' + emailLang.trim() + ' %\'');
        }

        String query = 'SELECT Category__c,JSON__c,CreatedDate,Email_Template_Id__c FROM CLT_Email_Template__c WHERE PersonalizedTemplate__c = FALSE AND ('+ String.join(langConditions, ' OR ') +') AND Is_Active__c = TRUE ORDER BY Category__c';

        Set<String> emailTemplatesIds = new Set<String>();
        Map<String, List<CLT_Email_Template__c>> cltEmailTemplatesMap = new Map<String, List<CLT_Email_Template__c>>();

        Utils.addCustomHeader('QUERY', query, RestContext.request);
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
                jsonWrapper.put('createdDate', cltEmailTemplate.CreatedDate);
                templatesList.add(jsonWrapper);
            }
            categoryWrapper.put('templates', templatesList);
            categoryWrapper.putAll(currentCategoryMap);
            emailTemplatesList.add(categoryWrapper);
        }
        return emailTemplatesList;
    }

    public static List<Object> getEmailTemplates(list<String> emailLanguages) {
        String defaultCategory = 'Other';
        Map<String, Object> userCategoriesMap = getUserCategoriesMap(defaultCategory);

        String langCondition = '';
        for(string emailLang : emailLanguages){
            String language = emailLang.trim();
            langCondition += ' Folder_Name__c LIKE \'' + language + ' %\' OR';
        }
        langCondition = langCondition.removeEnd('OR');

        String query = 'SELECT Category__c,JSON__c,Email_Template_Id__c FROM CLT_Email_Template__c WHERE PersonalizedTemplate__c = FALSE AND ('+ langCondition +') AND Is_Active__c = TRUE ORDER BY Category__c';

        Set<String> emailTemplatesIds = new Set<String>();
        Map<String, List<CLT_Email_Template__c>> cltEmailTemplatesMap = new Map<String, List<CLT_Email_Template__c>>();

        Utils.addCustomHeader('QUERY', query, RestContext.request);
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

    public static Map<String, Object> getUserCategoriesMap(String defaultCategory) {
        Map<String, CLT_FieldsMapping__mdt> emailTemplateCategoryFieldsMapping = CLT_Utils_Mapping.getMappingObjectDict('CLT_EmailTemplateCategory__mdt', 'EmailTemplateCategory', 'SFFieldPath__c');
        String categoriesQuery = CLT_Utils_Mapping.getQueryString(emailTemplateCategoryFieldsMapping, ',Id,IsDefault__c FROM CLT_EmailTemplateCategory__mdt');

        String lang = UserInfo.getLanguage();
        Set<String> categoryMdtFields = Schema.SObjectType.CLT_EmailTemplateCategory__mdt.fields.getMap().keySet();
        if(!categoryMdtFields.contains(lang + '_category__c')) {
            lang = 'en_US';
        }

        Map<String, Object> categoriesMap = new Map<String, Object>();

        Boolean defaultExists = false;
        Utils.addCustomHeader('QUERY', categoriesQuery, RestContext.request);
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

    public static Map<Id, List<Object>> getEmailTemplatesImages(Set<String> emailTemplatesIds) {
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

    public static Map<String,Object> getSharingTemplates(list<String> emailLanguages, Map<String, CLT_FieldsMapping__mdt> fieldsMapping){
        Map<String,Object> wrapperMap = new Map<String,Object>();

        String langCondition = '';
        for(string emailLang : emailLanguages){
             String language = emailLang.trim();
            langCondition += ' Name LIKE \'' + language + '%\' OR';
        }
        langCondition = langCondition.removeEnd('OR');  

        String query =  ' FROM EmailTemplate '+
                        'WHERE Folder.DeveloperName =\'Sharing_Templates\' AND ('+ langCondition +') AND IsActive = TRUE';

        Utils.addCustomHeader('QUERY', query, RestContext.request);
        for(SObject item : Database.query(CLT_Utils_Mapping.getQueryString(fieldsMapping, query))){
            Map<String, Object> itemWrapper = CLT_Utils_Mapping.getItemWrapper(fieldsMapping, item);

            string templateName = String.valueOf(itemWrapper.get('devName'));
            list<String> templateNameItems = templateName.split('_');
           
            itemWrapper.put('lang', templateNameItems.size() > 0 ? templateNameItems[0] : '');

            wrapperMap.put(String.valueOf(itemWrapper.get('lang')), itemWrapper);
        }

        return wrapperMap;
    }

    public static Object upsertPersonalizedEmailTemplate(Map<String, Object> body) {
        CLT_Email_Template__c emailTemplateCLT = getEmailTemplateCLTFromBody(body);
        upsert emailTemplateCLT;
        return CLT_Utils_Mapping.getStandardWrapperList('CLT_Email_Template__c', 'PersonalEmailTemplates', 'FROM CLT_Email_Template__c WHERE Id = \'' + emailTemplateCLT.Id + '\'');
    }

    public static CLT_Email_Template__c getEmailTemplateCLTFromBody(Map<String, Object> body) {
        CLT_EmailTemplateWrapper cltEmailTemplateWrapped = (CLT_EmailTemplateWrapper)JSON.deserialize(JSON.serialize(body), CLT_EmailTemplateWrapper.class);
        CLT_Email_Template__c emailTemplateCLT = new CLT_Email_Template__c(
            Id = cltEmailTemplateWrapped.id,
            Name = cltEmailTemplateWrapped.name,
            Language__c = cltEmailTemplateWrapped.lang,
            Category__c = cltEmailTemplateWrapped.reason,
            Subject__c = cltEmailTemplateWrapped.subject,
            PlainText__c = cltEmailTemplateWrapped.plainText,
            Signature__c = cltEmailTemplateWrapped.signature,
            Type__c = cltEmailTemplateWrapped.type,
            User__c = UserInfo.getUserId(),
            PersonalizedTemplate__c = true,
            Is_Active__c = true
        );
        return emailTemplateCLT;
    }

    public class CLT_EmailTemplateWrapper {
        String id {get; set;}
        String name {get; set;}
        String lang {get; set;}
        String reason {get; set;}
        String subject {get; set;}
        String plainText {get; set;}
        String signature {get; set;}
        String type {get; set;}
    }

    public static Object deletePersonalCLTEmailTemplate(Map<String, String> params) {
        String cltEmailTemplateId = params.get('id');

		List<CLT_Email_Template__c> cltEmailTemplateList = [SELECT Id FROM CLT_Email_Template__c WHERE Id = :cltEmailTemplateId AND PersonalizedTemplate__c = true LIMIT 1];
		if(cltEmailTemplateList.size() > 0) {
			CLT_Email_Template__c cltEmailTemplate = cltEmailTemplateList[0];

			delete cltEmailTemplate;
			return true;
		}
		else {
			throw new BL_Exceptions.CLTException('401', 'No Personal CLT Email Template with the receiven Id', 'No Personal CLT Email Template with the receiven Id');
		}
    }
}