/*public class SOM_AutomatedEmailWithProcessEXBatch implements Database.Batchable<SObject> {

public Database.QueryLocator start(Database.BatchableContext bc){
return Database.getQueryLocator('Select ProcessExceptionNumber , Category , CreatedDate, Message, Description from ProcessException where Status = \'New\' order by category asc, CreatedDate desc');
}

public void execute(Database.BatchableContext bc, List<ProcessException > ProcessExceptionList ){
SOM_Automated_EmailWithProcessEx.SendEmailPE(ProcessExceptionList);
}

public void finish(Database.BatchableContext bc){
System.debug('*** Batch job completed ***');
}
}*/
global class SOM_AutomatedEmailWithProcessEXBatch  Implements Schedulable{
    global void execute(SchedulableContext sc){
        DoExport();
    }
    @future(callout=true)
    public static void DoExport() {
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    DeveloperName = 'New_SOM_Process_Exception_Report_h7t'];
        String reportId = (String)reportList.get(0).get('Id');
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        ApexPages.PageReference report = new ApexPages.PageReference('/'+reportId+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName('report.csv');
        attachment.setBody(Blob.valueof(report.getContent().toString()));
        attachment.setContentType('text/csv');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
        String subject ='Report of Process Exceptions not resolved';
        message.setSubject(subject);
        message.setPlainTextBody(' Link to see the report : '+baseUrl+'/'+reportId);
        String[] toAddresses = new list<string>();
        toAddresses.addAll((Label.EmailsPE).split(';'));
        message.setToAddresses( toAddresses );
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
    }    
    
}