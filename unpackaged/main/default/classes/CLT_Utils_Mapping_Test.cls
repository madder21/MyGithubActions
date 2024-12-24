@isTest
private class CLT_Utils_Mapping_Test {
	
	@isTest static void test_method_one() {
		Map<String, String> params = new Map<String, String>();
		Map<String, Object> body = new Map<String, Object>();
		params.put('', '');

		Test.startTest();
		
		CLT_Utils_Mapping.getMappingByObjectTitle('Account');
		CLT_Utils_Mapping.getMappingObjectDict('Account', 'Account' ,'SFFieldPath__c');
		CLT_Utils_Mapping.getQueryString('Account', 'Account', 'SELECT Id From ');
        CLT_Utils_Mapping.getStandardWrapperList('CLT_NotificationManagement__mdt', 'NotificationManagement', 'FROM CLT_NotificationManagement__mdt WHERE Muted__c = FALSE AND CanBeMuteByCA__c = TRUE');
        
		//CLT_Utils_Mapping.getStandardWrapperList('Account', 'Account', 'SELECT Id From ');
		//CLT_Utils_Mapping.getStandardWrapperListFromObjectList('Account', null);
		Test.stopTest();
	}
	
}