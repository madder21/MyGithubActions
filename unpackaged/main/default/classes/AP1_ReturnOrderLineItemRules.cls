public with sharing class AP1_ReturnOrderLineItemRules {
    public static void canUpdateReturnOrderLineItemConditionId(Map<ID, ReturnOrderLineItem> oldMap, Map<ID, ReturnOrderLineItem> newMap){
        Map<Id, ReturnOrderLineItem> roLineItems = new Map<Id, ReturnOrderLineItem>([SELECT Id, ReturnOrder.Status FROM ReturnOrderLineItem WHERE Id IN :oldMap.keySet()]); 
        for(ID roItemId:newMap.keySet()) {
            if (oldMap.get(roItemId).ConditionId__c != newMap.get(roItemId).ConditionId__c 
                && roLineItems.get(roItemId).ReturnOrder.Status != SOM_Constants.RETURN_ORDER_STATUS_RECEIVED) {
                newMap.get(roItemId).addError(SOM_Constants.RETURN_ORDER_CONDITIONID_ERROR_MESSAGE);
            }
        }
    }
}