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
public  class TNP_001_InvocableClassAccount {
    Public Static String CLASS_NAME = 'TNP_001_InvocableClassAccount';
   
    @InvocableMethod(label='send Account Data to Mulsoft')
    public static void sendAccountData(List<AccountIntegrationRequest> flowInputs) {
        String METHOD_NAME = 'sendAccountData';
         System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        Account accountInput = new Account();
        B2CContactProcessCustomInput customInputRecord = new  B2CContactProcessCustomInput();
         String JSONGenerated ;
        System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'flowInputs -->'+flowInputs);
        if (flowInputs != null && flowInputs.size()>0){
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'flowInputs[0] -->'+flowInputs[0]);
            accountInput = flowInputs[0].account;
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'accountInput -->'+accountInput.id);
            Account acc = TNP001_DM_Account.getAccountById(accountInput.id);
            customInputRecord = flowInputs[0].customInputRecord; 
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'customInputRecord -->'+customInputRecord);
             System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'customInputRecord -->'+customInputRecord.CaptureSource);
            JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,customInputRecord.CaptureSource);
            
        }	
        System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'JSONGenerated -->'+JSONGenerated);
        if (JSONGenerated != null){
            //TNP_002_ServiceClass.sendRequest(JSONGenerated);
            System.enqueueJob(new TNP_001_QueueableCallOut(JSONGenerated));  
            
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