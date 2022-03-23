@isTest
private class Batch_CreateEmailTemplateJSON_Test {
    @isTest
    static void test_batch_createEmailTemplateJSON() {

        Test.startTest();
        Database.executeBatch(new Batch_CreateEmailTemplateJSON(' AND Name = \'EN EMAIL\''));
        Test.stopTest();
    }
}