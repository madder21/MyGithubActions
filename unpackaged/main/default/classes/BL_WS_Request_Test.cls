/**
* @group Clienteling 
* @since Juny 2020
* @description Test class for BL_WS_Request
*/

@isTest
public class BL_WS_Request_Test {
    
    @isTest
    static void testMethod1(){
        
        BL_WS_Request request = new BL_WS_Request();
        
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());
        //Object ob= BL_AppSettings.customParams;
        BL_AppSettings.setAppSettings('WECHAT');
        String json= '{	"records" :[	]}';      

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueof(json);
        
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
     	     request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
       		 request.getRequestRecord();
     	     request.getRequestRecords();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2(){   
        BL_WS_Request request = new BL_WS_Request();

        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());
        BL_AppSettings.setAppSettings('WECHAT');

        RestRequest req = new RestRequest();
        req.params.put('s', 'test');
        RestContext.request = req;
        
        Test.startTest();
           try{
           		 request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
               
                req.params.put('pageIndex', '');
                request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
            }
            catch(exception e){}
        
           req.params.put('pageIndex', '6');
            try{
           		 request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
            }
            catch(exception e){}
        
        	req.params.put('pageSize', '');
        	try{
           		 request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
            }
       		 catch(exception e){}
                
        	req.params.put('queryId', '');
        	try{
           		 request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
            }
       		 catch(exception e){}

        	
        Test.stopTest();
    }
    
    @isTest
    static void testMethod3(){   
        BL_WS_Request request = new BL_WS_Request();
        
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        BL_AppSettings.setAppSettings('WECHAT');
        
        RestRequest req = new RestRequest();            
        RestContext.request = req;
        
        request.supportedQueryParams = new Set<String>{'aaa'};
        req.params.put('pageIndex', '6');
        
        Test.startTest();
           try{
           		 request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
            }
            catch(exception e){}
           
        	
        Test.stopTest();
    }

    @isTest
    static void testMethod4(){   
        BL_WS_Request request = new BL_WS_Request();
        
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        BL_AppSettings.setAppSettings('WECHAT');
        
        RestRequest req = new RestRequest();            
        RestContext.request = req;
        
        request.supportedQueryParams = new Set<String>{'aaa'};
        req.params.put('queryId', '');
        
        Test.startTest();
           try{
           		 request.init('/wechat/v0/bind', 'path', (BL_UserInfo)Type.forName('BL_WECHAT_UserInfo').newInstance());
            }
            catch(exception e){}
           
        	
        Test.stopTest();
    }

}