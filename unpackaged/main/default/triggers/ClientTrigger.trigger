trigger ClientTrigger on Account (before insert, before update) {
    if (Trigger.isInsert) {
        CLT_Utils_ClientTrigger.updateTargetedCustomersCAreattributionDate(Trigger.new, new Map<Id, Account>());
        CLT_Utils_ClientTrigger.updateTargetedCAreattributionContactDate(Trigger.new, new Map<Id, Account>());
    }

    if (Trigger.isUpdate) {
        CLT_Utils_ClientTrigger.updateTargetedCustomersCAreattributionDate(Trigger.new, Trigger.oldMap);
        CLT_Utils_ClientTrigger.updateTargetedCAreattributionContactDate(Trigger.new, Trigger.oldMap);
    }
}