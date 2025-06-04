@isTest
private class CLT_EmailTemplates_Test {

    @TestSetup
    static void prepareTestData(){
        CLT_TestDateFactory.createTestUser(System.Label.profileName_StoreUser, true);
        CLT_TestDateFactory.createTestStore('TST123', true);

        EmailTemplate emailTemplate = [SELECT Id,Name,Description,FolderId,Subject,DeveloperName,HtmlValue,Body
                                    FROM EmailTemplate 
                                    WHERE ( Folder.Name LIKE 'EN %' ) AND IsActive = TRUE 
                                    LIMIT 1];

        Folder folder = [SELECT Id,Name,DeveloperName FROM Folder WHERE Id = :emailTemplate.FolderId LIMIT 1];
        CLT_Email_Template__c cltEmailTemplate = new CLT_Email_Template__c();

        String description = emailTemplate.Description != null ? emailTemplate.Description : '';
        if(description.contains(';')) {
            List<String> descItems = description.split(';');
            cltEmailTemplate.Category__c = descItems.size() > 0 ? descItems[0] : '';
        }
        cltEmailTemplate.Name = emailTemplate.Name;
        Map<String, Object> bodyWrapper = new Map<String, Object>();
        
        String folderName = folder.Name;
        Boolean isEmail = folderName.toUpperCase().contains('EMAIL');
        Boolean isPostal = folderName.toUpperCase().contains('POSTAL');
        bodyWrapper.put('type', isEmail ? 'Email' : isPostal ? 'Postal' : 'InstantMessage');
        
        list<String> folderNameItems = (folder.DeveloperName).split('\\_');
        bodyWrapper.put('lang', folderNameItems.size() > 0 ? folderNameItems[0] : '');
        
        bodyWrapper.put('id', emailTemplate.Id);
        bodyWrapper.put('subject', emailTemplate.Subject);
        bodyWrapper.put('devName', emailTemplate.DeveloperName);
        bodyWrapper.put('name', emailTemplate.Name);
        bodyWrapper.put('developerName', (folder.DeveloperName));
        bodyWrapper.put('htmlValue', emailTemplate.HtmlValue != null ? emailTemplate.HtmlValue : null);
        
        string htmlBody = String.valueOf(emailTemplate.HtmlValue); 
        bodyWrapper.put('body', isEmail && !String.isEmpty(htmlBody) ? htmlBody : emailTemplate.Body); 
        
        cltEmailTemplate.JSON__c = JSON.serialize(bodyWrapper);
        cltEmailTemplate.Email_Template_Id__c = emailTemplate.Id;
        cltEmailTemplate.Is_Active__c = true;
        cltEmailTemplate.Folder_Name__c = folderName;    

        insert cltEmailTemplate;
        
        Template_Images__c ti = new Template_Images__c();
        ti.Email_Template_Id__c = emailTemplate.Id;
        ti.Image_1__c = 'www.google.com';
        ti.Image_2__c = 'www.google.com';
        insert ti;
    }

    @isTest
    static void test_EmailTemplates_DELETE() {
        CLT_EmailTemplates cltEmailTemplates = new CLT_EmailTemplates();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            CLT_Email_Template__c emailTemplateCLT = new CLT_Email_Template__c(
                Name = 'test name',
                Language__c = 'English',
                Category__c = 'Others',
                Subject__c = 'test subject',
                PlainText__c = 'test plain text',
                Signature__c = 'test signature',
                Type__c = 'Email',
                User__c = sa.Id,
                PersonalizedTemplate__c = true,
                Is_Active__c = true
            );
            insert emailTemplateCLT;
            
            Object cltEmailTemplatesDeleteResponse = cltEmailTemplates.retrieveDelete(new Map<String, String>{'id' => emailTemplateCLT.id});
            System.assertEquals(true, (Boolean)cltEmailTemplatesDeleteResponse, 'Dalete of personal Email template is not true');

            Test.stopTest();
        }
    }

    @isTest
    static void test_EmailTemplates_POST() {
        CLT_EmailTemplates cltEmailTemplates = new CLT_EmailTemplates();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Map<String,Object> body = new Map<String,Object> {
                'name' => 'test name',
                'lang' => 'english',
                'reason' => 'Other',
                'subject' => 'test subject',
                'plainText' => 'test plainText',
                'signature' => 'test signature',
                'type' => 'Email'
            };

            Object cltEmailTemplatesPostResponse = cltEmailTemplates.retrievePost(new Map<String, String>(), body);
            String cltEmailTemplateIdFromRes = (String)(((Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)JSON.deserializeUntyped(JSON.serialize(cltEmailTemplatesPostResponse)))[0]))).get('id'));
            String cltEmailTemplateIdInserted = [SELECT Id FROM CLT_Email_Template__c WHERE User__c = :sa.Id LIMIT 1].Id;
            System.assertEquals(cltEmailTemplateIdFromRes, cltEmailTemplateIdInserted, 'Inserted Email Id is not the same as returned in insert WS');

            Test.stopTest();
        }
    }

    @isTest
    static void test_EmailTemplates_GET() {
        CLT_EmailTemplates cltEmailTemplates = new CLT_EmailTemplates();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Object cltEmailTemplatesGetResponse = cltEmailTemplates.retrieveGet(new Map<String, String>{'isNew' => 'true'});
            Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cltEmailTemplatesGetResponse));
            Map<String,Object> sharingTemplates = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(objMap.get('sharingTemplates')));
            String englishSharingTemplateId = (String)(((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sharingTemplates.get('English')))).get('id'));

            List<EmailTemplate> sharingTemplatesListInSF = Database.query('SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName =\'Sharing_Templates\' AND (Name LIKE \'EN%\') AND IsActive = TRUE');
            System.assertEquals(sharingTemplatesListInSF[0].Id, englishSharingTemplateId, 'receiven english sharing template id is different than expected');
            Test.stopTest();
        }
    }

    @isTest
    static void test_EmailTemplates_v2_GET() {
        CLT_EmailTemplates cltEmailTemplates = new CLT_EmailTemplates();

        User sa = [SELECT Id FROM User WHERE Username LIKE '%clttestuser@rimowa.com' AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            CLT_Email_Template__c emailTemplateCLT = new CLT_Email_Template__c(
                Name = 'test name',
                Language__c = 'English',
                Category__c = 'Others',
                Subject__c = 'test subject',
                PlainText__c = 'test plain text',
                Signature__c = 'test signature',
                Type__c = 'Email',
                User__c = sa.Id,
                PersonalizedTemplate__c = true,
                Is_Active__c = true
            );
            insert emailTemplateCLT;

            Object cltEmailTemplatesGetResponse = cltEmailTemplates.retrieveGet(new Map<String, String>{'versionNum' => '2.13'});
            Map<String, Object> objMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(cltEmailTemplatesGetResponse));
            List<Object> personalTemplates = (List<Object>)JSON.deserializeUntyped(JSON.serialize(objMap.get('personalEmailTemplates')));

            System.assertEquals(1, personalTemplates.size(), 'personal templates list size is not 1');
            Test.stopTest();
        }
    }
}