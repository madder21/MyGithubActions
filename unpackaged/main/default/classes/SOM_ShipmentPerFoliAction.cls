/**************************************************************************************

-- - Author        : Fatima-Ezzahra Laftoumi

-- - Description   : An action class for managing the Shipment per FOLI for ScreenFlow

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 17-08-2022    FEL    1.0          Initial version

***************************************************************************************/

public with sharing class SOM_ShipmentPerFoliAction {
    @InvocableVariable @AuraEnabled
    public String idFOLI;

    @InvocableVariable @AuraEnabled
    public Integer qty;

    /**
     * @description getShippedQuantityByFOLI Calculate already shipped quantity
     * @param  foLineItemsIds foLineItemsIds : Fulfillment Order Line Item Ids
     * @return                return         : Already shipped quantity by Fulfillment Order Line Item Id
     */
    @InvocableMethod(label='Shipped Quantity By FOLI')
    public static List<List<SOM_ShipmentPerFoliAction>> getShippedQuantityByFOLI(List<List<Id>> foLineItemsIds){
        List<List<SOM_ShipmentPerFoliAction>> output = new List<List<SOM_ShipmentPerFoliAction>>();
        List<SOM_ShipmentPerFoliAction> listWR = new List<SOM_ShipmentPerFoliAction>();
        Map<Id, Integer> mapQ = new Map<Id, Integer>();
        for(AggregateResult resultFoli : [SELECT  FulfillmentOrderLineItemId FoliId , SUM(Quantity) Quantity  
                                            FROM ShipmentItem 
                                            WHERE FulfillmentOrderLineItemId IN : foLineItemsIds[0]
                                            GROUP BY FulfillmentOrderLineItemId ORDER BY FulfillmentOrderLineItemId DESC]){
            SOM_ShipmentPerFoliAction foliqte = new SOM_ShipmentPerFoliAction();                                   
            foliqte.idFoli = (Id) resultFoli.get('FoliId');
            foliqte.qty    = Integer.valueOf((Decimal) resultFoli.get('Quantity'));
            listWR.add(foliqte);
            mapQ.put((Id) resultFoli.get('FoliId'), Integer.valueOf((Decimal) resultFoli.get('Quantity')));
        }
        for(Id foliId : foLineItemsIds[0]){
            if(!mapQ.containsKey(foliId)){
                SOM_ShipmentPerFoliAction foliNotShipped = new SOM_ShipmentPerFoliAction();                                   
                foliNotShipped.idFoli = foliId;
                foliNotShipped.qty    = 0;
                listWR.add(foliNotShipped);
            }
        }

        output.add(listWR);
        return output;

    }
}