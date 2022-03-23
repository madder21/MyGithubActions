trigger DDC_ContentDocumentLinkTrigger on ContentDocumentLink (before insert, before update) {
    if (Trigger.isBefore) {
        DDC_ContentDocumentLinkHandler.shareTranslationsDocuments(Trigger.New);
    }
}