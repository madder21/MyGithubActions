global with sharing class SOM_CreateCreditMemoPDFFileAction {
    @InvocableMethod(label='Create Credit Memo PDF File' description='Create Credit Memo PDF file for the specified Credit Memo Id')
    global static void CreateInvoicePDFFileAction(List<Id> creditMemoIds){
        List<Attachment> attachmentList = new List<Attachment>();
        List<CreditMemo> CreditMemoList = new List<CreditMemo>();
        PageReference page = new PageReference('/apex/SOM_CreditMemoDocument');
        List<CreditMemo> creditMemoRecords = [SELECT Id, CreditMemoNumber, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id, OrderNumber, BillingCountry END FROM CreditMemo WHERE Id IN :creditMemoIds];
        
        OrderSummary ordSummary = (OrderSummary) creditMemoRecords[0].ReferenceEntity;
        OrderDeliveryGroupSummary odg = [SELECT Id, OrderSummaryId, deliverToCountry FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: ordSummary.Id];
        page.getParameters().put('template', odg.deliverToCountry);
        if(odg.deliverToCountry == 'AE') page = new PageReference('/apex/SOM_CreditMemoArabicDocument');
        page.getParameters().put('creditMemoId', creditMemoRecords[0].Id);
        Attachment attachment = new Attachment();
        if(Test.isRunningTest()) { 
            attachment.Body = blob.valueOf('Unit.Test');
          } else {
            attachment.Body = page.getContent();
          }
        attachment.IsPrivate  = false;
        attachment.ParentId   = creditMemoRecords[0].Id;
        attachment.Name       = getFileName(creditMemoRecords[0]);
        attachmentList.add(attachment);
        //update credit memo
        creditMemoRecords[0].PDFGenerationStatus__c = SOM_Constants.PDF_GENERATION_STATUS_GENERATED;
        CreditMemoList.add(creditMemoRecords[0]);
    
        if(!attachmentList.isEmpty()) {
            insert attachmentList;
            update CreditMemoList ;
        }else {
        System.debug('We cannot find any Credit Memo with ids: ' + creditMemoIds);
        }
    
    }

    global static String getFileName(CreditMemo creditMemo){
        if (creditMemo.ReferenceEntity instanceOf OrderSummary) {
            OrderSummary ordSummary = (OrderSummary) creditMemo.ReferenceEntity;
            return 'Refund_'+ordSummary.OrderNumber+'_'+creditMemo.CreditMemoNumber+'.pdf';
        } else {
            return 'Unknown.pdf';
        }
    }
}