@IsTest
public with sharing class SOM_AdaptReservations_Test {
    
    @IsTest
    public static void testAdapt(){

        List<SOM_AdaptReservations.Request> requestList = new List<SOM_AdaptReservations.Request>();
        SOM_AdaptReservations.Request req = new SOM_AdaptReservations.Request();
        SOM_ADV_Reservation reservation = new SOM_ADV_Reservation();

        req.reservations = new List<SOM_ADV_Reservation>();

        List<OrderSummary> lOS = SOM_testDataFactory.createOrderSummaryBulk(false,SOM_testDataFactory.OrderType.Standard,1);
        Set<Id> osIds = (new Map<Id,OrderSummary>(lOS)).keySet();    

        OrderItemSummary ois = [SELECT Id, quantity, stockKeepingUnit, reservedAtLocationId, product2.stockKeepingUnit FROM OrderItemSummary WHERE OrderSummaryId =: lOS[0].Id AND Type =: 'Order Product' LIMIT 1];
        req.ois = ois;

        reservation.orderSummaryId = lOS[0].ID;
        reservation.orderItemSummaryId = ois.Id;
        reservation.locationId = ois.ReservedAtLocationId;
        reservation.stockKeepingUnit = ois.product2.stockKeepingUnit;
        reservation.quantityAlreadyAllocated = 2;

        req.reservations.add(reservation);
        requestList.add(req);

        Test.startTest();
        
        List<List<SOM_ADV_Reservation>> results = SOM_AdaptReservations.AdaptReserv(requestList);
        List<SOM_ADV_Reservation> result = results[0];
        System.assertEquals(result[0].quantityAlreadyAllocated, 2 + ois.quantity);
        Test.stopTest();
    }
}