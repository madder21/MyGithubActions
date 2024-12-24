/**
 * @author (Balink)
 * @Type Apex Class
 ****************************************************************************************************************************************************************************
 * @description This class is called from R-Client App at the endpoint /retail/clientDetails and let the SA get all client details and update the insights of the client
 ****************************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 1.0		|2024/05/12			|.Sarah A	|.RCLIENT-1062	    |.add fields to returned events in getTimline				
*/
global with sharing class CLT_ClientDetail implements CLT_RetailInterface{
    
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
     
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return CLT_Utils_ClientDetails.upsertClientinsight(body);
    }   

    /*
     * @METHOD 	: retrieveGet
     * @DESC 	: GET call on /retail/clientDetails endpoint
     * @PARAM 	: params map of sent query params in the URL
     * @RETURN 	: wrapped resonse of all client details including related objects records
     */
    public Object retrieveGet(Map<String, String> params){
        String clientId = params.get('clientId');
        String contactId = CLT_Utils.getContactId(clientId);
        Map<String, Object> result = new Map<String, Object>();
        if(!String.isEmpty(contactId)){
            Map<String, Object> clientFields = CLT_Utils_ClientDetails.getClientFields(clientId);
            Map<String, Object> clientExtIdsMap = CLT_Utils_ClientDetails.getClientIds(clientId);
            clientFields.putAll(clientExtIdsMap);
            String clientCegidId = clientExtIdsMap.containsKey('clientCegidId') ? (String)clientExtIdsMap.get('clientCegidId') : '';

            result.put('clientFields', clientFields);
            result.put('clientAddresses', CLT_Utils_ClientDetails.getClientAddresses(clientId));
            result.put('purchases', CLT_Utils_ClientDetails.getPurchases(clientId));
            result.put('timelineItems', CLT_Utils_ClientDetails.getClientTimeline(clientId, clientCegidId));
            result.put('notes', CLT_Utils_ClientDetails.getClientNotes(clientId));
            result.put('clientInsights', CLT_Utils_ClientDetails.getClientInsights(clientId));
            result.put('wishlistItems', CLT_Utils_ClientDetails.getClientWishList(clientId));
            result.put('gifts', CLT_Utils_ClientDetails.getClientGifts(clientId));
            result.put('events', CLT_Utils_ClientDetails.getClientEvents(clientId));
        }
        return result;  
    }
    
}