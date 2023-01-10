@isTest
public class SOM_ClosingOrderSummaryAction_Test {
public static List<List<Id>> listeFOids = new List<List<Id>>();
    public static List<Id> listFOids = new List<Id>();
    public static Boolean shipping = false;
    public static Boolean cancel = false;

    @IsTest(seeAllData = true)
    public static void setupData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.STANDARD,3);
        Set<Id> osIds = new Set<Id>{los[0].Id,los[1].Id,los[2].Id};
        System.debug('osIds'+osIds);
        FulfillmentOrder fo1 = SOM_testDataFactory.createFO(los[0]);
        FulfillmentOrder fo2 = SOM_testDataFactory.createFO(los[1]);
        List<FulfillmentOrder> fo3 = SOM_testDataFactory.createMultipleFO(los[2]);
        List<Id> FulfillmentOrderIds = new List<Id>{fo1.Id,fo2.Id,fo3[0].Id,fo3[1].Id};
        listFOids.addAll(FulfillmentOrderIds);
        System.debug('FulfillmentOrderIds'+FulfillmentOrderIds);
        List<OrderItemSummary> ois = [SELECT Id, OrderSummaryId,status FROM OrderItemSummary WHERE Status =: 'Ordered' AND OrderSummaryId IN :osIds];
        System.debug('ios'+ois);
        List<List<Id>> lfoIds = new List<List<Id>>{FulfillmentOrderIds};
        System.debug('lfoIds'+lfoIds);
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
        System.debug('listeFOids'+listeFOids);
        System.debug('mme *********** listFOids ************'+listFOids);
        
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs request = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
        if(listFOids.size() > 0)
        request.foIds = listFOids;
        request.doUpdateOSStatus = true;
        
        Test.startTest();
        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request});
        Test.stopTest();
        System.assertEquals(true,SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> {request}).get(0).isSuccess);
    }
    
}