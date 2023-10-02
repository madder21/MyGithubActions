public class SOM_InvoiceHelper {
    public static void updateInvoiceTimezoneDate(List<Invoice> newMap){
        Map<String, Id> InvoiceIds = new Map<String, Id>(); // Map<Invoice Id, Order Summary Id>
        for(Invoice singleInv : newMap){
            InvoiceIds.put(singleInv.Id, singleInv.ReferenceEntityId);
        }
        Map<Id,OrderSummary> relatedOrderSummary = new Map<Id, OrderSummary>([SELECT Id, Tech_ShippingCountry__c FROM OrderSummary WHERE Id IN :InvoiceIds.values()]);
        Map<String, String> invoiceCountryMap = new Map<String, String>(); // Map<Invoice Id, Tech_ShippingCountry__c>
        for(String singleIn : InvoiceIds.KeySet()){
            invoiceCountryMap.put(singleIn, relatedOrderSummary.get(InvoiceIds.get(singleIn)).Tech_ShippingCountry__c);
        }
        List<Sales_Channel_Mapping__mdt> salesChannelMDT = [SELECT Zone__c, TimeZones__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c IN :invoiceCountryMap.values()];
        Map<String, String> salesChannelMDTMap = new Map<String, String>(); // Map<Zone__c, Timezone__c>
        for(Sales_Channel_Mapping__mdt oneMDT : salesChannelMDT){
            salesChannelMDTMap.put(oneMDT.Zone__c, oneMDT.TimeZones__c);
        }
        Map<Id, String> invoiceTimeZonesMap = new Map<Id, String>(); // Map<Invoice Id, TimeZone>
        for(String invo : invoiceCountryMap.KeySet()){
            invoiceTimeZonesMap.put(invo, salesChannelMDTMap.get(invoiceCountryMap.get(invo)));
        }
        for(Invoice singleInvoice : newMap){
            SOM_DateConvertionInput dateinput          = new SOM_DateConvertionInput();
            dateinput.targetTimeZone                   = invoiceTimeZonesMap.get(singleInvoice.Id);
            dateinput.dateToConvert                    = singleInvoice.CreatedDate;
            singleInvoice.Invoice_Timezone_Date__c     = SOM_DateTimeHelper.convertDateTimeByTimeZone(new List<SOM_DateConvertionInput>{dateinput})[0].date();
        }
    }
}