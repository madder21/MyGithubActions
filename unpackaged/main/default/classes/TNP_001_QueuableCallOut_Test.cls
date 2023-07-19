/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP_001_QueuableCallOut  
-- - Author             : Ilhem Zraiga
-- - Description        : TNP_001_QueuableCallOut Test Class
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 19/05/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
@isTest
public class TNP_001_QueuableCallOut_Test {
    
    
    @isTest 
    public static void listAccountAfterInsert_TEST (){
        AccountAPI__c apiAccount = new AccountAPI__c();
        apiAccount.Name = 'Account Api';
        apiAccount.EndPoint__c = 'https://api-nprd.rimowa.com/qa/salesforce-eapi/v1/customer-cleansing';
        apiAccount.Method__c ='POST';
        apiAccount.Client_Id__c = '64983556f39d4710952c7a461d8c3ea5';
        apiAccount.Content_Type__c='application/json';
        apiAccount.Client_secret__c='A058Cc3117E843Fba0c93a5FbA4E8b33';
        insert apiAccount;
        Account account =  new Account();
        account.LastName='Account4';
        account.PersonEmail = 'Account.test4@gmail.com';
        account.B2C_Customer_ID__pc = 'abKveEa2SaQRM0004';
        account.B2C_Customer_No__pc = '000170004';
        account.Country__pc = 'FR';
        account.LastUpdateOptinEmailing__pc = System.now();
        account.OptinEmailing__pc = true;
        account.Country__pc='FR';
        
        insert account;
                CountryCode__c CountryCode = new CountryCode__c();
        CountryCode.Name = 'France';
        CountryCode.Alpha_2_code__c = 'FR';
        CountryCode.Alpha_3_code__c ='FRA';
        insert CountryCode;
          Test.setMock(HttpCalloutMock.class, new MockUpdateInsertAccount());
       // TNP_001_QueueableCallOut queue = new TNP_001_QueueableCallOut();
    }
    
    private class MockUpdateInsertAccount implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/xml');
            //Endpoint of update Account call
            
            res.setBody('{Done}');
            res.setStatusCode(200);
            res.setStatus('OK');
            
            return res;
        }
    }
    
    
}