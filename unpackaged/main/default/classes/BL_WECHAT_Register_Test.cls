@isTest
public class BL_WECHAT_Register_Test {
    @isTest
    static void test_register() {
        Savepoint sp = Database.setSavepoint();
        Id rtId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        try{
            BL_WECHAT_Register blRequest = new BL_WECHAT_Register();
            RestRequest req = new RestRequest();
            req.requestURI = 'wechat/v0/offiaccount/register';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{"last_name":"test"}');
            RestContext.request = req;
            blRequest.init('wechat/v0/offiaccount/register',  '/offiaccount/register', null);
    
            Object o = blRequest.executePOST();

        }
        catch(Exception ex){
            Database.rollback(sp); 
            throw new BL_Exceptions.CLTException(ex.getMessage(), ex.getMessage());
        }

    }
    @isTest
    static void test_register2() {
        Savepoint sp = Database.setSavepoint();
        Id rtId =  Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        try{
            BL_WECHAT_Register blRequest = new BL_WECHAT_Register();
            RestRequest req = new RestRequest();
            req.requestURI = 'wechat/v0/offiaccount/register';
            req.httpMethod = 'POST';
            req.requestBody = Blob.valueOf('{}');
            RestContext.request = req;
            blRequest.init('wechat/v0/offiaccount/register',  '/offiaccount/register', null);
    
            Object o = blRequest.executePOST();

        }
        catch(Exception ex){
            Database.rollback(sp);
        }

    }
}