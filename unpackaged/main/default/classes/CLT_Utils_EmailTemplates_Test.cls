/**
 * @author Sarah AYOUN (Balink)
 * @date June,10 2024
 * @Type Apex Test Class
 *****************************************************************************************************************************************************************
 * @description This Test class contains the methods to test those method from CLT_Utils_EmailTemplates :
 * testSetup : Creation of test user and store and Email Template with it's related CLT template
 * TEST METHOD				                |	DESCRIPTION
 * testGetPersonalEmailTemplates            |	Test of getPersonalEmailTemplates
 * testGetEmailTemplatesV2       	        |	Test of getEmailTemplatesV2
 * testGetEmailTemplates           	        |	Test of getEmailTemplates
 * testGetUserCategoriesMap                 |	Test of getUserCategoriesMap
 * testGetEmailTemplatesImages              |	Test of getEmailTemplatesImages
 * testGetSharingTemplates                  |	Test of getSharingTemplates
 * testUpsertPersonalizedEmailTemplate      |	Test of upsertPersonalizedEmailTemplate
 * testGetEmailTemplateCLTFromBody          |	Test of getEmailTemplateCLTFromBody
 * testDeletePersonalCLTEmailTemplate       |	Test of deletePersonalCLTEmailTemplate
 * 
 * ****************************************************************************************************************************************************************
 * @Version : 
 * Version	|Date of modication	|Modified By	|Related Jira Ticket	|Description of changes			
 * 0.0		|2024/06/10			|.Sarah A		|.						|.original version
*/
@isTest
private class CLT_Utils_EmailTemplates_Test {
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
    static void testGetPersonalEmailTemplates() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        System.runAs(sa) {
            CLT_Email_Template__c cltEmailTemplate = new CLT_Email_Template__c();
            cltEmailTemplate.Category__c = 'Other';
            cltEmailTemplate.Name = 'TESTPersonal';
            cltEmailTemplate.Is_Active__c = true;
            cltEmailTemplate.PersonalizedTemplate__c = true; 
            cltEmailTemplate.User__c = sa.Id;
            insert cltEmailTemplate;

            Test.startTest();
            Map<String, Object> userCategoriesMap = CLT_Utils_EmailTemplates.getUserCategoriesMap('Other');
            List<object> personalTemplates = CLT_Utils_EmailTemplates.getPersonalEmailTemplates(userCategoriesMap, 'Other');
            Test.stopTest();
            System.assertEquals(1, personalTemplates.size(), 'CLT_Utils_EmailTemplates_Test:testGetPersonalEmailTemplates: personal templates list size is not 1');
        }
    }

    @isTest
    static void testGetEmailTemplatesV2() {
        CLT_EmailTemplates cltEmailTemplates = new CLT_EmailTemplates();

        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Map<String, Object> userCategoriesMap = CLT_Utils_EmailTemplates.getUserCategoriesMap('Other');
            List<Object> getEmailTemplateV2List = CLT_Utils_EmailTemplates.getEmailTemplatesV2(new List<String> {'EN'}, userCategoriesMap, 'Other');

			System.assertEquals(1, getEmailTemplateV2List.size(), 'CLT_Utils_EmailTemplates_Test:testGetEmailTemplatesV2: get templates v2 list size is not 1');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetEmailTemplates() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Test.startTest();
            Map<String, Object> userCategoriesMap = CLT_Utils_EmailTemplates.getUserCategoriesMap('Other');
            List<Object> getEmailTemplateV2List = CLT_Utils_EmailTemplates.getEmailTemplates(new List<String> {'EN'});

			System.assertEquals(1, getEmailTemplateV2List.size(), 'CLT_Utils_EmailTemplates_Test:testGetEmailTemplates: get templates list size is not 1');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetUserCategoriesMap() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Map<String, Object> userCategoriesMap = CLT_Utils_EmailTemplates.getUserCategoriesMap('Other');
            System.assertEquals(true, userCategoriesMap.containsKey('Other'), 'CLT_Utils_EmailTemplates_Test:testGetUserCategoriesMap: userCategoriesMap not contain sent default category in keyset.');
        }
    }

    @isTest
    static void testGetEmailTemplatesImages() {
        CLT_Email_Template__c cltET = [SELECT Email_Template_Id__c FROM CLT_Email_Template__c WHERE PersonalizedTemplate__c = false];

        Test.startTest();
        Map<Id, List<Object>> emailTemplateImagesMap = CLT_Utils_EmailTemplates.getEmailTemplatesImages(new Set<String> {cltET.Email_Template_Id__c});
        Test.stopTest();
        System.assertEquals(2, emailTemplateImagesMap.get(cltET.Email_Template_Id__c).size(), 'CLT_Utils_EmailTemplates_Test:testGetEmailTemplatesImages: images list size is not 2');
    }

    @isTest
    static void testGetSharingTemplates() {
        Map<String, CLT_FieldsMapping__mdt> fieldsMapping = CLT_Utils_Mapping.getMappingObjectDict('EmailTemplate', 'EmailTemplate', 'SFFieldPath__c');
        Map<String,Object> sharingTemplatesMap = CLT_Utils_EmailTemplates.getSharingTemplates(new List<String> {'EN'},  fieldsMapping);

        List<EmailTemplate> sharingTemplateList = [SELECT Id FROM EmailTemplate WHERE Folder.DeveloperName = 'Sharing_Templates' AND Name LIKE 'EN%' AND IsActive = TRUE];
        System.assertEquals(sharingTemplateList.size(), sharingTemplatesMap.keySet().size(), 'CLT_Utils_EmailTemplates_Test:testGetSharingTemplates: sharing template list size is not as expected');
    }

    @isTest
    static void testUpsertPersonalizedEmailTemplate() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Map<String,Object> body = new Map<String,Object> {
                'name' => 'test name',
                'lang' => 'english',
                'reason' => 'Other',
                'subject' => 'test subject',
                'plainText' => 'test plainText',
                'signature' => 'test signature',
                'type' => 'Email'
            };
            Map<String, Object> upsertedPersonalTemplate = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(((List<Object>)JSON.deserializeUntyped(JSON.serialize(CLT_Utils_EmailTemplates.upsertPersonalizedEmailTemplate(body))))[0]));
            CLT_Email_Template__c personalEmailTemplate = [SELECT Id FROM CLT_Email_Template__c WHERE User__c = :sa.Id AND PersonalizedTemplate__c = true];
            System.assertEquals(personalEmailTemplate.Id, (String)upsertedPersonalTemplate.get('id'), 'CLT_Utils_EmailTemplates_Test:testUpsertPersonalizedEmailTemplate: retrieved another personal template');
        }
    }

    @isTest
    static void testGetEmailTemplateCLTFromBody() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];
        System.runAs(sa) {
            Map<String,Object> body = new Map<String,Object> {
                'name' => 'test name',
                'lang' => 'english',
                'reason' => 'Other',
                'subject' => 'test subject',
                'plainText' => 'test plainText',
                'signature' => 'test signature',
                'type' => 'Email'
            };
            CLT_Email_Template__c personalEmailTemplate = CLT_Utils_EmailTemplates.getEmailTemplateCLTFromBody(body);
            System.assertEquals(sa.Id, personalEmailTemplate.User__c, 'CLT_Utils_EmailTemplates_Test:testGetEmailTemplateCLTFromBody: personal template user is not the creating user');
        }
    }

    @isTest
    static void testDeletePersonalCLTEmailTemplate() {
        String testUserEmailPostfix = '%' + CLT_TestDateFactory.TEST_USER_EMAIL_POSTFIX;
        User sa = [SELECT Id FROM User WHERE Username LIKE :testUserEmailPostfix AND Profile.Name = :System.Label.profileName_StoreUser LIMIT 1];

        System.runAs(sa) {
            CLT_Email_Template__c cltEmailTemplate = new CLT_Email_Template__c();
            cltEmailTemplate.Category__c = 'Other';
            cltEmailTemplate.Name = 'TESTPersonal';
            cltEmailTemplate.Is_Active__c = true;
            cltEmailTemplate.PersonalizedTemplate__c = true; 
            cltEmailTemplate.User__c = sa.Id;
            insert cltEmailTemplate;

            Test.startTest();
            CLT_Utils_EmailTemplates.deletePersonalCLTEmailTemplate(new Map<String, String>{'id' => cltEmailTemplate.Id});
            Test.stopTest();
            List<CLT_Email_Template__c> sltTemplatesAfterDelete = [SELECT Id FROM CLT_Email_Template__c WHERE Id = :cltEmailTemplate.Id];
            System.assertEquals(0, sltTemplatesAfterDelete.size(), 'CLT_Utils_EmailTemplates_Test:testDeletePersonalCLTEmailTemplate: personal templates list size is not 0 after delete');
        }  
    }
}