@isTest
public class SOM_InvoiceHelperTest {
    public static List<Invoice> invoices = new List<Invoice>();

    @isTest(seeAllData = true)
    static void makeData(){
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId = :los[0].id];
        Map<Id, FulfillmentOrder> fotest = new Map<Id, FulfillmentOrder>(lFO);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        Invoice invoice = [SELECT Id , CreatedDate,ReferenceEntityId , InvoiceNumber__c , CurrencyIsoCode from Invoice where ReferenceEntity.type =: SOM_Constants.ORDER_SUMMARY_NAME AND ReferenceEntityId = :los[0].Id];
        invoices.add(invoice);
    }

    @isTest(seeAllData = true)
    public static void callConstructor() {
        makeData();
        SOM_InvoiceHelper.updateInvoiceTimezoneDate(invoices);
        System.assertNotEquals(invoices[0].Invoice_Timezone_Date__c,null, 'Invoice_Timezone_Date__c Updated');
        
    }
}