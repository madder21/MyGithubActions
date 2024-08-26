@isTest
public with sharing class SOM_BatchAnonymization_6_Test {
    @isTest(seeAllData=true)
    public static OrderSummary setUpData() {
        
        Id pricebookId = Test.getStandardPricebookId();
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Order OrderWithoutOs = SOM_testDataFactory.createOrder(los[0].AccountId,'Order01',los[0].SalesChannelId,'Order1011',pricebookId, true, false);
        insert OrderWithoutOs;
        Schema.Location location1 = SOM_testDataFactory.createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        insert location1;
        Product2 product = SOM_testDataFactory.createProduct('produit 1', '10012022', 'sku10101',true);
        insert product;
        OrderDeliveryMethod oDeliveryMethod = SOM_testDataFactory.createOrderDeliveryMethod('standard_XX',product.Id,'standard_XX');
        insert oDeliveryMethod;
        PricebookEntry priceentry = SOM_testDataFactory.createPricebookEntry(79.2, product.Id, pricebookId);
        insert priceentry;
        OrderDeliveryGroup oDG = SOM_testDataFactory.createOrderDeliveryGroup(OrderWithoutOs.Id,oDeliveryMethod.Id);
        insert oDG;
        
        OrderItem orderItem1 = SOM_testDataFactory.createOrderItem(product.Id, OrderWithoutOs.Id, 1, 79.2,79.2, oDG.Id, SOM_Constants.ORDER_PRODUCT, priceentry.Id, location1.Id, true,false,null);
        insert orderItem1;
        
        OrderWithoutOs.Status = 'Activated'; 
        Update OrderWithoutOs;
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        List<OrderSummary> os = [SELECT Id, OriginalOrderId, Status, AccountId, (SELECT Id, Status FROM OrderItemSummaries) FROM OrderSummary WHERE Id = :los[0].id];
        os[0].Status = SOM_Constants.ORDER_SUMMARY_FULFILLED;
        update os[0];
        DigitalWallet digitWall = new DigitalWallet();
        digitWall.Status         = 'Active';
        digitWall.ProcessingMode = 'External';
        digitWall.AccountId      = los[0].AccountId;
        insert digitWall;
        return los[0];
    }
    
    @isTest(seeAllData=true)
    public static void anonymizeTestOK(){
        OrderSummary orderSu = setUpData();
        String accId = orderSu.AccountId;
        Map<String, String> objectClientId = new Map<String, String>();
        List<String> orderIds = new List<String>();
        Map<String, List<String>> orderSummaryNumbers = new Map<String, List<String>>();
        List<String> ordNum = new List<String>();
        ordNum.add(orderSu.OrderNumber);
        orderIds.add(orderSu.OriginalOrderId);
        orderSummaryNumbers.put(accId, ordNum);
        List<String> cls = new List<String>();
        cls.add(accId); 
        String nonAnonymLogToSend = string.valueof(ordNum).replace('{', '').replace('}', '').replace('(', '').replace(')', '');
        Test.startTest();
        SOM_BatchAnonymization_6 nextBatch = new SOM_BatchAnonymization_6(orderIds, objectClientId, cls,'',nonAnonymLogToSend );
        database.executebatch(nextBatch);
        Test.stopTest();
    }
}