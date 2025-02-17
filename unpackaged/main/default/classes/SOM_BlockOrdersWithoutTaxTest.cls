@isTest
public with sharing class SOM_BlockOrdersWithoutTaxTest {
    
    @isTest
    public static void BlockOrdersWithoutTax(){
        List<List<SOM_RequestBlockOrdersWithoutTax>> Requests = new List<List<SOM_RequestBlockOrdersWithoutTax>>();
        List<SOM_RequestBlockOrdersWithoutTax> Request = new List<SOM_RequestBlockOrdersWithoutTax>();
        SOM_RequestBlockOrdersWithoutTax Req1 = new SOM_RequestBlockOrdersWithoutTax();
        Req1.orderId   = 'Req1orderId';
        Req1.RecordId  = 'Req1RecordId';
        Req1.OrderReferenceNumber = 'Req1OrderReferenceNumber';
        SOM_RequestBlockOrdersWithoutTax Req2 = new SOM_RequestBlockOrdersWithoutTax();
        Req2.orderId   = 'Req2orderId';
        Req2.RecordId  = 'Req2RecordId';
        Req2.OrderReferenceNumber = 'OrderReferenceNumber' ;
        Request.add(Req1);
        Request.add(Req2);
        Requests.add(Request);
        Test.startTest();
        SOM_BlockOrdersWithoutTax.SOM_BlockOrdersWithoutTax(Requests);
        Test.stopTest();
    }
}