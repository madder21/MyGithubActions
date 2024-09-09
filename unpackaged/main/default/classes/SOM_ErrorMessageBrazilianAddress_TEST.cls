@isTest
public with sharing class SOM_ErrorMessageBrazilianAddress_TEST {
    public static OrderSummary os = new OrderSummary();
    public static List<Invoice> listeInvoice = new List<Invoice>();
@IsTest(SeeAllData=true)
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
    }
    
    @isTest(seeAllData=true)
    public static void ErrorMessageBrazilianAddressOS_Test() { 
        setup();
        Test.startTest();
        OrderSummary OsS = [ Select Id, BillingPostalCode, BillingStreet, RI_Neighborhood__c, BillingCity, BillingState from OrderSummary Where Id =: (os.Id) limit 1 ];
        List<SOM_ErrorMessageBrazilianAddress.Requests> Reqs = new List<SOM_ErrorMessageBrazilianAddress.Requests>();
        SOM_ErrorMessageBrazilianAddress.Requests Req = new SOM_ErrorMessageBrazilianAddress.Requests();
        Req.cep = '';
        Req.logradouro = '';
        Req.bairro = '';
        Req.localidade = '';
        Req.uf = '';
        Req.RecordId = OsS.Id;
        Reqs.add(Req);
        
        System.assertNotEquals((SOM_ErrorMessageBrazilianAddress.ErrorMessageBrazilianAddress(Reqs))[0].ErrorMessageDescription, null , 'ErrorMessageBrazilianAddress OS');
        Test.stopTest();
    }
    
    @isTest(seeAllData=true)
    public static void ErrorMessageBrazilianAddressODGS_Test() { 
        setup();
        Test.startTest();
        OrderDeliveryGroupSummary ODGS = [ Select Id, DeliverToPostalCode, DeliverToStreet, RI_Neighborhood__c, DeliverToCity, DeliverToState from OrderDeliveryGroupSummary Where OrderSummaryId =: (os.Id) limit 1 ];
        List<SOM_ErrorMessageBrazilianAddress.Requests> Reqs = new List<SOM_ErrorMessageBrazilianAddress.Requests>();
        SOM_ErrorMessageBrazilianAddress.Requests Req = new SOM_ErrorMessageBrazilianAddress.Requests();
        Req.cep = '';
        Req.logradouro = '';
        Req.bairro = '';
        Req.localidade = '';
        Req.uf = ''; 
        Req.RecordId = ODGS.Id;
        Reqs.add(Req);
        
        System.assertNotEquals((SOM_ErrorMessageBrazilianAddress.ErrorMessageBrazilianAddress(Reqs))[0].ErrorMessageDescription, null , 'ErrorMessageBrazilianAddress ODGS');
        Test.stopTest();
    }
}