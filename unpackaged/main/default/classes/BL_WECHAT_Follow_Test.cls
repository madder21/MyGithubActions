@isTest
public class BL_WECHAT_Follow_Test {
    @isTest
    static void test_follow() {

        BL_WECHAT_Follow blRequest = new BL_WECHAT_Follow();
        RestRequest req = new RestRequest();
        req.requestURI = 'wechat/v0/offiaccount/follow';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{ "unionid": "test8", "last_name":"test"}');
        RestContext.request = req;
        blRequest.init('wechat/v0/offiaccount/follow',  '/offiaccount/follow', null);

        Object o = blRequest.executePOST();

    }

    @isTest
    static void test_follow2() {

        BL_WECHAT_Follow blRequest = new BL_WECHAT_Follow();
        RestRequest req = new RestRequest();
        req.requestURI = 'wechat/v0/offiaccount/follow';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        RestContext.request = req;
        blRequest.init('wechat/v0/offiaccount/follow',  '/offiaccount/follow', null);

        Object o = blRequest.executePOST();

    }
    
}