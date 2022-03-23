global class Batch_CreateEmailTemplateJSON implements Database.Batchable<sObject>, Schedulable {
    String query;

    public Batch_CreateEmailTemplateJSON() {
        query = 'SELECT Id,Name FROM Folder WHERE Type = \'Email\' AND Name != \'Sharing Templates\'';
    }

    public Batch_CreateEmailTemplateJSON(String condition) {
        query = 'SELECT Id,Name FROM Folder WHERE Type = \'Email\' ' + condition;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Folder> scope) {
        List<CLT_Email_Template__c> cltEmailTemplates = new List<CLT_Email_Template__c>();
        Set<String> cltEmailTemplatesExtIds = new Set<String>();
        List<CLT_Email_Template__c> cltEmailTemplatesToDelete = new List<CLT_Email_Template__c>();

        for(Folder folder : scope) {
            //We can have a query inside the loop as we are running over 1 each time and we have <40 folders in total
            List<EmailTemplate> emailTemplates = [SELECT Id,Description,Folder.Name,Folder.DeveloperName,Subject,HtmlValue,DeveloperName,Name,Body,IsActive
                                                FROM EmailTemplate WHERE FolderId = :folder.Id];
            for(EmailTemplate emailTemplate : emailTemplates) {
                CLT_Email_Template__c cltEmailTemplate = new CLT_Email_Template__c();

                String description = emailTemplate.Description != null ? emailTemplate.Description : '';
                if(description.contains(';')) {
                    List<String> descItems = description.split(';');
                    cltEmailTemplate.Category__c = descItems.size() > 0 ? descItems[0] : '';
                }
                cltEmailTemplate.Name = emailTemplate.Name;

                Map<String, Object> bodyWrapper = new Map<String, Object>();

                String folderName = emailTemplate.Folder.Name;
                Boolean isEmail = folderName.toUpperCase().contains('EMAIL');
                Boolean isPostal = folderName.toUpperCase().contains('POSTAL');
                bodyWrapper.put('type', isEmail ? 'Email' : isPostal ? 'Postal' : 'InstantMessage');

                list<String> folderNameItems = emailTemplate.Folder.DeveloperName.split('\\_');
                bodyWrapper.put('lang', folderNameItems.size() > 0 ? folderNameItems[0] : '');

                bodyWrapper.put('id', emailTemplate.Id);
                bodyWrapper.put('subject', emailTemplate.Subject);
                bodyWrapper.put('devName', emailTemplate.DeveloperName);
                bodyWrapper.put('name', emailTemplate.Name);
                bodyWrapper.put('developerName', emailTemplate.Folder.DeveloperName);
                bodyWrapper.put('htmlValue', emailTemplate.HtmlValue != null ? emailTemplate.HtmlValue : null);

                string htmlBody = String.valueOf(emailTemplate.HtmlValue); 
                bodyWrapper.put('body', isEmail && !String.isEmpty(htmlBody) ? htmlBody : emailTemplate.Body); 

                cltEmailTemplate.JSON__c = JSON.serialize(bodyWrapper);
                cltEmailTemplate.Email_Template_Id__c = emailTemplate.Id;
                cltEmailTemplate.Is_Active__c = emailTemplate.IsActive;
                cltEmailTemplate.Folder_Name__c = folderName;

                cltEmailTemplates.add(cltEmailTemplate);
                cltEmailTemplatesExtIds.add(cltEmailTemplate.Email_Template_Id__c);
            }
            cltEmailTemplatesToDelete.addAll([SELECT Id FROM CLT_Email_Template__c WHERE Folder_Name__c = :folder.Name AND (NOT Email_Template_Id__c IN :cltEmailTemplatesExtIds)]);
        }
        Database.Upsert(cltEmailTemplates, CLT_Email_Template__c.Email_Template_Id__c, false);
        delete cltEmailTemplatesToDelete;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('**********Batch_CreateEmailTemplateJSON FINISHED**********');
    }

    global void execute(SchedulableContext sc) {
        Batch_CreateEmailTemplateJSON b = new Batch_CreateEmailTemplateJSON();
        Database.executeBatch(b, 1);
    }
}