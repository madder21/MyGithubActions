@isTest
public with sharing class SOM_BlockOrdersWithoutTaxTest {
    
    @isTest
    public static void BlockOrdersWithoutTax(){
        List<List<SOM_RequestBlockOrdersWithoutTax>> Requests = new List<List<SOM_RequestBlockOrdersWithoutTax>>();
        List<SOM_RequestBlockOrdersWithoutTax> Request = new List<SOM_RequestBlockOrdersWithoutTax>();
        SOM_RequestBlockOrdersWithoutTax Req1 = new SOM_RequestBlockOrdersWithoutTax();
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        OrderSummary os = orderList[0];

        Req1.orderId   = os.Id;
        Req1.RecordId  = os.Id;
        Req1.OrderReferenceNumber = 'Req1OrderReferenceNumber';
        SOM_RequestBlockOrdersWithoutTax Req2 = new SOM_RequestBlockOrdersWithoutTax();
        Req2.orderId   = os.Id;
        Req2.RecordId  = os.Id;
        Req2.OrderReferenceNumber = 'OrderReferenceNumber' ;
        Request.add(Req1);
        Request.add(Req2);
        Requests.add(Request);
        Test.startTest();
        Id OrderIdRecord = Requests[0][0].orderId;
        SOM_BlockOrdersWithoutTax.SOM_BlockOrdersWithoutTax(Requests);
        Test.stopTest();
    }
}