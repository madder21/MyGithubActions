public with sharing class SOM_DownloadInvoiceDocumentController {
    public String invoiceData {get; set;}
    public String errorMessage {get; set;}
    public String title;

    public SOM_DownloadInvoiceDocumentController() {
          this.getInvoiceDocumentFromAzure();
    }

    public void getInvoiceDocumentFromAzure(){
        Id invoiceId         = ApexPages.currentPage().getParameters().get('invoiceId');
        String invoiceNumber = getInvoiceNumber(invoiceId);
        if (invoiceNumber != null) {
            try{
                HttpRequest request  = new HttpRequest();
                request.setEndpoint('callout:InvoiceDocumentMulesoftEndpoint/'+invoiceId);
                request.setMethod('GET');
                Http http1 = new Http();
                HttpResponse response = http1.send(request);
        
                if (response.getStatusCode() == 200) {
                    this.invoiceData = EncodingUtil.base64Encode(response.getBodyAsBlob());
                } else {
                    this.errorMessage = title + ' document number ' + invoiceNumber + ' not found.';
                    System.debug('Error while getting invoice content.');
                }
            } catch(Exception ex) {
                 this.errorMessage = ex.getMessage();
            }
        }
        else {
            System.debug('We cannot find the Invoice Number.');
        }
    }

    public String getInvoiceNumber(Id invoiceId){
        if (invoiceId == null) {
            this.errorMessage = 'Invoice id cannot be empty.';
            return null;
        }

        if (invoiceId.getSObjectType().getDescribe().getName() == SOM_Constants.CREDIT_MEMO_SOBJECT_TYPE_NAME) {
            //it s a credit memo
            this.title = 'Credit Memo';
            List<CreditMemo> creditMemo = [SELECT Id, CreditMemoNumber FROM CreditMemo WHERE Id = :invoiceId];
            if (creditMemo != null && !creditMemo.isEmpty()) {
                return creditMemo.get(0).CreditMemoNumber;
            }
            this.errorMessage = 'We cannot find the Credit Memo Number for Id: ' + invoiceId;
            return null;
        } else if(invoiceId.getSObjectType().getDescribe().getName() == SOM_Constants.INVOICE_SOBJECT_TYPE_NAME) {
            this.title = 'Invoice';
            //it s an invoice
            List<Invoice> invoice = [SELECT Id, InvoiceNumber__c FROM Invoice WHERE Id = :invoiceId];
            if (invoice != null && !invoice.isEmpty()) {
                return invoice.get(0).InvoiceNumber__c;
            }
            
            this.errorMessage = 'We cannot find the Invoice Number for Id: ' + invoiceId;
            return null;

        } else if(invoiceId.getSObjectType().getDescribe().getName() == SOM_Constants.CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME) {
            this.title = 'Corrective Invoice';
            
            List<CorrectiveInvoice__c> cInvoice = [SELECT Id, Name FROM CorrectiveInvoice__c WHERE Id = :invoiceId];
            if (cInvoice != null && !cInvoice.isEmpty()) {
                return cInvoice.get(0).Name;
            }
            
            this.errorMessage = 'We cannot find the Corrective Invoice Number for Id: ' + invoiceId;
            return null;
        }

        this.errorMessage = 'Object type : ' + invoiceId.getSObjectType().getDescribe().getName() + ' is not supported.';
        return null;
    }
}