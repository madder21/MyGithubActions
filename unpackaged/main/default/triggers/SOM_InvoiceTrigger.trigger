trigger SOM_InvoiceTrigger on Invoice (before update) {
    new SOM_InvoiceTriggerHandler().run();
}
