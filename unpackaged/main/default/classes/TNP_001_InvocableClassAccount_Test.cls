@isTest
public class TNP_001_InvocableClassAccount_Test {
    
   public  class AccountIntegrationRequest {       
        public Account account; 
        public B2CContactProcessCustomInput customInputRecord;
    }
    @isTest
    Public static void sendAccountDataTest(){
   TNP_001_InvocableClassAccount.AccountIntegrationRequest AccountIntegrationRequestInput = new TNP_001_InvocableClassAccount.AccountIntegrationRequest();
        List<AccountIntegrationRequest> flowInputs = new List<AccountIntegrationRequest>();
        CountryCode__c CountryCode = new CountryCode__c();
        CountryCode.Name = 'France';
        CountryCode.Alpha_2_code__c = 'FR';
        CountryCode.Alpha_3_code__c ='FRA';
        insert CountryCode;
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
        
        
        AccountIntegrationRequestInput.account = account;
        B2CContactProcessCustomInput customInputObj = new B2CContactProcessCustomInput();
        customInputObj.CaptureSource = 'Account Creation';
        
        
      
        AccountIntegrationRequestInput.customInputRecord = customInputObj;
        //flowInputs.add(AccountIntegrationRequestInput);
        //insert flowInputs;
        Test.setMock(HttpCalloutMock.class, new MockUpdateInsertAccount());
        TNP_001_InvocableClassAccount.sendAccountData(new list< TNP_001_InvocableClassAccount.AccountIntegrationRequest>{AccountIntegrationRequestInput});
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