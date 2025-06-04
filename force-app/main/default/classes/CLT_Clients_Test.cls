@isTest
private class CLT_Clients_Test {
    
    @isTest static void test_method_one() {
        Id recordTypeId = [SELECT Id FROM RecordType WHERE IsPersonType = true LIMIT 1].Id;

        Account account = new Account(LastName = 'Test', FirstName = 'Adam', Phone = '4848579', RecordTypeId = recordTypeId);
        insert account;
        
        ClientSource__c cs = new ClientSource__c(Client__c = account.Id, SourceCode__c = 'TST123');
        insert cs;
        
        Map<String, String> params = new Map<String, String>();
        Map<String, Object> body = new Map<String, Object>();
        params.put('Phone', '4848579');
        params.put('Id', 'test123');
        body.put('Id', 'test123');
        CLT_Clients cltClients = new CLT_Clients();

        Test.startTest();
        cltClients.retrieveGet(params);
        cltClients.retrieveDelete(params);
        params.clear();
        cltClients.retrievePost(params, body);
        Test.stopTest();
    }
    
}