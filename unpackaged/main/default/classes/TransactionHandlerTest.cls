@isTest
private class TransactionHandlerTest {

    static testMethod void myUnitTest() {
        /*ACCOUNT*/
		Account acc1 = new Account();  
        acc1.LastName = 'Serge';
    	insert acc1;
    
        
        Transaction__c trans = new Transaction__c();
        trans.Client__c = acc1.Id;
        trans.TransactionDate__c = date.today();
        insert trans;
        TransactionItem__c transItem = new TransactionItem__c();
        transItem.Client__c = acc1.Id;
        transItem.Transaction__c = trans.Id;
        insert transItem;
    }
}