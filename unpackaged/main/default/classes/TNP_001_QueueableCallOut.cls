public class TNP_001_QueueableCallOut implements Queueable,Database.AllowsCallouts{
    public String source ;
    public String Action ;   
    public list<Account> listAccount;  
    public String CLASS_NAME = 'TNP_001_QueueableCallOut' ;  
    public TNP_001_QueueableCallOut(List<Account> listAccount,String source, string Action){
        this.listAccount = listAccount;  
        this.Action = Action;
        this.source = source;
    }
    
    public void execute(QueueableContext context) {
        String METHOD_NAME = 'sendRequest' ;
        try { 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Source'+source);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Action'+Action);
            Map<Id,User> mapInfoUser = TNP_002_ServiceClass.returnMapUserIntegration();
            String JSONGenerated;
            list <CountryCode__c> listCountryCode = [Select Name,Alpha_3_code__c,Alpha_2_code__c from  CountryCode__c ];
            
            if (Action.equalsIgnoreCase(Label.TNP_CL_AfterInsert) && String.isEmpty(Source)){
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'listAccount.size'+listAccount.size());
                for (Account acc : listAccount ){
                    User user = mapInfoUser.get(acc.CreatedById);
                    System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Action in Queueable'+Action);
                    
                    System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'AfterInsert'); 
                    if(user != null ){
                        if ( user.Name == Label.SFSC_Integration_User  ){
                            JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFSC_Source,listCountryCode );//source 'SFSC'     
                        }
                    }
                    if(user == null ){
                        JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFDC_Source,listCountryCode );//source 'SFDC'       
                    }
                }
                
                
            }
            
            if (Action.equalsIgnoreCase(Label.TNP_CL_AfterUpdate)  && String.isEmpty(Source)  ){
                for (Account acc : listAccount ){
                    User user = mapInfoUser.get(acc.LastModifiedById);
                    System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'AfterUpdate'); 
                    if( user == Null){
                        System.debug(CLASS_NAME+'/'+ METHOD_NAME+'/'+'In user Condition');
                        JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFDC_Source,listCountryCode);//source 'SFDC'                   
                    }
                    if(user != null ){
                        if ( user.Name == Label.SFSC_Integration_User  ){
                            JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFSC_Source,listCountryCode);//source 'SFSC'
                            //System.enqueueJob(new TNP_001_QueueableCallOut(JSONGenerated)); 
                            
                        }
                    }
                    
                }
            }
            if (Action.equalsIgnoreCase(Label.TNP_CL_Invocable) && !String.isEmpty(Source) ){ 
                for (Account acc : listAccount ){
                    
                    System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Invocable');                 
                    JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Source,listCountryCode);//source 'SFDC'
                }
            }
            if (String.isNotEmpty(JSONGenerated)){
                TNP_002_ServiceClass.sendRequest(JSONGenerated);
            }
            
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
        } catch(Exception e) { 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'exception : '+e.getMessage());  
        }
    }
    
}