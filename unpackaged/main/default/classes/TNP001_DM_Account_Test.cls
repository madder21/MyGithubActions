/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP001_DM_Account_Test  
-- - Author             : Ilhem Zraiga
-- - Description        : Data Managment Account Object Test Class
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 19/05/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
@isTest
public class TNP001_DM_Account_Test {
    @isTest
    static public void getAccount(){   
        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;
        TNP001_DM_Account.getAccountById(acc.Id);
    }

}