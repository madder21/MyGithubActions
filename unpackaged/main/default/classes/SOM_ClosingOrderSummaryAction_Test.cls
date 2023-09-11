@isTest
public class SOM_ClosingOrderSummaryAction_Test {
	public static List<List<Id>> listeFOids = new List<List<Id>>();
    public static List<Id> listFOids = new List<Id>();
    public static List<List<Id>> ListeOsSIds = new List<List<Id>>();
    public static List<Id> listOSids = new List<Id>();
    public static Boolean shipping = false;
    public static Boolean cancel = false;
    public static String errorMessage = '';
    

    @IsTest(seeAllData = true)
    public static void setupData() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.STANDARD,3);
        List<Id> OrderSummaryIds = new List<Id>{los[0].Id,los[1].Id,los[2].Id};
        ListeOsSIds.add(OrderSummaryIds);
        Set<Id> osIds = new Set<Id>{los[0].Id,los[1].Id,los[2].Id};
        FulfillmentOrder fo1 = SOM_testDataFactory.createFO(los[0]);
        FulfillmentOrder fo2 = SOM_testDataFactory.createFO(los[1]);
        List<FulfillmentOrder> fo3 = SOM_testDataFactory.createMultipleFO(los[2]);
        List<Id> FulfillmentOrderIds = new List<Id>{fo1.Id,fo2.Id,fo3[0].Id,fo3[1].Id};
        listFOids.addAll(FulfillmentOrderIds);
        List<OrderItemSummary> ois = [SELECT Id, OrderSummaryId,status FROM OrderItemSummary WHERE Status =:SOM_Constants.Status_Ordered  AND OrderSummaryId IN :osIds];
        List<List<Id>> losIds = new List<List<Id>>{OrderSummaryIds};
		ListeOsSIds = losIds ; 
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
    public static void testClosingOSIsSuccessTrue() {
        setupData(); 
        SOM_CloseFulfillmentOrderResponseWr request = new SOM_CloseFulfillmentOrderResponseWr();
        if(listFOids.size() > 0   )
        request.foIds = listFOids;
        request.osIds = listOSids;
        request.isSuccess = true;
        request.errorMessage = errorMessage;
        
        Test.startTest();
        SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request});
        Test.stopTest();
        System.assertEquals(true,SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request}).get(0).isSuccess,'OS is not closed');
       
    }
    
     @isTest(seeAllData = true)
    public static void testClosingOSIsSuccessFalse() {
        setupData(); 
        SOM_CloseFulfillmentOrderResponseWr request = new SOM_CloseFulfillmentOrderResponseWr();
        if(listFOids.size() > 0  && listOSids.size() > 0 )
        request.foIds = listFOids;
        request.osIds = listOSids;
        request.isSuccess = False;
        request.errorMessage = errorMessage;
        
        Test.startTest();
        SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request});
        Test.stopTest();
        System.assertEquals(false,SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request}).get(0).isSuccess,'OS is closed, status has been updated');
    }
    
     @isTest(seeAllData = true)
    public static void testClosingOSIsFOCanceled() {
        setupData(); 
        SOM_CloseFulfillmentOrderResponseWr request = new SOM_CloseFulfillmentOrderResponseWr();
        list<FulfillmentOrder> FOs = [select Id, Status from FulfillmentOrder where Id in :listFOids];
        for(FulfillmentOrder Fo:FOs){
            Fo.Status = SOM_Constants.FULFILLMENT_ORDER_CANCELED ; 
        }
        update FOs ; 
        if(listFOids.size() > 0 )
        request.foIds = listFOids;
        request.osIds = listOSids;
        request.isSuccess = true;
        request.errorMessage = errorMessage;
        
        Test.startTest();
        SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request});
        Test.stopTest();
        System.assertEquals(true,SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request}).get(0).isSuccess,'OS is not closed, status has not been updated');
    }
    @isTest(seeAllData = true)
    public static void testClosingOSIsFOFulfilled() {
        setupData(); 
        SOM_CloseFulfillmentOrderResponseWr request = new SOM_CloseFulfillmentOrderResponseWr();
        list<FulfillmentOrder> FOs = [select Id, Status from FulfillmentOrder where Id in :listFOids];
        for(FulfillmentOrder Fo:FOs){
            Fo.Status = SOM_Constants.FULFILLMENT_ORDER_FULFILLED ; 
        }
        update FOs ; 
        if(listFOids.size() > 0 )
        request.foIds = listFOids;
        request.osIds = listOSids;
        request.isSuccess = true;
        request.errorMessage = errorMessage;
        
        Test.startTest();
        SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request});
        Test.stopTest();
        System.assertEquals(true,SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request}).get(0).isSuccess,'OS is not closed, status has not been updated');
    } 
     @isTest(seeAllData = true)
    public static void testClosingOSIsFOPartiallyFulfilled() {
        setupData(); 
        SOM_CloseFulfillmentOrderResponseWr request = new SOM_CloseFulfillmentOrderResponseWr();
        list<FulfillmentOrder> FOs = [select Id, Status from FulfillmentOrder where Id in :listFOids];
        for(FulfillmentOrder Fo:FOs){
            Fo.Status = SOM_Constants.FULFILLMENT_ORDER_PARTIALLY_FULFILLED ; 
        }
        update FOs ; 
        if(listFOids.size() > 0 )
        request.foIds = listFOids;
        request.osIds = listOSids;
        request.isSuccess = true;
        request.errorMessage = errorMessage;
        
        Test.startTest();
        SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request});
        Test.stopTest();
        System.assertEquals(true,SOM_ClosingOrderSummaryAction.UpdateOrderSummaryStatus(new List<SOM_CloseFulfillmentOrderResponseWr> {request}).get(0).isSuccess,'OS is not closed, status has not been updated');
    }
    
}