public class CLT_Notes implements clt_retailInterface{
   
	public Object retrievePost(Map<String, String> params, Map<String, Object> body) {
		return upsertItems(body);
	}

	public Object retrieveGet(Map<String, String> params) {
		return null;
	}

	public Object retrieveDelete(Map<String, String> params) {
		string objName = params.get('objectName');

		sobject note = new Note__c();
		note.Id = params.get('id');

		delete note;
		return true;
    
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