@isTest
public with sharing class DataMigrationScheduleTest {
    //Create Data for customSetting
    @testSetup
    static void setupTestData() {
        // Create a new record for the BatchLastExecutionTime__c custom setting
        BatchLastExecutionTime__c setting = BatchLastExecutionTime__c.getOrgDefaults();
        setting.DataMigrationLastExecutionDate__c = System.now().addDays(-1);
        insert setting;
    }
    @isTest
    static void testScheduleExecution() {
        // Test the scheduled batch job execution
        DateTime thisNow = Datetime.now();
        Test.startTest();
        String jobId = System.schedule('Data Migration Batch', '0 0 0 * * ?', new DataMigrationSchedule());
        Test.stopTest();
        // Verify that the scheduled job was executed
        List<AsyncApexJob> jobs = [SELECT Id, Status FROM AsyncApexJob];
        Assert.areEqual('Queued', jobs[0].Status);
        // Verify that the customsetting was updated with last execution date
        BatchLastExecutionTime__c setting = BatchLastExecutionTime__c.getOrgDefaults();
        Assert.areEqual(thisNow, setting.DataMigrationLastExecutionDate__c);
    }
}