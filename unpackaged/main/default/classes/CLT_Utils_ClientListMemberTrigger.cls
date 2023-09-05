public class CLT_Utils_ClientListMemberTrigger {
    public static void updateLastContactDate(List<ClientListMember__c> newClientListMembers, Map<Id,ClientListMember__c> oldCLMMap) {
        List<Account> accountToUpdate = new List<Account>();
    
        for (ClientListMember__c clm : newClientListMembers) {
            if (clm.Status__c == 'Contacted' && (!oldCLMMap.containsKey(clm.Id) || (oldCLMMap.containsKey(clm.Id) && oldCLMMap.get(clm.Id).Status__c != 'Contacted'))) {
                Account account = new Account(id = clm.Client__c);
                account.LastContactDate__pc = Date.today();
                accountToUpdate.add(account);
            }
        }

        if(accountToUpdate.size() > 0) {
            update accountToUpdate;
        }
    }
}