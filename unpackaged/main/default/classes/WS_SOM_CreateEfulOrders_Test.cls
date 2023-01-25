@IsTest
public with sharing class WS_SOM_CreateEfulOrders_Test {
    
    @testSetup static void setup() {
        //create pricebook
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;

        List<Product2> prdList = new List<Product2>();
        List<PricebookEntry> priceEntries = new List<PricebookEntry>();
        Product2 prd0 = SOM_testDataFactory.createProduct('Standard delivery', 'ProductCode1','sku10002',true);
        Product2 prd1 = SOM_testDataFactory.createProduct('Cabin S', 'Cabin S', '123456',false);
        Product2 prd2 = SOM_testDataFactory.createProduct('Cabin L', 'Cabin L', '654321',false);
        prdList.add(prd1);
        prdList.add(prd2);
        prdList.add(prd0);
        insert prdList;
        PricebookEntry entry1 = SOM_testDataFactory.createPricebookEntry(850, prd1.Id, Test.getStandardPricebookId());
        PricebookEntry entry2 = SOM_testDataFactory.createPricebookEntry(850, prd2.Id, Test.getStandardPricebookId());
        PricebookEntry entry0 = SOM_testDataFactory.createPricebookEntry(0, prd0.Id, Test.getStandardPricebookId());
        priceEntries.add(entry1);
        priceEntries.add(entry2);
        priceEntries.add(entry0);
        insert priceEntries;
        SalesChannel saleschannel = SOM_testDataFactory.createSaleschannel('CEGID','CEGID');
        insert saleschannel;
        OrderDeliveryMethod odm = SOM_testDataFactory.createOrderDeliveryMethod('standard_AE', prd0.Id, 'standard_AE');
        insert odm;
        Schema.Location loc = SOM_testDataFactory.createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        insert loc;
        Schema.Location loc2 = SOM_testDataFactory.createLocation('STORE_AE','sTORE_ae', true, 'Store');
        insert loc2;
    }

    @IsTest
    public static void testCreateOrder(){
        Test.startTest();
        List<Account> account = [SELECT Id FROM Account LIMIT 1];
        List<WS_SOM_CreateEfulOrders.EfulOrderRequest> request = createEfulRequest();
        List<Order> ordersBefore = [SELECT Id FROM Order];
        System.debug(ordersBefore);
        WS_SOM_CreateEfulOrders.createEfulOrder(request);
        List<Order> ordersAfter = [SELECT Id FROM Order];
        System.assertEquals(ordersBefore.size()+1, ordersAfter.size());
        Test.stopTest();
    }

    public static List<WS_SOM_CreateEfulOrders.EfulOrderRequest> createEfulRequest(){
        List<WS_SOM_CreateEfulOrders.EfulOrderRequest> efulOrderRequest = new List<WS_SOM_CreateEfulOrders.EfulOrderRequest>();
        WS_SOM_CreateEfulOrders.EfulOrderRequest efulOrder = new WS_SOM_CreateEfulOrders.EfulOrderRequest();
        WS_SOM_CreateEfulOrders.OrderContact deliveryContact = new WS_SOM_CreateEfulOrders.OrderContact();
        deliveryContact.lastName = 'LAFTOUMI';
        deliveryContact.firstName = 'FATIMA-EZZAHRA';
        deliveryContact.street = '123 Secret Street';
        deliveryContact.city = 'Baltimore';
        deliveryContact.state = null;
        deliveryContact.postalCode = 'E1 7AY';
        deliveryContact.country = 'AE';
        deliveryContact.email = 'fatima-ezzahra.laftoumi@viseo.com';
        deliveryContact.phone = '0123456789';

        WS_SOM_CreateEfulOrders.OrderContact billingContact = new WS_SOM_CreateEfulOrders.OrderContact();
        billingContact.lastName = 'LAFTOUMI';
        billingContact.firstName = 'FATIMA-EZZAHRA';
        billingContact.street = '123 Secret Street';
        billingContact.city = 'Baltimore';
        billingContact.state = null;
        billingContact.postalCode = 'E1 7AY';
        billingContact.country = 'AE';
        billingContact.email = 'fatima-ezzahra.laftoumi@viseo.com';
        billingContact.phone = '0123456789';

        List<WS_SOM_CreateEfulOrders.OrderProduct> orderProducts = new List<WS_SOM_CreateEfulOrders.OrderProduct>();
        WS_SOM_CreateEfulOrders.OrderProduct orderProduct = new WS_SOM_CreateEfulOrders.OrderProduct();
        orderProduct.productSKU = '123456';
        orderProduct.quantity = 2;
        orderProduct.amount   = 2040;
        orderProduct.description = null;
        orderProduct.lineNumber = 1;
        orderProduct.type = SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT;
        orderProduct.locationExternalReference = 'rimowa-inventory-ae';

        WS_SOM_CreateEfulOrders.OrderProductTax orderProductTax = new WS_SOM_CreateEfulOrders.OrderProductTax();
        orderProductTax.vat     = 340;
        orderProductTax.vatRate = 20;
        orderProduct.orderProductTax = orderProductTax;
            
        WS_SOM_CreateEfulOrders.OrderProduct orderProduct2 = new WS_SOM_CreateEfulOrders.OrderProduct();
        orderProduct2.productSKU = '654321';
        orderProduct2.quantity   = 1;
        orderProduct2.amount	 = 1020;
        orderProduct2.description = null;
        orderProduct2.lineNumber = 2;
        orderProduct.type = SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT;
        orderProduct2.locationExternalReference = 'rimowa-inventory-ae';

        WS_SOM_CreateEfulOrders.OrderProductTax orderProductTax2 = new WS_SOM_CreateEfulOrders.OrderProductTax();
        orderProductTax2.vat     = 170;
        orderProductTax2.vatRate = 20;
        orderProduct2.orderProductTax = orderProductTax2;

        orderProducts.add(orderProduct);
        orderProducts.add(orderProduct2);

        efulOrder.delivery = deliveryContact;
        efulOrder.billing  = billingContact;
        efulOrder.orderProducts   = orderProducts;
        efulOrder.orderDeliveryMethodName = 'standard_AE';
        efulOrder.salesChannelNumber = 'CEGID';
        efulOrder.orderedDate        = '2022-05-20T17:15:58.000Z';
        efulOrder.currencyCode       = 'AED';
        efulOrder.orderSummaryNumber  ='EFUL-2021072219-1456';

        efulOrderRequest.add(efulOrder);

        return efulOrderRequest;
    }
}