@isTest
private class DeleteRecordsBatch_Test {
    @isTest
    static void test_batchDeleteRecords() {
        Task t = new Task();
        insert t;
        Test.startTest();
        Database.executeBatch(new DeleteRecordsBatch('Task'));
        Database.executeBatch(new DeleteRecordsBatch(1));
        Test.stopTest();
    }
}