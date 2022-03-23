@isTest
private class Batch_ClientBirthday_Test {
    @isTest
    static void test_batch_clientBirthday() {
        Account acc = new Account();
        acc.FirstName = 'Client';
        acc.LastName = 'Test';
        acc.PersonBirthdate = Date.today().adddays(3);
        acc.LightCurrentCluster__pc = 'VIC_L';
        insert acc;

        Test.startTest();
        Database.executeBatch(new Batch_ClientBirthday());
        Test.stopTest();
    }
}