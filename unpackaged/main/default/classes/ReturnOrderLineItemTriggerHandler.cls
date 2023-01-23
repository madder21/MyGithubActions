public with sharing class ReturnOrderLineItemTriggerHandler extends BaseTriggerHandler{

    private List<ReturnOrderLineItem> newList;
    private List<ReturnOrderLineItem> oldList;
    private Map<ID, ReturnOrderLineItem> newMap;
    private Map<ID, ReturnOrderLineItem> oldMap;

    public ReturnOrderLineItemTriggerHandler() {
        oldList = (List<ReturnOrderLineItem>)Trigger.old;
        newList = (List<ReturnOrderLineItem>)Trigger.new;
        newMap  =  (Map<ID, ReturnOrderLineItem>)Trigger.newMap;
        oldMap  = (Map<ID, ReturnOrderLineItem>)Trigger.oldMap;
    }

    protected override void beforeUpdate(){
        if(PAD.canRun(SOM_Constants.RETURN_ORDER_ITEM_TRIGGER_CONDITION_ID)){  
             AP1_ReturnOrderLineItemRules.canUpdateReturnOrderLineItemConditionId(oldMap, newMap);
        }
    }
}