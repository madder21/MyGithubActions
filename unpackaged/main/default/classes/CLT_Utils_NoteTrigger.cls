public with sharing class CLT_Utils_NoteTrigger {
    public static void createNoteHistories(List<Note__c> newNotes, Map<Id, Note__c> oldNotesMap) {
        List<Note_History__c> noteHistoriesToInsert = new List<Note_History__c>();
        for(Note__c note : newNotes) {
            if((!oldNotesMap.containsKey(note.Id) && (note.Body__c != null ))|| 
                (oldNotesMap.containsKey(note.Id) && note.Body__c != oldNotesMap.get(note.Id).Body__c)) {
                noteHistoriesToInsert.add(new Note_History__c (
                    Note__c = note.Id,
                    ModifiedField__c = 'Body__c',
                    NewValue__c = (note.Body__c != NULL && note.Body__c.length() > 255) ? (note.Body__c.substring(0, 251) + '...') : note.Body__c,
                    PreviousValue__c = oldNotesMap.containsKey(note.Id) ? (oldNotesMap.get(note.Id).Body__c.length() > 255 ? (oldNotesMap.get(note.Id).Body__c.substring(0, 251) + '...') : oldNotesMap.get(note.Id).Body__c) : '',
                    ModifiedBy__c = note.LastModifiedById,
                    ModifiedAt__c = note.LastModifiedDate
                ));
            }
            if((!oldNotesMap.containsKey(note.Id) && (note.Name != null ))|| 
                (oldNotesMap.containsKey(note.Id) && note.Name != oldNotesMap.get(note.Id).Name)) {
                noteHistoriesToInsert.add(new Note_History__c (
                    Note__c = note.Id,
                    ModifiedField__c = 'Name',
                    NewValue__c = note.Name,
                    PreviousValue__c = oldNotesMap.containsKey(note.Id) ? oldNotesMap.get(note.Id).Name : '',
                    ModifiedBy__c = note.LastModifiedById,
                    ModifiedAt__c = note.LastModifiedDate
                ));
            }
        }
        insert noteHistoriesToInsert;
    }

    public static void populateHashtageFromNote(List<Note__c> newNotes, Map<Id, Note__c> oldNotesMap) {
        for(Note__c note : newNotes) {
            if((!oldNotesMap.containsKey(note.Id) && !String.isEmpty(note.Body__c) && note.Body__c.contains('#')) || 
                (oldNotesMap.containsKey(note.Id) && oldNotesMap.get(note.Id).Body__c != note.Body__c && 
                ((!String.isEmpty(note.Body__c) && note.Body__c.contains('#')) || (!String.isEmpty(oldNotesMap.get(note.Id).Body__c) && oldNotesMap.get(note.Id).Body__c.contains('#'))))) {
                String hashtags = '';
                String body = note.Body__c;
                while (!String.isEmpty(body)) {
                    body = body.substringAfter('#');
                    String hashtag = substringBeforeFirstSeparator(body);
                    if(!String.isEmpty(hashtag)){
                        hashtags += '#' + hashtag;
                        body = body.substringAfter(hashtag);
                    }
                }
                note.Hashtags__c = hashtags.length() > 0 ? hashtags + '#' : hashtags;
            }
        }
    }

    public static String substringBeforeFirstSeparator(String body) {
        List<String> separators = new List<String>{' ', ',', '.', ';', '/'};

        if (String.isBlank(body)) {
            return null;
        }

        Integer indexOfFirst = body.length();
        for (String separator : separators) {
            Integer index = body.indexOf(separator);
            if (index >= 0 && index < indexOfFirst) {
                indexOfFirst = index;
            }
        }

        return body.substring(0, Math.min(indexOfFirst, body.length()));
    }
}