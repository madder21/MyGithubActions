public without sharing class LaunchEmailTemplatesJSONBatchController {
    @AuraEnabled
    public static void launchEmailTemplatesJSONBatch() {
        Batch_CreateEmailTemplateJSON b = new Batch_CreateEmailTemplateJSON();
        Database.executeBatch(b, 1);
    }
}