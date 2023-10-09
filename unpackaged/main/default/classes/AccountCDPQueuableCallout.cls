/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 03-10-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
public with sharing class AccountCDPQueuableCallout implements Queueable,Database.AllowsCallouts {
    
    public List<Account> accountList;
    
    public AccountCDPQueuableCallout(List<Account> listAccount) {
    	this.accountList = listAccount;   
    }
    
    public void execute(QueueableContext context) {
        String JSONGenerated;
        for(Account acc : this.accountList) {
        	Map<String, String> dataMap = new Map<String, String>();
           	dataMap.put('salesforce_id', acc.Id);
        	dataMap.put('cegid_id', acc.Other_sources_ID__c);
            JSONGenerated = JSON.serialize(dataMap);
            WS_AccountUTL.pushRequest(JSONGenerated, 'CDPAccountAPI');
        }       
    }

}