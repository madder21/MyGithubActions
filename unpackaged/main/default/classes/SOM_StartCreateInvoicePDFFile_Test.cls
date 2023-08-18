@isTest
public class SOM_StartCreateInvoicePDFFile_Test {
    public static OrderSummary os = new OrderSummary();
    public static List<Invoice> listeInvoice = new List<Invoice>();
    
    public static void setup() {
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,3);
        os = los[0];
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        List<FulfillmentOrder> lFO = [SELECT Id,DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
                                      FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
                                      FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                                      (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                                       OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                                      FROM FulfillmentOrder where Id =: fo.Id];
        Map<Id, FulfillmentOrder> mapIDFO = new Map<Id, FulfillmentOrder>(lFO);
        Map<Id, Shipment> ships = SOM_testDataFactory.createShipments(mapIDFO);
        List<Invoice> invs = [SELECT id, InvoiceNumber__c, CurrencyIsoCode FROM Invoice WHERE ReferenceEntityId =: los[0].Id];
        listeInvoice = invs;
        
    }
    @IsTest(SeeAllData=true)  
    static void TestPushEvent() {
        setup();
        test.enablechangedatacapture();
        test.starttest ();
        InvoiceCreated__e InvoiceEvent = new InvoiceCreated__e (Invoice_Id__c = listeInvoice[0].Id );
        list<Database.SaveResult> sr = eventbus.publish (new List< InvoiceCreated__e > {InvoiceEvent} );
        test.geteventbus().deliver();
        test.stoptest ();
        system.assertEquals(1, sr.size(),'Expected one InvoiceEvent to be published') ;
        system.assertEquals(true, sr[0].isSuccess(),'InvoiceEvent has not been published') ;
        
    }
    
}