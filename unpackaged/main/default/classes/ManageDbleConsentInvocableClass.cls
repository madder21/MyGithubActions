public with sharing class ManageDbleConsentInvocableClass {

    @InvocableMethod(label='Double consent send Account Data to Mulsoft')
    public static void sendAccountData(List<DbleConsentIntegrationWrapper> flowInputs) {
        List<Account> accountList = new List<Account>();
        Account acc = TNP001_DM_Account.getAccountById(flowInputs[0].account.Id);
        accountList.add(acc);
        System.enqueueJob(new TNP_001_QueueableCallOut(accountList, flowInputs[0].consent.CaptureSource,Label.TNP_CL_Invocable));
    }

    public class DbleConsentIntegrationWrapper {
        @InvocableVariable(required=true)
        public Account account;
        @InvocableVariable(required=true)
        public ContactPointConsent consent;
       
    } 
}