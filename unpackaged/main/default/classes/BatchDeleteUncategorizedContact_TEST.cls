/**
 * @author Paul Louis MONY
 * @date 
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts comprehensive testing for the class BatchDeleteUncategorizedContact
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25052023			|.PLM		|.					|.
*/

@Istest
public with sharing class BatchDeleteUncategorizedContact_TEST {
    @TestSetup
    static void setup(){
        //Create CommSubscriptionChannelType
        List<CommSubscriptionChannelType> channelTypeTestDataList = ConsentManagement_TestDataFactory.createCommSubscriptionChannelType();
        List<Account> accounts = new list<Account>();
        
        for (Integer i=0; i<10; i++) {
            //Account to be deleted
            Account acc1 = new Account();
            acc1.FirstName = 'no firstname';
            acc1.lastName = 'no lastname';
            acc1.salutation = '1';
            acc1.personEmail = 'noemail'+i+'@yopmail.com';
            acc1.OptinEmailing__pc = false;
			accounts.Add(acc1);
            
            //Account not to be deleted
            Account acc2 = new Account();
            acc2.FirstName = 'no firstname';
            acc2.lastName = 'no lastname';
            acc2.salutation = '1';
            acc2.personEmail = 'noemail'+(i+1)+'@yopmail.com';
            acc2.OptinEmailing__pc = true;
			accounts.Add(acc2);
            
            //Account not to be deleted
            Account acc3 = new Account();
            acc3.FirstName = 'no firstname';
            acc3.lastName = 'Olala';
            acc3.salutation = '1';
            acc3.personEmail = 'noemail'+i+'@yopmail.com';
            acc3.OptinEmailing__pc = false;
			accounts.Add(acc3);
        }
        insert accounts;
        
    }

    @Istest
    static void test() {
        
        //Get all accounts with the following criteria
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, LastName, FirstName FROM Account]);
        
        //Get all B2CCustomInput related to accounts which will be deleted
        List<B2CCustomInput__c> customInputToDelete = [SELECT Id FROM B2CCustomInput__c WHERE AccountId__c in :accountMap.keySet()];
        
        //Delete all B2CCustomInputs and their associated accounts
        if (!customInputToDelete.isEmpty()) {
            delete customInputToDelete;
            Database.emptyRecycleBin(customInputToDelete);
        }
        
        Test.startTest();
        	BatchDeleteUncategorizedContact batchclass = new BatchDeleteUncategorizedContact(System.today()+1);
        	Id batchInstanceId = Database.executeBatch(batchclass);
        Test.stopTest();
        
        System.assertEquals(30, accountMap.keySet().size());
        System.assertEquals(20, [SELECT COUNT() FROM Account]);
        
    }
}