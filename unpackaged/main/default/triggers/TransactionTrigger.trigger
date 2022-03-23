trigger TransactionTrigger on Transaction__c (after insert) {
    //TransactionHandler.updateClientPurchaseDatesLastSAAndStore(trigger.new);
}