trigger TaskTrigger on Task(after insert, before insert, before update) {

    if (Trigger.isInsert && Trigger.isAfter) {
        CLT_Utils_TaskTrigger.updateLastContactDate(Trigger.new);
    }

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        CLT_Utils_TaskTrigger.updateRelatedProductDetails(Trigger.new);
    }

}