///*
// * Created by Israel Zygelboim on 28/02/2019.
// */
public class CLT_Utils_ClientDetails {

    public static Map<String, Object> getClientFields(String clientId) {
        Map<String, Object> clients = CLT_Utils_Mapping.getStandardWrapperList('Account', 'ClientFields', 'FROM Account WHERE Id = \'' + clientId + '\'')[0];
        return clients;
    }

    public static Map<String, Object> getClientIds(String clientId) {
        Map<String, Object> clientIds = new Map<String, Object>();

        list<ClientSource__c> clientSources = [SELECT Id, SourceCode__c, Source__c FROM ClientSource__c where Client__c =: clientId];
        
        for(ClientSource__c clientSource: clientSources){
            if(clientSource.Source__c == '001'){
                clientIds.put('clientCegidId', clientSource.SourceCode__c);
            }else if(clientSource.Source__c == '002'){
                clientIds.put('clientEcomId', clientSource.SourceCode__c);
            }
        }
        
        return clientIds;
    } 
    
    public static  List<Map<String, Object>> getPurchases(String clientId){
        return CLT_Utils_Mapping.getStandardWrapperList('TransactionItem__c', 'OrderItem',
                        'FROM TransactionItem__c WHERE Transaction__r.Client__c =  \''+ clientId + '\' ORDER BY Transaction__r.TransactionDate__c DESC');
    }

    public static List<Object> getClientTimeline(String clientId) {
        List<Object> objects = new List<Object>();

        List<Object> tasks = CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task',
                        'FROM Task WHERE WhatId = \'' + clientId + '\' AND (ActivityDate >= LAST_N_YEARS:5 OR (ActivityDate = NULL AND CreatedDate >= LAST_N_YEARS:5))  ORDER BY ActivityDate, CreatedDate DESC');
        
        objects.addAll(tasks);

        List<Object> events = CLT_Utils_Mapping.getStandardWrapperList('Event', 'Event',
                        'FROM Event WHERE WhatId = \'' + clientId + '\' AND (ActivityDate >= LAST_N_YEARS:5 OR (ActivityDate = NULL AND CreatedDate >= LAST_N_YEARS:5))  ORDER BY ActivityDate, CreatedDate DESC');

        objects.addAll(events);

        List<Object> nps = CLT_Utils_Mapping.getStandardWrapperList('due__Diduenjoy_Answer__c','DiduenjoyAnswer',
                        'FROM due__Diduenjoy_Answer__c WHERE due__Diduenjoy_Feedback__r.due__Account__c = \'' + clientId + '\' ORDER BY due__Diduenjoy_Feedback__r.due__CreatedAt__c, CreatedDate DESC');
        objects.addAll(nps);

        return objects;
    }

    public static List<Map<String, Object>> getClientNotes(String clientId) {
        string userId = UserInfo.getUserId();

        return CLT_Utils_Mapping.getStandardWrapperList('Note__c','Note',
                        ' FROM Note__c WHERE Client__c = \'' + clientId + '\' ORDER BY LastModifiedDate DESC');
    }
    public static List<Map<String, Object>> getClientWishList(String clientId) {
        //string userId = UserInfo.getUserId();

        return CLT_Utils_Mapping.getStandardWrapperList('WishlistItem__c','WishListItem',
                        ' FROM WishlistItem__c WHERE Client__c = \'' + clientId + '\' AND removedItem__c = FALSE ORDER BY LastModifiedDate DESC');
    }

    public static List<Map<String, Object>> getClientAddresses(String clientId) {

        return CLT_Utils_Mapping.getStandardWrapperList('ClientAddress__c','ClientAddress',
                        ' FROM ClientAddress__c WHERE Client__c = \'' + clientId + '\' ORDER BY IsMain__c DESC');
    }
}