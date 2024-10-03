public with sharing class SOM_LWC_DisplayFoliToShip_Controller {

    

    public class Wr_ShippedQty{
        @AuraEnabled
        public String idFOLI {get;set;}

        @AuraEnabled
        public Integer qty {get;set;}

    }

    @AuraEnabled(cacheable=true)
    public static List<Wr_FOLItoShip> getFOLItoShip(List<Wr_ShippedQty> listQte) {
        Set<Id> foliIds = new Set<Id>();
        List<Wr_FOLItoShip> wrFOLIS = new List<Wr_FOLItoShip>();
        for(Wr_ShippedQty qte : listQte){
            foliIds.add(qte.idFOLI);
        }

        List<FulfillmentOrderLineItem> folis = [SELECT Id, Quantity, Description, OrderItemSummary.isSerialized__c, FulfillmentOrderLineItemNumber, Product2Id, Product2.Name, Product2.StockKeepingUnit, OrderItemSummaryId,Product2.isSecondHand__c,Product2.masterSku__c FROM FulfillmentOrderLineItem WHERE Id IN :foliIds ORDER BY Id Desc];
        
        for(FulfillmentOrderLineItem foli : folis){
            for(Wr_ShippedQty qte : listQte){
               if(foli.Id == qte.idFOLI && foli.Quantity > qte.qty){
                    Wr_FOLItoShip wrFoli = new Wr_FOLItoShip();
                    wrFoli.id                 = foli.Id;
                    wrFoli.foliName           = foli.FulfillmentOrderLineItemNumber;
                    wrFoli.qty                = Integer.valueOf(foli.Quantity);
                    wrFoli.qtyAvailableToShip = Integer.valueOf(foli.Quantity - qte.qty);
                    wrFoli.productName        = foli.Product2.Name;
                    wrFoli.productSKU         = foli.Product2.StockKeepingUnit;
                    wrFoli.productId          = foli.Product2Id;
                    wrFoli.description        = foli.Description;
                    wrFoli.osItemId           = foli.OrderItemSummaryId;
                    wrFoli.isSerialized       = foli.OrderItemSummary.isSerialized__c;
                   	wrFoli.isSecondhand		  = foli.Product2.isSecondHand__c;
                   	wrFoli.MasterSKU		  = foli.Product2.masterSku__c;
                    wrFOLIS.add(wrFoli);
                    
               }
            }
        }
        return wrFOLIS;

    }
}