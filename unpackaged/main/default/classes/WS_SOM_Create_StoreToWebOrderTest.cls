@IsTest
public with sharing class WS_SOM_Create_StoreToWebOrderTest {
    
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
        OrderDeliveryMethod odm = SOM_testDataFactory.createOrderDeliveryMethod('standard_GB', prd0.Id, 'standard_GB');
        insert odm;
        Schema.Location loc = SOM_testDataFactory.createLocation('WH_GB','rimowa-inventory-uk', true, 'Warehouse');
        insert loc;
        SOM_testDataFactory.createAccount('test.user@rimowa.com');
    }

    @IsTest//(SeeAllData=true)
    public static void testCreateOrder(){
        Test.startTest();
        List<Account> account = [SELECT Id FROM Account LIMIT 1];
        WS_SOM_Create_StoreToWebOrder.StoreToWebRequest request = createStoreToWebRequest(account.get(0).Id);
        List<Order> ordersBefore = [SELECT Id FROM Order];
        System.debug('------------orders before----');
        System.debug(ordersBefore);
        WS_SOM_Create_StoreToWebOrder.createOrder(request);
        List<Order> ordersAfter = [SELECT Id FROM Order];
        System.assertEquals(ordersBefore.size()+1, ordersAfter.size());
        Test.stopTest();
    }

    public static WS_SOM_Create_StoreToWebOrder.StoreToWebRequest createStoreToWebRequest(Id accoundId){
        WS_SOM_Create_StoreToWebOrder.StoreToWebOrder storeToWebOrder = new WS_SOM_Create_StoreToWebOrder.StoreToWebOrder();
        WS_SOM_Create_StoreToWebOrder.OrderContact deliveryContact = new WS_SOM_Create_StoreToWebOrder.OrderContact();
        deliveryContact.lastName = 'ANBRI';
        deliveryContact.firstName = 'AMINE';
        deliveryContact.street = '123 Secret Street';
        deliveryContact.city = 'Baltimore';
        deliveryContact.state = null;
        deliveryContact.postalCode = 'E1 7AY';
        deliveryContact.country = 'GB';
        deliveryContact.email = 'mohamed-amine.anbri@viseo.com';
        deliveryContact.phone = '0123456789';

        WS_SOM_Create_StoreToWebOrder.OrderContact billingContact = new WS_SOM_Create_StoreToWebOrder.OrderContact();
        billingContact.lastName = 'ANBRI';
        billingContact.firstName = 'AMINE';
        billingContact.street = '123 Secret Street';
        billingContact.city = 'Baltimore';
        billingContact.state = null;
        billingContact.postalCode = 'E1 7AY';
        billingContact.country = 'GB';
        billingContact.email = 'mohamed-amine.anbri@viseo.com';
        billingContact.phone = '0123456789';

        List<WS_SOM_Create_StoreToWebOrder.OrderProduct> orderProducts = new List<WS_SOM_Create_StoreToWebOrder.OrderProduct>();
        WS_SOM_Create_StoreToWebOrder.OrderProduct orderProduct = new WS_SOM_Create_StoreToWebOrder.OrderProduct();
        orderProduct.productSKU = '123456';
        orderProduct.quantity = 2;
        orderProduct.amount   = 2040;
        orderProduct.shortDescription = null;
        orderProduct.lineNumber = 1;
        orderProduct.type = SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT;
        orderProduct.locationExternalReference = 'rimowa-inventory-uk';

        WS_SOM_Create_StoreToWebOrder.OrderProductTax orderProductTax = new WS_SOM_Create_StoreToWebOrder.OrderProductTax();
        orderProductTax.vat     = 340;
        orderProductTax.vatRate = 20;
        orderProduct.orderProductTax = orderProductTax;
            
        WS_SOM_Create_StoreToWebOrder.OrderProduct orderProduct2 = new WS_SOM_Create_StoreToWebOrder.OrderProduct();
        orderProduct2.productSKU = '654321';
        orderProduct2.quantity   = 1;
        orderProduct2.amount	 = 1020;
        orderProduct2.shortDescription = null;
        orderProduct2.lineNumber = 2;
        orderProduct.type = SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT;
        orderProduct2.locationExternalReference = 'rimowa-inventory-uk';

        WS_SOM_Create_StoreToWebOrder.OrderProductTax orderProductTax2 = new WS_SOM_Create_StoreToWebOrder.OrderProductTax();
        orderProductTax2.vat     = 170;
        orderProductTax2.vatRate = 20;
        orderProduct2.orderProductTax = orderProductTax2;

        orderProducts.add(orderProduct);
        orderProducts.add(orderProduct2);

        storeToWebOrder.deliveryContact = deliveryContact;
        storeToWebOrder.billingContact  = billingContact;
        storeToWebOrder.orderProducts   = orderProducts;
        storeToWebOrder.orderDeliveryMethodReferenceNumber = 'standard_GB';
        storeToWebOrder.paymentReference = '1234567';
        storeToWebOrder.paymentMethodCode = 'CIP';
        storeToWebOrder.accountId         = accoundId;
        storeToWebOrder.salesChannelNumber = 'CEGID';
        storeToWebOrder.orderedDate        = '2022-05-20T17:15:58.000Z';
        storeToWebOrder.currencyCode       = 'GBP';
        storeToWebOrder.orderSummaryNumber  ='STS-2021072219-1456';
        storeToWebOrder.storeOriginName	   = 'Dallas - North Park Centre';
        storeToWebOrder.storeOrigin        = 'US11';

        List<WS_SOM_Create_StoreToWebOrder.StoreToWebOrder> orders = new List<WS_SOM_Create_StoreToWebOrder.StoreToWebOrder>();
        orders.add(storeToWebOrder);

        WS_SOM_Create_StoreToWebOrder.StoreToWebRequest req = new WS_SOM_Create_StoreToWebOrder.StoreToWebRequest();
        req.orders = orders;

        return req;
    }
}