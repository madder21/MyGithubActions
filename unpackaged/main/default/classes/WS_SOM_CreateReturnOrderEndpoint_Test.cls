@IsTest
public with sharing class WS_SOM_CreateReturnOrderEndpoint_Test {

    @IsTest (SeeAllData = true)
    public static void testHandleReturnOrderCreateUpdateRequestOK(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();
        List<OrderItemSummary> OSItems = [SELECT Id, StockKeepingUnit, OrderSummaryId, isSerialized__c, Product2.isSerialized__c, Product2Id FROM OrderItemSummary WHERE OrderSummaryId IN :osIds];
        List<Product2> prds = new List<Product2>();
        for(OrderItemSummary OSitm : OSItems){
            Product2 prd = new Product2();
            prd.Id = OSitm.Product2Id;
            prd.isSerialized__c = true;
            prds.add(prd);
        }
        update prds;        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds];
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);

        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);
        List<Shipment> shipsList = ships.values();
        Set<Id> shipsIds = (new Map<Id,Shipment>(shipsList)).keySet();
        List<ShipmentItem> shipItems = [SELECT Id, SerialNumber__c, OrderItemSummaryId, OrderItemSummary.StockKeepingUnit FROM ShipmentItem WHERE ShipmentId IN: shipsIds];
        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate roliReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate();
        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest roReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest();
        roliReq.sku                 = shipItems[0].OrderItemSummary.StockKeepingUnit;
        roliReq.quantity            = 1;
        roliReq.conditionId         = 'Resalable';
        roliReq.serialNumbers       = new List<String>{shipItems[0].SerialNumber__c};
        roliReq.reasonCode          = 'RE01';
        roliReq.reasonFreeText      = null;

        roReq.type                  = 1;
        roReq.orderSummaryNumber    = lOS.get(0).OrderNumber;
        roReq.warehouseId           = 'WH_AE';
        roReq.returnOrigin          = 'Customer';
        roReq.returnDate            = '2022-12-16T17:15:58.000Z';
        roReq.items                 = new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate>();
        roReq.items.add(roliReq);

        Test.startTest();
        List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateResponse> res = WS_SOM_CreateReturnOrderEndpoint.handleReturnOrderCreateUpdateRequest(new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest>{roReq});
        System.assertEquals(res[0].returnOrderStatus, 'OK');
        Test.stopTest();
    }


    @IsTest (SeeAllData = true)
    public static void testHandleReturnOrderCreateUpdateRequestOKcaseTWO(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();
        List<OrderItemSummary> OSItems = [SELECT Id, StockKeepingUnit, OrderSummaryId, isSerialized__c, Product2.isSerialized__c, Product2Id FROM OrderItemSummary WHERE OrderSummaryId IN :osIds];
        List<Product2> prds = new List<Product2>();
        for(OrderItemSummary OSitm : OSItems){
            Product2 prd = new Product2();
            prd.Id = OSitm.Product2Id;
            prd.isSerialized__c = true;
            prds.add(prd);
        }
        update prds;        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds];
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);

        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);
        List<Shipment> shipsList = ships.values();
        Set<Id> shipsIds = (new Map<Id,Shipment>(shipsList)).keySet();

        List<ShipmentItem> shipItems = [SELECT Id, SerialNumber__c, OrderItemSummary.StockKeepingUnit FROM ShipmentItem WHERE ShipmentId IN: shipsIds];
        ReturnOrder ro = SOM_testDataFactory.createReturnOrder(lOS[0]);

        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate roliReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate();
        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest roReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest();

        roliReq.sku                 = shipItems[0].OrderItemSummary.StockKeepingUnit;
        roliReq.quantity            = 1;
        roliReq.conditionId         = 'Resalable';
        roliReq.serialNumbers       = new List<String>{shipItems[0].SerialNumber__c};
        roliReq.reasonCode          = 'RE01';
        roliReq.reasonFreeText      = null;

        roReq.type                  = 2;
        roReq.orderSummaryNumber    = lOS.get(0).OrderNumber;
        roReq.warehouseId           = 'WH_AE';
        roReq.returnOrigin          = 'Customer';
        roReq.returnDate            = '2022-12-16T17:15:58.000Z';
        roReq.items                 = new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate>();
        roReq.items.add(roliReq);

        Test.startTest();
        List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateResponse> res = WS_SOM_CreateReturnOrderEndpoint.handleReturnOrderCreateUpdateRequest(new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest>{roReq});
        System.assertEquals(res[0].returnOrderStatus, 'OK');
        Test.stopTest();
    }


    @IsTest
    public static void testHandleReturnOrderCreateUpdateRequestNoShipmentKO(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        

        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate roliReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate();
        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest roReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest();

        roliReq.sku                 = 'sku10001';
        roliReq.quantity            = 4;
        roliReq.conditionId         = 'Resalable';
        roliReq.serialNumbers       = new List<String>{'ser1','ser2','ser3','ser4'};
        roliReq.reasonCode          = 'RE01';
        roliReq.reasonFreeText      = null;

        roReq.type                  = 1;
        roReq.orderSummaryNumber    = lOS.get(0).OrderNumber;
        roReq.warehouseId           = 'WH_AE';
        roReq.returnOrigin          = 'Customer';
        roReq.returnDate            = '2022-12-16T17:15:58.000Z';
        roReq.items                 = new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate>();
        roReq.items.add(roliReq);

        Test.startTest();
        List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateResponse> res = WS_SOM_CreateReturnOrderEndpoint.handleReturnOrderCreateUpdateRequest(new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest>{roReq});
        System.assertEquals(res[0].returnOrderStatus, 'KO');
        Test.stopTest();
    }


    @IsTest (SeeAllData = true)
    public static void testHandleReturnOrderCreateUpdateRequestQuantityKO(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId IN: osIds];
        System.debug('foooo ' + lFO);
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);

        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);


        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate roliReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate();
        WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest roReq = new WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest();

        roliReq.sku                 = 'sku10001';
        roliReq.quantity            = 3;
        roliReq.conditionId         = 'Resalable';
        roliReq.serialNumbers       = new List<String>{'ser1','ser2'};
        roliReq.reasonCode          = 'RE01';
        roliReq.reasonFreeText      = null;

        roReq.type                  = 2;
        roReq.orderSummaryNumber    = lOS.get(0).OrderNumber;
        roReq.warehouseId           = 'WH_AE';
        roReq.returnOrigin          = 'Customer';
        roReq.returnDate            = '2022-12-16T17:15:58.000Z';
        roReq.items                 = new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderItemCreateUpdate>();
        roReq.items.add(roliReq);

        Test.startTest();
        List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateResponse> res = WS_SOM_CreateReturnOrderEndpoint.handleReturnOrderCreateUpdateRequest(new List<WS_SOM_CreateReturnOrderEndpoint.ReturnOrderCreateUpdateRequest>{roReq});
        System.assertEquals(res[0].returnOrderStatus, 'KO');
        Test.stopTest();
    }

}