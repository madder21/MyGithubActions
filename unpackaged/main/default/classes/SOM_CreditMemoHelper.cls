public class SOM_CreditMemoHelper {
    public static void updateCreditMemoDate(List<CreditMemo> newMap){
        Map<String, Id> CreditMemoIdsMap = new Map<String, Id>(); // Map<Credit Memo Id, Order Summary Id>
        for(CreditMemo singleCM : newMap){
            CreditMemoIdsMap.put(singleCM.Id, singleCM.ReferenceEntityId);
        }
        List<OrderSummary> relatedOrderSummary = [SELECT Id, BillingCountry FROM OrderSummary WHERE Id IN :CreditMemoIdsMap.values()];
        Map<String, String> CreditMemoCountryMap = new Map<String, String>(); // Map<Credit Memo Id, BillingCountry>
        for(OrderSummary singleOS : relatedOrderSummary){
            for(String singleCr : CreditMemoIdsMap.KeySet()){
                if(singleOS.Id == CreditMemoIdsMap.get(singleCr)){
                	CreditMemoCountryMap.put(singleCr, singleOS.BillingCountry);
                }
            }
        }
        List<Sales_Channel_Mapping__mdt> salesChannelMDT = [SELECT Zone__c, Timezone__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c IN :CreditMemoCountryMap.values()];
        Map<Id, String> CreditMemoTimeZonesMap = new Map<Id, String>(); // Map<Credit Memo Id, TimeZone>
        for(String crMemo : CreditMemoCountryMap.KeySet()){
            for(Sales_Channel_Mapping__mdt singleMDT : salesChannelMDT){
                if(CreditMemoCountryMap.get(crMemo) == singleMDT.Zone__c){
                    CreditMemoTimeZonesMap.put(crMemo, singleMDT.Timezone__c);
                }
            }
        }
        for(CreditMemo singleCredit : newMap){
            SOM_DateConvertionInput dateinput   = new SOM_DateConvertionInput();
            dateinput.targetTimeZone            = CreditMemoTimeZonesMap.get(singleCredit.Id);
            dateinput.dateToConvert             = singleCredit.CreatedDate;
            singleCredit.Credit_Memo_Date__c    = SOM_DateTimeHelper.convertDateTimeByTimeZone(new List<SOM_DateConvertionInput>{dateinput})[0].date();
        }
    }
}
