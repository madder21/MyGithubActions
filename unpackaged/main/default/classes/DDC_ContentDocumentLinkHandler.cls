public with sharing class DDC_ContentDocumentLinkHandler {

    private static final String TRANSLATION_OBJECT_NAME = 'BL_Translation__c';

    public static void shareTranslationsDocuments(List<ContentDocumentLink> docLinks) {
        for (ContentDocumentLink docLink : docLinks) {
            Schema.SObjectType objType = docLink.LinkedEntityId.getSObjectType();
            String objName = objType.getDescribe().getName();
            if (objName == TRANSLATION_OBJECT_NAME) {
                docLink.ShareType = 'V';
                docLink.Visibility = 'AllUsers';
            }
        }
    }
}