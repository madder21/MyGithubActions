/**
 * @author Sarah AYOUN (Balink)
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from NotificationTrigger :
 * testSetup : Creation of test user and store
 * TEST METHOD				                    |	DESCRIPTION
 * testBeforeInsertNotificationTranslations     |	Test of befor insert execution of method setNotificationTranslations
 * testBeforeInsertNotificationDynamicFields     |	Test of befor insert execution of method testBeforeInsertNotificationDynamicFields
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 1.0		|2024/05/23			|.Sarah A		|.						|.add of testReplaceDynamicFields
*/
@isTest
private class CLT_NotificationTranslation_Utils_Test {
    @TestSetup
	static void prepareTestData() {
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        sa.LanguageLocaleKey = 'fr';
        insert sa;

		CLT_TestDateFactory.createTestStore('TST123', true);
	}

    @isTest
    static void testSetNotificationTranslations() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        CLT_NotificationManagement__mdt notificationMgmt = [SELECT Id,Type__c,Subtype__c,Translation__c
                                                            FROM CLT_NotificationManagement__mdt
                                                            WHERE Type__c = 'product' AND Subtype__c = 'new'
                                                            LIMIT 1];

		Notification__c notif = CLT_TestDateFactory.createTestNotification(notificationMgmt.Type__c, sa.Id, DateTime.now(), false);
        notif.NotificationManagementId__c = notificationMgmt.Id;
        notif.Subtype__c = notificationMgmt.Subtype__c;

        CLT_NotificationTranslation_Utils.setNotificationTranslations(new List<Notification__c>{notif});

        String frName = ((Map<String, String>)JSON.deserialize(JSON.serialize(((Map<String,Object>)JSON.deserializeUntyped(notificationMgmt.Translation__c)).get('fr')), Map<String, String>.class)).get('name');

        System.assertEquals(frName, notif.Title__c, 'CLT_NotificationTranslation_Utils_Test - testSetNotificationTranslations - title not equal to fr title');
    }

    @isTest
    static void testGetNotificationTransaltionMap() {
        CLT_NotificationManagement__mdt notificationMgmt = [SELECT Id,Type__c,Subtype__c,Translation__c
                                                            FROM CLT_NotificationManagement__mdt
                                                            WHERE Type__c = 'product' AND Subtype__c = 'new'
                                                            LIMIT 1];
                                                            
        Map<String, Map<String,String>> notificationTranslationMap = CLT_NotificationTranslation_Utils.getNotificationTransaltionMap(new List<String>{notificationMgmt.Id});
        Map<String, String> frTranslationMap = (Map<String, String>)JSON.deserialize(JSON.serialize(((Map<String,Object>)JSON.deserializeUntyped(notificationMgmt.Translation__c)).get('fr')), Map<String, String>.class);
        System.assertEquals(frTranslationMap, notificationTranslationMap.get('fr_product_new'), 'CLT_NotificationTranslation_Utils_Test - testGetNotificationTransaltionMap - fr translation map not equal to map in metadata');
    }

    @isTest
    static void testGetUsersLanguageMap() {
        User sa = [SELECT Id,LanguageLocaleKey FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        Map<String,String> userLangMap = CLT_NotificationTranslation_Utils.getUsersLanguageMap(new List<String>{sa.Id});

        System.assertEquals(sa.LanguageLocaleKey, userLangMap.get(sa.Id), 'CLT_NotificationTranslation_Utils_Test - testGetUsersLanguageMap - user language in map is not correct');
    }

    @isTest
    static void testReplaceDynamicFields() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = :'TST123' LIMIT 1];
        Account client = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, true);

        List<Notification__c> notifications = new List<Notification__c>();

		Notification__c notifNoDynamicField = CLT_TestDateFactory.createTestNotification('Test', sa.Id, DateTime.now(), false);
        notifNoDynamicField.Body__c = 'test body';
        notifNoDynamicField.Title__c = 'test title';
        notifNoDynamicField.Client__c = client.Id;
        notifications.add(notifNoDynamicField);

        Notification__c notifDynamicBody = CLT_TestDateFactory.createTestNotification('Test', sa.Id, DateTime.now(), false);
        notifDynamicBody.Body__c = 'test body {{clientName}}';
        notifDynamicBody.Title__c = 'test title';
        notifDynamicBody.Client__c = client.Id;
        notifications.add(notifDynamicBody);

        Notification__c notifDynamicTitle = CLT_TestDateFactory.createTestNotification('Test', sa.Id, DateTime.now(), false);
        notifDynamicTitle.Body__c = 'test body';
        notifDynamicTitle.Title__c = 'test title {{clientName}}';
        notifDynamicTitle.Client__c = client.Id;
        notifications.add(notifDynamicTitle);

        CLT_NotificationTranslation_Utils.replaceDynamicFields(notifications);

        String clientName = [SELECT Name FROM Account WHERE Id = :client.Id LIMIT 1].Name;

        System.assertEquals('test body', notifNoDynamicField.Body__c, 'CLT_NotificationTranslation_Utils_Test - testReplaceDynamicFields - body of notification without dynamic field is not the same as initialized');
        System.assertEquals('test body ' + clientName, notifDynamicBody.Body__c, 'CLT_NotificationTranslation_Utils_Test - testReplaceDynamicFields - body of notification with dynamic body is not updated as expected');
        System.assertEquals('test title ' + clientName, notifDynamicTitle.Title__c, 'CLT_NotificationTranslation_Utils_Test - testReplaceDynamicFields - title of notification with dynamic title is not updated as expected');
    }
}