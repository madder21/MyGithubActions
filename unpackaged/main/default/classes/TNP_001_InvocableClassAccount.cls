/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP_001_InvocableClassAccount  
-- - Author             : Ilhem Zraiga
-- - Description        : Class invocable by the B2C Account Creation/Update process Flow 
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 21/03/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
public  with sharing class TNP_001_InvocableClassAccount {
    Public Static String CLASS_NAME = 'TNP_001_InvocableClassAccount';
   
    @InvocableMethod(label='send Account Data to Mulsoft')
    public static void sendAccountData(List<AccountIntegrationRequest> flowInputs) {
        String METHOD_NAME = 'sendAccountData';
        Account acc = new Account(); 
         System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        B2CContactProcessCustomInput customInputRecord = new  B2CContactProcessCustomInput();
        System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'flowInputs -->'+flowInputs);
        if (flowInputs != null && flowInputs.size()>0){
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'flowInputs[0] -->'+flowInputs[0]);
            ID accountInputID = flowInputs[0].account.id;
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'accountInput -->'+accountInputID);
             acc = TNP001_DM_Account.getAccountById(accountInputID);
            customInputRecord = flowInputs[0].customInputRecord; 
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'customInputRecord -->'+customInputRecord);
             System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'customInputRecord.CaptureSource -->'+customInputRecord.CaptureSource);
           
        }	
        if (customInputRecord.CaptureSource != null){
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'customInputRecord -->'+customInputRecord.CaptureSource);
            System.enqueueJob(new TNP_001_QueueableCallOut(new list<Account>{acc},customInputRecord.CaptureSource,Label.TNP_CL_Invocable));  
            
        }
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
    } 
    public class AccountIntegrationRequest {
        @InvocableVariable(required=true)
        public Account account;
        @InvocableVariable(required=true)
        public B2CContactProcessCustomInput customInputRecord;
       
    }
    
    
    
    
    
    
    
    
}