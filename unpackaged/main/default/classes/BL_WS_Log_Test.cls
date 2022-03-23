@isTest
public with sharing class BL_WS_Log_Test {
    @isTest
    static void testGeneral(){    
        
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());
        String json= '{}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueof(json);

        RestContext.request = req;
        RestContext.response = res;
        
        BL_AppSettings.setAppSettings('Clienteling');
        BL_AppSettings.currentAppSettings.isLogActive = true;
        BL_AppSettings.currentAppSettings.isImmediateLog = true;
        
        Test.startTest();
            BL_WS_Log.setPersistentLog('CLT_Task','Clienteling');
       		BL_WS_Log.setErrorLogException( new CalloutException());
      	    BL_WS_Log.addLogNotes('Test','');
            BL_WS_Log.addLogNotes('Test');
            BL_WS_Log.getErrorMessage();
            BL_WS_Log.insertPersistentLog();
            BL_WS_Log.insertPersistentLogWithError();
        	BL_WS_Log.insertPersistentLogWithError( new CalloutException());
            BL_WS_Log.asyncInsertPersistemtLog();
            BL_WS_Log.closePersistentLog();
        Test.stopTest();

    }
    
    //test 'setPersistentLog' without request body and 'insertPersistentLog' with 'isLogActive' = false
    @isTest
    static void testMethod2(){
        
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        RestRequest req = new RestRequest();
        RestContext.request = req;    
        
        BL_AppSettings.setAppSettings('Clienteling');
        BL_AppSettings.currentAppSettings.isLogActive = false;
        BL_AppSettings.currentAppSettings.isImmediateLog = true;
        String appName = BL_AppSettings.currentApplicationName;
        
        Test.startTest();
			BL_WS_Log.setPersistentLog('CLT_Task','Clienteling');
        	BL_WS_Log.insertPersistentLog();
        Test.stopTest();
    }
    
    //test functions without defined app
    @isTest
    static void testMethod3(){
        
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        RestRequest req = new RestRequest();
        RestContext.request = req;      
        
        Test.startTest();
           try{
                BL_WS_Log.insertPersistentLog();
                BL_WS_Log.getErrorMessage();
                BL_WS_Log.asyncInsertPersistemtLog();
            }
            catch(exception e){}
        Test.stopTest();

    }
}