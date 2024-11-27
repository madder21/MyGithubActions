///*
// * Created by Israel Zygelboim on 28/02/2019.
// */
public class CLT_Utils_ClientDetails {
    public static Map<String, Object> upsertClientinsight(Map<String,Object> body) {
        if(body.containsKey('clientInsights')) {
            Object ciItem = body.get('clientInsights');
            Map<String, Object> clientInsightsMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(ciItem));
            Boolean isReviewedInsightsMode = false;
            if(clientInsightsMap.containsKey('isReview')) {
                isReviewedInsightsMode = (Boolean)clientInsightsMap.get('isReview');
                clientInsightsMap.remove('isReview');
            }
            String clientId = (String)clientInsightsMap.get('clientId');
            Map<String, Object> mapClientInsight = (CLT_Utils_Mapping.getMapObjectsByWrapperItems('Client_Insight__c', 'Client_Insight__c', new List<Object>{ciItem}))[0];
            mapClientInsight.put('ExternalId__c', clientId);
            Client_Insight__c clientInsight = (Client_Insight__c) JSON.deserialize(JSON.serialize(mapClientInsight), Client_Insight__c.class);

            if(isReviewedInsightsMode) {
                Map<String, String> reviewedInformationMap = new Map<String, String>();
                List<Client_Insight__c> existingCIList = [SELECT Id,ReviewedInformation__c FROM Client_Insight__c WHERE ExternalId__c = :clientId];
                if(existingCIList.size() > 0) {
                    Client_Insight__c existingCI = existingCIList[0];
                    reviewedInformationMap = !String.isEmpty(existingCI.ReviewedInformation__c) ? (Map<String,String>)JSON.deserialize(existingCI.ReviewedInformation__c, Map<String, String>.class) : new Map<String, String>();
                }
                reviewedInformationMap.put(UserInfo.getUserId(), Date.today().day() + '-' + Date.today().month() + '-' + Date.today().year());
                clientInsight.ReviewedInformation__c = JSON.serialize(reviewedInformationMap);
                clientInsight.LastReviewDate__c = Date.today();
            }

            Database.upsert(clientInsight, Client_Insight__c.ExternalId__c);

            return getClientInsights(clientId);
        }
        else {
            return new Map<String, Object>();
        }
    }

    public static Map<String, Object> getClientFields(String clientId) {
        Map<String, Object> clients = CLT_Utils_Mapping.getStandardWrapperList('Account', 'ClientFields', 'FROM Account WHERE Id = \'' + clientId + '\'')[0];
        return clients;
    }

    public static Map<String, Object> getClientIds(String clientId) {
        Map<String, Object> clientIds = new Map<String, Object>();

        list<ClientSource__c> clientSources = [SELECT Id, SourceCode__c, Source__c, SourceCreationDate__c 
                                                FROM ClientSource__c 
                                                WHERE Client__c =: clientId 
                                                ORDER BY SourceCreationDate__c ASC];
        DateTime cegidCreationDate = null;
        DateTime ecomCreationDate = null;

        for(ClientSource__c clientSource: clientSources){
            if(clientSource.Source__c == '001' && (!clientIds.containsKey('clientCegidId') 
                || (clientIds.containsKey('clientCegidId') && clientSource.SourceCreationDate__c < cegidCreationDate))){
                clientIds.put('clientCegidId', clientSource.SourceCode__c);
                cegidCreationDate = clientSource.SourceCreationDate__c;
            }else if(clientSource.Source__c == '002' && (!clientIds.containsKey('clientEcomId') 
            || (clientIds.containsKey('clientEcomId') && clientSource.SourceCreationDate__c < ecomCreationDate))){
                clientIds.put('clientEcomId', clientSource.SourceCode__c);
                ecomCreationDate = clientSource.SourceCreationDate__c;
            }
        }
        
        return clientIds;
    } 
    
    public static  List<Map<String, Object>> getPurchases(String clientId){
        return CLT_Utils_Mapping.getStandardWrapperList('TransactionItem__c', 'OrderItem',
                        'FROM TransactionItem__c WHERE Transaction__r.Client__c =  \''+ clientId + '\' ORDER BY Transaction__r.TransactionDate__c DESC');
    }

    public static List<Object> getClientTimeline(String clientId, String clientCegidId) {
        List<Object> objects = new List<Object>();

        List<Object> tasks = CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task',
                        'FROM Task WHERE AccountId = \'' + clientId + '\' ' +
                        ' AND (ActivityDate >= LAST_N_YEARS:5 OR (ActivityDate = NULL AND CreatedDate >= LAST_N_YEARS:5)) ' + 
                        ' AND (TaskType__c != \'Birthday\' OR (TaskType__c = \'Birthday\' AND (ActivityDate = NEXT_N_DAYS:3 OR ActivityDate  = TODAY))) ' +
                        '  ORDER BY ActivityDate, CreatedDate DESC');
        
        objects.addAll(tasks);

        Integer sixMonthAgoInterval = (Date.today().addMonths(-6)).daysBetween(Date.today());
        List<Map<String, Object>> events = CLT_Utils_Mapping.getStandardWrapperList('Event', 'Event',
                        'FROM Event WHERE AccountId = \'' + clientId + '\' AND (Status__c != \'Cancelled\' OR (Status__c = \'Cancelled\' AND CancelledDateTime__c = LAST_N_DAYS:' + sixMonthAgoInterval + ')) AND (ActivityDate >= LAST_N_YEARS:5 OR (ActivityDate = NULL AND CreatedDate >= LAST_N_YEARS:5))  ORDER BY ActivityDate, CreatedDate DESC');
        for(Map<String, Object> eventMap : events) {
            eventMap.put('clientCegidId', clientCegidId);
        }

        objects.addAll(events);

        List<Object> nps = CLT_Utils_Mapping.getStandardWrapperList('due__Diduenjoy_Answer__c','DiduenjoyAnswer',
                        'FROM due__Diduenjoy_Answer__c WHERE due__Diduenjoy_Feedback__r.due__Account__c = \'' + clientId + '\' ORDER BY due__Diduenjoy_Feedback__r.due__CreatedAt__c, CreatedDate DESC');
        objects.addAll(nps);

        return objects;
    }

    public static Map<String, Object> getClientInsights(String clientId) {
        Map<String, Object> clienInsightMap = new Map<String, Object>();
        List<Map<String, Object>> clienInsightMapList = CLT_Utils_Mapping.getStandardWrapperList('Client_Insight__c','Client_Insight__c', ' FROM Client_Insight__c WHERE ExternalId__c = \'' + clientId + '\'');

        DateTime lastModifiedAt = null;
        String lastModifiedById = '';
        String lastModifiedByName = '';

        if(clienInsightMapList.size() > 0){
            clienInsightMap = clienInsightMapList[0];
            
            List<Client_Insight_History__c> ciHistoriesList = [SELECT ModifiedBy__c,ModifiedBy__r.Name,ModifiedAt__c
                                                            FROM Client_Insight_History__c
                                                            WHERE ClientInsight__r.Client__c = :clientId AND NewValue__c != NULL AND NewValue__c != ''
                                                            ORDER BY ModifiedAt__c DESC
                                                            LIMIT 1];

            if(ciHistoriesList.size() > 0) {
                lastModifiedAt = ciHistoriesList[0].ModifiedAt__c;
                lastModifiedById = ciHistoriesList[0].ModifiedBy__c;
                lastModifiedByName = ciHistoriesList[0].ModifiedBy__r.Name;
            }
        }

        List<Note__c> notesList = [SELECT LastModifiedDate,LastModifiedById,LastModifiedBy.Name 
                                    FROM Note__c 
                                    WHERE Client__c = :clientId AND IsDeleted__c = FALSE 
                                    ORDER BY LastModifiedDate DESC 
                                    LIMIT 1];
        if(notesList.size() > 0 && (lastModifiedAt == null || (lastModifiedAt != null && notesList[0].LastModifiedDate > lastModifiedAt))) {
            lastModifiedAt = notesList[0].LastModifiedDate;
            lastModifiedById = notesList[0].lastModifiedById;
            lastModifiedByName = notesList[0].LastModifiedBy.Name;
        }
        
        if(lastModifiedAt != null) {
            clienInsightMap.put('modifiedAt', lastModifiedAt);
            clienInsightMap.put('modifiedById', lastModifiedById);
            clienInsightMap.put('modifiedByName', lastModifiedByName);
        }

        return clienInsightMap;
    }

    public static List<Map<String, Object>> getClientNotes(String clientId) {
        return CLT_Utils_Mapping.getStandardWrapperList('Note__c','Note',
                        ' FROM Note__c WHERE Client__c = \'' + clientId + '\' AND IsDeleted__c = FALSE ORDER BY LastModifiedDate DESC');
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

    public static List<Map<String, Object>> getClientGifts(String clientId) {
        return CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task',
                        'FROM Task WHERE WhatId = \'' + clientId + '\' AND Outreach_Type__c = \'Gift\' ORDER BY ActivityDate, CreatedDate DESC');
    }

    public static List<Map<String, Object>> getClientEvents(String clientId) {
        return CLT_Utils_Mapping.getStandardWrapperList('Task', 'Task',
                        'FROM Task WHERE WhatId = \'' + clientId + '\' AND Outreach_Type__c = \'Event\' ORDER BY ActivityDate, CreatedDate DESC');
    }
}