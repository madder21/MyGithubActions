/**************************************************************************************

-- - Author        : Bader Eddine Elkhal

-- - Description   : A Controller for the LWC SomLwcDisplayOrderItems to perform data preparation and oci calls

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 17-08-2022    MAA    1.0          Initial version

***************************************************************************************/
public with sharing class SOM_Manual_RO_Reception_Controller {


    @AuraEnabled (cacheable=true)
    public static String getReturnOrderLineItems(String returnOrderId){

        List<ReturnOrderLineItem> listRoli = new List<ReturnOrderLineItem>();
        if(returnOrderId == null || returnOrderId == ''){
            return JSON.serialize(listRoli);
        }
        for(ReturnOrderLineItem roli : [SELECT Id, ReturnOrderId, QuantityReceived, QuantityExpected, ReturnOrderLineItemNumber, ConditionId__c,
                                         RepaymentMethod, SerialNumber__c, Description,QuantityLeftToReceive__c, Sku__c, SourceLocationId, OrderItemSummary.isSerialized__c  
                                         FROM ReturnOrderLineItem WHERE QuantityExpected > 0 AND ReturnOrderId =: returnOrderId]){
            
                                            
            if(roli.QuantityExpected == roli.quantityReceived){
                continue;
            }
            if(String.isBlank(roli.ConditionId__c)){
                roli.ConditionId__c = SOM_Constants.RETURN_LINE_ITEM_CONDITION_RESALABLE;
            }
            if(String.isBlank(roli.SerialNumber__c)){
                roli.SerialNumber__c = '';
            }
            if(String.isBlank(roli.RepaymentMethod)){
                roli.RepaymentMethod = '';
            }
            roli.quantityReceived = roli.QuantityLeftToReceive__c;
            listRoli.add(roli);
        }         
        System.debug(listRoli);
        return JSON.serialize(listRoli);
    }

    @AuraEnabled (cacheable=true)
    public static String getShipmentSerialNumbers(String listIds){

        Set<String> listOisIds = new Set<String>((List<String>) JSON.deserialize(listIds, List<String>.class));
        Map<String, List<String>> listOutput = new Map<String, List<String>>();
        if(listOisIds?.isEmpty()){
            return null;
        }
        for(ShipmentItem shipmentLine : [SELECT Id, OrderItemSummaryId, SerialNumber__c FROM ShipmentItem WHERE OrderItemSummaryId IN : listOisIds]){
            
            if(listOutput.containsKey(shipmentLine.OrderItemSummaryId)){
                listOutput.get(shipmentLine.OrderItemSummaryId).add(shipmentLine.SerialNumber__c);
                continue;
            }
            listOutput.put(shipmentLine.OrderItemSummaryId, new List<String>{shipmentLine.SerialNumber__c});
        }         
                
        return JSON.serialize(listOutput);
    }

    @AuraEnabled (cacheable=true)
    public static List<Wr_PicklistValue> getCondtions(){

        List<Wr_PicklistValue> listCondtions = new List<Wr_PicklistValue>();
        Schema.DescribeFieldResult fieldResult = ReturnOrderLineItem.ConditionId__c.getDescribe();
        List<Schema.PicklistEntry> pickVals = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : pickVals){
            listCondtions.add(
                    new Wr_PicklistValue(pickListVal.getLabel(),pickListVal.getValue())
                    );
        }         
                
        return listCondtions;
    }
    @AuraEnabled (cacheable=true)
    public static List<Wr_PicklistValue> getFollowUps(){

        List<Wr_PicklistValue> listFollowUps = new List<Wr_PicklistValue>();
        Schema.DescribeFieldResult fieldResult = ReturnOrderLineItem.RepaymentMethod.getDescribe();
        List<Schema.PicklistEntry> pickVals = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : pickVals){
            listFollowUps.add(
                    new Wr_PicklistValue(pickListVal.getLabel(),pickListVal.getValue())
                    );
        }         
                
        return listFollowUps;
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