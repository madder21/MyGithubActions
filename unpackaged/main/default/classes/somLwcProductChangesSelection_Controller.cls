public with sharing class somLwcProductChangesSelection_Controller {
    
    
    @AuraEnabled (cacheable=true)
    public static List<Wr_PicklistValue> getReturnReasons(){
        
        List<Wr_PicklistValue> listReturnReasons = new List<Wr_PicklistValue>();
        Schema.DescribeFieldResult fieldResult = OrderItemSummary.Tech_ReturnReason__c.getDescribe();
        List<Schema.PicklistEntry> pickVals = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : pickVals){
            listReturnReasons.add(
                new Wr_PicklistValue(pickListVal.getLabel(),pickListVal.getValue())
            );
        }         
        
        return listReturnReasons;
    }
    
    @AuraEnabled 
    public static String getCurrency(String orderSumId){
        OrderSummary os = [SELECT Id, CurrencyIsoCode FROM OrderSummary 
                           WHERE Id =:orderSumId];
        
        return os.CurrencyIsoCode;
        
    }
    
    public class Wr_PicklistValue{
        
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public Wr_PicklistValue(String labelVal, String valueVal){
            this.label = labelVal;
            this.value = valueVal;
        }
    }
}