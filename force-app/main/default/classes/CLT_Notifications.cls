/**
 * @author Sarah AYOUN (Balink)
 * @date February,12 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is called from R-Client App at the endpoint /retail/notifications and let the SA get and manage his notifications
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|2024/02/12			|.Sarah A	|.				    |.original version with CLT_RetailInterface implemented methods (retrieveDelete, retrievePost, retrieveGet) and additional methods: upsertItems and getUserNotifications						
 * 1.0		|2024/08/14			|.Sarah A	|.				    |.Add silent notifications only when they are requested						
*/
public with sharing class CLT_Notifications implements CLT_RetailInterface {
    public Object retrieveDelete(Map<String, String> params){
        return null;
    }
    
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return upsertItems(body);
    }

    public Object retrieveGet(Map<String, String> params){
        Boolean includeSilent = params.containsKey('includeSilent') ? Boolean.valueOf(params.get('includeSilent')) : false;
        return getUserNotifications(includeSilent);
    }

    /*
     * @METHOD 	: upsertItems
     * @DESC 	: Return the wrapped list of updated notifications
     * @PARAM 	: body : list of notifications with their status of seen/read update
     * @RETURN 	: List<Map<String, Object>> : wrapped list of updated notifications
     */
    public List<Map<String, Object>> upsertItems(Map<String,Object> body) {
        List<Object> items = (List<Object>) body.get('items');
		Set<String> itemIds = new Set<String>();

		List<Map<String, Object>> mapNotifications = CLT_Utils_Mapping.getMapObjectsByWrapperItems('Notification__c', 'Notification__c', items);
		List<Notification__c> notifications = (List<Notification__c>) JSON.deserialize(JSON.serialize(mapNotifications), List<Notification__c>.class);
        upsert notifications;

		for(Notification__c item: notifications) {
			itemIds.add(item.Id);
		}

		if(itemIds.size() > 0) {
			return CLT_Utils_Mapping.getStandardWrapperList('Notification__c', 'Notification__c',
							' FROM Notification__c WHERE Id IN ' + CLT_Utils.convertToString(itemIds) + ' ORDER BY CreatedDate DESC');
		}

		return null;
	}

    /*
     * @METHOD 	: getUserNotifications
     * @DESC 	: Return the list of connected user's notificatios from the last 30 days
     * @PARAM 	: includeSilent
     * @RETURN 	: list<map<string, object>> : wrapped list of user's notifications from the last 30 days
     */
    public list<map<string, object>> getUserNotifications(Boolean includeSilent){
        String notificationQuery = 'FROM Notification__c WHERE User__c = \'' + UserInfo.getUserId() + '\' AND Sent__c = TRUE AND SendingTime__c = LAST_N_DAYS:30 AND SendingTime__c <= ' + DateTime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSSXXX');
        if(!includeSilent) {
            notificationQuery += ' AND Silent__c = FALSE';
        }
        else {
            notificationQuery += ' AND (Silent__c = FALSE OR (Silent__c = TRUE AND SendingTime__c = TODAY))';
        }
        notificationQuery += ' ORDER BY SendingTime__c';
        return CLT_Utils_Mapping.getStandardWrapperList('Notification__c', 'Notification__c', notificationQuery);
    }
}