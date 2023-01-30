@IsTest
public with sharing class WS_SOM_CreateEfulReturnOrders_Test {

    @testSetup static void setup() {

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet(); 

        Schema.Location loc = SOM_testDataFactory.createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        insert loc;
        
    }

    @IsTest
    public static void testCreateReturnOrder(){
        Test.startTest();
        List<WS_SOM_CreateEfulReturnOrders.EfulReturnOrderRequest> request = createEfulRequest();
        List<ReturnOrder> roBefore = [SELECT Id FROM ReturnOrder];
        System.debug(roBefore);
        WS_SOM_CreateEfulReturnOrders.createEfulReturnOrder(request);
        List<ReturnOrder> roAfter = [SELECT Id FROM ReturnOrder];
        System.assertEquals(roBefore.size()+1, roAfter.size());
        Test.stopTest();
    }

    public static List<WS_SOM_CreateEfulReturnOrders.EfulReturnOrderRequest> createEfulRequest(){
        List<WS_SOM_CreateEfulReturnOrders.EfulReturnOrderRequest> efulReturnOrderRequest = new List<WS_SOM_CreateEfulReturnOrders.EfulReturnOrderRequest>();
        WS_SOM_CreateEfulReturnOrders.EfulReturnOrderRequest efulReturnOrder = new WS_SOM_CreateEfulReturnOrders.EfulReturnOrderRequest();

        List<WS_SOM_CreateEfulReturnOrders.ReturnOrderItem> returnOrderProducts = new List<WS_SOM_CreateEfulReturnOrders.ReturnOrderItem>();
        WS_SOM_CreateEfulReturnOrders.ReturnOrderItem returnOrderProduct = new WS_SOM_CreateEfulReturnOrders.ReturnOrderItem();
        returnOrderProduct.sku          = 'sku10001';
        returnOrderProduct.reasonCode   = 'RE01';
        returnOrderProduct.lineFollowUp = 'Refund';
        returnOrderProduct.isProcessed  = true;
        returnOrderProduct.conditionId  = 'Resalable';
        returnOrderProduct.quantityExpected = 2;
        returnOrderProduct.quantityReceived = 2;
        returnOrderProduct.quantityReturned = 2;
        returnOrderProduct.serialNumbers    = new List<String>{'12345678901234567','3245353535355353'}	;
            
        returnOrderProducts.add(returnOrderProduct);

        OrderSummary os = [SELECT Id, OrderNumber FROM OrderSummary LIMIT 1];
        efulReturnOrder.roDescription = 'EFUL RO 0001';
        efulReturnOrder.roStatus        = 'Closed';
        efulReturnOrder.roLocation      = 'WH_AE';
        efulReturnOrder.roOrigin        = 'Customer';
        efulReturnOrder.roDate          = '2022-05-20T17:15:58.000Z';
        efulReturnOrder.orderSummaryNumber    = os.OrderNumber;
        efulReturnOrder.items                 = returnOrderProducts;

        efulReturnOrderRequest.add(efulReturnOrder);

        return efulReturnOrderRequest;
    }
}