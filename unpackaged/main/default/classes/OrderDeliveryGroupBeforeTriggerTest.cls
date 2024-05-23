@isTest
private class OrderDeliveryGroupBeforeTriggerTest {
    public static List<OrderSummary> listOrderSummary = new List<OrderSummary>();
    
    @testSetup
    static void setup() {
        OrderSummary orderSumm1 = SOM_testDataFactory.customOrderSummaryCreation('ORD-91001001', SOM_Constants.RI_REPAYMENT_METHOD_C_KLARNA, 'E4C294A4ED2CCF54E053AF598E0A061C', false, false);
    }
    
    @isTest
    static void Testbeforeinsert() {
        // Perform setup operations that would trigger the trigger
        Test.startTest();
        OrderSummary os = [SELECT Id FROM OrderSummary WHERE OrderNumber = 'ORD-91001001' LIMIT 1];
        System.debug('Order Summary Id: ' + os.Id);
        
        // Assuming OrderDeliveryGroupSummary and OrderDeliveryGroup records are created by the trigger, query them here
        OrderDeliveryGroupSummary ODGS = [SELECT OriginalOrderDeliveryGroupId FROM OrderDeliveryGroupSummary WHERE OrderSummaryId = :os.Id LIMIT 1];
        System.debug('Order Delivery Group Summary Id: ' + ODGS.Id);
        
        OrderDeliveryGroup[] ODG = [SELECT Id, DeliverToState,DeliverToCountry FROM Orderdeliverygroup WHERE Id = :ODGS.OriginalOrderDeliveryGroupId];
        System.debug('Order Delivery Group Id: ' + ODG[0].Id);
        for(OrderDeliveryGroup deliveryGroup : ODG) {
            deliveryGroup.DeliverToState = 'California';
            deliveryGroup.DeliverToCountry = 'US';
            }
        	update ODG;
            Map<String, String> stateMap = new Map<String, String>();
            Test.stopTest();
            
            // Verify the state of records before any changes are made
            System.assertEquals('California', ODG[0].DeliverToState, 'DeliverToState IS GOOD now');
        }
    }