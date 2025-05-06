public class SOM_OrderSummaryStatusFieldController {

    @AuraEnabled
    public static void UpdateOrderSummaryStatus(String OrderSummId) {
        try {
            System.debug('Starting UpdateOrderSummaryStatus for OrderSummId: ' + OrderSummId);
            OrderSummary OS = getOrderSummary(OrderSummId);
            OrderPaymentSummary OrderPS = getOrderPaymentSummary(OrderSummId);

                String newStatus = getOrderStatus(OS, OrderPS.CapturedAmount , OrderPS.RefundedAmount);
                if (newStatus != null) {
                    OS.Status__c = newStatus;
                    updateOrderSummary(OS);
                    System.debug('OrderSummary updated successfully : ' + newStatus);
                } else {
                    System.debug('No status update needed');
                }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            throw new AuraHandledException('Unable to update status: ' + e.getMessage());
        }
    }

    public static OrderSummary getOrderSummary(String OrderSummId) {
        return [SELECT ID, GrandTotalAmount, TotalProductAmountWithTax, Status, passedFraudScreening__c, FO_Capture_Error__c 
                FROM OrderSummary 
                WHERE ID = :OrderSummId 
                LIMIT 1];
    }

    public static OrderPaymentSummary getOrderPaymentSummary(String OrderSummId) {
        return [SELECT CapturedAmount , RefundedAmount 
                FROM OrderPaymentSummary 
                WHERE OrderSummaryId = :OrderSummId];
    }

    public static String getOrderStatus(OrderSummary OS, Decimal sumCapturedAmount, Decimal sumRefundedAmount) {
        if (OS.Status == 'Created' && sumCapturedAmount == 0 && !OS.passedFraudScreening__c) {
            return OS.Status + ' - Waiting Fraud Review';
        } else if (sumCapturedAmount == 0 && OS.FO_Capture_Error__c) {
            return OS.Status + ' - Pending Capture';
        } else if (sumCapturedAmount == OS.GrandTotalAmount && sumCapturedAmount > 0) {
            return OS.Status + ' - Captured';
        } else if ( ( sumRefundedAmount == OS.TotalProductAmountWithTax && sumRefundedAmount > 0 ) || ( sumRefundedAmount == sumCapturedAmount && sumRefundedAmount > 0 ))  {
            return OS.Status + ' - Refunded';
        } else if (sumRefundedAmount > 0 && sumRefundedAmount < OS.TotalProductAmountWithTax) {
            return OS.Status + ' - Partially Refunded';
        }
        return OS.Status;
    }

    public static void updateOrderSummary(OrderSummary OS) {
        update OS;
    }
}