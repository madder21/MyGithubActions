public with sharing class CLT_Utils_Query {
    public static String getClientsQuery(Boolean myClient, Boolean myStore){
        string clientsQuery = ' FROM Account WHERE IsPersonAccount = TRUE';
        string storeCode = '';        

        if(myClient){
            clientsQuery += getAccountMyClientsCondition(UserInfo.getUserId());
        }

        if(myStore){
            clientsQuery += getAccountMyStoreCondition(storeCode);
        }
        
        return CLT_Utils_Mapping.getQueryString('Account', 'Client', clientsQuery);  
    }
    
    public static String getGeneralClientsQuery(){
        string clientsQuery = ' FROM Account WHERE IsPersonAccount = TRUE';
        string storeCode = getUserInfos().storecode__c;
        clientsQuery += getAccountMyClientsCondition(UserInfo.getUserId());
        string basedFieldQuery = getBasedFieldListClientsQuery(UserInfo.getUserId(), storeCode);
        if(!String.isEmpty(basedFieldQuery)) {
            clientsQuery = clientsQuery.replace('AND ', 'AND (');
            clientsQuery += basedFieldQuery + ')';
        }
        
        return CLT_Utils_Mapping.getQueryString('Account', 'Client', clientsQuery);  
    }

    public static User getUserInfos(){   
        return [Select Id, StoreCode__c From User Where Id =: UserInfo.getUserId()][0];
    }    

    public static string getAccountMyClientsCondition(string userId){
        return ' AND ClientAdvisor__pc = \'' + userId + '\'';
    }

    public static string getAccountMyStoreCondition(string storeCode){
        return ' AND MainBoutiqueCode__c = \'' + storeCode + '\'';
    }

    public static string getAccountBasedFieldCondition(string visibilityBasedOnField, string userId) {
        return ' AND ' + visibilityBasedOnField + ' = \'' + userId + '\'';
    }
    
    public static string getBasedFieldListClientsQuery(string userId, string storeCode) {
        string basedFieldQuery = '';
        
        for(ClientList__c clientList : [SELECT VisibilityBasedOnField__c FROM ClientList__c WHERE VisibilityBasedOnField__c != '' AND (Stores__c includes (:storeCode) OR Stores__c = '')]) {
            if(!basedFieldQuery.contains(clientList.VisibilityBasedOnField__c)) {
                basedFieldQuery += ' OR ' + clientList.VisibilityBasedOnField__c + ' = \'' + userId + '\'';
            }            
        }
        
        return basedFieldQuery;
    }
}