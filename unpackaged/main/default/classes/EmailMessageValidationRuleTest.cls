@IsTest
private class EmailMessageValidationRuleTest {
    
    // Test method to verify domain validation logic without bypass permission
    @IsTest
    static void testErrorMessageSME_WithoutBypassPermission() {
        // Setup test data: Assume Admin_Email__mdt has '@example.com' as an allowed domain
        // Mocking Custom Metadata setup is assumed to be handled in the actual method or via mocking framework
        
        // Prepare a list of EmailMessage records for testing
        EmailMessage emailWithAllowedDomain = new EmailMessage();
        emailWithAllowedDomain.ToAddress = 'user1@example.com;user2@alloweddomain.com';
        emailWithAllowedDomain.ToSme__c = true;
        
        EmailMessage emailWithDisallowedDomain = new EmailMessage();
        emailWithDisallowedDomain.ToAddress = 'user3@disalloweddomain.com';
        emailWithDisallowedDomain.ToSme__c = true;
        
        List<EmailMessage> emailMessages = new List<EmailMessage>{emailWithAllowedDomain, emailWithDisallowedDomain};
        
        // Execute the method under test
        Test.startTest();
        EmailMessageValidationRule.errorMessageSME(emailMessages);
        Test.stopTest();
        
        // Assertions: Since we cannot directly assert on addError() without DML,
        // consider asserting on expected outcomes that result from the addError() logic.
        // For example, verify that an expected exception is thrown for records with disallowed domains,
        // or use a mocking framework to intercept and assert on addError() calls.
    }
    
    // Optional: Test method to verify logic with bypass permission
    @IsTest
    static void testErrorMessageSME_WithBypassPermission() {
        // This test would simulate the scenario where the user has the 'ByPassVR' custom permission
        // and thereby should not trigger the domain validation logic.
        
        // The approach to simulate the user having the 'ByPassVR' permission depends on your org's setup
        // and might involve mocking the FeatureManagement.checkPermission method to return true.
    }
    
    // Utility method to simulate fetching allowed domains from Custom Metadata in tests
    // This is a placeholder and should be adapted to your testing strategy.
    private static Set<String> simulateFetchAllowedDomains() {
        // Example: Simulate '@example.com' as an allowed domain
        return new Set<String>{'@example.com'};
    }
}