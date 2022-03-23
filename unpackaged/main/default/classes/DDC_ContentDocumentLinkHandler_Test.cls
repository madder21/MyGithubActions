@isTest
private with sharing class DDC_ContentDocumentLinkHandler_Test {

    private static testMethod void test_shareTranslationsDocuments() {
        BL_Translation__c translation = new BL_Translation__c(Language__c = 'fr');
        insert translation;
        ContentDocumentLink docLink = new ContentDocumentLink(LinkedEntityId = translation.Id);
        List<ContentDocumentLink> docLinks = new List<ContentDocumentLink> { docLink };
        DDC_ContentDocumentLinkHandler.shareTranslationsDocuments(docLinks);
        System.assertEquals('V', docLink.ShareType);
        System.assertEquals('AllUsers', docLink.Visibility);
    }
}