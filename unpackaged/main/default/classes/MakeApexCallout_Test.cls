@IsTest
private class MakeApexCallout_Test {
    
    	@isTest static void test_method() {
 			Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            MakeApexCallout.Dcase dcase=new MakeApexCallout.Dcase();
            dcase.clients_email='test@test.com';
            dcase.survey_id='12';
            dcase.template_id='1';
            List<MakeApexCallout.Dcase> dcaseList=new List<MakeApexCallout.Dcase>();
            dcaseList.add(dcase);
          	MakeApexCallout.invokeapexcallout(dcaseList);
            Test.stopTest();
        }

}