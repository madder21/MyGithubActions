@isTest
private class SOM_TransactionalEmailBatchTest {
    private static List<String> TransactionalEmailIds ;
    @isTest(SeeAllData=true)
    static void setupData() {
        Integer recoveryHour = (Integer)[SELECT RecoveryHour__c FROM recoveryHourTE__mdt WHERE DeveloperName = 'recoveryHour' LIMIT 1].RecoveryHour__c;
        
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        OrderSummary os = orderList[0];
        FulfillmentOrder fo = SOM_testDataFactory.createFO(os);
        List<FulfillmentOrder> foList = [
            SELECT Id, DeliveryMethodId, OrderSummaryId, Type, FulfilledFromLocationId,
                   FulfilledFromLocation.VisitorAddress.City,
                   FulfilledFromLocation.VisitorAddress.Street,
                   FulfilledFromLocation.VisitorAddress.PostalCode,
                   FulfilledFromLocation.VisitorAddress.State,
                   FulfilledFromLocation.VisitorAddress.Country,
                   FulfilledToName, FulfilledToCity, FulfilledToStreet, FulfilledToPostalCode,
                   FulfilledToState, FulfilledToCountry,
                   (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                           OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c 
                    FROM FulfillmentOrderLineItems 
                    WHERE Type != :SOM_Constants.DELIVERY_CHARGE)
            FROM FulfillmentOrder 
            WHERE Id = :fo.Id
        ];
        Map<Id, FulfillmentOrder> mapFO = new Map<Id, FulfillmentOrder>(foList);
        System.debug('FulfillmentOrder Map: ' + mapFO);
        Map<Id, Shipment> shipments = SOM_testDataFactory.createShipments(mapFO);
        
        List<Invoice> invList = [SELECT Id FROM Invoice WHERE ReferenceEntityId = :os.Id];
        if (!invList.isEmpty()) {
            invList[0].InvoiceNumber__c = 'invtest1';
            update invList;
        }
        
        Account accTest = new Account(personEmail = 'test@test.com', lastName = 'test');
        insert accTest;
        
        List<TransactionalEmail__c> testEmails = new List<TransactionalEmail__c>{
            new TransactionalEmail__c(
                Client__c = accTest.Id,
                OrderSummary__c = os.Id,
                Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND,
                Template__c = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CREATED
            ),
            new TransactionalEmail__c(
                Client__c = accTest.Id,
                OrderSummary__c = os.Id,
                Status__c = SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND,
                Template__c = SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION
            )
        };
        insert testEmails;
        
        List<String> Emails = new List<String>();
        for (TransactionalEmail__c te : testEmails) {
            Emails.add(te.Id);
        }
        TransactionalEmailIds = Emails ;    }
    
    @isTest(SeeAllData=true)
    static void testBatchProcess() {
        setupData();
        Test.startTest();
        Database.executeBatch(new SOM_TransactionalEmailBatch(TransactionalEmailIds));
        Test.stopTest();
        
        List<TransactionalEmail__c> emails = [SELECT Id, Status__c, Template__c FROM TransactionalEmail__c where Id IN :TransactionalEmailIds];
        System.assertEquals(2, emails.size(), 'There should be two transactional emails.');
         
    }
}