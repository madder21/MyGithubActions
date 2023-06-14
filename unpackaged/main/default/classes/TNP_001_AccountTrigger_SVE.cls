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
public class TNP_001_AccountTrigger_SVE {
    Public Static String CLASS_NAME = 'TNP_001_AccountTrigger_SVE';
    
    public static void listAccountAfterInsert( list<account> accountToInsert)
    {  
        String METHOD_NAME = 'listAccountAfterInsert';
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        string jsonstring;
        String JSONGenerated;
        list<string> listJSON = new list <String>();
        Map<Id,User> mapInfoUser = returnMapUserIntegration();
        map<string,account> mapListAllAccount = new map<string,account>();  
        if ( !accountToInsert.isEmpty() )
        {       
            for (Account acc : accountToInsert ){
                User user = mapInfoUser.get(acc.CreatedById);
                System.debug('acc'+acc);
                System.debug('user'+user);
               /* if(user != null ){
                    if ( user.Name == Label.SFSC_Integration_User  ){
                        JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFSC_Source );//source 'SFSC'
                        //TNP_002_ServiceClass.sendRequest(JSONGenerated);
                        System.enqueueJob(new TNP_001_QueueableCallOut(JSONGenerated));
                        
                    }
                }*/
                if(user == null ){
                        JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFDC_Source );//source 'SFDC'
                        //TNP_002_ServiceClass.sendRequest(JSONGenerated);
                        System.enqueueJob(new TNP_001_QueueableCallOut(JSONGenerated));          
                }
            }
            
        }     
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
    }    
    public static void listAccountAfterUpdate( list<account> accountToUpdate)
    {  
        String METHOD_NAME = 'listAccountAfterUpdate';
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
        string jsonstring;
        String JSONGenerated;
        Map<Id,User> mapInfoUser = returnMapUserIntegration();
        map<string,account> mapListAllAccount = new map<string,account>();  
        if ( !accountToUpdate.isEmpty() )
        {
            System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'accountToUpdate -->'+accountToUpdate);
            for (Account acc : accountToUpdate ){
                System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'Account -->'+acc);            
                System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'acc -->'+acc.LastModifiedById);
                User user = mapInfoUser.get(acc.LastModifiedById);
                System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'user -->'+user);
                if( user == Null){
                    System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'In user Condition');
                    JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFDC_Source);//source 'SFDC'
                    // TNP_002_ServiceClass.sendRequest(JSONGenerated); 
                    System.enqueueJob(new TNP_001_QueueableCallOut(JSONGenerated));             
                }
                  if(user != null ){
                    if ( user.Name == Label.SFSC_Integration_User  ){
                        JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFSC_Source );//source 'SFSC'
                        //TNP_002_ServiceClass.sendRequest(JSONGenerated);
                        System.enqueueJob(new TNP_001_QueueableCallOut(JSONGenerated));
                        
                    }
                }
            } 
        }  
        System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END');         
    }   
    
    //Method to get the Id of the User  Integration User
    public static Map<Id,User> returnMapUserIntegration(){ 
        String METHOD_NAME = 'returnIdUser' ;
        System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'Start');
        return new Map<Id,User>([SELECT Id, Name FROM User WHERE isIntegrationUser__c = TRUE and isActive = TRUE]);
    }
    
}