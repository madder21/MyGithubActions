public with sharing class BL_EditTranslationCtrl {

    @AuraEnabled(cacheable=true)
    public static String getTranslationContent(Id recordId) {
        ContentVersion contVer = getContentVersion(recordId);
        if (contVer != null) {
            return contVer.versionData.toString();
        }
        return '';
    }

    @AuraEnabled
    public static void saveTranslationContent(Id recordId, String content) {
        try {
            ContentVersion contVer = getContentVersion(recordId);
            if (contVer != null) {
                contVer.VersionData = Blob.valueOf(content);
                update contVer;
            } else {
                createNewFile(recordId, content);
            }
        } catch (Exception ex) {
            System.debug('Exception: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void addRowsToTranslations(String target, Map<String,String> valuesMap) {
        List<Translation> translations = getTranslations(target);
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Translation translation : translations) {
            translation.addRows(valuesMap);
            if (translation.isDirty) {
                contentVersions.add(translation.contentVersion);
            }
        }
        update contentVersions;
    }

    /*
     * Removes entries from all translations
     * @param target - target field in translation (like "ddc")
     * @param keys - list of keys to remove
     */
    @AuraEnabled
    public static void removeRowsFromTranslations(String target, List<String> keys) {
        List<Translation> translations = getTranslations(target);
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Translation translation : translations) {
            translation.removeRows(keys);
            if (translation.isDirty) {
                contentVersions.add(translation.contentVersion);
            }
        }
        update contentVersions;
    }

    /*
     * Replace keys for all translations for same target
     * @param target - filter by Target field in translation (e.g. "DDC")
     * @param keysMap - old key => new key
     * Keeps the original labels
     * E.g.: before:
     *      "old.key": "some value"
     *      after:
     *      "new.key": "some value"
     */
    @AuraEnabled
    public static void replaceKeysInTranslations(String target, Map<String,String> keysMap) {
        List<Translation> translations = getTranslations(target);
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Translation translation : translations) {
            translation.replaceKeys(keysMap);
            if (translation.isDirty) {
                contentVersions.add(translation.contentVersion);
            }
        }
        update contentVersions;
    }

    /*
     * Replaces texts in all labels of all translations for specific target
     * @param target - filter by Target field in translation (e.g. "DDC")
     * @param keysMap - old key => new key
     * E.g.: before:
     *      "some.key": "Value with merge {oldParam} text"
     *  after:
     *      "some.key": "Value with merge {newParam} text"
     */
    public static void replaceTextsInTranslations(String target, Map<String,String> keysMap, Set<String> restriceToKeys) {
        List<Translation> translations = getTranslations(target);
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        for (Translation translation : translations) {
            translation.replaceTexts(keysMap, restriceToKeys);
            if (translation.isDirty) {
                contentVersions.add(translation.contentVersion);
            }
        }
        update contentVersions;
    }

    @AuraEnabled
    public static String printTranslations(String target) {
        List<Translation> translations = getTranslations(target);
        String str = '';
        for (Translation translation : translations) {
            str += Json.serializePretty(translation.record) + '\n' +
                        translation.getContent() + '\n\n';
        }
        return str;
    }

    private static ContentVersion getContentVersion(Id parentId) {
        Set<Id> ids = new Set<Id> { parentId };
        Map<Id,ContentVersion> contentVersionsMap = getContentVersions(ids);
        if (!contentVersionsMap.isEmpty()) {
            return contentVersionsMap.get(parentId);
        }
        return null;
    }

    /*
     * Gets ContentVersion of files related to parent ids
     */
    private static Map<Id,ContentVersion> getContentVersions(Set<Id> parentIds) {
        Map<Id,ContentVersion> contentVersionsMap = new Map<Id,ContentVersion>();

        List<ContentDocumentLink> docLinks = [SELECT ContentDocumentId,Id, LinkedEntityId 
            FROM ContentDocumentLink WHERE LinkedEntityId IN :parentIds];
        if (docLinks.isEmpty()) {
            return contentVersionsMap;
        }
        // collect document ids
        Set<Id> contentDocumentIds = new Set<Id>();
        Map<Id,Id> docIdToRecordIdMap = new Map<Id,Id>();  // doc id => record id
        for (ContentDocumentLink docLink : docLinks) {
            contentDocumentIds.add(docLink.ContentDocumentId);
            docIdToRecordIdMap.put(docLink.contentDocumentId, docLink.LinkedEntityId);
        }
        // retrieve content versions
        List<ContentVersion> contentVersions = 
            [SELECT IsLatest, versionData, ContentDocumentId 
            FROM ContentVersion 
            WHERE IsLatest=true AND ContentDocumentId IN :contentDocumentIds];
        
        // build map: record id => content version
        for (ContentVersion contentVersion : contentVersions) {
            Id recordId = docIdToRecordIdMap.get(contentVersion.contentDocumentId);
            contentVersionsMap.put(recordId, contentVersion);
        }
        return contentVersionsMap;
    }

    @TestVisible
    private static ContentVersion createNewFile(Id recordId, String content) {
        BL_Translation__c record = [SELECT Id, Language__c FROM BL_Translation__c
            WHERE Id = :recordId];
        
        Boolean isJson = false;
        try {
            Json.deserializeUntyped(content);
            isJson = true;
        } catch (Exception ex) {
            isJson = false;
        }

        // create file
        String title = 'BL_Translation';
        if (String.isNotEmpty(record.Language__c)) {
            title += '_' + record.Language__c.toUpperCase();
        }
        ContentVersion contVer = new ContentVersion(
            ContentLocation = 'S',
            VersionData = Blob.valueOf(content),
            Title = title,
            PathOnClient = title + (isJson ? '.json' : '.txt'),
            IsMajorVersion = false  // so VersionData can be replaced
        );
        insert contVer;

        // reload ContentVersion to get ContentDocument id
        contVer = [SELECT ContentDocumentId, VersionData from ContentVersion WHERE Id = :contVer.Id];

        // link file to record
        ContentDocumentLink contDocLink = new ContentDocumentLink(
            ContentDocumentId = contVer.ContentDocumentId,
            LinkedEntityId = recordId,
            ShareType = 'V'
        );
        insert contDocLink;

        return contVer;
    }

    private static List<Translation> getTranslations(String target) {
        // get translations records
        List<BL_Translation__c> records = 
            [SELECT Id, Name, Target__c, Language__c FROM BL_Translation__c
            WHERE Target__c = :target];
        // collect ids
        Set<Id> recordIds = new Set<Id>();
        for (BL_Translation__c record : records) {
            recordIds.add(record.Id);
        }
        // get content versions
        Map<Id,ContentVersion> contentVersionsMap = getContentVersions(recordIds);
        
        List<Translation> translations = new List<Translation>();
        for (BL_Translation__c record : records) {
            Translation translation = new Translation(record, contentVersionsMap.get(record.Id));
            translations.add(translation);
        }
        return translations;
    }


    public class Translation {
        public BL_Translation__c record;
        public ContentVersion contentVersion;
        public Boolean isDirty;

        public Translation(BL_Translation__c record, ContentVersion contentVersion) {
            this.record = record;
            this.contentVersion = contentVersion;
            this.isDirty = false;
        }

        public Id getRecordId() {
            if (record != null) {
                return record.Id;
            }
            return null;
        }

        private String getContent() {
            if (contentVersion != null && contentVersion.VersionData != null) {
                return contentVersion.VersionData.toString();
            }
            return null;
        }

        private void setContent(String content) {
            if (contentVersion != null) {
                contentVersion.versionData = Blob.valueOf(content);
            }
        }

        public void addRows(Map<String,String> valuesMap) {
            Map<String,String> labelsMap = getLabelsMap();
            if (labelsMap != null) {
                Boolean hasChanged = false;
                for (String key : valuesMap.keySet()) {
                    if (!labelsMap.containsKey(key)) {
                        labelsMap.put(key, valuesMap.get(key));
                        hasChanged = true;
                    }
                }
                if (hasChanged) {
                    setContent(Json.serializePretty(labelsMap));
                    isDirty = true;
                }
            }
        }

        public void removeRows(List<String> keys) {
            Map<String,String> labelsMap = getLabelsMap();
            if (labelsMap != null) {
                Boolean hasChanged = false;
                for (String key : keys) {
                    if (labelsMap.containsKey(key)) {
                        labelsMap.remove(key);
                        hasChanged = true;
                    }
                }
                if (hasChanged) {
                    setContent(Json.serializePretty(labelsMap));
                    isDirty = true;
                }
            }
        }

        public void replaceKeys(Map<String,String> keysMap) {
            Map<String,String> labelsMap = getLabelsMap();
            if (labelsMap != null) {
                Boolean hasChanged = false;
                for (String oldKey : keysMap.keySet()) {
                    if (labelsMap.containsKey(oldKey)) {
                        String newKey = keysMap.get(oldKey);
                        String value = labelsMap.get(oldKey);
                        labelsMap.put(newKey, value);
                        labelsMap.remove(oldKey);
                        hasChanged = true;
                    }
                }
                if (hasChanged) {
                    setContent(Json.serializePretty(labelsMap));
                    isDirty = true;
                }
            }
        }

        public void replaceValue(String key, String newValue) {
            replaceValue(key, newValue, null);
        }

        public void replaceValue(String key, String newValue, String restrictOldValue) {
            Map<String,String> labelsMap = getLabelsMap();
            if (labelsMap != null) {
                Boolean hasChanged = false;
                if (labelsMap.containsKey(key)) {
                    String oldValue = labelsMap.get(key);
                    if (oldValue != newValue && 
                        (String.isEmpty(restrictOldValue) || oldValue == restrictOldValue))
                    {
                        labelsMap.put(key, newValue);
                        hasChanged = true;
                    }
                }
                if (hasChanged) {
                    setContent(Json.serializePretty(labelsMap));
                    isDirty = true;
                }
            }
        }

        /*
         * Replaces any text within values with replacement
         * Is useful to change vars like "{firstName}"
         */
        public void replaceTexts(Map<String,String> textsMap, Set<String> restriceToKeys) {
            Map<String,String> labelsMap = getLabelsMap();
            if (labelsMap == null) {
                return;
            }

            Boolean hasChanged = false;
            for (String key : labelsMap.keySet()) {
                if (restriceToKeys.isEmpty() || restriceToKeys.contains(key)) {
                    String oldLabel = labelsMap.get(key);
                    String newLabel = oldLabel;
                    for (String target : textsMap.keySet()) {
                        String replacement = textsMap.get(target);
                        while (newLabel.contains(target)) {
                            newLabel = newLabel.replace(target, replacement);
                        }
                    }
                    if (newLabel != oldLabel) {
                        hasChanged = true;
                        labelsMap.put(key, newLabel);
                    }
                }
            }
            if (hasChanged) {
                setContent(Json.serializePretty(labelsMap));
                isDirty = true;
            }
        }

        @TestVisible
        private Map<String,String> getLabelsMap() {
            String content = this.getContent();
            if (String.isEmpty(content)) {
                return null;
            }
            try {
                return (Map<String,String>) Json.deserialize(content, Map<String,String>.class);
            } catch (Exception ex) {
                return null;
            }
        }
    }
}