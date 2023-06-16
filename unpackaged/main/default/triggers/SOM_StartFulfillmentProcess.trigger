trigger SOM_StartFulfillmentProcess on Start_Fulfillment_Process__e (after insert) {
    SOM_StartFulfillmentProcessHelper.startFulfillmentProcess(trigger.new);
}