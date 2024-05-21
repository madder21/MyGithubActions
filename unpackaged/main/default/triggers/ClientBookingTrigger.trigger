/* @author Paul Louis MONY
 * @date May,15th 2024
 * @Type Apex Trigger Class 
 *****************************************************************************************************************************************************************
 * @description : This Trigger is fired for any events of the CLientBooking__c
 *  
 ***************************************************************************************************************************************************************** 
 * 0.0      |2024/05/15         |.PLM       |.          |.Original Version
*/
trigger ClientBookingTrigger on ClientBooking__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    TriggerDispatcher.run(new ClientBookingTriggerHandler(), Trigger.operationType);
}