/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP001_AccountTrigger  
-- - Author             : Ilhem Zraiga
-- - Description        : Trigger for account  object 
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 21/03/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
trigger TNP001_AccountTrigger on Account (before insert,after insert, after update, before update) {
    
    if (Trigger.isAfter) {
        System.debug('/'+ 'IsAfter-->'+Trigger.New); 
        if (Trigger.isInsert) {
            System.debug('/'+ 'ISINSERT-->'+Trigger.New); 
            //TNP_001_AccountTriggerHandler.listAccountAfterInsert(Trigger.New);
        }
        if (Trigger.isUpdate) {
             System.debug('/'+ 'ISUPDATE-->'+Trigger.New); 
            // TNP_001_AccountTriggerHandler.listAccountAfterUpdate(Trigger.New);
        }
    }
    
}