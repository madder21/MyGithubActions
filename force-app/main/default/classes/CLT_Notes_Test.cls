/*
 * Created by Israel Zygelboim on 11/02/2019.
 */
@IsTest
private class CLT_Notes_Test {

    @TestSetup
    static void prepareTestData(){
        User sa = CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        Store__c store = CLT_TestDateFactory.createTestStore('TST123', true);
        Account client = CLT_TestDateFactory.createTestClient('Test First Name', 'Test Last Name', sa.Id, store.Id, true);
    }

    @isTest
    static void testPostNotes() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];

        Map<String,Object> notesObjToInsert = new Map<String,Object>();
        notesObjToInsert.put('isPrivate', false);
        notesObjToInsert.put('client', client.Id);
        notesObjToInsert.put('body', 'Test Note Body!');
        notesObjToInsert.put('name', 'Test Note Name!');

        Map<String,Object> body = new Map<String,Object>();
        body.put('objectName', 'Note__c');
        body.put('items', new List<Object> {notesObjToInsert});

        System.runAs(sa) {
            CLT_Notes cltNotes = new CLT_Notes();
            
            Test.startTest();
            cltNotes.retrievePost(new Map<String, String>(), body);
            Test.stopTest();

            List<Note__c> insertedNoteWS = [SELECT Id FROM Note__c WHERE Client__c = :client.Id AND CreatedById = :sa.Id];
            System.assertEquals(1, insertedNoteWS.size(), 'note list size is not 1 after insert');
        }
    }

    @isTest
    static void testGetNotes() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        System.runAs(sa) {
            Test.startTest();
            CLT_Notes cltNotes = new CLT_Notes();

            Object cltNotesGetResponse = cltNotes.retrieveGet(new Map<String, String>());
            System.assertEquals(null, cltNotesGetResponse, 'Get method defined and not tested');

            Test.stopTest();
        }
    }

    @isTest
    static void testDeleteNotes() {
        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        Account client = [SELECT Id FROM Account WHERE FirstName = 'Test First Name' AND LastName = 'Test Last Name' LIMIT 1];

        System.runAs(sa) {
            Test.startTest();
            Note__c note = CLT_TestDateFactory.createTestNote('Test Note!', client.Id, true);

            CLT_Notes cltNotes = new CLT_Notes();
            
            Object cltNotesDeleteResponse = cltNotes.retrieveDelete(new Map<String, String>{'id' => note.Id});

            Note__c noteAfterDelete = [SELECT Id,IsDeleted__c FROM Note__c WHERE Id = :note.Id LIMIT 1];
            System.assertEquals(true, noteAfterDelete.IsDeleted__c, 'Note IsDeleted__c field is not equal to true after Delete');

            Test.stopTest();
        }
    }
}