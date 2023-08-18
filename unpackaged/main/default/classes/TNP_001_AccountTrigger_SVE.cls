/*     
-------------------------------------------------------------------------------------------
-- - Name               : TNP_001_AccountTrigger_SVE  
-- - Author             : Ilhem Zraiga
-- - Description        : Handler for the Trigger AccountTriggerHandler 
--    
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ------------------------------------------------------------
-- 20/03/2023    IZR    1.0      Intitial version
-------------------------------------------------------------------------------------------
*/
public with sharing class TNP_001_AccountTrigger_SVE {
    Public Static String CLASS_NAME = 'TNP_001_AccountTrigger_SVE';
    
    public static void listAccountAfterInsert( list<account> listAccountToInsert)
    {  
        String METHOD_NAME = 'listAccountAfterInsert';
        list<account> listFinalAccountToInsert = new list<account>();
        Map<Id,User> mapInfoUser = TNP_002_ServiceClass.returnMapUserIntegration();
       map<String,SObject> mapSobject  = new map<String,SObject>();
        for (Account accountToInsert:listAccountToInsert ){
             User user = mapInfoUser.get(accountToInsert.CreatedById);
            if (user == null || (user != null && user.Name == Label.SFSC_Integration_User) ){
                listFinalAccountToInsert.add(accountToInsert);
            }
        }
        
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        if ( !listFinalAccountToInsert.isEmpty() )
        {    
            System.enqueueJob(new TNP_001_QueueableCallOut(listFinalAccountToInsert,'',Label.TNP_CL_AfterInsert));   
        }     
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
    }    
    
    
  public static void listAccountAfterUpdate( list<account> listAccountToUpdate)
    {  
        String METHOD_NAME = 'listAccountAfterUpdate';
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
         list<account> listFinalAccountToUpdate = new list<account>();
        Map<Id,User> mapInfoUser = TNP_002_ServiceClass.returnMapUserIntegration();
       
        for (Account accountToUpdate: listAccountToUpdate ){
             User user = mapInfoUser.get(accountToUpdate.LastModifiedById);
            if (user == null || (user != null && user.Name == Label.SFSC_Integration_User)  ){
                listFinalAccountToUpdate.add(accountToUpdate);
            }
        }
     if ( !listFinalAccountToUpdate.isEmpty() )
        {  
            System.enqueueJob(new TNP_001_QueueableCallOut(listFinalAccountToUpdate,'',Label.TNP_CL_AfterUpdate));   
        }  
        
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END');         
    } 

    
}