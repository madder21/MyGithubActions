public class CLT_Notes implements clt_retailInterface{
   
	public Object retrievePost(Map<String, String> params, Map<String, Object> body) {
		return upsertItems(body);
	}

	public Object retrieveGet(Map<String, String> params) {
		return null;
	}

	public Object retrieveDelete(Map<String, String> params) {
		String noteId = params.get('id');

		List<Note__c> notesList = [SELECT Id,IsDeleted__c FROM Note__c WHERE Id = :noteId LIMIT 1];
		if(notesList.size() > 0) {
			Note__c note = notesList[0];
			note.IsDeleted__c = true;

			update note;
			return true;
		}
		else {
			throw new BL_Exceptions.CLTException('401', 'No Note found with the receiven Id', 'No Note found with the receiven Id');
		}
    
	}

	public List<Map<String, Object>> upsertItems(Map<String,Object> body) {
		String objectName = (String) body.get('objectName');
		Store__c myStore = CLT_Utils.getMyStore();

		List<Object> items = (List<Object>) body.get('items');
		Set<String> itemIds = new Set<String>();

		List<Map<String, Object>> mapNotes = CLT_Utils_Mapping.getMapObjectsByWrapperItems(objectName, 'Note', items);
		List<Note__c> notes = (List<Note__c>) JSON.deserialize(JSON.serialize(mapNotes), List<Note__c>.class);

		for(Note__c note : notes){
            if(myStore != null ){
			note.Store__c = myStore.Id;
            }
		}

		upsert notes;

		for(Note__c item: notes) {
			itemIds.add(item.Id);
		}

		if(itemIds.size() > 0) {
			return CLT_Utils_Mapping.getStandardWrapperList('Note__c', 'Note',
							' FROM ' + objectName + ' WHERE Id IN ' + CLT_Utils.convertToString(itemIds) + ' ORDER BY CreatedDate DESC');
		}

		return null;

	}
}