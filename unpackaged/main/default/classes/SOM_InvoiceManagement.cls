public with sharing class SOM_InvoiceManagement {

    //Update Invoice Document Number / Increment by Country
    public static void UpdateInvoicesNumber (Map<Id,Invoice> newInvMap, Map<Id,Invoice> oldInvMap) {
        
        
        //GET Max invoice Number By Country Code
        Map<string,string> maxInvoiceByCountryMap= new  Map<string,string>();
        AggregateResult[] groupedInvoiceByCountry=  [SELECT  FulfilledToCountry, max(Invoice.DocumentNumber__c)  from FulfillmentOrder  WHERE FulfilledToCountry !=null group by FulfilledToCountry];        
        for (AggregateResult gr : groupedInvoiceByCountry)  {
            System.debug('FulfilledToCountry' + gr.get('FulfilledToCountry'));
            System.debug('Max Invoice Number' + gr.get('expr0'));
            maxInvoiceByCountryMap.put((String)gr.get('FulfilledToCountry'),(String)gr.get('expr0'));
        }

         // Get Info Home Delivery method

         Map<Id,Boolean> oDGMap= new  Map<Id,Boolean>();
         for ( OrderSummary Os:[select id , (Select id , OrderDeliveryMethod.isHomeDelivery__c from OrderDeliveryGroupSummaries limit 1) 
                                             FROM OrderSummary 
                                             WHERE 
                                             ID IN (Select ReferenceEntityId from invoice  where ReferenceEntity.type ='OrderSummary'  and ID IN :newInvMap.keyset())]){
 
            oDGMap.put(Os.Id, Os.OrderDeliveryGroupSummaries[0].OrderDeliveryMethod.isHomeDelivery__c);
         }

         // Invoice related DATA
       Map<Id,Invoice> InvDataMap= new Map<Id,Invoice>();  
       for (invoice inv:[SELECT Id,DocumentNumber__c,InvoiceNumber__c,TYPEOF ReferenceEntity WHEN OrderSummary THEN Id,SalesChannelName__c END,(SELECT FulfilledToCountry FROM FulfillmentOrders  LIMIT 1)  
                    FROM Invoice WHERE Id IN:newInvMap.keyset()]){   
               InvDataMap.put(inv.id, inv);         
        }                
        for(Invoice inv : newInvMap.values()){
            if((newInvMap.get(inv.Id).PDFGenerationStatus__c != oldInvMap.get(inv.Id).PDFGenerationStatus__c) && newInvMap.get(inv.Id).PDFGenerationStatus__c =='Not started'){  

            
            OrderSummary objOrderSummary = InvDataMap.get(inv.Id).ReferenceEntity;
            System.debug('objOrderSummarySalesChannelName__c ----' + objOrderSummary.SalesChannelName__c);
            System.debug('id invoice  ----' + inv.Id);

            String NextDocumentNumberInvoice;
            if(
            (objOrderSummary.SalesChannelName__c == 'Rimowa' || objOrderSummary.SalesChannelName__c == 'Manual Order') 
            && oDGMap.get(objOrderSummary.Id)!= null 
            && oDGMap.get(objOrderSummary.Id)== true){
            system.debug('FulfillmentOrders--' + InvDataMap.get(inv.Id).FulfillmentOrders);
            if( InvDataMap.get(inv.Id) !=null && InvDataMap.get(inv.Id).FulfillmentOrders.size()>0 ){
            if(maxInvoiceByCountryMap.get(invDataMap.get(inv.Id).FulfillmentOrders[0].FulfilledToCountry)!=null ){
            String MaxNumberInvoice = maxInvoiceByCountryMap.get(invDataMap.get(inv.Id).FulfillmentOrders[0].FulfilledToCountry).substring(1,10);
            integer MaxNumber=integer.valueof(MaxNumberInvoice)+1;
            NextDocumentNumberInvoice = 'I' + String.valueOf(MaxNumber).leftPad(9, '0') + invDataMap.get(inv.Id).FulfillmentOrders[0].FulfilledToCountry;
            inv.DocumentNumber__c = NextDocumentNumberInvoice;
            inv.InvoiceNumber__c=NextDocumentNumberInvoice;
            maxInvoiceByCountryMap.put(invDataMap.get(inv.Id).FulfillmentOrders[0].FulfilledToCountry,NextDocumentNumberInvoice);
            System.debug('updateInvoice'+NextDocumentNumberInvoice);
            }
            else{
            NextDocumentNumberInvoice = 'I000000001' + invDataMap.get(inv.Id).FulfillmentOrders[0].FulfilledToCountry;
            inv.DocumentNumber__c = NextDocumentNumberInvoice;
            inv.InvoiceNumber__c=NextDocumentNumberInvoice;
            maxInvoiceByCountryMap.put(invDataMap.get(inv.Id).FulfillmentOrders[0].FulfilledToCountry,NextDocumentNumberInvoice);

            System.debug('updateInvoice'+NextDocumentNumberInvoice);
            }
            }

            }
            }
            }
        }   
        

       


        

        

    }