trigger TaskTrigger on Task(after insert, before insert, after update, before update) {

    if (Trigger.isInsert && Trigger.isAfter) {
        CLT_Utils_TaskTrigger.updateLastContactDate(Trigger.new);
        CLT_Utils_TaskTrigger.updateRelatedClientListMembersStatus(Trigger.new);
    }

    if (Trigger.isUpdate && Trigger.isAfter) {
        CLT_Utils_TaskTrigger.updateLastContactDate(Trigger.new);
        CLT_Utils_TaskTrigger.updateRelatedClientListMembersStatus(Trigger.new);
    }

    if (Trigger.isInsert && Trigger.isBefore) {
        CLT_Utils_TaskTrigger.updateRelatedProductDetails(Trigger.new);
        CLT_Utils_TaskTrigger.updateENOutreachReason(Trigger.new, new Map<Id, Task>());
    }

    if (Trigger.isUpdate && Trigger.isBefore) {
        CLT_Utils_TaskTrigger.updateRelatedProductDetails(Trigger.new);
        CLT_Utils_TaskTrigger.updateENOutreachReason(Trigger.new, Trigger.oldMap);
    }
}