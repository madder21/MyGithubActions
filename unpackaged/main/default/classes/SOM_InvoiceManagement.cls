public with sharing class SOM_InvoiceManagement {
    
    //Update Invoice Document Number / Increment by Country
    public static void UpdateInvoicesNumber (Invoice newInvMap, Invoice oldInvMap) {
        try{
            //GET Max invoice Number By Country Code
            Map<string,string> maxInvoiceByCountryMap= new  Map<string,string>();
            Invoice InvDataMap  = [SELECT Id,DocumentNumber__c,DocumentNumber,InvoiceNumber__c,TYPEOF ReferenceEntity WHEN OrderSummary THEN Id,SalesChannelName__c END,(SELECT FulfilledToCountry FROM FulfillmentOrders  LIMIT 1)  
                                   FROM Invoice WHERE Id =:newInvMap.Id];   
            
            String countryCode = InvDataMap.FulfillmentOrders[0].FulfilledToCountry;
            FulfillmentOrder groupedInvoiceByCountry=  [SELECT  FulfilledToCountry, Invoice.DocumentNumber__c FROM FulfillmentOrder  WHERE Invoice.DocumentNumber__c!=null AND FulfilledToCountry !=null AND OrderSummary.SalesChannelName__c !='CEGID' AND invoice.DocumentNumber__c LIKE 'I0%' AND Type!='Store' and FulfilledToCountry=:countryCode order by Invoice.DocumentNumber__c desc limit 1];        
            //Get Info Home Delivery method
            Map<Id,Boolean> oDGMap = new  Map<Id,Boolean>();
            for ( OrderSummary Os:[SELECT id , (SELECT id , OrderDeliveryMethod.isHomeDelivery__c FROM OrderDeliveryGroupSummaries LIMIT 1) 
                                   FROM OrderSummary 
                                   WHERE 
                                   ID IN (SELECT ReferenceEntityId FROM invoice WHERE ReferenceEntity.type ='OrderSummary' AND ID  =:newInvMap.Id)]){
                                       
                                       oDGMap.put(Os.Id, Os.OrderDeliveryGroupSummaries[0].OrderDeliveryMethod.isHomeDelivery__c);
                                   }
            
            //Invoice related DATA
            
            OrderSummary objOrderSummary = InvDataMap.ReferenceEntity;
            if (objOrderSummary.SalesChannelName__c == 'CEGID') {
                // Set InvoiceNumber__c and DocumentNumber__c equal to DocumentNumber
                newInvMap.InvoiceNumber__c = newInvMap.DocumentNumber;
                newInvMap.DocumentNumber__c = newInvMap.DocumentNumber; }
            else if((newInvMap.PDFGenerationStatus__c != oldInvMap.PDFGenerationStatus__c) && newInvMap.PDFGenerationStatus__c =='Not started'){  
                String NextDocumentNumberInvoice;
                if(
                    (objOrderSummary.SalesChannelName__c == 'Rimowa' || objOrderSummary.SalesChannelName__c == 'Manual Order') 
                    && oDGMap.get(objOrderSummary.Id)!= null 
                    && oDGMap.get(objOrderSummary.Id)== true){
                        if( InvDataMap !=null && InvDataMap.FulfillmentOrders.size()>0 ){
                            if(groupedInvoiceByCountry.Invoice.DocumentNumber__c!=null ){
                                String MaxNumberInvoice = groupedInvoiceByCountry.Invoice.DocumentNumber__c.substring(1,10);
                                integer MaxNumber = integer.valueof(MaxNumberInvoice)+1;
                                NextDocumentNumberInvoice = 'I0' + String.valueOf(MaxNumber).leftPad(8, '0') + InvDataMap.FulfillmentOrders[0].FulfilledToCountry;
                                newInvMap.DocumentNumber__c = NextDocumentNumberInvoice;
                                newInvMap.InvoiceNumber__c  = NextDocumentNumberInvoice;
                                
                            }
                            else{
                                NextDocumentNumberInvoice = 'I000000001' + InvDataMap.FulfillmentOrders[0].FulfilledToCountry;
                                newInvMap.DocumentNumber__c = NextDocumentNumberInvoice;
                                newInvMap.InvoiceNumber__c  = NextDocumentNumberInvoice;
                            }
                        } 
                    }
            }
            
            Logs.debug('Invoice Management','SOM_InvoiceManagement','UpdateInvoicesNumber||'+newInvMap.Id,'',''); 
         
            
        } catch(Exception e){
              Logs.error(e,'SOM_InvoiceManagement','UpdateInvoicesNumber:||'+newInvMap.Id,'','');   
        } 
    }   
}
