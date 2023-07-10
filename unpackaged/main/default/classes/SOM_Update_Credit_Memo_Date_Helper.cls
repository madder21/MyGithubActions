public class SOM_Update_Credit_Memo_Date_Helper {
    public static void updateCreditMemoDate(List<CreditMemo> newMap){
         Map<String, Id> CreditMemoIds = new Map<String, Id>(); // Map<Order Summary Id, Credit Mamo Id>
        for(CreditMemo singleCM : newMap){
            CreditMemoIds.put(singleCM.ReferenceEntityId, singleCM.Id);
        }
        List<OrderSummary> relatedOrderSummary = [SELECT Id, BillingCountry FROM OrderSummary WHERE Id IN :CreditMemoIds.KeySet()];
        List<String> orderSummaryCountryList = new List<String>(); 
        for(OrderSummary singleOS : relatedOrderSummary){
            orderSummaryCountryList.add(singleOS.BillingCountry);
        }
        List<Sales_Channel_Mapping__mdt> salesChannelMDT = [SELECT Zone__c, Timezone__c FROM Sales_Channel_Mapping__mdt WHERE Zone__c IN :orderSummaryCountryList];
        Map<Id, String> CreditMemoTimeZonesMap = new Map<Id, String>(); // Map<Credit Mamo Id, TimeZone>
        for(OrderSummary os : relatedOrderSummary){
            for(Sales_Channel_Mapping__mdt singleMDT : salesChannelMDT){
                if(os.BillingCountry == singleMDT.Zone__c){
                    CreditMemoTimeZonesMap.put(CreditMemoIds.get(os.Id), singleMDT.Timezone__c);
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