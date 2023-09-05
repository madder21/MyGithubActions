@isTest
public class SOM_InvoiceTriggerTest {
    public static List<Invoice> invoices = new List<Invoice>();
    @isTest(seeAllData = true)
    static void makeData(){
        List<OrderSummary> los = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        FulfillmentOrder fo = SOM_testDataFactory.createFO(los[0]);
        Map<Id, FulfillmentOrder> fotest = SOM_testDataFactory.prepareFulfillmentOrderMap(los[0].id);
        Map<Id,Shipment> test = SOM_testDataFactory.createShipments(fotest);
        Invoice invoice = [SELECT Id , Invoice_Timezone_Date__c,CreatedDate, ReferenceEntityId , InvoiceNumber__c , CurrencyIsoCode from Invoice where ReferenceEntity.type =: SOM_Constants.ORDER_SUMMARY_NAME AND ReferenceEntityId = :los[0].Id];
        invoices.add(invoice);
    }

    @isTest(seeAllData = true)
    public static void callConstructor() {
        makeData();
        System.assertNotEquals(invoices[0].Invoice_Timezone_Date__c,null, 'Invoice_Timezone_Date__c Updated');
    }
}