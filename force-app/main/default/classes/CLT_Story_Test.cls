@IsTest
private class CLT_Story_Test {

	@isTest static void test_story_methods() {
        
        Story__c newStory = new Story__c();
        insert newStory;
        
        CLT_Story story = new  CLT_Story();
 		Test.startTest();

		story.retrieveGet(new Map<String, String>());
		story.retrieveDelete(new Map<String, String>());
		story.retrievePost(new Map<String, String>(),new Map<String,Object>());

		Test.stopTest();

    }
}