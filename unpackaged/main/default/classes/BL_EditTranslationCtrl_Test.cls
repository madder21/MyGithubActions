@IsTest
private class BL_EditTranslationCtrl_Test {
    
    private static testMethod void test_BL_EditTranslationCtrl() {
        BL_Translation__c record = new BL_Translation__c(
            Language__c = 'EN'
        );
        insert record;

        BL_EditTranslationCtrl.saveTranslationContent(record.Id, 'test');

        String content = BL_EditTranslationCtrl.getTranslationContent(record.Id);
        System.assertEquals('test', content);
    }

    private static testMethod void test_replaceKeys() {
        BL_EditTranslationCtrl.Translation translation = createTranslation('DDC', 'EN', '{"key1": "value1"}');
        
        Map<String,String> keysMap = new Map<String,String> { 'key1' => 'key2' };
        translation.replaceKeys(keysMap);

        Map<String,String> labelsMap = translation.getLabelsMap();
        System.debug('labelsMap: ' + labelsMap);
        System.assertNotEquals(null, labelsMap);
        System.assertEquals(1, labelsMap.size());
        System.assert(!labelsMap.containsKey('key1'));
        System.assert(labelsMap.containsKey('key2'));
        System.assertEquals('value1', labelsMap.get('key2'));
        System.assert(translation.isDirty);

        BL_EditTranslationCtrl.replaceKeysInTranslations('DDC', keysMap);
    }

    private static BL_EditTranslationCtrl.Translation createTranslation(
        String target, String language, String content)
    {
        BL_Translation__c record = new BL_Translation__c(
            Target__c = target,
            Language__c = language
        );
        insert record;

        ContentVersion contentVersion = BL_EditTranslationCtrl.createNewFile(record.Id, content);

        return new BL_EditTranslationCtrl.Translation(record, contentVersion);
    }
}