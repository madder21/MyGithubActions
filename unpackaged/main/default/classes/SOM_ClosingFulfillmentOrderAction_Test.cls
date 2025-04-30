@isTest
public with sharing class SOM_ClosingFulfillmentOrderAction_Test {

    public static List<List<Id>> listeFOids = new List<List<Id>>();
    public static List<Id> listFOids = new List<Id>();
    public static List<Id> FOidsList = new List<Id>();
    public static Boolean shipping = false;
    public static Boolean cancel = false;

    @IsTest(seeAllData = true)
    public static void setupData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.STANDARD,1);
        Set<Id> osIds = new Set<Id>{los[0].Id,los[1].Id,los[2].Id};
        FulfillmentOrder fo1 = SOM_testDataFactory.createFO(los[0]);
        FulfillmentOrder fo2 = SOM_testDataFactory.createFO(los[1]);
        List<FulfillmentOrder> fo3 = SOM_testDataFactory.createMultipleFO(los[2]);
        List<Id> FulfillmentOrderIds = new List<Id>{fo1.Id,fo2.Id,fo3[0].Id,fo3[1].Id};
        listFOids.addAll(FulfillmentOrderIds);
        FOidsList.add(FulfillmentOrderIds[0]);
        
        List<OrderItemSummary> ois = [SELECT Id, OrderSummaryId,status FROM OrderItemSummary WHERE Status =: SOM_Constants.Status_Ordered AND OrderSummaryId IN :osIds];
        List<List<Id>> lfoIds = new List<List<Id>>{FulfillmentOrderIds};
        listeFOids = lfoIds;
        if(cancel) {
            List<FulfillmentOrderLineItem> listfoli = [SELECT Id , Quantity FROM FulfillmentOrderLineItem WHERE FulfillmentOrderId IN : FulfillmentOrderIds];
            listfoli[0].Quantity = 0 ;
            update listfoli;
        }
        if(shipping) {
            Map<Id, FulfillmentOrder> mapFO = new Map<Id, FulfillmentOrder>();
            mapFO.put(fo1.Id,fo1);
            mapFO.put(fo2.Id,fo2);
            mapFO.put(fo3[0].Id,fo3[0]);
            SOM_testDataFactory.createShipments(mapFO);
        }
    }

    @isTest(seeAllData = true)
    public static void testClosingOK() {
        setupData(); 
    	List<Id> foIds = new List<Id>();
        List<fulfillmentOrder> ListfulfillmentOrder = [Select Id, Status from fulfillmentOrder where id in: FOidsList  ];
        
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs request = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
        if(FOidsList.size() > 0)
        request.foIds = FOidsList;
        request.doUpdateOSStatus = true;
        
        Test.startTest();
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request});
        Test.stopTest();
        System.assertEquals(true,SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request}).get(0).isSuccess,'Fo Has not been closed');
    }
    
    @isTest(seeAllData = true)
    public static void testClosingEmptyFOLI() {
        setupData(); 
    	List<Id> foIds = new List<Id>();
        List<fulfillmentOrder> ListfulfillmentOrder = [Select Id, Status from fulfillmentOrder where id in: listFOids  ];
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs request = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
        if(listFOids.size() > 0)
        request.foIds = listFOids;
        request.doUpdateOSStatus = true;
        List<FulfillmentOrderLineItem> listfoli = [SELECT Id , Quantity FROM FulfillmentOrderLineItem WHERE FulfillmentOrderId IN : listFOids];
        delete listfoli; 
        update ListfulfillmentOrder;

        Test.startTest();
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request});
        Test.stopTest();
        System.assertEquals(false,SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request}).get(0).isSuccess,'Fo is closed, status has been updated');
    }
    
    @isTest(seeAllData = true)
    public static void testClosingFOLIBadStatus() {
        setupData(); 
    	List<Id> foIds = new List<Id>();
        List<fulfillmentOrder> ListfulfillmentOrder = [Select Id, Status from fulfillmentOrder where id in: listFOids  ];
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs request = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
        if(listFOids.size() > 0)
        request.foIds = listFOids;
        request.doUpdateOSStatus = true;
        List<FulfillmentOrderLineItem> listfoli = [SELECT Id , Quantity FROM FulfillmentOrderLineItem WHERE FulfillmentOrderId IN : listFOids];
        delete listfoli; 
        update ListfulfillmentOrder;

        Test.startTest();
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request});
        Test.stopTest();
        System.assertEquals(false,SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request}).get(0).isSuccess,'Fo is closed, status has been updated');
    }
    
    
    
    



}
