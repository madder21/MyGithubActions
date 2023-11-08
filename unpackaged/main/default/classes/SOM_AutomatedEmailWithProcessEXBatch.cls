global with sharing class SOM_AutomatedEmailWithProcessEXBatch Implements Schedulable{
    global void execute(SchedulableContext sc){ 
        DoExport();
    }
    @future(callout=true)
    public static void DoExport() {
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{};
        List <PE_Emails_Setting__mdt> peEmailSettings = [SELECT Id, DeveloperName, Country__c, Distribution_List__c  
                                                         FROM PE_Emails_Setting__mdt WHERE Distribution_List__c != null];
        Map <String, String> reportsDeveloperNamesMap = new Map <String, String>();
        for(PE_Emails_Setting__mdt singleMDT : peEmailSettings){
            reportsDeveloperNamesMap.put(SOM_Constants.ECOMMERCE_PAYMENT_CAPTURE_ERRORS + singleMDT.Country__c, singleMDT.Distribution_List__c);
        }
        List <ProcessException> ProcessExceptionRecords = [Select Id from ProcessException where Status=: SOM_Constants.PE_NEW and Category=: SOM_Constants.PE_PAYMENT ];
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    DeveloperName IN :reportsDeveloperNamesMap.keySet()];
        OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address = 'maha.meghras@viseo.com' OR Address = 'noreply@rimowa.com' limit 1];
        if (!ProcessExceptionRecords.isEmpty()){
            for(Report singleReport : reportList){
                String country = singleReport.DeveloperName.right(2) == 'GB' ? 'UK' : singleReport.DeveloperName.right(2) ; 
                Reports.ReportResults results = Reports.ReportManager.runReport(singleReport.Id, true);
                // check if report is empty (without rows)
                if(((Reports.ReportFactWithDetails)results?.getFactMap()?.get(SOM_Constants.TABULAR_REPORT_FACT_MAP_KEY))?.getRows()?.size() > 0){
                    String reportId = (String)singleReport.Id;
                    String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                    ApexPages.PageReference report = new ApexPages.PageReference('/'+reportId+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                    Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                    attachment.setFileName('E-Commerce Payment Capture Errors - ' + country + '.csv');
                    if(Test.isRunningTest()) { 
                        attachment.setBody(Blob.valueOf('EmailBody.Test'));
                    }else{
                        attachment.setBody(Blob.valueof(report.getContent().toString()));
                    }
                    attachment.setContentType('text/csv');
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
                    message.setOrgWideEmailAddressId(owa.id);
                    String subject ='Report of Process Exceptions not resolved - ' + country;
                    message.setSubject(subject);
                    message.setPlainTextBody('Hello,' + '\n\n' +'Find attached payment capture errors report for '+country+'\n\n' + 'Best regards.');
                    String[] toAddresses = new list<string>();
                    toAddresses.addAll((reportsDeveloperNamesMap.get(singleReport.DeveloperName)).split(';'));
                    message.setToAddresses( toAddresses );
                    emailList.add(message);
                }
        	}
            if(!emailList.isEmpty()) Messaging.sendEmail(emailList);
        }
                
    }    
    
}