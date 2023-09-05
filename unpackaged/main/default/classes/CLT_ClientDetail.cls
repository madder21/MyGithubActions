global with sharing class CLT_ClientDetail implements CLT_RetailInterface{
    
    public Object retrieveDelete(Map<String, String> params){
        return null;    
    }
     
    public Object retrievePost(Map<String, String> params, Map<String,Object> body){
        return CLT_Utils_ClientDetails.upsertClientinsight(body);
    }   

    public Object retrieveGet(Map<String, String> params){
        String clientId = params.get('clientId');
        String contactId = CLT_Utils.getContactId(clientId);
        Map<String, Object> result = new Map<String, Object>();
        if(!String.isEmpty(contactId)){
            Map<String, Object> clientFields = CLT_Utils_ClientDetails.getClientFields(clientId);
            clientFields.putAll(CLT_Utils_ClientDetails.getClientIds(clientId));

            result.put('clientFields', clientFields);
            result.put('clientAddresses', CLT_Utils_ClientDetails.getClientAddresses(clientId));
            result.put('purchases', CLT_Utils_ClientDetails.getPurchases(clientId));
            result.put('timelineItems', CLT_Utils_ClientDetails.getClientTimeline(clientId));
            result.put('notes', CLT_Utils_ClientDetails.getClientNotes(clientId));
            result.put('clientInsights', CLT_Utils_ClientDetails.getClientInsights(clientId));
            result.put('wishlistItems', CLT_Utils_ClientDetails.getClientWishList(clientId));
            result.put('gifts', CLT_Utils_ClientDetails.getClientGifts(clientId));
            result.put('events', CLT_Utils_ClientDetails.getClientEvents(clientId));
        }
        return result;  
    }
    
}