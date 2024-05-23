@RestResource(urlMapping='/CreateStoreToWebOrderEndpoint/*')
global with sharing class WS_SOM_Create_StoreToWebOrder {
    
    public static final String PAYMENT_METHOD_NICKNAME_PAID_IN_STORE = 'Paid in Store';
    public static final String ORDER_ITEM_TAX_NAME_SUFFIX            = ' - Tax';
    public static final Decimal TAX_DIFF                             = 0.01;
    public static final String CHAR_CONCAT                           = '_';
    public static final String UUID_CHAR_CONCAT                      = '-';
    
    @HttpPost
    global static StoreToWebResponse createOrder(StoreToWebRequest request){
        StoreToWebResponse response = new StoreToWebResponse();
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeObject(request);
        //savepoint
        Savepoint sp = Database.setSavepoint();
        try {
            //Get standard PriceBook
            List<Pricebook2> pricebooks = [SELECT Id,IsActive, IsStandard FROM Pricebook2 WHERE IsStandard=true LIMIT 1];
            
            Map<Integer, Order> ordersToPersistMap                               = new Map<Integer, Order>();
            Map<Integer, OrderDeliveryGroup> orderDeliveryGroupToPersistMap      = new Map<Integer, OrderDeliveryGroup>();
            Map<String, PricebookEntry> pricebookEntriesToPersistMap             = new Map<String, PricebookEntry>();
            Map<Integer, Map<Integer, OrderItem>> orderItemsToPersistMap         = new Map<Integer, Map<Integer, OrderItem>>();
            Map<Integer, Map<Integer,OrderItemTaxLineItem>> orderItemsTaxToPersistMap = new Map<Integer, Map<Integer,OrderItemTaxLineItem>>();
            Map<Integer, PaymentGroup> paymentGroupsToPersistMap                 = new Map<Integer, PaymentGroup>();
            Map<Integer, AlternativePaymentMethod> paymentMethodsToPersistMap    = new Map<Integer, AlternativePaymentMethod>();
            Map<Integer, PaymentAuthorization> paymentAuthorizationsToPersistMap = new Map<Integer, PaymentAuthorization>();
            Map<Integer, Payment> paymentsToPersistMap                           = new Map<Integer, Payment>();
            
            Map<String, OrderDeliveryMethod> orderDeliveryMethodMap = new Map<String, OrderDeliveryMethod>();
            Map<String, Product2> productsMap                       = new Map<String, Product2>();
            Map<String, PricebookEntry> pricebookEntriesMap         = new Map<String, PricebookEntry>();
            Map<String, SalesChannel> salesChannelsMap              = new Map<String, SalesChannel>();
            Map<String, SObject> locationsMap                       = new Map<String, SObject>();
            
            Set<String> orderReferenceNumbers               = new Set<String>(); 
            Set<String> orderDeliveryMethodReferenceNumbers = new Set<String>();
            Set<String> productsSKU                         = new Set<String>();
            Set<String> currencies                          = new Set<String>();
            Set<String>     accountIds                          = new Set<String>();
            Set<String> salesChannelRefNumbers              = new Set<String>();
            Set<String> locationsExternalRef                = new Set<String>();
            List<String> PostalCodes               			= new List<String>();
            Set<String> OrderDeliveryMethodListIds          = new Set<String>();
            List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
            List<String> STWpostalCodeList = new List<String>();
            List<STWDeliveryMethod__c> STWListEX = new List<STWDeliveryMethod__c>();
            
            Boolean isStockAvailable = true;
            for (StoreToWebOrder storeToWebOrder:request.orders) {
                if (storeToWebOrder.orderDeliveryMethodReferenceNumber != null) orderDeliveryMethodReferenceNumbers.add(storeToWebOrder.orderDeliveryMethodReferenceNumber);
                if (storeToWebOrder.currencyCode != null) currencies.add(storeToWebOrder.currencyCode);
                if (storeToWebOrder.accountId != null) accountIds.add(storeToWebOrder.accountId);
                if (storeToWebOrder.salesChannelNumber != null) salesChannelRefNumbers.add(storeToWebOrder.salesChannelNumber);
                if (storeToWebOrder.orderSummaryNumber != null) orderReferenceNumbers.add(storeToWebOrder.orderSummaryNumber);
                for (OrderProduct orderProduct:storeToWebOrder.orderProducts) {
                    if (orderProduct.productSKU != null) productsSKU.add(orderProduct.productSKU);
                    if (orderProduct.locationExternalReference != null) locationsExternalRef.add(orderProduct.locationExternalReference);
                }
                if ( storeToWebOrder.deliveryContact.postalCode != null && storeToWebOrder.storeOrigin =='DE22' && storeToWebOrder.deliveryContact.country =='DE' ){
                    PostalCodes.add(storeToWebOrder.deliveryContact.postalCode);
                }
                
            }
            System.debug('PostalCode' + PostalCodes);
            if(PostalCodes != null && PostalCodes.size() !=0 ){
                STWListEX = [SELECT ID, storeOrigin__c, country__c, postalCode__c, parentId__r.parentId__r.storeOrigin__c, deliveryMethodId__r.ReferenceNumber, DeliveryMethodName__c 
                             FROM STWDeliveryMethod__c 
                             WHERE postalCode__c IN :PostalCodes AND parentId__r.parentId__r.storeOrigin__c = 'DE22'];            
                OrderDeliveryMethod STorderDeliveryMethod = [SELECT ID, ReferenceNumber FROM OrderDeliveryMethod WHERE ReferenceNumber = 'standard_DE'];
                OrderDeliveryMethodListIds.add(STorderDeliveryMethod.Id);
                if(STWListEX != null){ 
                    for(STWDeliveryMethod__c stw : STWListEX){
                        OrderDeliveryMethodListIds.add(stw.deliveryMethodId__c);
                        STWpostalCodeList.add(stw.postalCode__c);
                    }
                    System.debug('OrderDeliveryMethodListIds' + OrderDeliveryMethodListIds);
                    orderDeliveryMethods = [SELECT ID, ReferenceNumber FROM OrderDeliveryMethod WHERE ID IN :OrderDeliveryMethodListIds];
                    System.debug('orderDeliveryMethods' + orderDeliveryMethods);
                }
            }else{
                orderDeliveryMethods = [SELECT ID, ReferenceNumber FROM OrderDeliveryMethod WHERE ReferenceNumber IN :orderDeliveryMethodReferenceNumbers];
            }
            //check order
            List<Order> orders = [SELECT ID, OrderReferenceNumber FROM Order WHERE OrderReferenceNumber IN :orderReferenceNumbers];
            if (orders != null && !orders.isEmpty()){
                List<String> duplicateOrderNumbers = new List<String>();
                for(Order singleOrder : orders){
                    duplicateOrderNumbers.add(singleOrder.OrderReferenceNumber);
                }
                throw new StoreToWebException('We cannot process your request, the following Order Summary Numbers already exist in Salesforce : '+duplicateOrderNumbers);
            }
            
            for (OrderDeliveryMethod odm:orderDeliveryMethods) {
                orderDeliveryMethodMap.put(odm.ReferenceNumber, odm);
            }
            System.debug('orderDeliveryMethodMap' + orderDeliveryMethodMap);
            //products
            Map<Id, Product2> productsByIdMap = new Map<Id, Product2>([SELECT ID, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :productsSKU]);
            for (Id prdId:productsByIdMap.keySet()) {
                productsMap.put(productsByIdMap.get(prdId).StockKeepingUnit, productsByIdMap.get(prdId));
            }
            //pricebook entries
            List<PricebookEntry> pricebookEntries = [SELECT Id, CurrencyIsoCode, Product2.StockKeepingUnit FROM PricebookEntry WHERE Product2.StockKeepingUnit IN :productsSKU AND CurrencyIsoCode IN :currencies];
            for (PricebookEntry pbEntry:pricebookEntries) {
                pricebookEntriesMap.put(pbEntry.CurrencyIsoCode+CHAR_CONCAT+pbEntry.Product2.StockKeepingUnit, pbEntry);
            }
            //accounts
            Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :accountIds]);
            //salesChannel
            List<SalesChannel> salesChannels = [SELECT Id, SalesChannelName, ExternalChannelNumber FROM SalesChannel WHERE ExternalChannelNumber IN :salesChannelRefNumbers];
            for (SalesChannel sc:salesChannels) {
                salesChannelsMap.put(sc.ExternalChannelNumber, sc);
            }
            //location
            List<SObject> locations = [SELECT ID, ExternalReference FROM Location WHERE ExternalReference IN :locationsExternalRef];
            for (SObject loc:locations) {
                locationsMap.put(String.valueOf(loc.get('ExternalReference')), loc);
            }
            for (Integer i=0; i < request.orders.size(); i++) {
                StoreToWebOrder storeToWebOrder = request.orders.get(i);
                //check accountId
                if (accountsMap.get(storeToWebOrder.accountId) == null) 
                    throw new StoreToWebException('Account with Id '+storeToWebOrder.accountId+' does not exist, orderNumber: '+storeToWebOrder.orderSummaryNumber);
                //check order delivery method
                if (orderDeliveryMethodMap.get(storeToWebOrder.orderDeliveryMethodReferenceNumber) == null && storeToWebOrder.storeOrigin != 'DE22'  && storeToWebOrder.deliveryContact.country != 'DE') 
                    throw new StoreToWebException('Order Delivery Method with reference number '+storeToWebOrder.orderDeliveryMethodReferenceNumber+' does not exist, orderNumber: '+storeToWebOrder.orderSummaryNumber);
                //check saleschannel
                if (salesChannelsMap.get(storeToWebOrder.salesChannelNumber) == null) 
                    throw new StoreToWebException('SalesChannel with number '+storeToWebOrder.salesChannelNumber+' does not exist, orderNumber: '+storeToWebOrder.orderSummaryNumber);
                
                //Create Order
                Order order = createStoreToWebOrder(storeToWebOrder, pricebooks, salesChannelsMap);
                ordersToPersistMap.put(i, order);
                //Create OrderDeliveryGroup
                OrderDeliveryGroup odg = createOrderDeliveryGroup(storeToWebOrder, orderDeliveryMethodMap, STWpostalCodeList);
                //-----set order id
                orderDeliveryGroupToPersistMap.put(i, odg);
                //Create order Items
                Map<Integer, OrderItem> orderItemsMap               = new Map<Integer, OrderItem>();
                Map<Integer, OrderItemTaxLineItem> orderItemsTaxMap = new Map<Integer, OrderItemTaxLineItem>();
                for (Integer j=0;j<storeToWebOrder.orderProducts.size();j++) {
                    OrderProduct orderProduct = storeToWebOrder.orderProducts.get(j);
                    Product2 sourceProduct    = productsMap.get(orderProduct.productSKU);
                    if (sourceProduct == null) {
                        //Rise error and quite
                        throw new StoreToWebException('Product with sku ' +orderProduct.productSKU+ ' does not exist, orderNumber: '+storeToWebOrder.orderSummaryNumber);
                    }
                    if (orderProduct.locationExternalReference == null) {
                        throw new StoreToWebException('Location external refernce is empty for product sku: ' +orderProduct.productSKU+ ' , orderNumber: '+storeToWebOrder.orderSummaryNumber);
                    }
                    OrderItem orderItem       = new OrderItem();
                    orderItem.Type            = orderProduct.type;
                    orderITem.Description     = orderProduct.shortDescription;
                    orderItem.Quantity        = orderProduct.quantity;
                    orderItem.TotalLineAmount = orderProduct.amount-orderProduct.orderProductTax.vat; //Total amount without tax
                    orderItem.LineNumber      = orderProduct.lineNumber;
                    orderItem.UnitPrice       = (orderProduct.amount-orderProduct.orderProductTax.vat) / orderProduct.quantity; //unit price without tax
                    orderItem.GrossUnitPrice  = orderProduct.amount / orderProduct.quantity;
                    orderItem.Product2Id      = sourceProduct.Id;
                    if (locationsMap.get(orderProduct.locationExternalReference) != null) orderItem.ReservedAtLocationId = (Id)locationsMap.get(orderProduct.locationExternalReference).get('Id');
                    
                    PricebookEntry sourcePriceBookEntry = pricebookEntriesMap.get(storeToWebOrder.currencyCode+CHAR_CONCAT+orderProduct.productSKU);
                    if (sourcePriceBookEntry == null) {
                        //create new pricebook entry
                        sourcePriceBookEntry  = new PricebookEntry();
                        sourcePriceBookEntry.CurrencyIsoCode = storeToWebOrder.currencyCode;
                        sourcePriceBookEntry.Pricebook2Id    = pricebooks.get(0).Id; 
                        sourcePriceBookEntry.UnitPrice       = (orderProduct.amount-orderProduct.orderProductTax.vat) / orderProduct.quantity;
                        sourcePriceBookEntry.Product2Id      = sourceProduct.Id;
                        pricebookEntriesToPersistMap.put(storeToWebOrder.currencyCode+CHAR_CONCAT+orderProduct.productSKU, sourcePriceBookEntry);
                    } else {
                        orderItem.PricebookEntryId = sourcePriceBookEntry.Id;
                    }
                    //----set pricebookEntryId in case we've created a new one
                    //----set orderDeliveryGroupId
                    //----Set Order Id
                    orderItemsMap.put(j, orderItem);
                    
                    //create OrderItemTaxLineItem
                    Decimal taxRateScaled = orderProduct.orderProductTax.vatRate.setScale(1, RoundingMode.HALF_EVEN) / 100;
                    Decimal taxDiff = Math.abs(((orderProduct.amount-orderProduct.orderProductTax.vat)*taxRateScaled) - orderProduct.orderProductTax.vat);
                    /*if (taxDiff > TAX_DIFF) {
//rise error and quite
throw new StoreToWebException('Tax difference is greater than 0.01, OrderNumber: ' + storeToWebOrder.orderSummaryNumber + 
', Product SKU: '+orderProduct.productSKU + ', Amount: ' + orderProduct.amount + 
', TaxRate: ' + orderProduct.orderProductTax.vatRate + 
', TaxAmount: ' + orderProduct.orderProductTax.vat);
}*/
                    OrderItemTaxLineItem orderItemTax = new OrderItemTaxLineItem();
                    orderItemTax.Name                 = orderProduct.productSKU+ORDER_ITEM_TAX_NAME_SUFFIX;
                    orderItemTax.Type                 = SOM_Constants.ORDER_ITEM_TAX_TYPE_ESTIMATED;
                    orderItemTax.Amount               = orderProduct.orderProductTax.vat;
                    orderItemTax.Rate                 = orderProduct.orderProductTax.vatRate;
                    orderItemTax.TaxEffectiveDate     = Date.today();
                    //----set OrderItemId
                    orderItemsTaxMap.put(j, orderItemTax);
                }
                orderItemsToPersistMap.put(i, orderItemsMap);
                orderItemsTaxToPersistMap.put(i, orderItemsTaxMap);
                //Create PaymentGroup
                PaymentGroup paymentGroup    = new PaymentGroup();
                paymentGroup.CurrencyIsoCode = storeToWebOrder.currencyCode;
                //-----set order Id
                paymentGroupsToPersistMap.put(i, paymentGroup);
                //Create AlternativePaymentMethod
                AlternativePaymentMethod apm = createPaymentMethod(storeToWebOrder);
                paymentMethodsToPersistMap.put(i, apm);
                //Create PaymentAuthorization
                PaymentAuthorization pa = createPaymentAuthorization(storeToWebOrder);
                //----Set payment Group Id
                //----Set Payment Method Id
                paymentAuthorizationsToPersistMap.put(i, pa);
                //Create Payment
                Payment py = createPayment(storeToWebOrder);
                //----set payment method Id
                //----set payment group Id
                //----set payment authorization id
                paymentsToPersistMap.put(i, py);
            }
            
            //start persisting objects
            //1-persist orders
            insert ordersToPersistMap.values();
            //2-persist orderDeliveryGroups
            for (Integer idx:orderDeliveryGroupToPersistMap.keySet()) {
                OrderDeliveryGroup odg = orderDeliveryGroupToPersistMap.get(idx);
                odg.OrderId            = ordersToPersistMap.get(idx).Id;
            }
            insert orderDeliveryGroupToPersistMap.values();
            //3-persist pricebook entries
            insert pricebookEntriesToPersistMap.values();
            //4-persist order items
            List<OrderItem> allOrderItems = new List<OrderItem>();
            for (Integer idx:orderItemsToPersistMap.keySet()) {
                Map<Integer, OrderItem> orderItemsMap = orderItemsToPersistMap.get(idx);
                for (Integer idx2:orderItemsMap.keySet()) {
                    OrderItem odi = orderItemsMap.get(idx2);
                    odi.OrderId   = ordersToPersistMap.get(idx).Id;
                    odi.OrderDeliveryGroupId = orderDeliveryGroupToPersistMap.get(idx).Id;
                    if (odi.PricebookEntryId == null) {
                        odi.PricebookEntryId = pricebookEntriesToPersistMap.get(ordersToPersistMap.get(idx).CurrencyIsoCode+CHAR_CONCAT+productsByIdMap.get(odi.Product2Id).StockKeepingUnit).Id;
                    }
                }
                allOrderItems.addAll(orderItemsMap.values());
            }
            insert allOrderItems;
            //5-persist orderitemTaxLineItem
            List<OrderItemTaxLineItem> allOrderItemsTax = new List<OrderItemTaxLineItem>();
            for (Integer idx:orderItemsTaxToPersistMap.keySet()) {
                Map<Integer, OrderItem> orderItemsMap               = orderItemsToPersistMap.get(idx);
                Map<Integer, OrderItemTaxLineItem> orderItemsTaxMap = orderItemsTaxToPersistMap.get(idx);
                for (Integer idx2:orderItemsTaxMap.keySet()) {
                    OrderItem odi            = orderItemsMap.get(idx2);
                    OrderItemTaxLineItem oit = orderItemsTaxMap.get(idx2);
                    oit.OrderItemId          = odi.Id;
                }
                allOrderItemsTax.addAll(orderItemsTaxMap.values());
            }
            insert allOrderItemsTax;
            //6-persist payment group
            for (Integer idx:paymentGroupsToPersistMap.keySet()) {
                PaymentGroup pg   = paymentGroupsToPersistMap.get(idx);
                pg.SourceObjectId = ordersToPersistMap.get(idx).Id;
            }
            insert paymentGroupsToPersistMap.values();
            //7-persist payment methods
            insert paymentMethodsToPersistMap.values();
            //8-persist payment authorization
            for (Integer idx:paymentAuthorizationsToPersistMap.keySet()) {
                PaymentAuthorization pa = paymentAuthorizationsToPersistMap.get(idx);
                pa.PaymentGroupId       = paymentGroupsToPersistMap.get(idx).Id;
                pa.PaymentMethodId      = paymentMethodsToPersistMap.get(idx).Id;
            }
            insert paymentAuthorizationsToPersistMap.values();
            //9-persist payments
            for (Integer idx:paymentsToPersistMap.keySet()) {
                Payment py = paymentsToPersistMap.get(idx);
                py.PaymentAuthorizationId = paymentAuthorizationsToPersistMap.get(idx).Id;
                py.PaymentGroupId         = paymentGroupsToPersistMap.get(idx).Id;
                py.PaymentMethodId        = paymentMethodsToPersistMap.get(idx).Id;
            }
            insert paymentsToPersistMap.values();
            //10-update orders to activated
            for (Integer idx:ordersToPersistMap.keySet()) {
                Order od  = ordersToPersistMap.get(idx);
                od.Status = SOM_Constants.ORDER_ACTIVATED_STATUS;
            }
            update ordersToPersistMap.values();
            response.status = 'OK';
            response.orderNumber = 'The following Orders are commited successfully : '+string.valueof(orderReferenceNumbers).replace('{', '').replace('}', '');
        } catch(Exception ex) {
            Database.rollback(sp);
            response.status       = 'KO';
            response.errorMessage = ex.getMessage();
        }
        
        return response;
    }
    
    public static Order createStoreToWebOrder(StoreToWebOrder storeToWebOrder, List<Pricebook2> pricebooks, Map<String, SalesChannel> salesChannelsMap){
        Order order                = new Order();
        order.Status               = SOM_Constants.ORDER_DRAFT_STATUS;
        order.StoreOrigin__c       = storeToWebOrder.storeOrigin;
        order.StoreOriginName__c   = storeToWebOrder.storeOriginName;
        order.Pricebook2Id         = pricebooks.get(0).Id;
        order.Name                 = storeToWebOrder.billingContact.firstName + ' ' + storeToWebOrder.billingContact.lastName;
        order.BillingContactFirstName__c  = storeToWebOrder.billingContact.firstName;
        order.BillingContactLastName__c   = storeToWebOrder.billingContact.lastName;
        order.CurrencyIsoCode      = storeToWebOrder.currencyCode;
        order.BillingCity          = storeToWebOrder.billingContact.city;
        order.BillingCountry       = storeToWebOrder.billingContact.country;
        order.BillingState         = storeToWebOrder.billingContact.state;
        order.BillingPostalCode    = storeToWebOrder.billingContact.postalCode;
        order.BillingStreet        = storeToWebOrder.billingContact.street;
        order.BillingPhoneNumber   = storeToWebOrder.billingContact.phone;
        order.BillingEmailAddress  = storeToWebOrder.billingContact.email;
        order.SalesChannelId       = salesChannelsMap.get(storeToWebOrder.salesChannelNumber).Id;
        order.AccountId            = storeToWebOrder.accountId;
        order.OrderedDate          = SOM_DateTimeHelper.convertISO8601ToDateTime(storeToWebOrder.orderedDate);
        order.EffectiveDate        = Date.today();
        order.OrderReferenceNumber = storeToWebOrder.orderSummaryNumber;
        order.passedFraudScreening__c = true;
        order.captureAtShipment__c    = false;
        order.DeliverySignature__c    = true;
        
        return order;
    }
    
    public static OrderDeliveryGroup createOrderDeliveryGroup(StoreToWebOrder storeToWebOrder, Map<String, OrderDeliveryMethod> orderDeliveryMethodMap, List<String> STWpostalCodeList){
        OrderDeliveryGroup odg    = new OrderDeliveryGroup();
        odg.EmailAddress          = storeToWebOrder.deliveryContact.email;
        odg.DeliverToCity         = storeToWebOrder.deliveryContact.city;
        odg.DeliverToCountry      = storeToWebOrder.deliveryContact.country;
        odg.DeliverToName         = storeToWebOrder.deliveryContact.firstName + ' ' + storeToWebOrder.deliveryContact.lastName;
        odg.DeliverToPostalCode   = storeToWebOrder.deliveryContact.postalCode;
        odg.DeliverToState        = storeToWebOrder.deliveryContact.state;
        odg.DeliverToStreet       = storeToWebOrder.deliveryContact.street;
        odg.PhoneNumber           = storeToWebOrder.deliveryContact.phone;
        if(storeToWebOrder.storeOrigin == 'DE22' &&  storeToWebOrder.deliveryContact.country == 'DE' && STWpostalCodeList.contains(storeToWebOrder.deliveryContact.postalCode) ){
            odg.OrderDeliveryMethodId = orderDeliveryMethodMap.get('Express_DE').Id;
        } else if(storeToWebOrder.storeOrigin == 'DE22' &&  storeToWebOrder.deliveryContact.country == 'DE' && !(STWpostalCodeList.contains(storeToWebOrder.deliveryContact.postalCode))){
            odg.OrderDeliveryMethodId = orderDeliveryMethodMap.get('standard_DE').Id;
        }else{
            odg.OrderDeliveryMethodId = orderDeliveryMethodMap.get(storeToWebOrder.orderDeliveryMethodReferenceNumber).Id;
        }
        
        return odg;
    }
    
    public static AlternativePaymentMethod createPaymentMethod(StoreToWebOrder storeToWebOrder){
        AlternativePaymentMethod apm = new AlternativePaymentMethod();
        apm.AccountId                = storeToWebOrder.accountId;
        apm.Status                   = SOM_Constants.PAYMENT_METHOD_STATUS_ACTIVE;
        apm.ProcessingMode           = SOM_Constants.PAYMENT_PROCESSING_MODE_EXTERNAL;
        apm.NickName                 = PAYMENT_METHOD_NICKNAME_PAID_IN_STORE;
        apm.RI_PaymentMethodId__c    = storeToWebOrder.paymentMethodCode;
        
        return apm;
    }
    
    public static PaymentAuthorization createPaymentAuthorization(StoreToWebOrder storeToWebOrder){
        PaymentAuthorization pa  = new PaymentAuthorization();
        pa.ProcessingMode        = SOM_Constants.PAYMENT_PROCESSING_MODE_EXTERNAL;
        pa.AccountId             = storeToWebOrder.accountId;
        pa.Status                = SOM_Constants.PAYMENT_STATUS_PROCESSED;
        pa.Amount                = getTotalAmount(storeToWebOrder);
        pa.GatewayRefNumber      = storeToWebOrder.paymentReference;
        pa.CurrencyIsoCode       = storeToWebOrder.currencyCode;
        
        return pa;
    }
    
    public static Payment createPayment(StoreToWebOrder storeToWebOrder){
        Payment py         = new Payment();
        py.AccountId       = storeToWebOrder.accountId;
        py.Amount          = getTotalAmount(storeToWebOrder);
        py.CurrencyIsoCode = storeToWebOrder.currencyCode;
        py.Status          = SOM_Constants.PAYMENT_STATUS_PROCESSED;
        py.ProcessingMode  = SOM_Constants.PAYMENT_PROCESSING_MODE_EXTERNAL;
        py.Type            = SOM_Constants.PAYMENT_TYPE_CAPTURE;
        py.Date    		   = System.now();
        
        
        return py;
    }
    
    public static Decimal getTotalAmount(StoreToWebOrder storeToWebOrder){
        Decimal amount = 0;
        for (OrderProduct orderProduct:storeToWebOrder.orderProducts) {
            amount += orderProduct.amount;
        }
        
        return amount;
    }
    
    public static String generateUUID(){
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        return h.SubString(0,8)+ UUID_CHAR_CONCAT + h.SubString(8,12) + 
            UUID_CHAR_CONCAT + h.SubString(12,16) + UUID_CHAR_CONCAT + 
            h.SubString(16,20) + UUID_CHAR_CONCAT + h.substring(20);
    }
    
    public class StoreToWebException extends Exception {}
    
    global with sharing class StoreToWebResponse{
        public String errorMessage;
        public String status;
        public String orderNumber;
    }
    
    global with sharing class StoreToWebRequest {
        public List<StoreToWebOrder> orders;
    }
    
    public class StoreToWebOrder{
        public String storeOrigin; //Order.storeOrigin__c
        public String storeOriginName; //Order.storeOriginName__c
        public String orderSummaryNumber; //Order.OrderReferenceNumber
        public String currencyCode; //Order.CurrencyIsoCode
        public String orderedDate;//Order.OrderedDate
        public String salesChannelNumber; //SalesChannel.??
        public String accountId; //Order.AccountId
        public String paymentMethodCode; //PaymentMethod.RI_PaymentMethod ==> C_CC , C_KLARNA , CIP
        public String paymentReference; //PaymentAuthorization.GatewayRefNumber
        //order delivery method
        public String orderDeliveryMethodReferenceNumber; //OrderDeliveryMethod.ReferenceNumber
        //delivery contact
        public OrderContact deliveryContact;
        //order item
        public List<OrderProduct> orderProducts;
        //billing contact
        public OrderContact billingContact;
    }
    
    public class OrderProduct{
        public String          productSKU; //if code sku doesn't exist => create new product with new pricebook entry
        public Integer         quantity; //OrderItem.Quantity
        public Decimal         amount; //OrderItem.TotalLineAmount
        public String          shortDescription; //OrderItem.Description
        public Integer         lineNumber; //OrderItem.LineNumber
        public String          locationExternalReference;
        public String          type;
        public OrderProductTax orderProductTax;
    }
    
    public class OrderProductTax{
        public Decimal vat; //OrderItemTaxLineItem.Amount
        public Decimal vatRate; //OrderItemTaxLineItem.Rate
    }
    
    public class OrderContact{
        public String lastName;
        public String firstName;
        public String street;
        public String city;
        public String state;
        public String postalCode;
        public String country;
        public String email;
        public String phone;
    }
}