public class SOM_Update_Invoice_Timezone_Date_Helper {
    public static void updateInvoiceTimezoneDate(List<Invoice> newMap){
        Map<String, Id> InvoiceIds = new Map<String, Id>(); // Map<Order Summary Id, Invoice Id>
        for(Invoice singleInv : newMap){
            InvoiceIds.put(singleInv.ReferenceEntityId, singleInv.Id);
        }
        List<OrderSummary> relatedOrderSummary = [SELECT Id, BillingCountry FROM OrderSummary WHERE Id IN :InvoiceIds.KeySet()];
        List<String> orderSummaryCountryList = new List<String>(); 
        for(OrderSummary singleOS : relatedOrderSummary){
            orderSummaryCountryList.add(singleOS.BillingCountry);
        }
        List<Sales_Channel_Mapping__mdt> salesChannelMDT = [SELECT Zone__c, Timezone__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c IN :orderSummaryCountryList];
        Map<Id, String> invoiceTimeZonesMap = new Map<Id, String>(); // Map<Invoice Id, TimeZone>
        for(OrderSummary os : relatedOrderSummary){
            for(Sales_Channel_Mapping__mdt singleMDT : salesChannelMDT){
                if(os.BillingCountry == singleMDT.Zone__c){
                    invoiceTimeZonesMap.put(InvoiceIds.get(os.Id), singleMDT.Timezone__c);
                }
            }
        }
        for(Invoice singleInvoice : newMap){
            SOM_DateConvertionInput dateinput          = new SOM_DateConvertionInput();
            dateinput.targetTimeZone                   = invoiceTimeZonesMap.get(singleInvoice.Id);
            dateinput.dateToConvert                    = singleInvoice.CreatedDate;
            singleInvoice.Invoice_Timezone_Date__c     = SOM_DateTimeHelper.convertDateTimeByTimeZone(new List<SOM_DateConvertionInput>{dateinput})[0].date();
        }
    }
}