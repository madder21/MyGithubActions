public class SOM_InvoiceHelper {
    public static void updateInvoiceTimezoneDate(List<Invoice> newMap){
        Map<String, Id> InvoiceIds = new Map<String, Id>(); // Map<Invoice Id, Order Summary Id>
        for(Invoice singleInv : newMap){
            InvoiceIds.put(singleInv.Id, singleInv.ReferenceEntityId);
        }
        List<OrderSummary> relatedOrderSummary = [SELECT Id, BillingCountry FROM OrderSummary WHERE Id IN :InvoiceIds.values()];
        Map<String, String> invoiceCountryMap = new Map<String, String>(); // Map<Invoice Id, BillingCountry>
        for(OrderSummary singleOS : relatedOrderSummary){
            for(String singleIn : InvoiceIds.KeySet()){
                if(singleOS.Id == InvoiceIds.get(singleIn)){
                	invoiceCountryMap.put(singleIn, singleOS.BillingCountry);
                }
            }
        }
        List<Sales_Channel_Mapping__mdt> salesChannelMDT = [SELECT Zone__c, Timezone__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c IN :invoiceCountryMap.values()];
        Map<Id, String> invoiceTimeZonesMap = new Map<Id, String>(); // Map<Invoice Id, TimeZone>
        for(String invo : invoiceCountryMap.KeySet()){
            for(Sales_Channel_Mapping__mdt singleMDT : salesChannelMDT){
                if(invoiceCountryMap.get(invo) == singleMDT.Zone__c){
                    invoiceTimeZonesMap.put(invo, singleMDT.Timezone__c);
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
