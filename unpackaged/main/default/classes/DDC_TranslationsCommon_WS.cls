// /services/apexrest/ddc/v0/translations/{lng}/common
public with sharing class DDC_TranslationsCommon_WS implements BL_Rest_Router_Factory.DispatchableGET {
    
    private class TranslationException extends Exception {}

    private static final Map<String,String> LANG_CODES = new Map<String,String> {
        'zh-Hans' => 'zh_CN',
        'zh-Hant' => 'zh_TW',
        'en-GB'   => 'en_GB',
        'en-US'   => 'en_US',
        'pt-BR'   => 'pt_BR',
        'pt'      => 'pt_BR'
    };

    private static final String DEFAULT_LANG_CODE = 'en';

    public Object executeGET(Map<String, String> pathParameters, Map<String, String> queryParams) {
        return getLanguageData(pathParameters.get('langCode'));
    }

    /*public Object executePOST(Map<String, String> pathParameters, Map<String, String> queryParams, Map<String, Object> bodyMap) {
        String content = JSON.serializePretty(bodyMap);
        return updateTranslation(pathParameters.get('langCode'), content);
    }*/

    /*
     * Gets JSON content from attached file of Translation__c record
     * for Site user: Check "Customer Access" on the specific file sharing screen
     */
    @TestVisible
    private Object getLanguageData(String langCode) {
        System.debug('getLanguageData: langCode: ' + langCode);
        if (LANG_CODES.containsKey(langCode)) {
            langCode = LANG_CODES.get(langCode);
        }
        List<BL_Translation__c> translations = [SELECT Id, Language__c FROM BL_Translation__c 
                WHERE Target__c = 'DDC' AND (Language__c =:langCode OR Language__c = :DEFAULT_LANG_CODE)];
        if (translations.isEmpty()) {
            Schema.DescribeSObjectResult describe = BL_ObjectDescriber.getObjectDescribe('BL_Translation__c');
            if (!describe.isAccessible()) {
                throw new TranslationException('Missing permission for translations');
            }
            throw new TranslationException('No translation for language: ' + langCode);
        }
        String transId = translations[0].Id;
        if (langCode != DEFAULT_LANG_CODE && translations.size() > 1 && translations[0].Language__c == DEFAULT_LANG_CODE) {
            transId = translations[1].Id;
        }
        Blob content = getFileContent(transId);
        if (content == null) {
            throw new TranslationException('No translation file for language: ' + langCode);
        }
        return Json.deserializeUntyped(content.toString());
    }

    private Blob getFileContent(String parentId) {
        List<ContentDocumentLink> contDocLinks = [SELECT ContentDocumentId,Id,LinkedEntityId 
                FROM ContentDocumentLink WHERE LinkedEntityId=:parentId];
        if (contDocLinks.isEmpty()) {
            return null;
        }
        string contentDocId = contDocLinks[0].ContentDocumentId;
        blob fileData = [SELECT IsLatest,versionData FROM ContentVersion WHERE IsLatest=true AND ContentDocumentId =:contentDocId].versionData;
        return fileData;
    }

    /*private static String updateTranslation(String langCode, String content) {
        if (LANG_CODES.containsKey(langCode)) {
            langCode = LANG_CODES.get(langCode);
        }
        List<BL_Translation__c> records = [SELECT Id from BL_Translation__c
            WHERE Target__c = 'DDC' AND Language__c = :langCode];

        if (records.isEmpty()) {
            Schema.DescribeSObjectResult describe = BL_ObjectDescriber.getObjectDescribe('BL_Translation__c');
            if (!describe.isAccessible()) {
                throw new TranslationException('Missing permission for translations');
            }
            throw new TranslationException('No translation for language: ' + langCode);
        }
        
        Id recordId = records[0].Id;
        BL_EditTranslationCtrl.saveTranslationContent(recordId, content);
        return recordId;
    }*/
}