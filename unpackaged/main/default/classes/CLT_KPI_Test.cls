/*
 * Created by israel on 7/14/2019.
 */
@IsTest
private class CLT_KPI_Test {

	@isTest static void test_method_one() {
		Map<String, String> params = new Map<String, String>();
		Map<String, Object> body = new Map<String, Object>();
		CLT_KPI kpi = new CLT_KPI();


		User u = [SELECT id FROM User where StoreCode__c != null AND IsActive = true  LIMIT 1];
		System.runAs(u){
			params.put('userIds', '["' + u.Id + '"]');
			params.put('myStore', 'true');
			params.put('period', 'm');
			Test.startTest();
			kpi.retrieveGet(params);
			kpi.retrievePost(params, body);
			Test.stopTest();
		}


	}
}