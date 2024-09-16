/**************************************************************************************

-- - Author        : Fatima-Ezzahra LAFTOUMI

-- - Description   : A class for Creating Shipment and Shipment Items Called from Flow 'SOM 990 Manual Shipment'

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 22-08-2022    FEL    1.0          Initial version

***************************************************************************************/
public with sharing class SOM_CreateShipment {
    
    /**
     * @description CreateShipmentAndShipmentItems Invocable Method
     * @param  wrShips List<List<SOM_Wr_ShipmentShipmentItems>> Wrapper List of Shipments and Shipments Items to persist
     */
    @InvocableMethod
    public static void CreateShipmentAndShipmentItems(List<List<SOM_Wr_ShipmentShipmentItems>> wrShips) {
      try {
        Shipment shipment;
        List<Shipment> shipmentsToInsert = new List<Shipment>();
        ShipmentItem shipmentLine;
        List<ShipmentItem> shipItemsToInsert = new List<ShipmentItem>();
        List<String> serialNumbers;
        Map<String,Shipment> mapExtShip = new Map<String,Shipment>();
        Map<String,Shipment> mapExtShipAfterInsert = new Map<String,Shipment>();
        Map<String,List<ShipmentItem>> mapExtShipItem = new Map<String,List<ShipmentItem>>();
        List<Id> foIds = new List<Id>();
        for(SOM_Wr_ShipmentShipmentItems input : wrShips[0]){
            foIds.add(input.foId);
        }
        List<FulfillmentOrder> listFO = [SELECT Id, OrderSummaryId, FulfilledToName, FulfilledFromLocationId,DeliveryMethod.Carrier, DeliveryMethod.ClassOfService, FulfilledToCity, FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry FROM fulfillmentOrder WHERE Id IN : foIds];
        Map<Id,FulfillmentOrder> mapIdFo = new Map<Id, FulfillmentOrder>(listFO);

        List<OrderDeliveryMethod> listODM = [SELECT Id, Carrier, ClassOfService FROM OrderDeliveryMethod];
        Map<Id,OrderDeliveryMethod> mapODM = new Map<Id, OrderDeliveryMethod>(listODM);

        for(SOM_Wr_ShipmentShipmentItems input : wrShips[0]){
            
            if(!mapExtShip.containsKey(input.trackingNumber + input.orderMethodId)){
                shipment     = new Shipment();
                shipment.DeliveryMethodId   = input.orderMethodId;
                shipment.FulfillmentOrderId = input.foId;
                shipment.OrderSummaryId     = mapIdFo.get(input.foId).OrderSummaryId;
                shipment.ShipToName         = mapIdFo.get(input.foId).FulfilledToName;
                shipment.SourceLocationId   = mapIdFo.get(input.foId).FulfilledFromLocationId;
                SOM_DateConvertionInput dateinput = new SOM_DateConvertionInput();
                dateinput.targetTimeZone    = input.timezone;
                dateinput.dateToConvert     = input.dispatchDate;
                shipment.DispatchDate__c    = SOM_DateTimeHelper.convertDateTimeByTimeZone(new List<SOM_DateConvertionInput>{dateinput})[0];
                shipment.WMSShipmentId__c   = input.shipmentExternalId;
                shipment.TrackingNumber     = input.trackingNumber;
                shipment.Carrier__c         = mapODM.get(input.orderMethodId).Carrier;
                shipment.ShippingService__c = mapODM.get(input.orderMethodId).ClassOfService;
                shipment.Status             = SOM_Constants.SHIPMENT_SHIPPED;
                shipment.ShipToCity         = mapIdFo.get(input.foId).FulfilledToCity;
                shipment.ShipToStreet       = mapIdFo.get(input.foId).FulfilledToStreet;
                shipment.ShipToPostalCode   = mapIdFo.get(input.foId).FulfilledToPostalCode;
                shipment.ShipToState        = mapIdFo.get(input.foId).FulfilledToState;
                shipment.ShipToCountry      = mapIdFo.get(input.foId).FulfilledToCountry;
                shipment.CentiroShipmentId__c = input.CrossborderId;
                mapExtShip.put(input.trackingNumber + input.orderMethodId,shipment);
                shipmentsToInsert.add(shipment);
            }
            
            if(input.serialNumber != null){
                serialNumbers = new List<String>();
                serialNumbers = input.serialNumber.split(';');
                for(String serial : serialNumbers){
                    shipmentLine = new ShipmentItem();
                    shipmentLine.SerialNumber__c            = serial;
                    shipmentLine.Quantity                   = Integer.valueOf(input.quantity/serialNumbers.size());  
                    shipmentLine.Product2Id                 = input.productId;
                    shipmentLine.FulfillmentOrderLineItemId = input.foliId;
                    shipmentLine.OrderItemSummaryId         = input.osItemId;
                    if(input.S10Digits == true){
                    	shipmentLine.Sku10Digits__c         	= serial.substring(0, 10);
                    }else{
                    	shipmentLine.Sku10Digits__c         	= input.sku10Digits; 
                    }
                    if(mapExtShipItem.containsKey(input.trackingNumber + input.orderMethodId)){
                        mapExtShipItem.get(input.trackingNumber + input.orderMethodId).add(shipmentLine);
                    }else{
                        mapExtShipItem.put(input.trackingNumber + input.orderMethodId,new List<ShipmentItem>{shipmentLine});
                    }  
      
                }   

            }else{
                shipmentLine = new ShipmentItem();
                shipmentLine.Product2Id                 = input.productId;
                shipmentLine.FulfillmentOrderLineItemId = input.foliId;
                shipmentLine.OrderItemSummaryId         = input.osItemId; 
                shipmentLine.Quantity                   = input.quantity;  
                shipmentLine.Sku10Digits__c             = input.sku10Digits;
                if(mapExtShipItem.containsKey(input.trackingNumber + input.orderMethodId)){
                    mapExtShipItem.get(input.trackingNumber + input.orderMethodId).add(shipmentLine);
                }else{
                    mapExtShipItem.put(input.trackingNumber + input.orderMethodId,new List<ShipmentItem>{shipmentLine});
                }
            }
    
        }
        insert shipmentsToInsert;
        //generate TE for manual shipment
        GenerateTransactionalEmail(shipmentsToInsert);

        for(Shipment ship : shipmentsToInsert){
            mapExtShipAfterInsert.put(ship.TrackingNumber + ship.DeliveryMethodId,ship);
            for(ShipmentItem item : mapExtShipItem.get(ship.TrackingNumber + ship.DeliveryMethodId)){
                item.ShipmentId = (mapExtShipAfterInsert.get(ship.TrackingNumber + ship.DeliveryMethodId)).Id;
                shipItemsToInsert.add(item); 
            }

        }

        insert shipItemsToInsert;
        List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> params = new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs>();
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs param = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
        List<Id> fulIds = new List<Id>();
        param.foIds = new List<Id>();
        param.foIds.addAll(foIds);
        param.doUpdateOSStatus = true;
        params.add(param);
        List<SOM_CloseFulfillmentOrderResponseWr> listFoIdResponse = SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(params); 
           Logs.debug('Create Shippement','SOM_CreateShipment','CreateShipmentAndShipmentItems','','');   
           Logs.info('Create Shippement','SOM_CreateShipment','CreateShipmentAndShipmentItems','','');   
            
        }catch(Exception e){
            Logs.error(e,'SOM_CreateShipment','CreateShipmentAndShipmentItems','','');   
        }  
        }


        /*
            Author : NAIMY BOUCHAIB
            DESCRIPTION : this method used for creating transactional email of shipment after creating
                          manual shipment
        */
        public static void GenerateTransactionalEmail(List<Shipment> shipmentsToInsert) {
            List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> generateTransactionalEmailInputsList = new List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput>();
            for (Shipment shipment : shipmentsToInsert) {
                SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput generateTransactionalEmailInput = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
                generateTransactionalEmailInput.templateName = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION;
                generateTransactionalEmailInput.recordId     = shipment.Id;
                generateTransactionalEmailInputsList.add(generateTransactionalEmailInput);
                
            }
            SOM_TransactionalEmailHandler.generateTransactionalEmail(generateTransactionalEmailInputsList);
        }
    }