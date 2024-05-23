/* @author Paul Louis MONY
 * @date May,15th 2024
 * @Type Apex Class 
 *****************************************************************************************************************************************************************
 * @description : This Scalable Vector Extension deal with ClientBooking Record througout the Triggers
 * 
 ***************************************************************************************************************************************************************** 
 * 0.0      |2024/05/15         |.PLM       |.SFMC-425          |.Original Version
*/
public without sharing class ClientBooking_SVE {
    public static void manageAppointment(List<SObject> clientBookings){
        List<ClientBooking__c> ClientBookings_LocaleDateTimeEmpty = new List<ClientBooking__c> ();
        for(ClientBooking__c ClientBooking : (List<ClientBooking__c>) clientBookings){
            if(!ClientBooking.isSet(ClientBooking__c.LocaleDateTime__c)) 
                ClientBookings_LocaleDateTimeEmpty.add(ClientBooking);
        }
        manageAppointmentLocaleDateTime(ClientBookings_LocaleDateTimeEmpty);
    }
    public static void manageAppointment(Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        manageAppointmentLocaleDateTime(filterOnUpdatedAppointmentDate(newItems,oldItems));
    }
    public static void manageAppointmentLocaleDateTime(List<ClientBooking__c> clientBookings){
        for(ClientBooking__c clientBooking : clientBookings){
            clientBooking.LocaleDateTime__c = AP4_DateTimeHelper.getDateTimeByTimeZone(clientBooking.StartsOn__c,clientBooking.TimeZone__c);
        }
    }
    private static List<ClientBooking__c> filterOnUpdatedAppointmentDate (Map<Id, SObject> newItems, Map<Id, SObject> oldItems){
        List<ClientBooking__c> clientBookingUpdated = new List<ClientBooking__c>();
        for(sObject obj : newItems.values()){
            ClientBooking__c newClientBooking = (ClientBooking__c) obj;
            ClientBooking__c oldClientBooking = (ClientBooking__c) oldItems.get(newClientBooking.Id);
            if(
                newClientBooking.StartsOn__c != oldClientBooking.StartsOn__c ||
                newClientBooking.TimeZone__c != oldClientBooking.TimeZone__c
            )
            clientBookingUpdated.add(newClientBooking);
        }
        return clientBookingUpdated;
    }
}