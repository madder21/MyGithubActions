/**
 * @author Sarah AYOUN (Balink)
 * @date August,10 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is the trigger helper of EventTrigger for clienteling functions
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|2024/08/10 		|.Sarah A	|.				    |.original version to send silent notifications on any Event update						
*/
public class CLT_Utils_EventTrigger {
    /*
     * @METHOD 	: silentNotificationOnEventUpsert
     * @DESC 	: Sends silent notifications when new events are inserted or updated.
     * @PARAM 	: newEvents : List<Event> : List of new or updated Event records.
     * @RETURN 	: void
     */
    public static void silentNotificationOnEventUpsert(List<Event> newEvents) {
        Set<String> usersToNotify = new Set<String>();
        for(Event event : newEvents) {
            if(!usersToNotify.contains(event.OwnerId)) {
                usersToNotify.add(event.OwnerId);
            }
        }
        CLT_SendSilentPushNotifications.sendSilentNotifications(usersToNotify, CLT_SendSilentPushNotifications.SILENT_AGENDA_TYPE, CLT_SendSilentPushNotifications.SILENT_AGENDA_DELTA_SUBTYPE);
    }

    /*
     * @METHOD 	: silentNotificationOnEventAssignmentUpdate
     * @DESC 	: Sends silent notifications when event ownership is reassigned.
     * @PARAM 	: newEvents : List<Event> : List of new or updated Event records, oldEventsMap : Map<Id, Event> : Map of old Event records, keyed by their IDs.
     * @RETURN 	: void
     */
    public static void silentNotificationOnEventAssignmentUpdate(List<Event> newEvents, Map<Id, Event> oldEventsMap) {
        Map<String, List<String>> userDeleteRecordsNotifMap = new Map<String, List<String>>();
        for(Event event : newEvents) {
            if(oldEventsMap.containsKey(event.Id) && event.OwnerId != (oldEventsMap.get(event.Id)).OwnerId) {
                if(!userDeleteRecordsNotifMap.containsKey((oldEventsMap.get(event.Id)).OwnerId)) {
                    userDeleteRecordsNotifMap.put((oldEventsMap.get(event.Id)).OwnerId, new List<String>());
                }
                userDeleteRecordsNotifMap.get((oldEventsMap.get(event.Id)).OwnerId).add(event.Id);
            }
        }
        if(userDeleteRecordsNotifMap.keySet().size() > 0) {
            CLT_SendSilentPushNotifications.sendSilentNotifications(userDeleteRecordsNotifMap, CLT_SendSilentPushNotifications.SILENT_AGENDA_TYPE, CLT_SendSilentPushNotifications.SILENT_AGENDA_DELETE_SUBTYPE);
        }
    }
}