global with sharing class SOM_AutomatedEmailWithProcessEXBatch Implements Schedulable{
    global void execute(SchedulableContext sc){ 
        DoExport();
    }
    @future(callout=true)
    public static void DoExport() {
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[]{};
        List <PE_Emails_Setting__mdt> peEmailSettings = [SELECT Id, DeveloperName, PE_Emails_Setting_Name__c, Countries__c, Distribution_List__c  
                                                         FROM PE_Emails_Setting__mdt WHERE Distribution_List__c != null];
        Map <String, String> reportsDeveloperNamesMap = new Map <String, String>();
        Map <String, String> distributionListMap      = new Map <String, String>();
        for(PE_Emails_Setting__mdt singleMDT : peEmailSettings){
            reportsDeveloperNamesMap.put('ECommerce_Payment_Capture_Errors_'+singleMDT.Countries__c, singleMDT.Countries__c);
            distributionListMap.put(singleMDT.Countries__c, singleMDT.Distribution_List__c);
        }
        List <ProcessException> ProcessExceptionRecords = [Select Id from ProcessException where Status=: SOM_Constants.PE_NEW and Category=: SOM_Constants.PE_PAYMENT ];
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    DeveloperName IN :reportsDeveloperNamesMap.keySet()];
        OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address = 'maha.meghras@viseo.com' OR Address = 'noreply@rimowa.com' limit 1];
        if (!ProcessExceptionRecords.isEmpty()){
            for(Report singleReport : reportList){
                String reportId = (String)singleReport.Id;
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
                ApexPages.PageReference report = new ApexPages.PageReference('/'+reportId+'?csv=1&exp=1&enc=UTF-8&isdtp=p1');
                Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                attachment.setFileName('report.csv');
                attachment.setBody(Blob.valueof(report.getContent().toString()));
                attachment.setContentType('text/csv');
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment } );
                message.setOrgWideEmailAddressId(owa.id);
                String subject ='Report of Process Exceptions not resolved';
                message.setSubject(subject);
                message.setPlainTextBody(' Link to see the report : '+baseUrl+'/'+reportId);
                String[] toAddresses = new list<string>();
                toAddresses.addAll((distributionListMap.get(reportsDeveloperNamesMap.get(singleReport.DeveloperName))).split(';'));
                message.setToAddresses( toAddresses );
                emailList.add(message);
        	}
            if(!emailList.isEmpty()) Messaging.sendEmail(emailList);
        }
                
    }    
    
}
