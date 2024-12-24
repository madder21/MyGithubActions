public with sharing class CLT_EmailTemplates implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return CLT_Utils_EmailTemplates.deletePersonalCLTEmailTemplate(params);    
    }
   
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return CLT_Utils_EmailTemplates.upsertPersonalizedEmailTemplate(body);
    }

    public Object retrieveGet(Map<String, String> params){
        Decimal versionNum = params.containsKey('versionNum') ? Decimal.valueOf(params.get('versionNum')) : 0;
        String emailLanguage = Test.isRunningTest() ? 'EN;' : 'EN;' + CLT_Utils.getMyUser().Email_templates__c;
        list<String> emailLanguages = emailLanguage.split('\\;');
        system.debug('emailLanguages: ' + emailLanguages);
        Map<String, CLT_FieldsMapping__mdt> fieldsMapping = CLT_Utils_Mapping.getMappingObjectDict('EmailTemplate', 'EmailTemplate', 'SFFieldPath__c');
        system.debug('fieldsMapping :' + fieldsMapping);

        if(versionNum >= 2.13) {
            
            Map<String, Object> userCategoriesMap = CLT_Utils_EmailTemplates.getUserCategoriesMap('Other');
            String defaultCategory = (String)userCategoriesMap.get('Default');
            userCategoriesMap.remove('Default');

            return new Map<String, Object> {
                'personalEmailTemplates' => CLT_Utils_EmailTemplates.getPersonalEmailTemplates(userCategoriesMap, defaultCategory),
                'emailTemplates' => CLT_Utils_EmailTemplates.getEmailTemplatesV2(emailLanguages, userCategoriesMap, defaultCategory),
                'sharingTemplates' => CLT_Utils_EmailTemplates.getSharingTemplates(emailLanguages, fieldsMapping)
            };
        }
        else {
            return new Map<String, Object> {
                'emailTemplates' => CLT_Utils_EmailTemplates.getEmailTemplates(emailLanguages),
                'sharingTemplates' => CLT_Utils_EmailTemplates.getSharingTemplates(emailLanguages, fieldsMapping)
            };
        }
    }

    

    

    

    
}