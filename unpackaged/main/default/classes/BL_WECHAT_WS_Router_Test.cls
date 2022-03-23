@isTest
private class BL_WECHAT_WS_Router_Test {
     @isTest
     static void testRestRouterGet(){
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'wechat/v1/offiaccount/register';
         
        RestContext.request = req;
        RestContext.request.httpMethod ='GET';
        RestContext.response = res;
        
        
        Test.startTest();
        BL_WECHAT_WS_Router.doGET();
        Test.stopTest();
    }
    
    @isTest
    static void testRestRouterPost(){
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'wechat/v1/offiaccount/register';

        RestContext.request = req;
        RestContext.request.httpMethod ='POST';
        RestContext.response = res;
        
        
        Test.startTest();
        BL_WECHAT_WS_Router.doPOST();
        Test.stopTest();
    }
    
    @isTest
    static void testRestRouterPatch(){
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'wechat/v1/offiaccount/register';

        RestContext.request = req;
        RestContext.request.httpMethod ='PATCH';
        RestContext.response = res;
        
        
        Test.startTest();
        BL_WECHAT_WS_Router.doPATCH();
        Test.stopTest();
    }
    
    
    @isTest
    static void testRestRouterDelete(){
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'wechat/v1/offiaccount/register';

        RestContext.request = req;
        RestContext.request.httpMethod ='DELETE';
        RestContext.response = res;
        
        
        Test.startTest();
        BL_WECHAT_WS_Router.doDELETE();
        Test.stopTest();
    }
    
    @isTest
    static void testRestRouterPut(){
        Test.setMock(HttpCalloutMock.class, new BL_WECHAT_CalloutMockInstance());

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = 'wechat/v1/offiaccount/register';

        RestContext.request = req;
        RestContext.request.httpMethod ='PUT';
        RestContext.response = res;
        
        
        Test.startTest();
        BL_WECHAT_WS_Router.doPUT();
        BL_WS_Router router = new BL_WS_Router();
        router.initCustomMergeFields();
        BL_WS_RouteMapping brm= new BL_WS_RouteMapping();
        brm.routesMapping();
        Test.stopTest();
    }

}