/* @author Paul Louis MONY
 * @date May,15th 2024
 * @Type Apex Trigger Handler Class 
 *****************************************************************************************************************************************************************
 * @description : This Apex class Trigger, in ClientBooking__c is handling the ClientBooking triggers
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0      |2024/05/15         |.PLM       |.SFMC-425          |.Original Version
*/
public class ClientBookingTriggerHandler implements ITriggerHandler {
    public static Boolean TriggerDisabled = false;
    public Boolean IsDisabled() {
        BypassTrigger.checkBypassClass(clientBookingTriggerHandler.class.getName());
        return TriggerDisabled;
    }

    public void BeforeInsert(List<SObject> newItems) {
        clientBooking_SVE.manageAppointment(newItems);
    }
    public void BeforeUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {
        clientBooking_SVE.manageAppointment(newItems, oldItems);
    }

    public void BeforeDelete(Map<Id, SObject> oldItems) {}
    public void AfterInsert(Map<Id, SObject> newItems) {}
    public void AfterUpdate(Map<Id, SObject> newItems, Map<Id, SObject> oldItems) {}
    public void AfterDelete(Map<Id, SObject> oldItems) {}
    public void AfterUndelete(Map<Id, SObject> oldItems) {}
}