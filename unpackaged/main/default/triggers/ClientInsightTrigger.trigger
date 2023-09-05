trigger ClientInsightTrigger on Client_Insight__c (after insert, after update) {
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            CLT_Utils_ClientInsightTrigger.createClientInsightHistories(trigger.new, new Map<Id, Client_Insight__c>());
        }
        if(trigger.isUpdate) {
            CLT_Utils_ClientInsightTrigger.createClientInsightHistories(trigger.new, trigger.oldMap);
        }
    }
}