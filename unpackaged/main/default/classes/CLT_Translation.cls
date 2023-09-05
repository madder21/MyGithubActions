public class CLT_Translation implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }

    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return null;
    }

    public Object retrieveGet(Map<String, String> params){
        String targetApplication = params.containsKey('target') ? (String)params.get('target') : 'CLT';
        return getLanguageData(targetApplication, UserInfo.getLanguage());
    }

    private Object getLanguageData(String targetApplication, String language){
        List<BL_Translation__c> trans = [SELECT Id 
                                    FROM BL_Translation__c 
                                    WHERE Language__c = :language AND Target__c = :targetApplication];
 
        Utils.addCustomHeader('QUERY','SELECT Id FROM BL_Translation__c WHERE Language__c = ' + language + ' AND Target__c = ' + targetApplication,RestContext.request);
 
        string transId;
        if(trans.size() > 0) {
            transId = trans[0].Id;
        }
        else {
            List<BL_Translation__c> defaultTrans = [SELECT Id FROM BL_Translation__c WHERE Language__c = 'en_US' AND Target__c = :targetApplication];
            if(defaultTrans.size() > 0) {
                transId = defaultTrans[0].Id;
            }
            else {
                throw new TranslationException(
                    'No default en_US translation with target = \'' + targetApplication + '\' were found.'
                    );
            }
        }

        List<ContentDocumentLink> contentDocs = [
            SELECT ContentDocumentId,Id,LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :transId
        ];

        if(contentDocs.size() >= 0) {
            List<ContentVersion> contentVersions = [
                SELECT IsLatest,versionData,ContentDocumentId
                FROM ContentVersion
                WHERE IsLatest=true AND ContentDocumentId = :contentDocs[0].ContentDocumentId
            ];

            return contentVersions[0].versionData.toString();
        }
        else {
            throw new TranslationException(
                'No default contentDoc attached to translation: ' + transId
            );
        }
    }

    public class TranslationException extends Exception {
    }
}