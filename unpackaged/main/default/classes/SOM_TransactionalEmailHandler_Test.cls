/**************************************************************************************

-- - Author        : Fatima-Ezzahra LAFTOUMI

-- - Description   : Test class for 'SOM_TransactionalEmailHandler' Class

--

-- Maintenance History:

--

-- Date         Name    Version      Remarks

-- -----------  ----    -------  -------------------------------------------------------

-- 08-07-2022    FEL    1.0          Initial version

***************************************************************************************/
@isTest
public with sharing class SOM_TransactionalEmailHandler_Test {

    /**
     * @description setup : create test data (Order Summaries ...)
     */
    // public static void setup() {
    //     Id pricebookId = Test.getStandardPricebookId();
    //     Pricebook2 standardPricebook = new Pricebook2(
    //         Id = pricebookId,
    //         IsActive = true
    //     );
    //     update standardPricebook;


    //     List<Product2> prodList = new List<Product2>();
    //     List<PricebookEntry> priceEntries = new List<PricebookEntry>();
    //     Product2 prod1 = SOM_testDataFactory.createProduct('Prod1', 'Code1','SKU00001');
    //     Product2 prod2 = SOM_testDataFactory.createProduct('Prod2', 'Code2','SKU00002');
    //     Product2 prod3 = SOM_testDataFactory.createProduct('Prod3', 'Code3','SKU00003');
    //     prodList.add(prod1);
    //     prodList.add(prod2);
    //     prodList.add(prod3);
    //     insert prodList;
    //     PricebookEntry entry1 = SOM_testDataFactory.createPricebookEntry(870, prod1.Id, Test.getStandardPricebookId());
    //     PricebookEntry entry2 = SOM_testDataFactory.createPricebookEntry(855, prod2.Id, Test.getStandardPricebookId());
    //     PricebookEntry entry3 = SOM_testDataFactory.createPricebookEntry(800, prod3.Id, Test.getStandardPricebookId());
    //     priceEntries.add(entry1);
    //     priceEntries.add(entry2);
    //     priceEntries.add(entry3);
    //     insert priceEntries;
    //     SalesChannel saleschannel = SOM_testDataFactory.createSaleschannel('CEGID','CEGID');
    //     insert saleschannel;
    //     OrderDeliveryMethod odm = SOM_testDataFactory.createOrderDeliveryMethod('standard_GB', prod1.Id, 'standard_GB');
    //     insert odm;
    //     Schema.Location loc = SOM_testDataFactory.createLocation('WH_GB','rimowa-inventory-uk', true, 'Warehouse');
    //     insert loc;
    //     Account acc = SOM_testDataFactory.createAccount('test.user@rimowa.com');
    //     Order ord = SOM_testDataFactory.createOrder(acc.Id,'Fatima ezzahra Laftoumi',saleschannel.Id,'Ref001100011',standardPricebook.Id, true,false);
    //     insert ord;
    //     OrderDeliveryGroup odg = SOM_testDataFactory.createOrderDeliveryGroup(ord.Id,odm.Id);
    //     odg.STORE_OPENING_FR__c = '11:00 - 19:00';
    //     odg.STORE_OPENING_SA__c = '11:00 - 19:00';
    //     odg.STORE_OPENING_SU__c = '11:00 - 19:00';
    //     odg.STORE_OPENING_MO__c = '11:00 - 19:00';
    //     odg.STORE_OPENING_TU__c = '11:00 - 19:00';
    //     odg.STORE_OPENING_WE__c = '11:00 - 19:00';
    //     odg.STORE_OPENING_TH__c = '11:00 - 19:00';

    //     insert odg;
    //     List<OrderItem> listOrderItems =new List<OrderItem>();
    //     OrderItem orderItem1 = SOM_testDataFactory.createOrderItem(prodList[0].Id, ord.Id, 1, 870, 870, odg.Id, SOM_Constants.ORDER_PRODUCT, priceEntries[0].Id, loc.Id, false,false,null);
    //     listOrderItems.add(orderItem1);
    //     OrderItem orderItem2 = SOM_testDataFactory.createOrderItem(prodList[1].Id, ord.Id, 1, 855, 855, odg.Id, SOM_Constants.DELIVERY_CHARGE, priceEntries[1].Id, loc.Id, false,false,null);
    //     listOrderItems.add(orderItem2);
    //     OrderItem orderItem3 = SOM_testDataFactory.createOrderItem(prodList[2].Id, ord.Id, 2, 800, 800, odg.Id, SOM_Constants.ORDER_PRODUCT,priceEntries[2].Id, loc.Id, false,false,null);
    //     listOrderItems.add(orderItem3);
    //     insert listOrderItems;
    
    //     ord.Status = SOM_Constants.ORDER_ACTIVATED_STATUS;
    //     update ord;
    
    //     SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);

    // }

    /**
    * @description createInputs : 
    * @return List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> 
    */    
    public static List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> createInputs (){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        FulfillmentOrder fo2 = SOM_testDataFactory.createFO(lOS[1]);
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
        Set<Id> shipIds = ships.keySet();
        List<String> strShipIds = (List<String>)JSON.deserialize(JSON.serialize(shipIds), List<String>.class);

        List<Invoice> inv = [SELECT Id FROM Invoice WHERE ReferenceEntityId IN: osIds];

        ReturnOrder ro = SOM_testDataFactory.createReturnOrder(lOS[0]);

        Refund ref = SOM_testDataFactory.createRefundWithCreditMemo(lOS[1],false,false);

        List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> inputs = new List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput>();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input1 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input2 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input3 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input4 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input5 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input6 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input7 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();
        SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput input8 = new SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput();

        input1.templateName = 'ShipmentConfirmation';
        input2.templateName = 'Invoice';
      //  input3.templateName = 'OrderCreated';
        input4.templateName = 'ReturnReceived';
        input5.templateName = 'OrderReadyForPickup';
        input6.templateName = 'ReturnCreated';
        input7.templateName = 'RefundConfirmation';
        input8.templateName = 'RefundValidationMissingProduct';

        input1.recordId = strShipIds[0];
        input2.recordId = inv[0].Id;
       // input3.recordId = lOS[5].Id;
        //input4.recordId = ro.Id;
        input5.recordId = lOS[0].Id;
        input6.recordId = ro.Id;
        input7.recordId = ref.Id;
        input8.recordId = ref.Id;

         //inputs.add(input1);
         // inputs.add(input2);
       // inputs.add(input3);
         // inputs.add(input4);
        // inputs.add(input5);
        // inputs.add(input6);
        // inputs.add(input7);
         inputs.add(input8);
System.debug('the h inputs :::: ' + inputs);
        return inputs;
    }

    @IsTest(seeAllData = true)
    public static void testGenerateTransactionalEmail(){
        
        Test.startTest();

        //List<TransactionalEmail__c> transactionalEmails = [SELECT Id FROM TransactionalEmail__c];
        List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> inputs = createInputs();
        SOM_TransactionalEmailHandler.generateTransactionalEmail(inputs);
        List<TransactionalEmail__c> transactionalEmailsAfter = [SELECT Id FROM TransactionalEmail__c];
        //System.assertEquals(transactionalEmails.size(), transactionalEmailsAfter.size());

        Test.stopTest();
    }

    @IsTest
    public static void testGenerateOrderTransactionalEmails(){
        SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);


        List<OrderSummary> lOS = [SELECT Id,Status FROM OrderSummary];
        Set<String> Ids = (new Map<String,OrderSummary>(lOS)).keySet();
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>(); 

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateOrderTransactionalEmails(Ids);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

    @IsTest(seeAllData = true)
    public static void testGenerateOrderReadyForPickupTransactionalEmails(){
        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(true,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo ' + fo);
        Set<String> Ids = (new Map<String,OrderSummary>(lOS)).keySet();
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>(); 

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateOrderReadyForPickupTransactionalEmails(Ids);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

    @IsTest(seeAllData = true)
    public static void testGenerateShipmentConfirmationTransactionalEmails(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo ' + fo);
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);
        List<Shipment> sh = [SELECT Id FROM Shipment];
        Set<Id> shipIds = (new Map<Id,Shipment>(sh)).keySet();
        List<ShipmentItem> shI = [SELECT Id FROM ShipmentItem];
        Set<String> lIds = (Set<String>)JSON.deserialize(JSON.serialize(shipIds), Set<String>.class);
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        List<FulfillmentOrder> lFO2 = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo 2' + lFO2);
        trans = SOM_TransactionalEmailHandler.generateShipmentConfirmationTransactionalEmails(lIds);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

    @IsTest(seeAllData = true)
    public static void testGenerateInvoiceTransactionalEmails(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo ' + lFO);
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);
        Map<Id, Invoice> inv = new Map<Id, Invoice>([SELECT Id, InvoiceNumber__c, CurrencyIsoCode FROM Invoice WHERE ReferenceEntityId =: lOS[0].Id]);
        System.debug('invoice :::::::::: ' +inv);
        Map<Id, CorrectiveInvoice__c> cinv = SOM_testDataFactory.createCorrectiveInvoices(inv);
        Set<Id> sIds = new Set<Id>(); 
        sIds.addAll(inv.keySet());
        sIds.addAll(cinv.keySet());
        Set<String> lIds = (Set<String>)JSON.deserialize(JSON.serialize(sIds), Set<String>.class);
   
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateInvoiceTransactionalEmails(lIds);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

    @IsTest(seeAllData = true)
    public static void testGenerateReturnOrderCreationTransactionalEmails(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo ' + lFO);
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        System.debug('fo: ::::::  ezdzd ' + mapIDFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        ReturnOrder ro = SOM_testDataFactory.createReturnOrder(lOS[0]);
        List<ReturnOrder> testDataRo = [SELECT Id FROM ReturnOrder WHERE Id =: ro.Id];

        Set<String> roIds = (new Map<String,ReturnOrder>(testDataRo)).keySet();
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateReturnOrderCreationTransactionalEmails(roIds);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

    @IsTest(seeAllData = true)
    public static void testGenerateReturnReceptionTransactionalEmails(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo ' + lFO);
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        ReturnOrder ro = SOM_testDataFactory.createReturnOrder(lOS[0]);
        List<ReturnOrder> testDataRo = [SELECT Id FROM ReturnOrder WHERE Id =: ro.Id];

        Set<String> roIds = (new Map<String,ReturnOrder>(testDataRo)).keySet();
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateReturnReceptionTransactionalEmails(roIds);
        System.debug('transacional ::: ' + trans);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

    @IsTest(seeAllData = true)
    public static void testGenerateRefundValidationTransactionalEmails(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo ' + lFO);
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        Refund ref = SOM_testDataFactory.createRefundWithCreditMemo(lOS[0],false,false);

        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateRefundValidationTransactionalEmails(new Set<String>{ref.Id});
        System.debug('transacional ::: ' + trans);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

    @IsTest(seeAllData = true)
    public static void testGenerateRefundWithoutCreditMemoTransactionalEmails(){

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,7);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();        
        FulfillmentOrder fo = SOM_testDataFactory.createFO(lOS[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: lOS[0].Id];
        System.debug('foooo ' + lFO);
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        Refund ref = SOM_testDataFactory.createRefundWithCreditMemo(lOS[0],false,false);

        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateRefundWithoutCreditMemoTransactionalEmails(new Set<String>{ref.Id});
        System.debug('transacional ::: ' + trans);
        System.assertNotEquals(0,trans.size());
        Test.stopTest();
    }

}