/*
 * Created by Israel Zygelboim on 11/02/2019.
 */
@IsTest
private class CLT_Notes_Test {

	@IsTest static void testOne() {
		Account account = new Account(Name = 'Name');
		insert  account;

		note__c note = new note__c(Client__c = account.Id);
		insert note;

		Store__c store = new Store__c(SourceStoreId__c = CLT_Utils.getMyUser().StoreCode__c);
		insert store;

		String jsonString  = '{"items" : [{"Id" : "' + note.Id + '", "sku" : "15X7707493001l", "client":"' + account.Id + '"}], "objectName" : "note__c"}';

		CLT_Notes cltNotes = new CLT_Notes();

		cltNotes.retrieveGet(new Map<String, String>());
		cltNotes.retrievePost(new Map<String, String>(),(Map<String,Object>) JSON.deserializeUntyped(jsonString));
		cltNotes.retrieveDelete(new Map<String, String>{'id' => note.Id});
	}
}