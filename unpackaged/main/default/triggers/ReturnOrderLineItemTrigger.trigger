trigger ReturnOrderLineItemTrigger on ReturnOrderLineItem (before update) {
                                                        new ReturnOrderLineItemTriggerHandler().run();        
}