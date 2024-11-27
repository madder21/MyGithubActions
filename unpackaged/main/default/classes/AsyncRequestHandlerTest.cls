@isTest
private class AsyncRequestHandlerTest {
    
    @isTest static void testCreationOneAsyncRequest () {
        String sContext = 'AfterInsert', sType = 'Account';
        Account accountForTesting = new Account(FirstName = 'Chloé', LastName = 'Burté', PersonEmail = 'chloe.burte.test@gmail.com');
        insert accountForTesting;
        
        AsyncRequestHandler.RecordAsyncRequest(sContext,sType,accountForTesting);
        
        Test.startTest();
        List<Async_Job_Request__c> lAsyncRequestsTests = [SELECT Id, Name, TriggeringObject__c, RecordId__c, SerializedObject__c, Status__c, RunningJobId__c, ContextInformation__c  
                                                          FROM Async_Job_Request__c 
                                                          WHERE RecordId__c = :accountForTesting.Id ];
        Test.stopTest();
        
        System.AssertEquals(1, lAsyncRequestsTests?.size(), 'AsyncRequestHandlerTest - testCreationOneAsyncRequest - One Async_Job_Request__c record only should have been created');
    }     
	
    
    @isTest static void  testCreationSeveralAsyncRequest () {
    	String sContext = 'AfterInsert', sType = 'Account';
        List<Account> listAccountForTesting = new List<Account> ();
        For (integer i=0; i<50; i++) {
        	Account accountForTesting = new Account(FirstName = 'Chloé'+'_'+i, LastName = 'Burté'+'_'+i, PersonEmail = 'chloe.burte.test'+'_'+i+'@gmail.com');
            listAccountForTesting.add(accountForTesting);
        }
        insert listAccountForTesting;
        
        AsyncRequestHandler.RecordMultipleAsyncRequest(sContext,sType,listAccountForTesting);
        
        Test.startTest();
        List<Async_Job_Request__c> lAsyncRequestsTests = [SELECT Id, Name, TriggeringObject__c, RecordId__c, SerializedObject__c, Status__c, RunningJobId__c, ContextInformation__c 
                                                          FROM Async_Job_Request__c ];
        Test.stopTest();
        
        System.AssertEquals(50, lAsyncRequestsTests?.size(), 'AsyncRequestHandlerTest - testCreationOneAsyncRequest - One Async_Job_Request__c record only should have been created');
    }  
    
    @isTest static void testUpdateStatus () {
        Account accountForTesting = new Account(FirstName = 'Chloé', LastName = 'Burté', PersonEmail = 'chloe.burte.test@gmail.com');
        insert accountForTesting;
        List<Async_Job_Request__c> lAsyncRequestsTests = new List<Async_Job_Request__c> ();
        lAsyncRequestsTests.add(new Async_Job_Request__c(TriggeringObject__c='Account',Status__c='NewLog', recordId__c = accountForTesting.Id, ContextInformation__c = 'TESTUPDATE'));
        lAsyncRequestsTests.add(new Async_Job_Request__c(TriggeringObject__c='Account',Status__c='NewLog', recordId__c = accountForTesting.Id, ContextInformation__c = 'TESTUPDATE'));
        insert lAsyncRequestsTests;
        
        Test.startTest();
        AsyncRequestHandler.UpdateStatusOfAsyncRequest (lAsyncRequestsTests, AsyncRequestHandler.EnumStatus.InProgress);
        
        String sStatus = AsyncRequestHandler.EnumStatus.InProgress.name();
        List<Async_Job_Request__c> lAsyncRequestsSuiteUpdate = [SELECT Id, Name, TriggeringObject__c, RecordId__c, SerializedObject__c, Status__c, RunningJobId__c, ContextInformation__c 
                                                          		FROM Async_Job_Request__c
                                                                WHERE Status__c = :sStatus ];
        Test.stopTest();
        
        System.AssertEquals(2, lAsyncRequestsSuiteUpdate?.size(), 'AsyncRequestHandlerTest - testUpdateStatus - The method has not correctly updated the status of all tested Async_Job_Request__c');
   	}
    
    @isTest static void testUpdateJobId () {
        Account accountForTesting = new Account(FirstName = 'Chloé', LastName = 'Burté', PersonEmail = 'chloe.burte.test@gmail.com');
        insert accountForTesting;
        List<Async_Job_Request__c> lAsyncRequestsTests = new List<Async_Job_Request__c> ();
        Async_Job_Request__c a1 = new Async_Job_Request__c(TriggeringObject__c='Account',Status__c='NewLog', recordId__c = accountForTesting.Id, ContextInformation__c = 'TESTUPDATE');
        Async_Job_Request__c a2 = new Async_Job_Request__c(TriggeringObject__c='Account',Status__c='NewLog', recordId__c = accountForTesting.Id, ContextInformation__c = 'TESTUPDATE');
        lAsyncRequestsTests.add(a1);
        lAsyncRequestsTests.add(a2);
        insert lAsyncRequestsTests;
        
        Test.startTest();

        String sFakeJobId = '707KD00000FLXIjYAP';
        Id idFakeJobId = Id.valueOf(sFakeJobId);
        String sStatus = AsyncRequestHandler.EnumStatus.InProgress.name();
        
        AsyncRequestHandler.UpdateAsyncRequestWithJobid (lAsyncRequestsTests, idFakeJobId);       
        List<Async_Job_Request__c> lAsyncRequestsSuiteUpdate = [SELECT Id, Name, TriggeringObject__c, RecordId__c, SerializedObject__c, Status__c, RunningJobId__c, ContextInformation__c 
                                                          		FROM Async_Job_Request__c
                                                                WHERE RunningJobId__c = :sFakeJobId ];
        Test.stopTest();
        
        System.AssertEquals(2, lAsyncRequestsSuiteUpdate?.size(), 'AsyncRequestHandlerTest - testUpdateStatus - The method has not correctly updated the jobId of all tested Async_Job_Request__c');
    }
    
}