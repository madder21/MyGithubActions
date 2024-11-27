@isTest
private class CLT_Utils_NoteTrigger_Test {
    @TestSetup
    static void prepareTestData(){
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
		Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test client 1', 'Test Last Name1', sa.Id, store.Id, true);
    }

    @isTest
    static void testCreateNoteHistories_Insert() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1' LIMIT 1];

        System.runAs(sa) {
            Note__c note = new Note__c(
                Name = 'Test Name',
                Client__c = client.Id,
                Body__c = 'Test Body'
            );
            Test.startTest();
            insert note;
            Test.stopTest();
        }

        List<Note_History__c> noteHistoryList = [SELECT Id
                                                FROM Note_History__c 
                                                WHERE Note__r.Client__c = :client.Id AND ModifiedBy__c = :sa.Id];

        System.assertEquals(2, noteHistoryList.size(), 'Note histories list is not 2 when inserting with 2 fields filled');
    }

    @isTest
    static void testCreateNoteHistories_Update() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1' LIMIT 1];

        Note__c note = new Note__c(
            Name = 'Test Name',
            Client__c = client.Id,
            Body__c = 'Test Body'
        );
        insert note;

        System.runAs(sa) {
            note.Name = 'Test Name Updated';
            note.Body__c = 'Test Body Updated';
            Test.startTest();
            update note;
            Test.stopTest();
        }

        List<Note_History__c> noteHistoryList = [SELECT Id
                                                FROM Note_History__c 
                                                WHERE Note__r.Client__c = :client.Id AND ModifiedBy__c = :sa.Id];

        System.assertEquals(2, noteHistoryList.size(), 'Note histories list is not 2 when updating 2 fields values by the SA');
    }

    @isTest
    static void testPopulateHashtageFromNote_Create() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1' LIMIT 1];

        System.runAs(sa) {
            Note__c note = new Note__c(
                Name = 'Test Hashtag Note Create',
                Client__c = client.Id,
                Body__c = '#Test note with #hashtag, # #create!'
            );
            Test.startTest();
            insert note;
            Test.stopTest();
        }

        Note__c insertedNote = [SELECT Hashtags__c FROM Note__c WHERE Name = 'Test Hashtag Note Create' LIMIT 1];

        System.assertEquals('#Test#hashtag#create!#', insertedNote.Hashtags__c, 'Hashtag of inserted note is not #Test#hashtag#create');
    }

    @isTest
    static void testPopulateHashtageFromNote_Update() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test client 1' AND LastName = 'Test Last Name1' LIMIT 1];

        Note__c note = new Note__c(
            Name = 'Test Hashtag Note Update',
            Client__c = client.Id,
            Body__c = 'Test Body no Hashtag'
        );
        insert note;

        System.runAs(sa) {
            note.Body__c = '#Test note with #hashtag, # #update!';
            Test.startTest();
            update note;
            Test.stopTest();
        }

        Note__c updatedNote = [SELECT Hashtags__c FROM Note__c WHERE Name = 'Test Hashtag Note Update' LIMIT 1];

        System.assertEquals('#Test#hashtag#update!#', updatedNote.Hashtags__c, 'Hashtag of updated note is not #Test#hashtag#update');
    }
}