trigger ClientListMemberTrigger on ClientListMember__c (after insert, after update) {
    if (Trigger.isInsert && Trigger.isAfter) {
        CLT_Utils_ClientListMemberTrigger.updateLastContactDate(Trigger.new, new Map<Id,ClientListMember__c>());
    }
    if (Trigger.isUpdate && Trigger.isAfter) {
        CLT_Utils_ClientListMemberTrigger.updateLastContactDate(Trigger.new, Trigger.oldMap);
    }
}