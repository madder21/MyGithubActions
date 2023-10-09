/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP001_AccountTriggerHandler_Test  
-- - Author             : Ilhem Zraiga
-- - Description        : TNP001_AccountTriggerHandler Test Class
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 19/05/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
@isTest 
public class TNP001_AccountTriggerHandler_Test {
    
    @isTest
    static void testCreateNotificationContent() {
        // Create a list of test Account records
        List<Account> accList = TestDataFactory.createSObjectList('Account',10);
        Test.startTest();
        
        // Call the createNotificationContent method
        TNP_001_AccountTrigger_SVE.createNotificationContent(accList);
        
        Test.stopTest();
        
        // Add assertions or verifications here based on your specific requirements
        // For example, you can check debug logs or verify that the queuable job was enqueued.
    }

    @isTest 
    public static void listAccountAfterInsert_TEST (){
        AccountAPI__c apiAccount = new AccountAPI__c();
        apiAccount.Name = 'Account Api';
        apiAccount.EndPoint__c = 'https://api-nprd.rimowa.com/qa/salesforce-eapi/v1/customer-cleansing';
        apiAccount.Method__c ='POST';
        apiAccount.Client_Id__c ='64983556f39d4710952c7a461d8c3ea5';
        apiAccount.Client_secret__c ='A058Cc3117E843Fba0c93a5FbA4E8b33';
        insert apiAccount;
        
        User user = new User();
        user.FirstName =Label.SFSC_Integration_User ;
        user.isIntegrationUser__c =true;
        user.Username= 'test22112@test.com';
            user.LastName= 'test';
            user.Email='test@test.com';
            user.Alias='ttest';
            user.TimeZoneSidKey='Europe/Paris';
            user.LocaleSidKey= 'fr_FR_EURO';
            user.EmailEncodingKey= 'ISO-8859-1';
            user.ProfileId ='00e1t000001XlmsAAC';
            user.LanguageLocaleKey='en_US';
            insert user;
        Account acc = new Account();
        acc.firstName ='laurent';
        acc.LastName ='laurent';
        acc.CreatedById=user.Id;
        Test.setMock(HttpCalloutMock.class, new MockUpdateInsertAccount());
        Test.startTest();
        insert acc;
       
        acc = [select id,firstName 
               from account
               where firstName ='laurent' ];
        acc.LastName ='Amine';
             
        update acc;
        
        
        Test.stopTest();
         system.assertNotEquals (acc , null);
    }
    
    private class MockUpdateInsertAccount implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Client Id', '64983556f39d4710952c7a461d8c3ea5');
            res.setHeader('Client secret', 'A058Cc3117E843Fba0c93a5FbA4E8b33');
            //Endpoint of update Account call
            
            res.setBody('{Done}');
            res.setStatusCode(200);
            res.setStatus('OK');
            
            return res;
        }
    
    
}
}