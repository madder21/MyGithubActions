public with sharing class SOM_USReportMonthSchedule Implements Schedulable {
    public void execute(SchedulableContext sc){
        monthExport();
    }
    
    @future(callout=true)
    public static void monthExport() {


        DateTime firstDayOfLastMonth = (DateTime)System.Today().toStartOfMonth().addMonths(-1);
        String firstDay = firstDayOfLastMonth.format('MM/dd/YYYY');
        
        OrgWideEmailAddress owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address = 'maha.meghras@viseo.com' OR Address = 'noreply@rimowa.com' limit 1];

        DateTime lastDayOfLastMonth  = firstDayOfLastMonth.addDays(Date.daysInMonth(firstDayOfLastMonth.year(), firstDayOfLastMonth.month()) - 1);
        String lastDay = lastDayOfLastMonth.format('MM/dd/YYYY');
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        Reports_Setting__mdt reportSetting = [SELECT Countries__c, Country_List__c, Distribution_List__c FROM Reports_Setting__mdt where Country_List__c ='North America' ];
        

            List<Report> invoiceRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Sales_Report_Invoice_US'];
            List<Report> creditMemoRep = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Sales_Report_Credit_Memo_US'];
            List<Report> paymentRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Payments_Report_US'];
            List<Report> shipmentRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName = 'Shipments_Report_Finance_US'];
            List<Report> returnOrdersRep    = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName  = 'Return_Orders_Report_Finance_US'];
            
            
            String invoiceReportId = (String)invoiceRep.get(0).get('Id');
            String creditMemoReportId = (String)creditMemoRep.get(0).get('Id');
            String paymentReportId = (String)paymentRep.get(0).get('Id');
            String shipmentReportId = (String)shipmentRep.get(0).get('Id');
            String returnOrdersReportId = (String)returnOrdersRep.get(0).get('Id');


            String urlFilters = '?&pv0=' + firstDay + '&pv1=' + lastDay + '&csv=1&exp=1&enc=UTF-8&isdtp=p1';
        
            
         
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
            
            String subject ='[SOM] Monthly extraction of payments and sales for ' + reportSetting.Country_List__c;
            email.setSubject(subject);
            email.setPlainTextBody('Hello,' + '\n\n' +'Find attached Sales, payments, shipments, returns and refunds reports for month starting from '+firstDay+' to '+lastDay+' for the country/countries: ' + reportSetting.Countries__c + +'\n\n' + 'Best regards.');
            email.setOrgWideEmailAddressId(owa.id);
            String[] toAddresses = new list<string>();
            toAddresses.addAll(reportSetting.Distribution_List__c.split(','));
            email.setToAddresses( toAddresses );
            emails.add(email);

        Messaging.sendEmail(emails);

    }
}