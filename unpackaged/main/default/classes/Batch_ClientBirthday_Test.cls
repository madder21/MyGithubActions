@isTest
private class Batch_ClientBirthday_Test {
    @isTest
    static void test_batch_clientBirthday() {
        Account acc = new Account();
        acc.FirstName = 'Client';
        acc.LastName = 'Test';
        acc.PersonBirthdate = Date.today().adddays(3);
        acc.LightCurrentCluster__pc = 'VIC';
        insert acc;

        Test.startTest();
        Batch_ClientBirthday schedBatch = new Batch_ClientBirthday();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Territory Check', sch, schedBatch);
        Test.stopTest();
    }
}