/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
public with sharing class ShipmentItemTriggerHandler {

    /**
    * @description : this method used to handle all treatments atfer insert action
    * @author BADER EDDINE ELKHAL | 03-19-2022 
    * @param listNewShipmentItem 
    **/
    public static void handleAfterInsert(List<ShipmentItem> listNewShipmentItem){

        Set<Id> foliIds = new Set<Id>();
        List<FulfillmentOrder> listOfTargetFulfillmentOrder = new List<FulfillmentOrder>();
        for(ShipmentItem shipmentLine : listNewShipmentItem){
            foliIds.add(shipmentLine.FulfillmentOrderLineItemId);
        }

        if(!foliIds.isEmpty()){
            ShipmentItemTriggerHandler.updateFulfillmentOrdersStatus(foliIds);
        }
        
    }

    /**
    * @description 
    * @author BADER EDDINE ELKHAL | 03-19-2022 
    * @param listOfTargetFulfillmentOrder 
    **/
    public static void updateFulfillmentOrdersStatus(Set<Id> foliIds){

        List<FulfillmentOrder> listFoToUpdate = new List<FulfillmentOrder>();
        List<OrderSummary> listOSToUpdate = new List<OrderSummary>();
        List<AggregateResult> listFObyShipmentItemsQuantity = new List<AggregateResult>();
        Map<Id, Wr_FulfillmentOrder> listOfTargetFO = new Map<Id, Wr_FulfillmentOrder>();
        Map<Id, List<FulfillmentOrder>> listofFOByOSId = new Map<Id, List<FulfillmentOrder>>();
        Set<Id> setOfFOIds = new Set<Id>();
        Set<Id> setOfOrderSummaryIds = new Set<Id>();

        for(FulfillmentOrderLineItem foliItem : [SELECT Id, FulfillmentOrderId FROM FulfillmentOrderLineItem WHERE Id IN : foliIds]){
            setOfFOIds.add(foliItem.FulfillmentOrderId);
            System.debug('$$$$$$ foliItem.FulfillmentOrder inside loop :'+ foliItem.FulfillmentOrderId);
        }
        for(FulfillmentOrder fo : [SELECT Id, ItemCount, Status, Type, OrderSummaryId, (SELECT Id, Type FROM FulfillmentOrderLineItems WHERE Type = 'Delivery Charge') FROM FulfillmentOrder WHERE Id IN : setOfFOIds]){
            Wr_FulfillmentOrder wrFo = new Wr_FulfillmentOrder();
            wrFo.foId = fo.Id;
            wrFo.status = fo.Status;
            wrFo.OrderSummaryId = fo.orderSummaryId;
            wrFo.type = fo.Type;
            wrFo.itemCount = fo.FulfillmentOrderLineItems?.size()>0 ? Integer.valueOf(fo.ItemCount - 1) : Integer.valueOf(fo.ItemCount);
            listOfTargetFO.put(fo.Id, wrFo);

            System.debug('$$$$$$ fo inside loop :'+ fo);
        }

        listFObyShipmentItemsQuantity = [SELECT  FulfillmentOrderLineItem.FulfillmentOrderId FulfillmentOrderId , 
            SUM(Quantity) Quantity  
            FROM ShipmentItem
            WHERE FulfillmentOrderLineItem.FulfillmentOrderId IN : listOfTargetFO.keySet()
            GROUP BY FulfillmentOrderLineItem.FulfillmentOrderId
        ];
        System.debug('$$$$$$ listFObyShipmentItemsQuantity :'+ listFObyShipmentItemsQuantity);

        for(AggregateResult foLine : listFObyShipmentItemsQuantity){
            //List<FulfillmentOrder> listOfTargetFO = new List<FulfillmentOrder>();
            Id foId = (Id) foLine.get('FulfillmentOrderId');
            System.debug('$$$$$$ foId inside loop again :'+ foId);
            if(listOfTargetFO.containsKey(foId)){
                if(listOfTargetFO.get(foId).status == 'Partially Fulfilled' || listOfTargetFO.get(foId).status == 'Fulfilling'){
                    //Stack OrderSummaries Ids  to process for OS update 
                    setOfOrderSummaryIds.add(listOfTargetFO.get(foId).orderSummaryId);
                    System.debug('$$$$$$ setOfOrderSummaryIds Updated :' + setOfOrderSummaryIds);

                    if((listOfTargetFO.get(foId).itemCount) == Integer.valueOf((Decimal) foLine.get('Quantity'))){
                            listFoToUpdate.add(new FulfillmentOrder(Id = foId, Status = 'Fulfilled', 
                            OrderSummaryId = listOfTargetFO.get(foId).orderSummaryId));
                            System.debug('$$$$$$ listFoToUpdate added with status Fulfilled :');
                        }
                        
                    else{
                        listFoToUpdate.add(new FulfillmentOrder(Id = foId, Status = 'Partially Fulfilled',
                        OrderSummaryId = listOfTargetFO.get(foId).orderSummaryId));
                        System.debug('$$$$$$ listFoToUpdate added with status Partially Fulfilled :');
                    }
                }
            }

        }
        if(!listFoToUpdate.isEmpty()){
            update listFoToUpdate;
        }
        
        /*for(FulfillmentOrder foItem : listFoToUpdate){
            //listOfTargetFO.get(foItem.Id).status = foItem.status;
            //FulfillmentOrder foRow = listOfTargetFO.get(foItem.Id);
            if(listofUpdatedFOByOSId.containsKey(foItem.OrderSummaryId)){
                listofUpdatedFOByOSId.get(foItem.OrderSummaryId).add(foItem);
            }
            else {
                listofUpdatedFOByOSId.put(foItem.OrderSummaryId, new List<FulfillmentOrder>{foItem});
            }
            
            
        }*/
        /*for(FulfillmentOrder fulfillmentOrder : [SELECT Id, ItemCount, Status, Type, OrderSummaryId FROM FulfillmentOrder 
            WHERE OrderSummaryId IN : setOfOrderSummaryIds AND Status != 'Canceled']){
            Boolean someFoPariallyFulfilled = false;
            Boolean noShippedFo = false;
            if(listofFOByOSId.containsKey(fulfillmentOrder.orderSummaryId)){
                listofFOByOSId.get(fulfillmentOrder.orderSummaryId).add(fulfillmentOrder);
            }
            System.debug('$$$$$$ fo inside loop :'+ fo);
        }*/
        System.debug('$$$$$$ Before Loop of Os :');
        for(OrderSummary orderSumm : [SELECT Id, (SELECT Id, Status FROM FulfillmentOrders WHERE Status != 'Canceled') FROM OrderSummary WHERE Id IN : setOfOrderSummaryIds]){
            if(!orderSumm.FulfillmentOrders?.isEmpty()){
                System.debug('$$$$$$ orderSumm.FulfillmentOrders :' + orderSumm.FulfillmentOrders);
                Boolean totalyFulfilled = true;
                Boolean noShippedFo = true;
                for(FulfillmentOrder foLine : orderSumm.FulfillmentOrders){
                    if(foLine.Status == 'Fulfilled' || foLine.Status == 'Partially Fulfilled'){
                        noShippedFo= false;
                        if(foLine.status == 'Partially Fulfilled') totalyFulfilled = false;
                        System.debug('$$$$$$ totalyFulfilled : ' + totalyFulfilled +' &&  noShippedFo : '+ noShippedFo);
                    }else{
                        totalyFulfilled = false;
                    }
                    
                }
                if(!noShippedFo && totalyFulfilled){
                    listOSToUpdate.add(new OrderSummary(Id = orderSumm.Id, Status = 'Fulfilled'));
                    System.debug('$$$$$$ totalyFulfilled : ' + totalyFulfilled +' &&  noShippedFo : '+ noShippedFo);
                }
                else if(!noShippedFo && !totalyFulfilled){
                    listOSToUpdate.add(new OrderSummary(Id = orderSumm.Id, Status = 'Partially Fulfilled'));
                    System.debug('$$$$$$ totalyFulfilled : ' + totalyFulfilled +' &&  noShippedFo : '+ noShippedFo);
                }
            }
        }
        System.debug('$$$$$$ listOSToUpdate : '+ listOSToUpdate);
        /*for(Id osId : listofFOByOSId.keySet()){
            Boolean someFoPariallyFulfilled = false;
            if(!listofFOByOSId.get(osId).isEmpty()){

                for(FulfillmentOrder foToCheck : listofFOByOSId.get(osId)){

                    if(foToCheck.status == 'Partially Fulfilled'){
                        someFoPariallyFulfilled = true; 
                    }
                }
                if(someFoPariallyFulfilled){
                    listOSToUpdate.add(new OrderSummary(Id = osId, Status = 'Partially Fulfilled'));
                }
                else {
                    listOSToUpdate.add(new OrderSummary(Id = osId, Status = 'Fulfilled'));
                }
            }
        }*/

        if(!listOSToUpdate.isEmpty()){
            update listOSToUpdate;
        }

    }

    public class Wr_FulfillmentOrder {

        public Id foId;
        
        public Integer itemCount;

        public String status;

        public String type;

        public Id OrderSummaryId;
    }


    
}