public class CLT_Utils_ClientListMemberTrigger {
    public static void updateLastContactDate(List<ClientListMember__c> newClientListMembers, Map<Id,ClientListMember__c> oldCLMMap) {
        List<Account> accountToUpdate = new List<Account>();
        Set<Id> setListAccountIdAlreadyAdded = new Set<Id>();
    
        for (ClientListMember__c clm : newClientListMembers) {
            if (clm.Status__c == 'Contacted' && (   !oldCLMMap.containsKey(clm.Id) 
                                                 || (oldCLMMap.containsKey(clm.Id) && oldCLMMap.get(clm.Id).Status__c != 'Contacted')) ) {
                Account account = new Account(id = clm.Client__c);
                
                //Fev2024: EBU>ToBalink : think about ensuring there is no duplicate in a to-be-created/updated list
                if (!setListAccountIdAlreadyAdded?.contains(clm.Client__c)) {
                    account.LastContactDate__pc = Date.today();
                    accountToUpdate.add(account);
                    //add the client list member id to the set Id variable to get only one instance of the same account in the list to be updated
                    setListAccountIdAlreadyAdded.Add(clm.Client__c);
                }
            }
        }
        
        if(accountToUpdate.size() > 0) {
            update accountToUpdate;
        }
    }
}