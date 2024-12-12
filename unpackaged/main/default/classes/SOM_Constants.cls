global with sharing class SOM_Constants {
    public static final String  CARD_PAYMENT_METHOD                 = 'CardPaymentMethod';
    public static final String  DIGITAL_WALLET                      = 'DigitalWallet';
    public static final String  AMOUNT_CURRENCY                     = 'amount_currency';
    public static final String  CAPTURE_CURRENCY_ATTRIBUTE          = 'currency';
    public static final String  CAPTURE_CALLOUT_ENDPOINT            = 'callout:Payment_Capture_Service/services/payments/capture';
    public static final String  DIGITAL_WALLET_TYPE_PAYPAL          = 'PAYPAL';
    public static final String  FULFILLMENT_ORDER_TO_CAPTURE_STATUS = 'To capture';
    public static final String  RI_REPAYMENT_METHOD_C_KLARNA        = 'C_KLARNA';
    public static final String  RI_REPAYMENT_METHOD_C_CREDIT_CARD   = 'C_CC';
    
    public static final String REFUND_METHOD_CC			            = 'CC';
    public static final String REFUND_METHOD_PPL			        = 'PPL';
    public static final String REFUND_METHOD_KLI			        = 'KLI';

    public static final String EXCHANGE			             		= 'Exchange';
    public static final String FULFILLING			             	= 'Fulfilling';
	public static final String TEMPLATE_CoreModel             		= 'CoreModel';
    public static final String PE_NEW             					= 'New';
    public static final String PE_PAYMENT             				= 'Payment';
    public static final String Status_Ordered             			= 'Ordered';
    
    
    public static final String INVOICE_LINE_TYPE_CHARGE             = 'Charge';
    public static final String INVOICE_LINE_TYPE_TAX                = 'Tax';
    public static final String CreditMemo_LINE_TYPE_ADJUSTMENT      = 'Adjustment';
    public static final String REFUND_ORIGIN_APPEASEMENT            = 'Appeasement';

    public static final String PDF_GENERATION_STATUS_GENERATED      = 'Generated';

    public static final Integer RMA_RETURN_TYPE              = 1;
    public static final Integer WMS_RETURN_TYPE              = 2;
    public static final String RETURN_ORDER_STATUS_CREATED   = 'Created';
    public static final String RETURN_ORDER_STATUS_RECEIVED  = 'Received';
    public static final String RETURN_ORDER_STATUS_SUBMITTED = 'Submitted';
    public static final String RETURN_ORDER_STATUS_CLOSED    = 'Closed';
    public static final String RETURN_ORDER_LIFE_CYCLE_TYPE  = 'MANAGED';
    public static final String RETURN_ORDER_LIFE_CYCLE_UNMANAGED  = 'UNMANAGED';

    public static final String FULFILLMENT_ORDER_ALLOCATED                 = 'Allocated';
    public static final String FULFILLMENT_ORDER_CREATED                   = 'Created';
    public static final String FULFILLMENT_ORDER_FULFILLING                = 'Fulfilling';
    public static final String FULFILLMENT_ORDER_CANCELED                  = 'Canceled';
    public static final String FULFILLMENT_ORDER_PARTIALLY_FULFILLED       = 'Partially Fulfilled';
    public static final String FULFILLMENT_ORDER_FULFILLED                 = 'Fulfilled';
    public static final String FULFILLMENT_ORDER_FULFILLED_IN_STORE_PICKUP = 'Store';
    public static final String ORDER_TO_CAPTURE_STATUS = 'To capture';

    public static final String FULFILLMENT_ORDER_LINE_ITEM_DELIVERY_CHARGE = 'Delivery Charge';

    public static final String ORDER_SUMMARY_CREATED             = 'Created';
    public static final String ORDER_SUMMARY_VALIDATED           = 'Validated';
    public static final String ORDER_SUMMARY_FULFILLING          = 'Fulfilling';
    public static final String ORDER_SUMMARY_CANCELED            = 'Canceled';
    public static final String ORDER_SUMMARY_PARTIALLY_FULFILLED = 'Partially Fulfilled';
    public static final String ORDER_SUMMARY_FULFILLED           = 'Fulfilled';

    public static final String RETURN_LINE_ITEM_CONDITION_RESALABLE  = 'Resalable';
    public static final String RETURN_ORDER_ITEM_TRIGGER_CONDITION_ID = 'ReturnOrderLineItemTriggerHandler-canUpdateReturnOrderLineItemConditionId';
    public static final String ORDER_SUMMARY_TRIGGER_ON_HOLD          = 'OrderSummaryTriggerHandler-canUpdateOrderSummaryOnHold';
    public static final String RETURN_ORDER_TRIGGER_STATUS            = 'ReturnOrderTriggerHandler-canUpdateReturnOrderStatus';
    public static final String RETURN_LINE_ITEM_FOLLOW_UP_REFUND      = 'Refund';

    public static final String SHIPMENT_CREATED     = 'Created';
    public static final String SHIPMENT_SHIPPED    = 'Shipped';

    public static final String RETURN_DEFAULT_REASON_CODE = 'RE10';

    public static final String RETURN_ORDER_CONDITIONID_ERROR_MESSAGE = 'You cannot update the condition field because the status of the Return Order is different to Received.';
    public static final String ORDER_SUMMARY_ONHOLD_ERROR_MESSAGE     = 'You cannot put this Order Summary on hold.';
    public static final String RETURN_ORDER_STATUS_ERROR_MESSAGE      = 'You cannot update the status field.';

    public static final String ORDER_ITEM_TYPE_ORDER_PRODUCT    = 'Order Product';
    public static final String ORDER_DRAFT_STATUS               = 'Draft';
    public static final String ORDER_ACTIVATED_STATUS           = 'Activated';
    public static final String ORDER_ITEM_TAX_TYPE_ESTIMATED    = 'Estimated';
    public static final String PAYMENT_METHOD_STATUS_ACTIVE     = 'Active';
    public static final String PAYMENT_STATUS_PROCESSED         = 'Processed';
    public static final String PAYMENT_TYPE_CAPTURE             = 'Capture';
    public static final String PAYMENT_PROCESSING_MODE_EXTERNAL = 'External';

    public static final String  CARD_PAYMENT_TYPE_VISA          = 'Visa';
    public static final String  PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETED        = 'Deleted';
    public static final String  PAYMENT_AUTHORIZATION_CUSTOMER_TOKEN_DELETION_ERROR = 'Deletion Error';
    public static final Integer MAX_CALLOUT_NUMBER = 100;
    //Test class Constants
    public static final String ACTIVE = 'Active';
    public static final String CREATED = 'Created';
    public static final String ACCOUNT = 'Account';
    public static final String ACTIVATED = 'Activated';
    public static final String ALLOCATED = 'Allocated';
    public static final String CANCELED = 'Canceled';
    public static final string DELIVERY_CHARGE = 'Delivery Charge';
    public static final String DRAFT = 'Draft';
    public static final String FO_STATUS_CATEGORY_FULFILLING = 'Fulfilling';
    public static final String CLOSED = 'Closed';
    public static final String FULFILLED = 'Fulfilled';
    public static final String GENERATED = 'Generated';
    public static final string ORDER_PRODUCT = 'Order Product';
    public static final String PERSON_ACCOUNT = 'PersonAccount';
    public static final String PRODUCT = 'Product';
    public static final String SHIPPED = 'Shipped';
    public static final String SUBMITTED = 'Submitted';
    public static final String TEST = 'Test';
    public static final String VALIDATED = 'Validated';
    public static final String WAREHOUSE = 'Warehouse';
    public static final String STORE = 'Store';
    public static final String EXTERNAL_MODE = 'External';
    public static final String PROCESSED = 'Processed';


    //OCI_Static_Labels
    public static final String FILE_TYPE = 'application/json';
    public static final String OCI_UPLOAD_MODE = 'UPDATE';
    public static final String STATUS_PENDING = 'PENDING';
    public static final String STATUS_COMPLETED = 'COMPLETED';

    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_SHIPPING_CONFIRMATION  = 'ShipmentConfirmation';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_INVOICE                = 'Invoice';
    public static final String TRANSACTIONAL_EMAIL_STATUS_TO_SEND                       = 'To send';
	public static final String TRANSACTIONAL_EMAIL_STATUS_SENT                      	= 'Sent';
    public static final String TRANSACTIONAL_EMAIL_STATUS_DRAFT                      	= 'Draft';
    
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CANCELED          = 'OrderCanceled';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CREATED          = 'OrderCreated';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_RECEIVED        = 'ReturnReceived';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_READY_FOR_PICKUP = 'OrderReadyForPickup';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_RETURN_CREATED         = 'ReturnCreated';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_CONFIRMATION    = 'RefundConfirmation';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_REFUND_ON_MISSING_PRODUCT = 'RefundValidationMissingProduct';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_ORDER_CC_AUTOMATIC_CANCEL   = 'CCAutomaticOrderCancellation';
    public static final String TRANSACTIONAL_EMAIL_TEMPLATE_NAME_ORDER_CC_REMINDER      = 'CCReminder';
	public static final String Rimowa_URL = 'https://rimowa.com/';
	public static final String STORELOCATOR_URL = 'storelocator';

    public static final String INVOICE_POSTED  = 'Posted';
    public static final String CREDITMEMOLINE_CHARGE_TYPE = 'Charge';

    public static final String ORDER_SUMMARY_NAME = 'OrderSummary';
    public static final String ORDER_DELIVERY_GROUP_SUMMARY_NAME = 'OrderDeliveryGroupSummary';
    public static final String ORDER_SUMMARY_COUNTRY_FIELD_NAME = 'CountryTech__c';

    public static final String CREDIT_MEMO_KEY_PREFIX        = '50g';
    public static final String CREDIT_MEMO_SOBJECT_TYPE_NAME = 'CreditMemo';
    public static final String INVOICE_SOBJECT_TYPE_NAME     = 'Invoice';
    public static final String CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME     = 'CorrectiveInvoice__c';
    public static final String SHIPMENT_SOBJECT_TYPE_NAME = 'Shipment';
    public static final String ORDER_SUMMARY_SOBJECT_TYPE_NAME = 'OrderSummary';
    public static final String RETURN_ORDER_SOBJECT_TYPE_NAME = 'ReturnOrder';
    public static final String REFUND_SOBJECT_TYPE_NAME = 'Refund';

    public static final String SALES_CHANNEL_CEGID = 'CEGID';
    public static final String SALES_CHANNEL_MANUAL = 'Manual Order';
    public static final String SALES_CHANNEL_RIMOWA = 'Rimowa';
    
    public static final String ECOMMERCE_PAYMENT_CAPTURE_ERRORS = 'E_Commerce_Payment_Capture_Errors_';
    
    public static final String AMOUNT_FORMAT1 = '###.##0,00';
    public static final String AMOUNT_FORMAT2 = '###,##0.00';
    
    public static final String TABULAR_REPORT_FACT_MAP_KEY = 'T!T';
    
    public static final String  STRING_OPERATOR_ANONYMIZATION = 'XXXXXXXXXX';
    public static final String  EMAIL_OPERATOR_ANONYMIZATION = 'XXXXXXXXXX@XXX.XXX';
    public static final Integer INTEGER_OPERATOR_ANONYMIZATION = 999999999;

    public static final String FULFILLMENT = 'Fulfillment';
    public static final String JP_COUNTRY_CODE = 'JP';
    public static final String CASH_ON_DELIVERY = 'COD';
    
    public static final String ZIP = ' - Zip';
    public static final String STREET = ' - Address';
    public static final String CITY = ' - City';
    public static final String NEIGHBORHOOD = ' - Neighborhood';
    public static final String STATE = ' - State/Province';
    public static final String STREETADDRESSERROR = ' The field: Street Address must not contain special characters! ';
    public static final String STREETNUMBERERROR = ' The field: Phone Number must contain between 11 and 13 digits! ';
    public static final String PHONENUMBERERROR = ' The field: Street Number must only contain numbers! ';
    public static final String NEIGHBERHOODERROR = ' The field: Neighborhood must not be empty! ';
    
    
    
    
}