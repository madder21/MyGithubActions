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
        input4.templateName = 'ReturnReceived';
        input5.templateName = 'OrderReadyForPickup';
        input6.templateName = 'ReturnCreated';
        input7.templateName = 'RefundConfirmation';
        input8.templateName = 'RefundValidationMissingProduct';

        input1.recordId = strShipIds[0];
        input2.recordId = inv[0].Id;
        input5.recordId = lOS[0].Id;
        input6.recordId = ro.Id;
        input7.recordId = ref.Id;
        input8.recordId = ref.Id;

         inputs.add(input8);
        return inputs;
    }

    @IsTest(seeAllData = true)
    public static void testGenerateTransactionalEmail(){
        
        Test.startTest();

        List<SOM_TransactionalEmailHandler.SOM_GenerateTransactionalEmailInput> inputs = createInputs();
        SOM_TransactionalEmailHandler.generateTransactionalEmail(inputs);
        List<TransactionalEmail__c> transactionalEmailsAfter = [SELECT Id FROM TransactionalEmail__c];
        System.assertNotEquals(0,transactionalEmailsAfter.size(), 'Transactional Email Generated');

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
        System.assertNotEquals(0,trans.size(), 'Transactional Email - Order Generated' );
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
        Set<String> Ids = (new Map<String,OrderSummary>(lOS)).keySet();
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>(); 

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateOrderReadyForPickupTransactionalEmails(Ids);
        System.assertNotEquals(0,trans.size(), 'Transactional Email - OrderReadyForPickup Generated');
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
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        List<Shipment> sh = SOM_testDataFactory.createShipments(mapIDFO).values();
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
        trans = SOM_TransactionalEmailHandler.generateShipmentConfirmationTransactionalEmails(lIds);
        System.assertNotEquals(0,trans.size(), 'Transactional Email - ShipmentConfirmation Generated');
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
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);
        Map<Id, Invoice> inv = new Map<Id, Invoice>([SELECT Id, InvoiceNumber__c, CurrencyIsoCode FROM Invoice WHERE ReferenceEntityId =: lOS[0].Id]);
        Map<Id, CorrectiveInvoice__c> cinv = SOM_testDataFactory.createCorrectiveInvoices(inv);
        Set<Id> sIds = new Set<Id>(); 
        sIds.addAll(inv.keySet());
        sIds.addAll(cinv.keySet());
        Set<String> lIds = (Set<String>)JSON.deserialize(JSON.serialize(sIds), Set<String>.class);
   
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateInvoiceTransactionalEmails(lIds);
        System.assertNotEquals(0,trans.size(), 'Transactional Email - Invoice Generated');
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
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        ReturnOrder ro = SOM_testDataFactory.createReturnOrder(lOS[0]);
        List<ReturnOrder> testDataRo = [SELECT Id FROM ReturnOrder WHERE Id =: ro.Id];

        Set<String> roIds = (new Map<String,ReturnOrder>(testDataRo)).keySet();
        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateReturnOrderCreationTransactionalEmails(roIds);
        System.assertNotEquals(0,trans.size(), 'Transactional Email - ReturnOrderCreation Generated');
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
        System.assertNotEquals(0,trans.size(), 'Transactional Email - ReturnReception Generated');
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
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        Refund ref = SOM_testDataFactory.createRefundWithCreditMemo(lOS[0],false,false);

        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateRefundValidationTransactionalEmails(new Set<String>{ref.Id});
        System.assertNotEquals(0,trans.size(), 'Transactional Email  - RefundValidation Generated');
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
        
        Set<Id> Ids = (new Map<Id,FulfillmentOrder>(lFO)).keySet();
        Set<String> LId = (Set<String>)JSON.deserialize(JSON.serialize(Ids), Set<String>.class);
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        SOM_testDataFactory.createShipments(mapIDFO);

        Refund ref = SOM_testDataFactory.createRefundWithCreditMemo(lOS[0],false,false);

        List<TransactionalEmail__c> trans = new List<TransactionalEmail__c>();

        Test.startTest();
        trans = SOM_TransactionalEmailHandler.generateRefundWithoutCreditMemoTransactionalEmails(new Set<String>{ref.Id});
        System.assertNotEquals(0,trans.size(), 'Transactional Email - RefundWithoutCreditMemo Generated');
        Test.stopTest();
    }

}
