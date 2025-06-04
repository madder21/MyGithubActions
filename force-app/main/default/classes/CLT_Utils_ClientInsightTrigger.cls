public with sharing class CLT_Utils_ClientInsightTrigger {

    public static void createClientInsightHistories(List<Client_Insight__c> newClientInsights, Map<Id, Client_Insight__c> oldClientInsightsMap) {
        List<Client_Insight_History__c> ciHistoriesToInsert = new List<Client_Insight_History__c>();
        for(Client_Insight__c clientInsight : newClientInsights) {
            for(String fieldName : System.Label.ClientInsightFieldsToTrack.split(';')) {
                if((!oldClientInsightsMap.containsKey(clientInsight.Id) && (clientInsight.get(fieldName) != null && (!(clientInsight.get(fieldName) instanceof Boolean) || ((clientInsight.get(fieldName) instanceof Boolean) && (Boolean)clientInsight.get(fieldName) == true)))) || 
                    (oldClientInsightsMap.containsKey(clientInsight.Id) && clientInsight.get(fieldName) != oldClientInsightsMap.get(clientInsight.Id).get(fieldName))) {
                    ciHistoriesToInsert.add(new Client_Insight_History__c (
                        ClientInsight__c = clientInsight.Id,
                        ModifiedField__c = fieldName,
                        NewValue__c = String.valueOf(clientInsight.get(fieldName)),
                        PreviousValue__c = oldClientInsightsMap.containsKey(clientInsight.Id) ? String.valueOf(oldClientInsightsMap.get(clientInsight.Id).get(fieldName)) : '',
                        ModifiedBy__c = clientInsight.LastModifiedById,
                        ModifiedAt__c = clientInsight.LastModifiedDate
                    ));
                }
            }
        }
        insert ciHistoriesToInsert;
    }
}