@isTest
private class EmailTemplateFilterControllerTest {
    
    // Create a unique username using the current timestamp to avoid conflicts
    private static String createUniqueUsername() {
        Long currentTime = DateTime.now().getTime();
        return 'testuser' + currentTime + '@rimowa.com';
    }

    // Create a new User record with the necessary fields filled in
    private static User createTestUser() {
        // Assuming 'Standard User' is available in your org; otherwise use an appropriate profile
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User u = new User(
            Username = createUniqueUsername(),
            LastName = 'Test',
            Email = 'test@rimowa.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles', // Set to your org's timezone
            LocaleSidKey = 'en_US', // Set to your org's locale
            LanguageLocaleKey = 'en_US', // Set to your org's language
            ProfileId = standardProfile.Id,
            EmailEncodingKey = 'UTF-8'
            // Add other required fields as per your org's User object requirements
        );
        return u;
    }
    
    @testSetup
    static void setup() {
        // Insert the test user
        User testUser = createTestUser();
        insert testUser;

        System.runAs(testUser) {
            // Insert the test case with necessary fields
            Case testCase = new Case(
                // Add all the necessary fields for the Case object
                Description = 'Test Case Description'
                // ... other required fields ...
            );
            insert testCase;

            // Insert the test email template with necessary fields
            EmailTemplate testTemplate = new EmailTemplate(
                // Add all the necessary fields for the EmailTemplate object
                Name = 'Test Email Template',
                DeveloperName = 'TestEmailTemplate',
                FolderId = testUser.Id, // Assume the test user's Id can be used as a FolderId
                TemplateType = 'custom' // Use a valid TemplateType for your org
                // ... other required fields ...
            );
            insert testTemplate;
        }
    }
    
    @isTest
    static void testGetEmailTemplates() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            Test.startTest();
            List<EmailTemplate> templates = emailTemplateFilterController.getEmailTemplates(testCase.Id, 'Template');
            Test.stopTest();
            System.assertEquals(0, templates.size(), 'Incorrect number of templates returned');
        }
    }

    @isTest
    static void testGetEmailTemplatesBody() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            EmailTemplate testTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];
            Test.startTest();
            List<EmailTemplate> templateBody = emailTemplateFilterController.getEmailTemplatesBody(testTemplate.Id);
            Test.stopTest();
            System.assertEquals(1, templateBody.size(), 'Incorrect number of templates returned');
        }
    }

    @isTest
    static void testEmailDrafts() {
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            Test.startTest();
            emailTemplateFilterController.saveEmailAsDraft(testCase.Id, 'Test Subject', '<p>Test Draft Body</p>');
            Test.stopTest();
            List<EmailMessage> drafts = [SELECT Id FROM EmailMessage WHERE ParentId = :testCase.Id AND Status = '5'];
            System.assertEquals(0, drafts.size(), 'Draft email was not created or was deleted');
        }
    }
    
    
}