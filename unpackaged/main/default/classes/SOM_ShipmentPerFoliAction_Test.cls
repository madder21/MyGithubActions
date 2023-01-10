@isTest
public class SOM_ShipmentPerFoliAction_Test {
public static List<FulfillmentOrderLineItem> listfoli = new List<FulfillmentOrderLineItem>();
    public static List<Id> listFOids = new List<Id>();
    public static List<List<Id>> listFOLineids = new List<List<Id>>();
    public static SOM_LWC_DisplayFoliToShip_Controller.Wr_ShippedQty request = new SOM_LWC_DisplayFoliToShip_Controller.Wr_ShippedQty();

    
    @isTest(seeAllData=true)
    public static void makeData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.STANDARD,3);
        Set<Id> osIds = new Set<Id>{los[0].Id,los[1].Id,los[2].Id};
        System.debug('osIds'+osIds);
        FulfillmentOrder fo1 = SOM_testDataFactory.createFO(los[0]);
        FulfillmentOrder fo2 = SOM_testDataFactory.createFO(los[1]);
        List<FulfillmentOrder> fo3 = SOM_testDataFactory.createMultipleFO(los[2]);
        List<Id> FulfillmentOrderIds = new List<Id>{fo1.Id,fo2.Id,fo3[0].Id,fo3[1].Id};
        listFOids.addAll(FulfillmentOrderIds);
        List<FulfillmentOrderLineItem> listfoli = [SELECT Id , Quantity FROM FulfillmentOrderLineItem WHERE FulfillmentOrderId IN : FulfillmentOrderIds];
        System.debug('listfoli'+listfoli);
        List<Id> FulfillmentOrderLineIds = new List<Id>{listfoli[0].Id};
        listFOLineids.add(FulfillmentOrderLineIds);
        request.idFOLI = listfoli[0].Id;
        request.qty = 0;
        
    }
    
    @isTest(seeAllData=true)
    public static void getShippedQuantityByFOLITest() { 
        makeData();
        
        Test.startTest();
        SOM_ShipmentPerFoliAction.getShippedQuantityByFOLI(listFOLineids);
        Test.stopTest();
    }
}