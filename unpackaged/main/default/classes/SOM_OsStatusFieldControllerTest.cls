@isTest
public class SOM_OsStatusFieldControllerTest {
    
    @isTest
    public static void UpdateOrderSummaryStatusTest(){
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        
        Test.startTest();
        SOM_OrderSummaryStatusFieldController.UpdateOrderSummaryStatus(orderList[0].Id );
        OrderSummary os = [ Select Id, Status__c from OrderSummary where Id =: orderList[0].Id ];        
        System.assertEquals('Validated',os.Status__c, 'Order Summary Status: Validated ' );
        Test.stopTest();
        
    }
    
    @isTest
    public static void getOrderSummaryTest(){
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        
        Test.startTest();
        OrderSummary os = SOM_OrderSummaryStatusFieldController.getOrderSummary(orderList[0].Id );
        System.assertNotEquals(null,os, 'Order Summary Status: Validated ' );
        Test.stopTest();
        
    }
    
    @isTest
    public static void getOrderStatusPendingCaptureTest(){
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        OrderSummary os = [ Select ID, GrandTotalAmount, TotalProductAmountWithTax, Status, passedFraudScreening__c, FO_Capture_Error__c,Status__c  from OrderSummary where Id =: orderList[0].Id ];  
        OrderPaymentSummary ops = [SELECT Id, PaymentMethodId , CurrencyIsoCode FROM OrderPaymentSummary WHERE OrderSummaryId =: os.Id];
        os.FO_Capture_Error__c = true;
        update os;
        Test.startTest();
        String Status = SOM_OrderSummaryStatusFieldController.getOrderStatus(os, 0, 0 );
        
        System.assertEquals('Validated - Pending Capture',Status, 'Order Summary Status: Validated - Pending Capture ' );
        Test.stopTest();
        
    }
    
    @isTest
    public static void getOrderStatusRefundedTest(){
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        OrderSummary os = [ Select ID, GrandTotalAmount, TotalProductAmountWithTax, Status, passedFraudScreening__c, FO_Capture_Error__c,Status__c  from OrderSummary where Id =: orderList[0].Id ];  
        OrderPaymentSummary ops = [SELECT Id, PaymentMethodId , CurrencyIsoCode FROM OrderPaymentSummary WHERE OrderSummaryId =: os.Id];
        os.FO_Capture_Error__c = true;
        update os;
        Test.startTest();
        String Status = SOM_OrderSummaryStatusFieldController.getOrderStatus(os, 100, 100 );
        
        System.assertEquals('Validated - Refunded',Status, 'Order Summary Status: Validated - Refunded ' );
        Test.stopTest();
        
    }
    
    @isTest
    public static void getOrderStatusPartiallyRefundedTest(){
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        OrderSummary os = [ Select ID, GrandTotalAmount, TotalProductAmountWithTax, Status, passedFraudScreening__c, FO_Capture_Error__c,Status__c  from OrderSummary where Id =: orderList[0].Id ];  
        OrderPaymentSummary ops = [SELECT Id, PaymentMethodId , CurrencyIsoCode FROM OrderPaymentSummary WHERE OrderSummaryId =: os.Id];
        Test.startTest();
        String Status = SOM_OrderSummaryStatusFieldController.getOrderStatus(os, 0, 100 );
        
        System.assertEquals('Validated - Partially Refunded',Status, 'Order Summary Status: Validated - Partially Refunded ' );
        Test.stopTest();
        
    }
    
    @isTest
    public static void getOrderStatusCapturedTest(){
        List<OrderSummary> orderList = SOM_testDataFactory.createOrderSummaryBulk(false, SOM_testDataFactory.OrderType.Standard, 1);
        OrderSummary os = [ Select ID, GrandTotalAmount, TotalProductAmountWithTax, Status, passedFraudScreening__c, FO_Capture_Error__c,Status__c  from OrderSummary where Id =: orderList[0].Id ];  
        OrderPaymentSummary ops = [SELECT Id, PaymentMethodId , CurrencyIsoCode FROM OrderPaymentSummary WHERE OrderSummaryId =: os.Id];
        Test.startTest();
        String Status = SOM_OrderSummaryStatusFieldController.getOrderStatus(os, 649.60, 0 );
        
        System.assertEquals('Validated - Captured',Status, 'Order Summary Status: Validated - Captured ' );
        Test.stopTest();
        
    }
    
}