/**
 * @author Sarah AYOUN (Balink)
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from NotificationTrigger :
 * testSetup : Creation of test user and store
 * TEST METHOD				                    |	DESCRIPTION
 * testBeforeInsertNotificationTranslations     |	Test of before insert execution of method setNotificationTranslations
 * testBeforeInsertNotificationDynamicFields     |	Test of before insert execution of method testBeforeInsertNotificationDynamicFields
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 1.0		|2024/05/23			|.Sarah A		|.						|.add of testBeforeInsertNotificationDynamicFields
*/
@isTest
private class NotificationTrigger_Test {
    @TestSetup
	static void prepareTestData() {
		User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, false);
        sa.LanguageLocaleKey = 'fr';
        insert sa;

		CLT_TestDateFactory.createTestStore('TST123', true);
	}

    @isTest
    static void testBeforeInsertNotificationTranslations() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        CLT_NotificationManagement__mdt notificationMgmt = [SELECT Id,Type__c,Subtype__c,Translation__c
                                                            FROM CLT_NotificationManagement__mdt
                                                            WHERE Type__c = 'product' AND Subtype__c = 'new'
                                                            LIMIT 1];

        Test.startTest();
		Notification__c notif = CLT_TestDateFactory.createTestNotification(notificationMgmt.Type__c, sa.Id, DateTime.now(), false);
        notif.NotificationManagementId__c = notificationMgmt.Id;
        notif.Subtype__c = notificationMgmt.Subtype__c;
        insert notif;
        Test.stopTest();

        String frName = ((Map<String, String>)JSON.deserialize(JSON.serialize(((Map<String,Object>)JSON.deserializeUntyped(notificationMgmt.Translation__c)).get('fr')), Map<String, String>.class)).get('name');

        Notification__c notifAfterInsert = [SELECT Title__c FROM Notification__c WHERE Id = :notif.Id LIMIT 1];

        System.assertEquals(frName, notifAfterInsert.Title__c, 'NotificationTrigger_Test - testBeforeInsertNotificationTranslations - title not equal to fr title');
    }

    @isTest
    static void testBeforeInsertNotificationDynamicFields() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Store__c store = [SELECT Id FROM Store__c WHERE SourceStoreId__c = :'TST123' LIMIT 1];
        Account client = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, true);

        Test.startTest();
		Notification__c notif = CLT_TestDateFactory.createTestNotification('Test', sa.Id, DateTime.now(), false);
        notif.Body__c = 'test {{clientName}}';
        notif.Client__c = client.Id;
        insert notif;
        Test.stopTest();

        Account clientAfterInsert = [SELECT Name FROM Account WHERE Id = :client.Id LIMIT 1];
        Notification__c notifAfterInsert = [SELECT Body__c FROM Notification__c WHERE Id = :notif.Id LIMIT 1];

        System.assertEquals('test ' + clientAfterInsert.Name, notifAfterInsert.Body__c, 'NotificationTrigger_Test - testBeforeInsertNotificationDynamicFields - body dynamic fields are not set correctly from trigger');
    }
}