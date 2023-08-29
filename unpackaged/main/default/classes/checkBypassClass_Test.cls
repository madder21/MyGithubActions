@isTest
public class checkBypassClass_Test {
	
    @isTest
    static void checkBypassClassTest_user_ECOIntegration() {
        
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'ecom', Email='eco-integration@rimowa.com',
        				  EmailEncodingKey='UTF-8', LastName='Integration', FirstName='ECO', LanguageLocaleKey='en_US',
        				  LocaleSidKey='en_US', ProfileId = p.Id,
        				  TimeZoneSidKey='America/Los_Angeles',
        				  UserName='eco-integration@rimowa.com.testcontext');
        
        System.runAs(u) {
            Test.startTest();
            	Boolean resultTrue = BypassTrigger.checkBypassClass('AccountTriggerHandler');
            	Boolean resultFalse = BypassTrigger.checkBypassClass('NoNameClass');
            Test.stopTest();
            Assert.isTrue(resultTrue);
            Assert.isFalse(resultFalse);
        }
    }
    
    @isTest
    static void checkBypassClassTest_user_currentUser() {
        
        Test.startTest();
        	Boolean resultFalse = BypassTrigger.checkBypassClass('NoNameClass');
        Test.stopTest();

        Assert.isFalse(resultFalse);

    }
}