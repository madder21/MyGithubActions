public class CLT_Utils_ClientTrigger {
    public static void updateTargetedCustomersCAreattributionDateAndNotify(List<Account> newClients, Map<Id, Account> oldClientsMap) {
        for(Account client : newClients) {
            if(client.Targeted_Customers_CAreattribution__c && (!oldClientsMap.containsKey(client.Id) ||
                (oldClientsMap.containsKey(client.Id) && !oldClientsMap.get(Client.Id).Targeted_Customers_CAreattribution__c))) {
                client.Targeted_Customers_CAreattribution_Date__c = Date.today();
                client.Targeted_Customers_CAreattribution_Notif__c = true;
            }
        }
    }

    public static void updateTargetedCAreattributionContactDate(List<Account> newClients, Map<Id, Account> oldClientsMap) {
        for(Account client : newClients) {
            if(client.Targeted_Customers_CAreattribution__c && client.Targeted_Customers_CAreattribution_Date__c != null && client.LastContactDate__pc != null && 
                (client.Targeted_CAreattribution_Contact_Date__c == null || client.Targeted_CAreattribution_Contact_Date__c <= client.Targeted_Customers_CAreattribution_Date__c) && 
                (!oldClientsMap.containsKey(client.Id) || (oldClientsMap.containsKey(client.Id) && (oldClientsMap.get(Client.Id).LastContactDate__pc == null || oldClientsMap.get(Client.Id).LastContactDate__pc < client.LastContactDate__pc)))) {
                client.Targeted_CAreattribution_Contact_Date__c = client.LastContactDate__pc;
            }
        }
    }
}