/**
 * @author (Balink)
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description This class is used by CLT_ClientList to return to R-Client App the correct protfolio at the endpoint /retail/clientList
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|.      			|.      	|.          	    |.original version
 * 1.0		|2025/01/12			|.Sarah A	|.RCLIENT-1617	    |.add default order by creation date
*/
global with sharing class CLT_Utils_ClientLists {
    /*
     * @METHOD 	: buildDynamicQuery
     * @DESC 	: calculate the dynamic part of the query for the received client list according to tghe connected user
     * @PARAM 	: clientList-for whom the query is calculated, userId-the connected user, storeCode-of the connected user, isSpecificClientList- is it a single client list call,noLimit-remove the limit of nm records that are returned
     * @RETURN 	: String : the dynamic part of client query that is run for the cliemt list
     */
    global static String buildDynamicQuery(ClientList__c clientList, string userId, string storeCode, Boolean isSpecificClientList, Boolean noLimit){
        String defaultOrderByField = 'CreatedDate DESC';
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
            if(!generalQuery.contains('ORDER BY')) {
                if(generalQuery.contains('LIMIT')) {
                    generalQuery = generalQuery.substringBeforeLast('LIMIT') + ' ORDER BY ' + defaultOrderByField + ' LIMIT' + generalQuery.substringAfterLast('LIMIT');
                }
                else {
                    generalQuery += ' ORDER BY ' + defaultOrderByField;
                    if(!isSpecificClientList) {
                        generalQuery += ' LIMIT 200';
                    }
                    else {
                        generalQuery += ' LIMIT 800';
                    }
                }
            }
            else {
                if(generalQuery.contains('LIMIT')) {
                    generalQuery = generalQuery.substringBeforeLast('LIMIT') +  ', ' + defaultOrderByField + ' LIMIT' + generalQuery.substringAfterLast('LIMIT');
                }
                else {
                    generalQuery += ', ' + defaultOrderByField;
                }
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

        if(isSpecificClientList && noLimit && !clientList.AlwaysLimitedList__c && generalQuery.contains('LIMIT')) {
            generalQuery = generalQuery.split('LIMIT ')[0];
        }

        system.debug(myClientsCondition + generalQuery);
        return myClientsCondition + generalQuery;
    }
}