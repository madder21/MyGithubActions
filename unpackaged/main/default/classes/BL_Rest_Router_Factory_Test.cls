@isTest
public class BL_Rest_Router_Factory_Test {
    
    @isTest
    static void BL_Rest_Router_FactoryTest(){
        List<String> fields = new List<String>();
        Map<String, Object> params = new Map<String, Object>();
        params.put('message' , 'message');
        params.put('clientMessage' , 'clientMessage');
        params.put('errorCode' , 'errorCode');
        params.put('statusCode' , 123);
        Test.startTest();
        BL_Rest_Router_Factory.Route rout = new BL_Rest_Router_Factory.Route('client' , 'retail/V1*');
        BL_Rest_Router_Factory.RestResponseObject obj = new BL_Rest_Router_Factory.RestResponseObject('client');
        BL_Rest_Router_Factory.RestResponseError err = new BL_Rest_Router_Factory.RestResponseError('message', 'err', fields ,'client message');
        BL_Rest_Router_Factory.RouterException excep = new BL_Rest_Router_Factory.RouterException(params);
        BL_Rest_Router_Factory.RouterException excep2 = new BL_Rest_Router_Factory.RouterException('message', 'clientMessage', 'errorCode' , 123);
         Test.stopTest();
    }

}