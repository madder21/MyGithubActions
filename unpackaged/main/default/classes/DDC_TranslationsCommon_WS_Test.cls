@isTest
private with sharing class DDC_TranslationsCommon_WS_Test {

    private static testMethod void test_getLanguageData() {
        // prepare data
        BL_Translation__c translation = new BL_Translation__c(Language__c = 'fr', Target__c = 'DDC');
        insert translation;
        ContentVersion docVersion = new ContentVersion(
            Title = 'test', 
            VersionData = Blob.valueOf('{ "shit": "merde" }'),
            PathOnClient = 'test');
        insert docVersion;
        docVersion = [select Id, ContentDocumentId from ContentVersion where Id = :docVersion.Id];
        ContentDocumentLink docLink = new ContentDocumentLink(
            LinkedEntityId = translation.Id, 
            ContentDocumentId = docVersion.ContentDocumentId);
        insert docLink;

        // test ws
        Map<String,String> pathParameters = new Map<String,String> { 'langCode' => 'fr' };
        DDC_TranslationsCommon_WS ws = new DDC_TranslationsCommon_WS();
        Map<String,Object> common = (Map<String,Object>) ws.executeGET(pathParameters, null);
        String value = (String) common.get('shit');
        System.assertEquals('merde', value);

        pathParameters.put('langCode', 'none');
        try {
            common = (Map<String,Object>) ws.executeGET(pathParameters, null);
        } catch (DDC_TranslationsCommon_WS.TranslationException ex) {}
    }
}