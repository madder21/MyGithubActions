public class SOM_CreditMemoHelper {
    public static void updateCreditMemoDate(List<CreditMemo> newMap){
        Map<String, Id> CreditMemoIdsMap = new Map<String, Id>(); // Map<Credit Memo Id, Order Summary Id>
        for(CreditMemo singleCM : newMap){
            CreditMemoIdsMap.put(singleCM.Id, singleCM.ReferenceEntityId);
        }
        Map<Id,OrderSummary> relatedOrderSummary = new Map<Id, OrderSummary>([SELECT Id, Tech_ShippingCountry__c FROM OrderSummary WHERE Id IN :CreditMemoIdsMap.values()]);
        Map<String, String> CreditMemoCountryMap = new Map<String, String>(); // Map<Credit Memo Id, Tech_ShippingCountry__c>
        for(String singleCr : CreditMemoIdsMap.KeySet()){
            CreditMemoCountryMap.put(singleCr, relatedOrderSummary.get(CreditMemoIdsMap.get(singleCr)).Tech_ShippingCountry__c);
        }
        List<Sales_Channel_Mapping__mdt> salesChannelMDT = [SELECT Zone__c, Timezone__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c IN :CreditMemoCountryMap.values()];
        Map<String, String> salesChannelMDTMap = new Map<String, String>(); // Map<Zone__c, Timezone__c>
        for(Sales_Channel_Mapping__mdt oneMDT : salesChannelMDT){
            salesChannelMDTMap.put(oneMDT.Zone__c, oneMDT.Timezone__c);
        }
        Map<Id, String> CreditMemoTimeZonesMap = new Map<Id, String>(); // Map<Credit Memo Id, TimeZone>
        for(String crMemo : CreditMemoCountryMap.KeySet()){
            CreditMemoTimeZonesMap.put(crMemo, salesChannelMDTMap.get(CreditMemoCountryMap.get(crMemo)));
        }
        
        for(CreditMemo singleCredit : newMap){
            SOM_DateConvertionInput dateinput   = new SOM_DateConvertionInput();
            dateinput.targetTimeZone            = CreditMemoTimeZonesMap.get(singleCredit.Id);
            dateinput.dateToConvert             = singleCredit.CreatedDate;
            singleCredit.Credit_Memo_Date__c    = SOM_DateTimeHelper.convertDateTimeByTimeZone(new List<SOM_DateConvertionInput>{dateinput})[0].date();
        }
    }
}
