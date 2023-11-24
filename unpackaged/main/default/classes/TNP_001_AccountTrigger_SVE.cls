/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP_001_AccountTrigger_SVE  
-- - Author             : Ilhem Zraiga
-- - Description        : Handler for the Trigger AccountTriggerHandler 
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 20/03/2023    IZR    1.0     Intitial version
-- 10/10/2023	UNN		1.1		Add ManageAccountEvent and CreateNotificationContent For CDP Integration, for China customer
-------------------------------------------------------------------------------------------
*/
public with sharing class TNP_001_AccountTrigger_SVE {
    Public Static String CLASS_NAME = 'TNP_001_AccountTrigger_SVE';
    
    public static void preventClientInfoDeletion(List<Account> accList, Map<Id, SObject> oldSObjectMap) {
        System.debug('*** TNP_001_AccountTrigger_SVE - preventClientInfoDeletion - START ***');
        String userName = UserInfo.getName();
        if(userName.contains(Label.R360_Integration_User_Name)) {//create another user for the API between CEGID -> Mulesoft -> SFDC
            for(Account acc : accList) {
                Account oldAccount = (Account)oldSObjectMap.get(acc.Id);
                acc.ClientType__pc = (acc.ClientType__pc!=null || !String.isEmpty(acc.ClientType__pc))?acc.ClientType__pc:oldAccount.ClientType__pc;
                acc.ContactableByEmail__pc = oldAccount.ContactableByEmail__pc;
                acc.OptinCalling__pc = acc.OptinCalling__pc!=null?acc.OptinCalling__pc:oldAccount.OptinCalling__pc;
                acc.OptinEmailing__pc = acc.OptinEmailing__pc!=null?acc.OptinEmailing__pc:oldAccount.OptinEmailing__pc;
                acc.OptinInstantMessaging__pc = acc.OptinInstantMessaging__pc!=null?acc.OptinInstantMessaging__pc:oldAccount.OptinInstantMessaging__pc;
                acc.OptinMailing__pc = acc.OptinMailing__pc!=null?acc.OptinMailing__pc:oldAccount.OptinMailing__pc;
                acc.LastUpdateOptinCalling__pc = acc.LastUpdateOptinCalling__pc!=null?acc.LastUpdateOptinCalling__pc:oldAccount.LastUpdateOptinCalling__pc;
                acc.LastUpdateOptinEmailing__pc = acc.LastUpdateOptinEmailing__pc!=null?acc.LastUpdateOptinEmailing__pc:oldAccount.LastUpdateOptinEmailing__pc;
                acc.LastUpdateOptinInstantMessaging__pc = acc.LastUpdateOptinInstantMessaging__pc!=null?acc.LastUpdateOptinInstantMessaging__pc:oldAccount.LastUpdateOptinInstantMessaging__pc;
                acc.LastUpdateOptinMailing__pc = acc.LastUpdateOptinMailing__pc!=null?acc.LastUpdateOptinMailing__pc:oldAccount.LastUpdateOptinMailing__pc;
            }
        }
        System.debug('*** TNP_001_AccountTrigger_SVE - preventClientInfoDeletion - END ***');
    }
    
    public static void backupKPIInfo(List<Account> accList) {
    	System.debug('*** TNP_001_AccountTrigger_SVE - backupKPIInfo - START ***');
        String userName = UserInfo.getName();
        if(userName.contains(Label.R360_Integration_User_Name)) {
            List<Account> accToBefixed = new List<Account>();
            List<Account> accToBefixedList = new List<Account>();
            List<String> accStoreToBefixed = new List<String>();
            List<String> accCAToBefixed = new List<String>();
            Map<String, Id> sourceStoreIdMap = new Map<String, Id>();
            Map<String, Id> clientAdvisorIdMap = new Map<String, Id>();
            Boolean shouldBeUpdated = false;
            for(Account acc : accList) {
                if(acc.MainStoreId__pc!=null && String.isEmpty(acc.MainStore__pc)) {
                    accCAToBefixed.add(acc.MainStoreId__pc);
                    shouldBeUpdated = true;
                }
                if(acc.ClientAdvisorId__pc!=null && String.isEmpty(acc.ClientAdvisor__pc)) {
                    accStoreToBefixed.add(acc.ClientAdvisorId__pc);
                    shouldBeUpdated = true;
                }
                if(shouldBeUpdated) {
                	accToBefixed.add(acc);
                }
            }
            
            System.debug('*** TNP_001_AccountTrigger_SVE - backupKPIInfo - accToBefixed: '+accToBefixed);
            for(Store__c store: [SELECT Id, SourceStoreId__c FROM Store__c WHERE SourceStoreId__c IN: accCAToBefixed]) {
                sourceStoreIdMap.put(store.SourceStoreId__c, store.Id);
            }
            System.debug('*** TNP_001_AccountTrigger_SVE - backupKPIInfo - sourceStoreIdMap: '+sourceStoreIdMap);
            for(User currentUser : [SELECT Id, StaffCode__c FROM User WHERE StaffCode__c IN: accStoreToBefixed]) {
                clientAdvisorIdMap.put(currentUser.StaffCode__c, currentUser.Id);
            }
            System.debug('*** TNP_001_AccountTrigger_SVE - backupKPIInfo - clientAdvisorIdMap: '+clientAdvisorIdMap);
            for(Account acc : accToBefixed) {
                System.debug('*** TNP_001_AccountTrigger_SVE - backupKPIInfo - clientAdvisorIdMap.get(acc.MainStoreId__pc): '+clientAdvisorIdMap.get(acc.MainStoreId__pc));
                acc.ClientAdvisor__pc = clientAdvisorIdMap.containsKey(acc.ClientAdvisorId__pc)?clientAdvisorIdMap.get(acc.ClientAdvisorId__pc):null;
                acc.MainStore__pc = sourceStoreIdMap.containsKey(acc.MainStoreId__pc)?sourceStoreIdMap.get(acc.MainStoreId__pc):null;
                accToBefixedList.Add(acc);
            }
            System.debug('*** TNP_001_AccountTrigger_SVE - backupKPIInfo - accToBefixedList: '+accToBefixedList);
            if(!accToBefixedList.isEmpty()) {
                update accToBefixedList;
            }
        }
        System.debug('*** TNP_001_AccountTrigger_SVE - backupKPIInfo - END ***');
    }
    
	public static void manageClientSource(List<Account> accList) {
        System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - START ***');
        String userName = UserInfo.getName();
        System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - accList *** '+accList);
        System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - userName *** '+userName);
        if(userName.contains(Label.R360_Integration_User_Name)) {
        	List<ClientSource__c> clientSourceList = new List<ClientSource__c>();
            for(Account acc : accList) {
                if(acc.Other_sources_ID__c != null && !acc.MainStoreId__pc.contains('ECO')) {
                    System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - IF OK ***');
                    ClientSource__c clientSource = new ClientSource__c();
                    clientSource.Client__c = acc.Id;
                    clientSource.Source__c = '001';
                    clientSource.SourceCode__c = acc.Other_sources_ID__c;
                    clientSource.SourceCreationDate__c = System.now();
                    clientSource.SourceLastUpdateDate__c = System.now();
                    clientSourceList.add(clientSource);
                }
            }
            System.debug('*** TNP_001_AccountTrigger_SVE - manageClientSource - clientSourceList ***: '+clientSourceList);
            if(!clientSourceList.isEmpty()){
                insert clientSourceList;
            }
        }
    }
    
    public static TNP_001_AccountWrapper manageAccountEvent(List<Account> accountList) {
      	TNP_001_AccountWrapper wrapper = new TNP_001_AccountWrapper();
        for(Account acc : accountList) {
            System.debug('*** acc.CreatedById: '+acc.CreatedById);
            if(acc.CreatedById==Label.CDPIntegrationUserID || acc.LastModifiedById==Label.CDPIntegrationUserID) {
                wrapper.cdpAccountList.add(acc);
            }else {
                wrapper.otherAccountList.add(acc);
            }
        }
        System.debug('*** wrapper: '+wrapper);
        return wrapper;
    }
    
    public static void createNotificationContent(List<Account> accountList) {
        if(!accountList.isEmpty()) {
        	System.enqueueJob(new AccountCDPQueuableCallout(accountList));
        }         
    }
    
    public static void listAccountAfterInsert( list<account> listAccountToInsert)
    {  
        String METHOD_NAME = 'listAccountAfterInsert';
        list<account> listFinalAccountToInsert = new list<account>();
        Map<Id,User> mapInfoUser = TNP_002_ServiceClass.returnMapUserIntegration();
        map<String,SObject> mapSobject  = new map<String,SObject>();
        for (Account accountToInsert:listAccountToInsert ){
            User user = mapInfoUser.get(accountToInsert.CreatedById);
            if (user == null || (user != null && user.Name == Label.SFSC_Integration_User) ){
                listFinalAccountToInsert.add(accountToInsert);
            }
        }
        
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        if ( !listFinalAccountToInsert.isEmpty() )
        {    
            System.enqueueJob(new TNP_001_QueueableCallOut(listFinalAccountToInsert,'',Label.TNP_CL_AfterInsert));   
        }     
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
    }    
    
    
    public static void listAccountAfterUpdate( list<account> listAccountToUpdateNew,Map<Id, Account>  listAccountToUpdateOld)
    {  
        String METHOD_NAME = 'listAccountAfterUpdate';
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        list<account> listFinalAccountToUpdate = new list<account>();
        Map<Id,User> mapInfoUser = TNP_002_ServiceClass.returnMapUserIntegration();
        List<Account> accountToBeProcessed = new List<Account>();
        for (Account accountToUpdate: listAccountToUpdateNew ){
            if(accountToUpdate.UCRInternalId__c == listAccountToUpdateOld.get(accountToUpdate.Id).UCRInternalId__c) {
                accountToBeProcessed.add(accountToUpdate);
                
            }
        }
        if(!accountToBeProcessed.isEmpty()) {
            
            
            for (Account accountToUpdate: accountToBeProcessed ){
                User user = mapInfoUser.get(accountToUpdate.LastModifiedById);
                if (user == null || (user != null && user.Name == Label.SFSC_Integration_User)  ){
                    listFinalAccountToUpdate.add(accountToUpdate);
                }
            }
            
        }
        if ( !listFinalAccountToUpdate.isEmpty() )
        {  
            System.enqueueJob(new TNP_001_QueueableCallOut(listFinalAccountToUpdate,'',Label.TNP_CL_AfterUpdate));   
        }  
        
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END');         
    } 
    
    
}