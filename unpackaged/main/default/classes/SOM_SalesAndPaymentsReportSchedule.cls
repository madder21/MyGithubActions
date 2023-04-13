public with sharing class SOM_SalesAndPaymentsReportSchedule Implements Schedulable{
    public void execute(SchedulableContext sc){ 
        weekExportTEST();
    }
    
    
    
    @future(callout=true)
    public static void weekExportTEST() {

        DateTime previousMondayDate = (DateTime)System.Today().addDays(-7);
        String previousMonday = previousMondayDate.format('MM/dd/YYYY');

        DateTime previousSundayDate = (DateTime)System.Today().addDays(-1);
        String previousSunday = previousSundayDate.format('MM/dd/YYYY');

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        Reports_Setting__mdt reportSetting = [SELECT Countries__c, Country_List__c, Distribution_List__c FROM Reports_Setting__mdt where Country_List__c ='UAE' ];
        

            List<Report> invoiceRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Sales_Report_Invoice_Wom'];
            List<Report> creditMemoRep = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Sales_Report_Credit_Memo_huW'];
            List<Report> paymentRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Payments_report_5w3'];
            List<Report> shipmentRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName = 'Shipments_Report_a6T'];
            List<Report> returnOrdersRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Return_Orders_Finance_3My'];
            
            
            
            String invoiceReportId = (String)invoiceRep.get(0).get('Id');
            String creditMemoReportId = (String)creditMemoRep.get(0).get('Id');
            String paymentReportId = (String)paymentRep.get(0).get('Id');
            String shipmentReportId = (String)shipmentRep.get(0).get('Id');
            String returnOrdersReportId = (String)returnOrdersRep.get(0).get('Id');


            String urlFilters = '?&pv0=' + previousMonday + '&pv1=' + previousSunday + '&csv=1&exp=1&enc=UTF-8&isdtp=p1';
        
            
            System.debug('urlFilters' + urlFilters);
         
            Messaging.EmailFileAttachment invoiceAttachment    = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment creditMemoAttachment = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment paymentAttachment    = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment shipmentAttachment    = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment returnOrdersAttachment    = new Messaging.EmailFileAttachment();
            


            ApexPages.PageReference invoiceReport;
            ApexPages.PageReference creditMemoReport;
            ApexPages.PageReference paymentReport;
            ApexPages.PageReference shipmentReport;
            ApexPages.PageReference returnOrdersReport;
			
            
            if(!invoiceRep.isEmpty()){
                invoiceReport    = new ApexPages.PageReference('/'+invoiceReportId + urlFilters);

            }
            if(!creditMemoRep.isEmpty()){
                creditMemoReport = new ApexPages.PageReference('/'+creditMemoReportId + urlFilters);

            }
            if(!paymentRep.isEmpty()){
                paymentReport    = new ApexPages.PageReference('/'+paymentReportId + urlFilters);

            }
            if(!shipmentRep.isEmpty()){
                    shipmentReport    = new ApexPages.PageReference('/'+shipmentReportId + urlFilters);
    
                }
            if(!returnOrdersRep.isEmpty()){
                    returnOrdersReport    = new ApexPages.PageReference('/'+returnOrdersReportId + urlFilters);
    
                }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<Messaging.EmailFileAttachment> attchs = new List<Messaging.EmailFileAttachment>();

            if(Test.isRunningTest()) { 
                invoiceAttachment.setBody(Blob.valueOf('UnitInvoice.Test'));
                creditMemoAttachment.setBody(Blob.valueOf('UnitCM.Test'));
                paymentAttachment.setBody(Blob.valueOf('UnitPayment.Test'));
                shipmentAttachment.setBody(Blob.valueOf('Unitshipment.Test'));
                returnOrdersAttachment.setBody(Blob.valueOf('UnitreturnOrders.Test'));
            } 
            else{
                if(!invoiceRep.isEmpty()){
                    invoiceAttachment.setFileName('Sales Invoice Report.csv');
                    invoiceAttachment.setBody(Blob.valueof(invoiceReport.getContent().toString()));
                    invoiceAttachment.setContentType('text/csv');
                    attchs.add(invoiceAttachment);
                }
                if(!creditMemoRep.isEmpty()){
                    creditMemoAttachment.setFileName('Sales Credit Memo Report.csv');
                    creditMemoAttachment.setBody(Blob.valueof(creditMemoReport.getContent().toString()));
                    creditMemoAttachment.setContentType('text/csv');
                    attchs.add(creditMemoAttachment);
                }
                if(!paymentRep.isEmpty()){
                    paymentAttachment.setFileName('Payment Report.csv');
                    paymentAttachment.setBody(Blob.valueof(paymentReport.getContent().toString()));
                    paymentAttachment.setContentType('text/csv');
                    attchs.add(paymentAttachment);
                }
                if(!shipmentRep.isEmpty()){
                    shipmentAttachment.setFileName('Shipment Report.csv');
                    shipmentAttachment.setBody(Blob.valueof(shipmentReport.getContent().toString()));
                    shipmentAttachment.setContentType('text/csv');
                    attchs.add(shipmentAttachment);
                }
                if(!returnOrdersRep.isEmpty()){
                    returnOrdersAttachment.setFileName('Return Orders Report.csv');
                    returnOrdersAttachment.setBody(Blob.valueof(returnOrdersReport.getContent().toString()));
                    returnOrdersAttachment.setContentType('text/csv');
                    attchs.add(returnOrdersAttachment);
                }
            }

            email.setFileAttachments(attchs);
            
            String subject ='[SOM] Weekly extraction of payments and sales for ' + reportSetting.Country_List__c;
            email.setSubject(subject);
            email.setPlainTextBody('Hello,' + '\n\n' +'Find attached Sales, payments, shipments and returns reports for week starting from '+previousMonday+' to '+previousSunday+' for the country/countries: ' + reportSetting.Countries__c + +'\n\n' + 'Best regards.');
           
            String[] toAddresses = new list<string>();
            toAddresses.addAll(reportSetting.Distribution_List__c.split(','));
            email.setToAddresses( toAddresses );
            emails.add(email);

        Messaging.sendEmail(emails);

    }   
    
    /*public static void weekExport() {

        DateTime previousMondayDate = (DateTime)System.Today().addDays(-7);
        String previousMonday = previousMondayDate.format('MM/dd/YYYY');

        DateTime previousSundayDate = (DateTime)System.Today().addDays(-1);
        String previousSunday = previousSundayDate.format('MM/dd/YYYY');

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        List<Reports_Setting__mdt> reportSettings = [SELECT Countries__c, Country_List__c, Distribution_List__c FROM Reports_Setting__mdt];
        for (Reports_Setting__mdt reportSetting : reportSettings) {

            String invoiceDevName    = '%'+reportSetting.Country_List__c+'%Sales%Invoice%';
            String creditMemoDevName = '%'+reportSetting.Country_List__c+'%Sales%Credit_Memo%';
            String paymentDevName    = '%'+reportSetting.Country_List__c+'%Sales%Payments%';

            List<Report> invoiceRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName LIKE :invoiceDevName];
            List<Report> creditMemoRep = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName LIKE :creditMemoDevName];
            List<Report> paymentRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName LIKE :paymentDevName];

            List<String> countryList = reportSetting.Countries__c.split(',');

            String urlFilters = '?';
            for( Integer i = 0 ; i<countryList.size(); i++){
                urlFilters += '&pv' + i + '=' + countryList[i];
            }
            String iterSize      = String.valueOf(countryList.size());
            String iterSizePlus1 = String.valueOf(countryList.size()+1);

            urlFilters += '&pv' + iterSize + '=' + previousMonday + '&pv' + iterSizePlus1 + '='  + previousSunday +'&csv=1&exp=1&enc=UTF-8&isdtp=p1';
            
            System.debug('urlFilters' + urlFilters);
         
            Messaging.EmailFileAttachment invoiceAttachment    = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment creditMemoAttachment = new Messaging.EmailFileAttachment();
            Messaging.EmailFileAttachment paymentAttachment    = new Messaging.EmailFileAttachment();
            
            String invoiceReportId;
            String creditMemoReportId;
            String paymentReportId;

            ApexPages.PageReference invoiceReport;
            ApexPages.PageReference creditMemoReport;
            ApexPages.PageReference paymentReport;

            if(!invoiceRep.isEmpty()){
                invoiceReportId      = (String)invoiceRep[0].Id;
                invoiceReport    = new ApexPages.PageReference('/'+invoiceReportId + urlFilters);

            }
            if(!creditMemoRep.isEmpty()){
                creditMemoReportId   = (String)creditMemoRep[0].Id;
                creditMemoReport = new ApexPages.PageReference('/'+creditMemoReportId + urlFilters);

            }
            if(!paymentRep.isEmpty()){
                paymentReportId      = (String)paymentRep[0].Id;
                paymentReport    = new ApexPages.PageReference('/'+paymentReportId + urlFilters);

            }

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            List<Messaging.EmailFileAttachment> attchs = new List<Messaging.EmailFileAttachment>();

            if(Test.isRunningTest()) { 
                invoiceAttachment.setBody(Blob.valueOf('UnitInvoice.Test'));
                creditMemoAttachment.setBody(Blob.valueOf('UnitCM.Test'));
                paymentAttachment.setBody(Blob.valueOf('UnitPayment.Test'));
            } 
            else{
                if(!invoiceRep.isEmpty()){
                    invoiceAttachment.setFileName('Sales Invoice Report.csv');
                    invoiceAttachment.setBody(Blob.valueof(invoiceReport.getContent().toString()));
                    invoiceAttachment.setContentType('text/csv');
                    attchs.add(invoiceAttachment);
                }
                if(!creditMemoRep.isEmpty()){
                    creditMemoAttachment.setFileName('Sales Credit Memo Report.csv');
                    creditMemoAttachment.setBody(Blob.valueof(creditMemoReport.getContent().toString()));
                    creditMemoAttachment.setContentType('text/csv');
                    attchs.add(creditMemoAttachment);
                }
                if(!paymentRep.isEmpty()){
                    paymentAttachment.setFileName('Payment Report.csv');
                    paymentAttachment.setBody(Blob.valueof(paymentReport.getContent().toString()));
                    paymentAttachment.setContentType('text/csv');
                    attchs.add(paymentAttachment);
                }
            }

            email.setFileAttachments(attchs);
            
            String subject ='[SOM] Weekly extraction of payments and sales for ' + reportSetting.Country_List__c;
            email.setSubject(subject);
            email.setPlainTextBody('Hello,' + '\n' +'Find attached Sales and Payments reports for week starting from '+previousMonday+' to '+previousSunday+' for the country/countries: ' + reportSetting.Countries__c + +'\n\n' + 'Best regards.');
           
            String[] toAddresses = new list<string>();
            toAddresses.addAll(reportSetting.Distribution_List__c.split(','));
            email.setToAddresses( toAddresses );
            emails.add(email);
        }

        Messaging.sendEmail(emails);

    } */   
}