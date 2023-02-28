global with sharing class SOM_AutomatedEmailWithProcessEXBatch  Implements Schedulable{
    global void execute(SchedulableContext sc){
        DoExport();
    }
    @future(callout=true)
    public static void DoExport() {
        List <ProcessException> ProcessExceptionRecords = [Select Id from ProcessException where Status= 'New' and Category= 'Payment' ];
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
        if (!ProcessExceptionRecords.isEmpty())
        Messaging.sendEmail( new Messaging.SingleEmailMessage[] { message } );
    }    
    
}