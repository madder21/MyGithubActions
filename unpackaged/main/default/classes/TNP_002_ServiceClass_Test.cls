/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP_002_ServiceClass_Test  
-- - Author             : Ilhem Zraiga
-- - Description        : TNP_002_ServiceClass Test Class
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 19/05/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
@isTest
public class TNP_002_ServiceClass_Test {
 @isTest
    static public void GenerateJSONTest(){   
        Account acc = new Account();
        acc.Name = 'Test';
        acc.B2C_Customer_ID__pc ='12333233';
        acc.B2C_Customer_No__pc = '22223';
        acc.Country__pc = 'FR';
        acc.FirstName ='Test';
        acc.PersonEmail ='test@tes.com';
        acc.B2C_CustomerList_ID__pc = 'Rimowa';
        insert acc;
        
         Map<string,object> clientMap = TNP_002_ServiceClass.buildObjectMap(acc, 'TNP_ClientMap__c');
         Map<string,object> addressMap = TNP_002_ServiceClass.buildObjectMap(acc, 'TNP_AddressMap__c');
        Map<string,object> emailMap = TNP_002_ServiceClass.buildObjectMap(acc, 'TNP_EmailMap__c');
         Map<string,object> phoneMap = TNP_002_ServiceClass.buildObjectMap(acc, 'TNP_PhoneMap__c');
        Map<string,object> consentMap = TNP_002_ServiceClass.buildObjectMap(acc, 'TNP_ConsentMap__c');
        
    }

}