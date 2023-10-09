/**
 * @description       : 
 * @author            : Ulrich M. NDONG NGOMO
 * @group             : 
 * @last modified on  : 03-10-2023
 * @last modified by  : Ulrich M. NDONG NGOMO
**/
@IsTest(SeeAllData=false)
public class AccountCDPQueuableCallout_TST {
    
    @isTest
    static void testExecute() {
        // Create a list of test Account records
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            Account acc = new Account();
            acc.Name = 'Test Account ' + i;
            acc.Other_sources_ID__c = 'CegidID' + i;
            insert acc;
            testAccounts.add(acc);
        }
        // Create a test instance of AccountCDPQueuableCallout
        AccountCDPQueuableCallout queuable = new AccountCDPQueuableCallout(testAccounts);
        
        // Start the test to execute the queueable
        Test.startTest();
        System.enqueueJob(queuable);
        Test.stopTest();
        System.assertNotEquals(testAccounts[0].Id, queuable.accountList[0].Id);
    }

}