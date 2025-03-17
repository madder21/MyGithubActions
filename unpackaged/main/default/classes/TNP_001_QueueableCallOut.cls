public class TNP_001_QueueableCallOut implements Queueable,Database.AllowsCallouts{
    public String source ;
    public String Action ;   
    public list<Account> listAccount;
    private integer iteratorElementsInListAccount = 0, iSizeOfInputAccountList; //EBU : attribute added to store the initial size of the input list
    public String CLASS_NAME = 'TNP_001_QueueableCallOut' ;
    
    public TNP_001_QueueableCallOut(List<Account> listAccount,String source, string Action){
        this.listAccount = listAccount;
        this.iSizeOfInputAccountList = listAccount.size(); //EBU : alimentation of the size of the input list
        this.Action = Action;
        this.source = source;
    }
    
    public void execute(QueueableContext context) {
        String METHOD_NAME = 'executeQueueable' ;
        try { 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'START'); 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Source'+source);
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Action'+Action);
            
            String JSONGenerated;
            Map<Id,User> mapInfoUser = TNP_002_ServiceClass.returnMapUserIntegration();
          
            list <CountryCode__c> listCountryCode = [Select Name,Alpha_3_code__c,Alpha_2_code__c from  CountryCode__c ];
            
            if (Action.equalsIgnoreCase(Label.TNP_CL_AfterInsert) && String.isEmpty(Source)){
                System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'listAccount.size'+listAccount.size());
                
                //EBU : Correction code TNP to allow a list to be processed
                iteratorElementsInListAccount++;
                
                //EBU : Loop of all accounts from the list
                for (Account acc : listAccount ){
                    User user = mapInfoUser.get(acc.CreatedById);
                    System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'Action in Queueable'+Action);
                    
                    System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'AfterInsert'); 
                    if(user != null ){
                        if ( user.Name == Label.SFSC_Integration_User  ){
                            JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFSC_Source,listCountryCode ); //source 'SFSC'     
                        }
                        if(user.Name == Label.SFMC_Username) {
                            JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFDC_Source,listCountryCode ); //source 'SFDC'   
                        }
                    }
                    if(user == null ){
                        JSONGenerated = TNP_002_ServiceClass.GenerateJSON(acc,Label.SFDC_Source,listCountryCode ); //source 'SFDC'       
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
                system.debug('TNP_001_QueueableCallOut - SEND if JSON not empty (l69) - '+JSONGenerated);
                TNP_002_ServiceClass.sendRequest(JSONGenerated);
            }
            
            //EBU Chain queuable to be able to handle the rest of the list
            if (iteratorElementsInListAccount < iSizeOfInputAccountList) {
               listAccount.remove(listAccount.size()-1);
               system.debug(CLASS_NAME + '/' + 'ENQUEUE JOB FROM WITHIN SAME CLASS - IDX : '+ iteratorElementsInListAccount +' out of '+iSizeOfInputAccountList);
               system.debug(CLASS_NAME + '/' + 'ENQUEUE JOB FROM WITHIN SAME CLASS - LST : '+ listAccount);
               ID jobID = System.enqueueJob(new TNP_001_QueueableCallOut(listAccount,source,Action)); 
               system.debug(CLASS_NAME + '/' + 'ENQUEUE JOB FROM WITHIN SAME CLASS - JOBID : '+ String.ValueOf(jobId) );
            }
            
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'END'); 
        } 
        catch(Exception e) { 
            System.debug(CLASS_NAME+ '/' + METHOD_NAME +'/'+ 'exception : '+e.getMessage());  
        }
    }
    
}