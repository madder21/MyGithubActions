global with sharing class CLT_Utils_ClientLists {
    global static String buildDynamicQuery(ClientList__c clientList, string userId, string storeCode, Boolean isSpecificClientList){
        List<String> conditions = new List<String>();

        string myClientsCondition = '';
        string generalQuery = ' ' + clientList.clientListQuery__c;
        
        if(!String.isEmpty(clientList.VisibilityBasedOnField__c)) {
            myClientsCondition = CLT_Utils_Query.getAccountBasedFieldCondition(clientList.VisibilityBasedOnField__c, userId);
        }
        else if(clientList.InMyStore__c){  
            myClientsCondition = CLT_Utils_Query.getAccountMyStoreCondition(storeCode);
        }else{
            myClientsCondition = CLT_Utils_Query.getAccountMyClientsCondition(userId);
        }

        if(!String.isEmpty(clientList.clientListQuery__c)) {
            if (!generalQuery.contains('LIMIT') && !isSpecificClientList){
                generalQuery += ' LIMIT 200';
            }
            else if(!generalQuery.contains('LIMIT') && isSpecificClientList) {
                generalQuery += ' LIMIT 800';
            }
        }
        else if (clientList.Type__c == 'Membered') {
            generalQuery = ' AND Id IN (SELECT Client__c FROM ClientListMember__c WHERE ClientList__c = \'' + clientList.Id + '\')';

            if (!isSpecificClientList){
                generalQuery += ' LIMIT 200';
            }
            else if(isSpecificClientList) {
                generalQuery += ' LIMIT 800';
            }
        }

        system.debug(myClientsCondition + generalQuery);
        return myClientsCondition + generalQuery;
    }
}