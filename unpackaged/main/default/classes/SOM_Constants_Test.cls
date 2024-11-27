/**
 * @author : Eric B
 * @date : January 2024
 * @Type Apex Class
 *****************************************************************************************************************************************************************
 * @description this class conducts only basic equality testing for all constants defined in SOM_Constants classs
 ***************************************************************************************************************************************************************** 
 * @Version : 
 * Version	|Date of modication	|Modified By|Related Jira Ticket|Description of changes			
 * 0.0		|25012024			|.EBU		|.					|.
 */

@IsTest
public class SOM_Constants_Test {

   /*
    * @Description : Test all string constants from SOM_Constants class
    * @param  : none
    * @return : none
    * @Expected behaviour : none, only test all constants
    */
    @IsTest
    static void TestAllStringConstants() {
        System.assertEquals( 'CardPaymentMethod' , SOM_Constants.CARD_PAYMENT_METHOD , 'CARD_PAYMENT_METHOD not equal to defined constant' );
        System.assertEquals( 'DigitalWallet' , SOM_Constants.DIGITAL_WALLET , 'DIGITAL_WALLET not equal to defined constant' );
        System.assertEquals( 'amount_currency' , SOM_Constants.AMOUNT_CURRENCY , 'AMOUNT_CURRENCY not equal to defined constant' );
        System.assertEquals( 'currency' , SOM_Constants.CAPTURE_CURRENCY_ATTRIBUTE , 'CAPTURE_CURRENCY_ATTRIBUTE not equal to defined constant' );
        System.assertEquals( 'callout:Payment_Capture_Service/services/payments/capture' , SOM_Constants.CAPTURE_CALLOUT_ENDPOINT , 'CAPTURE_CALLOUT_ENDPOINT not equal to defined constant' );
        System.assertEquals( 'PAYPAL' , SOM_Constants.DIGITAL_WALLET_TYPE_PAYPAL , 'DIGITAL_WALLET_TYPE_PAYPAL not equal to defined constant' );
        System.assertEquals( 'To capture' , SOM_Constants.FULFILLMENT_ORDER_TO_CAPTURE_STATUS , 'FULFILLMENT_ORDER_TO_CAPTURE_STATUS not equal to defined constant' );
        System.assertEquals( 'C_KLARNA' , SOM_Constants.RI_REPAYMENT_METHOD_C_KLARNA , 'RI_REPAYMENT_METHOD_C_KLARNA not equal to defined constant' );
        System.assertEquals( 'C_CC' , SOM_Constants.RI_REPAYMENT_METHOD_C_CREDIT_CARD , 'RI_REPAYMENT_METHOD_C_CREDIT_CARD not equal to defined constant' );
        System.assertEquals( 'CC' , SOM_Constants.REFUND_METHOD_CC , 'REFUND_METHOD_CC not equal to defined constant' );
        System.assertEquals( 'PPL' , SOM_Constants.REFUND_METHOD_PPL , 'REFUND_METHOD_PPL not equal to defined constant' );
        System.assertEquals( 'KLI' , SOM_Constants.REFUND_METHOD_KLI , 'REFUND_METHOD_KLI not equal to defined constant' );
        System.assertEquals( 'Exchange' , SOM_Constants.EXCHANGE , 'EXCHANGE not equal to defined constant' );
        System.assertEquals( 'Fulfilling' , SOM_Constants.FULFILLING , 'FULFILLING not equal to defined constant' );
        System.assertEquals( 'CoreModel' , SOM_Constants.TEMPLATE_CoreModel , 'TEMPLATE_CoreModel not equal to defined constant' );
        System.assertEquals( 'New' , SOM_Constants.PE_NEW , 'PE_NEW not equal to defined constant' );
        System.assertEquals( 'Payment' , SOM_Constants.PE_PAYMENT , 'PE_PAYMENT not equal to defined constant' );
        System.assertEquals( 'Ordered' , SOM_Constants.Status_Ordered , 'Status_Ordered not equal to defined constant' );
        System.assertEquals( 'Charge' , SOM_Constants.INVOICE_LINE_TYPE_CHARGE , 'INVOICE_LINE_TYPE_CHARGE not equal to defined constant' );
        System.assertEquals( 'Tax' , SOM_Constants.INVOICE_LINE_TYPE_TAX , 'INVOICE_LINE_TYPE_TAX not equal to defined constant' );
        System.assertEquals( 'Adjustment' , SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT , 'CreditMemo_LINE_TYPE_ADJUSTMENT not equal to defined constant' );
        System.assertEquals( 'Appeasement' , SOM_Constants.REFUND_ORIGIN_APPEASEMENT , 'REFUND_ORIGIN_APPEASEMENT not equal to defined constant' );
        System.assertEquals( 'Generated' , SOM_Constants.PDF_GENERATION_STATUS_GENERATED , 'PDF_GENERATION_STATUS_GENERATED not equal to defined constant' );
        System.assertEquals( 'Created' , SOM_Constants.RETURN_ORDER_STATUS_CREATED , 'RETURN_ORDER_STATUS_CREATED not equal to defined constant' );
        System.assertEquals( 'Received' , SOM_Constants.RETURN_ORDER_STATUS_RECEIVED , 'RETURN_ORDER_STATUS_RECEIVED not equal to defined constant' );
        System.assertEquals( 'Submitted' , SOM_Constants.RETURN_ORDER_STATUS_SUBMITTED , 'RETURN_ORDER_STATUS_SUBMITTED not equal to defined constant' );
        System.assertEquals( 'Closed' , SOM_Constants.RETURN_ORDER_STATUS_CLOSED , 'RETURN_ORDER_STATUS_CLOSED not equal to defined constant' );
        System.assertEquals( 'MANAGED' , SOM_Constants.RETURN_ORDER_LIFE_CYCLE_TYPE , 'RETURN_ORDER_LIFE_CYCLE_TYPE not equal to defined constant' );
        System.assertEquals( 'UNMANAGED' , SOM_Constants.RETURN_ORDER_LIFE_CYCLE_UNMANAGED , 'RETURN_ORDER_LIFE_CYCLE_UNMANAGED not equal to defined constant' );
        System.assertEquals( 'Allocated' , SOM_Constants.FULFILLMENT_ORDER_ALLOCATED , 'FULFILLMENT_ORDER_ALLOCATED not equal to defined constant' );
        System.assertEquals( 'Created' , SOM_Constants.FULFILLMENT_ORDER_CREATED , 'FULFILLMENT_ORDER_CREATED not equal to defined constant' );
        System.assertEquals( 'Fulfilling' , SOM_Constants.FULFILLMENT_ORDER_FULFILLING , 'FULFILLMENT_ORDER_FULFILLING not equal to defined constant' );
        System.assertEquals( 'Canceled' , SOM_Constants.FULFILLMENT_ORDER_CANCELED , 'FULFILLMENT_ORDER_CANCELED not equal to defined constant' );
        System.assertEquals( 'Partially Fulfilled' , SOM_Constants.FULFILLMENT_ORDER_PARTIALLY_FULFILLED , 'FULFILLMENT_ORDER_PARTIALLY_FULFILLED not equal to defined constant' );
        System.assertEquals( 'Fulfilled' , SOM_Constants.FULFILLMENT_ORDER_FULFILLED , 'FULFILLMENT_ORDER_FULFILLED not equal to defined constant' );
        System.assertEquals( 'Store' , SOM_Constants.FULFILLMENT_ORDER_FULFILLED_IN_STORE_PICKUP , 'FULFILLMENT_ORDER_FULFILLED_IN_STORE_PICKUP not equal to defined constant' );
        System.assertEquals( 'To capture' , SOM_Constants.ORDER_TO_CAPTURE_STATUS , 'ORDER_TO_CAPTURE_STATUS not equal to defined constant' );
        System.assertEquals( 'Delivery Charge' , SOM_Constants.FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE , 'FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE not equal to defined constant' );
        System.assertEquals( 'Created' , SOM_Constants.ORDER_SUMMARY_CREATED , 'ORDER_SUMMARY_CREATED not equal to defined constant' );
        System.assertEquals( 'Validated' , SOM_Constants.ORDER_SUMMARY_VALIDATED , 'ORDER_SUMMARY_VALIDATED not equal to defined constant' );
        System.assertEquals( 'Fulfilling' , SOM_Constants.ORDER_SUMMARY_FULFILLING , 'ORDER_SUMMARY_FULFILLING not equal to defined constant' );
        System.assertEquals( 'Canceled' , SOM_Constants.ORDER_SUMMARY_CANCELED , 'ORDER_SUMMARY_CANCELED not equal to defined constant' );
        System.assertEquals( 'Partially Fulfilled' , SOM_Constants.ORDER_SUMMARY_PARTIALLY_FULFILLED , 'ORDER_SUMMARY_PARTIALLY_FULFILLED not equal to defined constant' );
        System.assertEquals( 'Fulfilled' , SOM_Constants.ORDER_SUMMARY_FULFILLED , 'ORDER_SUMMARY_FULFILLED not equal to defined constant' );
        System.assertEquals( 'Resalable' , SOM_Constants.RETURN_LINE_ITEM_CONDITION_RESALABLE , 'RETURN_LINE_ITEM_CONDITION_RESALABLE not equal to defined constant' );
        System.assertEquals( 'ReturnOrderLineItemTriggerHandler-canUpdateReturnOrderLineItemConditionId' , SOM_Constants.RETURN_ORDER_ITEM_TRIGGER_CONDITION_ID , 'RETURN_ORDER_ITEM_TRIGGER_CONDITION_ID not equal to defined constant' );
        System.assertEquals( 'OrderSummaryTriggerHandler-canUpdateOrderSummaryOnHold' , SOM_Constants.ORDER_SUMMARY_TRIGGER_ON_HOLD , 'ORDER_SUMMARY_TRIGGER_ON_HOLD not equal to defined constant' );
        System.assertEquals( 'ReturnOrderTriggerHandler-canUpdateReturnOrderStatus' , SOM_Constants.RETURN_ORDER_TRIGGER_STATUS , 'RETURN_ORDER_TRIGGER_STATUS not equal to defined constant' );
        System.assertEquals( 'Refund' , SOM_Constants.RETURN_LINE_ITEM_FOLLOW_UP_REFUND , 'RETURN_LINE_ITEM_FOLLOW_UP_REFUND not equal to defined constant' );
        System.assertEquals( 'Created' , SOM_Constants.SHIPMENT_CREATED , 'SHIPMENT_CREATED not equal to defined constant' );
        System.assertEquals( 'Shipped' , SOM_Constants.SHIPMENT_SHIPPED , 'SHIPMENT_SHIPPED not equal to defined constant' );
        System.assertEquals( 'RE10' , SOM_Constants.RETURN_DEFAULT_REASON_CODE , 'RETURN_DEFAULT_REASON_CODE not equal to defined constant' );
        System.assertEquals( 'You cannot update the condition field because the status of the Return Order is different to Received.' , SOM_Constants.RETURN_ORDER_CONDITIONID_ERROR_MESSAGE , 'RETURN_ORDER_CONDITIONID_ERROR_MESSAGE not equal to defined constant' );
        System.assertEquals( 'You cannot put this Order Summary on hold.' , SOM_Constants.ORDER_SUMMARY_ONHOLD_ERROR_MESSAGE , 'ORDER_SUMMARY_ONHOLD_ERROR_MESSAGE not equal to defined constant' );
        System.assertEquals( 'You cannot update the status field.' , SOM_Constants.RETURN_ORDER_STATUS_ERROR_MESSAGE , 'RETURN_ORDER_STATUS_ERROR_MESSAGE not equal to defined constant' );
        System.assertEquals( 'Order Product' , SOM_Constants.ORDER_ITEM_TYPE_ORDER_PRODUCT , 'ORDER_ITEM_TYPE_ORDER_PRODUCT not equal to defined constant' );
        System.assertEquals( 'Draft' , SOM_Constants.ORDER_DRAFT_STATUS , 'ORDER_DRAFT_STATUS not equal to defined constant' );
        System.assertEquals( 'Activated' , SOM_Constants.ORDER_ACTIVATED_STATUS , 'ORDER_ACTIVATED_STATUS not equal to defined constant' );
        System.assertEquals( 'Estimated' , SOM_Constants.ORDER_ITEM_TAX_TYPE_ESTIMATED , 'ORDER_ITEM_TAX_TYPE_ESTIMATED not equal to defined constant' );
        System.assertEquals( 'Active' , SOM_Constants.PAYMENT_METHOD_STATUS_ACTIVE , 'PAYMENT_METHOD_STATUS_ACTIVE not equal to defined constant' );
        System.assertEquals( 'Processed' , SOM_Constants.PAYMENT_STATUS_PROCESSED , 'PAYMENT_STATUS_PROCESSED not equal to defined constant' );
        System.assertEquals( 'Capture' , SOM_Constants.PAYMENT_TYPE_CAPTURE , 'PAYMENT_TYPE_CAPTURE not equal to defined constant' );
        System.assertEquals( 'External' , SOM_Constants.PAYMENT_PROCESSING_MODE_EXTERNAL , 'PAYMENT_PROCESSING_MODE_EXTERNAL not equal to defined constant' );
        System.assertEquals( 'Visa' , SOM_Constants.CARD_PAYMENT_TYPE_VISA , 'CARD_PAYMENT_TYPE_VISA not equal to defined constant' );
        System.assertEquals( 'Deleted' , SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED , 'PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED not equal to defined constant' );
        System.assertEquals( 'Deletion Error' , SOM_Constants.PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR , 'PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR not equal to defined constant' );
        System.assertEquals( 'Active' , SOM_Constants.ACTIVE , 'ACTIVE not equal to defined constant' );
        System.assertEquals( 'Created' , SOM_Constants.CREATED , 'CREATED not equal to defined constant' );
        System.assertEquals( 'Account' , SOM_Constants.ACCOUNT , 'ACCOUNT not equal to defined constant' );
        System.assertEquals( 'Activated' , SOM_Constants.ACTIVATED , 'ACTIVATED not equal to defined constant' );
        System.assertEquals( 'Allocated' , SOM_Constants.ALLOCATED , 'ALLOCATED not equal to defined constant' );
        System.assertEquals( 'Canceled' , SOM_Constants.CANCELED , 'CANCELED not equal to defined constant' );
        System.assertEquals( 'Delivery Charge' , SOM_Constants.DELIVERY_CHARGE , 'DELIVERY_CHARGE not equal to defined constant' );
        System.assertEquals( 'Draft' , SOM_Constants.DRAFT , 'DRAFT not equal to defined constant' );
        System.assertEquals( 'Fulfilling' , SOM_Constants.FO_STATUS_CATEGORY_FULFILLING , 'FO_STATUS_CATEGORY_FULFILLING not equal to defined constant' );
        System.assertEquals( 'Closed' , SOM_Constants.CLOSED , 'CLOSED not equal to defined constant' );
        System.assertEquals( 'Fulfilled' , SOM_Constants.FULFILLED , 'FULFILLED not equal to defined constant' );
        System.assertEquals( 'Generated' , SOM_Constants.GENERATED , 'GENERATED not equal to defined constant' );
        System.assertEquals( 'Order Product' , SOM_Constants.ORDER_PRODUCT , 'ORDER_PRODUCT not equal to defined constant' );
        System.assertEquals( 'PersonAccount' , SOM_Constants.PERSON_ACCOUNT , 'PERSON_ACCOUNT not equal to defined constant' );
        System.assertEquals( 'Product' , SOM_Constants.PRODUCT , 'PRODUCT not equal to defined constant' );
        System.assertEquals( 'Shipped' , SOM_Constants.SHIPPED , 'SHIPPED not equal to defined constant' );
        System.assertEquals( 'Submitted' , SOM_Constants.SUBMITTED , 'SUBMITTED not equal to defined constant' );
        System.assertEquals( 'Test' , SOM_Constants.TEST , 'TEST not equal to defined constant' );
        System.assertEquals( 'Validated' , SOM_Constants.VALIDATED , 'VALIDATED not equal to defined constant' );
        System.assertEquals( 'Warehouse' , SOM_Constants.WAREHOUSE , 'WAREHOUSE not equal to defined constant' );
        System.assertEquals( 'Store' , SOM_Constants.STORE , 'STORE not equal to defined constant' );
        System.assertEquals( 'External' , SOM_Constants.EXTERNAL_MODE , 'EXTERNAL_MODE not equal to defined constant' );
        System.assertEquals( 'Processed' , SOM_Constants.PROCESSED , 'PROCESSED not equal to defined constant' );
        System.assertEquals( 'application/json' , SOM_Constants.FILE_TYPE , 'FILE_TYPE not equal to defined constant' );
        System.assertEquals( 'UPDATE' , SOM_Constants.OCI_UPLOAD_MODE , 'OCI_UPLOAD_MODE not equal to defined constant' );
        System.assertEquals( 'PENDING' , SOM_Constants.STATUS_PENDING , 'STATUS_PENDING not equal to defined constant' );
        System.assertEquals( 'COMPLETED' , SOM_Constants.STATUS_COMPLETED , 'STATUS_COMPLETED not equal to defined constant' );
        System.assertEquals( 'ShipmentConfirmation' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION not equal to defined constant' );
        System.assertEquals( 'Invoice' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE not equal to defined constant' );
        System.assertEquals( 'To send' , SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_TO_SEND , 'TRANSACTIONAL_EMAIL_STATUS_TO_SEND not equal to defined constant' );
        System.assertEquals( 'Sent' , SOM_Constants.TRANSACTIONAL_EMAIL_STATUS_SENT , 'TRANSACTIONAL_EMAIL_STATUS_SENT not equal to defined constant' );
        System.assertEquals( 'OrderCreated' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CREATED , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CREATED not equal to defined constant' );
        System.assertEquals( 'ReturnReceived' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_RECEIVED , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_RECEIVED not equal to defined constant' );
        System.assertEquals( 'OrderReadyForPickup' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_READY_FOR_PICKUP , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_READY_FOR_PICKUP not equal to defined constant' );
        System.assertEquals( 'ReturnCreated' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_CREATED , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_CREATED not equal to defined constant' );
        System.assertEquals( 'RefundConfirmation' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_CONFIRMATION , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_CONFIRMATION not equal to defined constant' );
        System.assertEquals( 'RefundValidationMissingProduct' , SOM_Constants.TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_ON_MISSING_PRODUCT , 'TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_ON_MISSING_PRODUCT not equal to defined constant' );
        System.assertEquals( 'Posted' , SOM_Constants.INVOICE_POSTED , 'INVOICE_POSTED not equal to defined constant' );
        System.assertEquals( 'Charge' , SOM_Constants.CREDITMEMOLINE_CHARGE_TYPE , 'CREDITMEMOLINE_CHARGE_TYPE not equal to defined constant' );
        System.assertEquals( 'OrderSummary' , SOM_Constants.ORDER_SUMMARY_NAME , 'ORDER_SUMMARY_NAME not equal to defined constant' );
        System.assertEquals( 'CountryTech__c' , SOM_Constants.ORDER_SUMMARY_COUNTRY_FIELD_NAME , 'ORDER_SUMMARY_COUNTRY_FIELD_NAME not equal to defined constant' );
        System.assertEquals( '50g' , SOM_Constants.CREDIT_MEMO_KEY_PREFIX , 'CREDIT_MEMO_KEY_PREFIX not equal to defined constant' );
        System.assertEquals( 'CreditMemo' , SOM_Constants.CREDIT_MEMO_SOBJECT_TYPE_NAME , 'CREDIT_MEMO_SOBJECT_TYPE_NAME not equal to defined constant' );
        System.assertEquals( 'Invoice' , SOM_Constants.INVOICE_SOBJECT_TYPE_NAME , 'INVOICE_SOBJECT_TYPE_NAME not equal to defined constant' );
        System.assertEquals( 'CorrectiveInvoice__c' , SOM_Constants.CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME , 'CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME not equal to defined constant' );
        System.assertEquals( 'Shipment' , SOM_Constants.SHIPMENT_SOBJECT_TYPE_NAME , 'SHIPMENT_SOBJECT_TYPE_NAME not equal to defined constant' );
        System.assertEquals( 'OrderSummary' , SOM_Constants.ORDER_SUMMARY_SOBJECT_TYPE_NAME , 'ORDER_SUMMARY_SOBJECT_TYPE_NAME not equal to defined constant' );
        System.assertEquals( 'ReturnOrder' , SOM_Constants.RETURN_ORDER_SOBJECT_TYPE_NAME , 'RETURN_ORDER_SOBJECT_TYPE_NAME not equal to defined constant' );
        System.assertEquals( 'Refund' , SOM_Constants.REFUND_SOBJECT_TYPE_NAME , 'REFUND_SOBJECT_TYPE_NAME not equal to defined constant' );
        System.assertEquals( 'CEGID' , SOM_Constants.SALES_CHANNEL_CEGID , 'SALES_CHANNEL_CEGID not equal to defined constant' );
        System.assertEquals( 'Manual Order' , SOM_Constants.SALES_CHANNEL_MANUAL , 'SALES_CHANNEL_MANUAL not equal to defined constant' );
        System.assertEquals( 'Rimowa' , SOM_Constants.SALES_CHANNEL_RIMOWA , 'SALES_CHANNEL_RIMOWA not equal to defined constant' );
        System.assertEquals( 'E_Commerce_Payment_Capture_Errors_' , SOM_Constants.ECOMMERCE_PAYMENT_CAPTURE_ERRORS , 'ECOMMERCE_PAYMENT_CAPTURE_ERRORS not equal to defined constant' );
        System.assertEquals( '###.##0,00' , SOM_Constants.AMOUNT_FORMAT1 , 'AMOUNT_FORMAT1 not equal to defined constant' );
        System.assertEquals( '###,##0.00' , SOM_Constants.AMOUNT_FORMAT2 , 'AMOUNT_FORMAT2 not equal to defined constant' );
        System.assertEquals( 'T!T' , SOM_Constants.TABULAR_REPORT_FACT_MAP_KEY , 'TABULAR_REPORT_FACT_MAP_KEY not equal to defined constant' );
        System.assertEquals( 'XXXXXXXXXX' , SOM_Constants.STRING_OPERATOR_ANONYMIZATION , 'STRING_OPERATOR_ANONYMIZATION not equal to defined constant' );
        System.assertEquals( 'XXXXXXXXXX@XXX.XXX' , SOM_Constants.EMAIL_OPERATOR_ANONYMIZATION , 'EMAIL_OPERATOR_ANONYMIZATION not equal to defined constant' );
        System.assertEquals( 'Fulfillment' , SOM_Constants.FULFILLMENT , 'FULFILLMENT not equal to defined constant' );
        
    }
    
   /*
    * @Description : Test all integer constants from SOM_Constants class
    * @param  : none
    * @return : none
    * @Expected behaviour : none, only test all constants
    */
    @IsTest
    static void TestAllIntegerConstants() {
        System.assertEquals( 1 , SOM_Constants.RMA_RETURN_TYPE , 'RMA_RETURN_TYPE not equal to defined constant' );
        System.assertEquals( 2 , SOM_Constants.WMS_RETURN_TYPE , 'WMS_RETURN_TYPE not equal to defined constant' );
        System.assertEquals( 100 , SOM_Constants.MAX_CALLOUT_NUMBER , 'MAX_CALLOUT_NUMBER not equal to defined constant' );
        System.assertEquals( 999999999 , SOM_Constants.INTEGER_OPERATOR_ANONYMIZATION , 'INTEGER_OPERATOR_ANONYMIZATION not equal to defined constant' );
        
    }
        
}