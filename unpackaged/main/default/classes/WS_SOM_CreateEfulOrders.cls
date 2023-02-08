@RestResource(urlMapping='/CreateEfulOrders/*')
global with sharing class WS_SOM_CreateEfulOrders {

    public static final String ORDER_ITEM_TAX_NAME_SUFFIX = ' - Tax';
    public static final String PAYMENT_METHOD_NICKNAME_UNMANAGED = 'Unmanaged';
    public static final String LOG_CLASS_NAME = 'WS_SOM_CreateEfulOrders -- Endpoint /CreateEfulOrders ';

    @HttpPost
    global static List<EfulOrderResponse> createEfulOrder(List<EfulOrderRequest> request){

        //limits summary
        System.debug('--------- WS_SOM_CreateEfulOrders -- START ');
        System.debug('---------Number of callouts executed is: ' + Limits.getCallouts() + ' in limit: ' + Limits.getLimitCallouts());
        System.debug('---------Number of dml rows executed is: ' + Limits.getDmlRows() + ' in limit: ' + Limits.getLimitDmlRows());
        System.debug('---------Number of dml statments executed is: ' + Limits.getDmlStatements() + ' in limit: ' + Limits.getLimitDmlStatements());
        System.debug('---------Number of queries executed is: ' + Limits.getQueries() + ' in limit: ' + Limits.getLimitQueries());
        System.debug('---------Number of query rows executed is: ' + Limits.getQueryRows() + ' in limit: ' + Limits.getLimitQueryRows());


        List<EfulOrderResponse> efulOrdersResponseList = new List<EfulOrderResponse>();
        List<Log__c> logs                               = new List<Log__c>();
        try{

            Set<String> orderSummaryNumbers                 = new Set<String>();
            Set<String> orderDeliveryMethodReferenceNumbers = new Set<String>();
            Set<String> productsSKU                         = new Set<String>();
            Set<String> invoices                            = new Set<String>();
            Set<String> currencies                          = new Set<String>();
            Set<String> accountNames                        = new Set<String>();
            Set<String> accountEmails                       = new Set<String>();
            Map<String, EfulOrderRequest> ordersNameEmail   = new Map<String, EfulOrderRequest>();
            Set<String> salesChannelRefNumbers              = new Set<String>();
            Set<String> locationsExternalRef                = new Set<String>();
    
            //Get standard PriceBook
            List<Pricebook2> pricebooks = [SELECT Id,IsActive, IsStandard FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    
            Map<String, EfulOrderRequest> orderSummaryRequestMap                 = new Map<String, EfulOrderRequest>();

            Map<Integer, Order> ordersToPersistMap                               = new Map<Integer, Order>();
            Map<Integer, OrderDeliveryGroup> orderDeliveryGroupToPersistMap      = new Map<Integer, OrderDeliveryGroup>();
            Map<String, PricebookEntry> pricebookEntriesToPersistMap             = new Map<String, PricebookEntry>();
            Map<Integer, Map<Integer, OrderItem>> orderItemsToPersistMap         = new Map<Integer, Map<Integer, OrderItem>>();
            Map<Integer, Map<Integer,OrderItemTaxLineItem>> orderItemsTaxToPersistMap = new Map<Integer, Map<Integer,OrderItemTaxLineItem>>();
            Map<Integer, PaymentGroup> paymentGroupsToPersistMap                 = new Map<Integer, PaymentGroup>();
            Map<Integer, AlternativePaymentMethod> paymentMethodsToPersistMap    = new Map<Integer, AlternativePaymentMethod>();
            Map<Integer, PaymentAuthorization> paymentAuthorizationsToPersistMap = new Map<Integer, PaymentAuthorization>();
            Map<Integer, Payment> paymentsToPersistMap                           = new Map<Integer, Payment>();
            
            Map<String, Order> ordersMap = new Map<String, Order>();
            Map<String, OrderDeliveryMethod> orderDeliveryMethodMap = new Map<String, OrderDeliveryMethod>();
            Map<String, Product2> productsMap                       = new Map<String, Product2>();
            Map<String, PricebookEntry> pricebookEntriesMap         = new Map<String, PricebookEntry>();
            Map<String, SalesChannel> salesChannelsMap              = new Map<String, SalesChannel>();
            Map<String, SObject> locationsMap                       = new Map<String, SObject>();
            
            for (EfulOrderRequest efulOrder : request) {
                if (efulOrder.orderSummaryNumber != null) { orderSummaryNumbers.add(efulOrder.orderSummaryNumber); orderSummaryRequestMap.put(efulOrder.orderSummaryNumber, efulOrder);}
                if (efulOrder.currencyCode != null) currencies.add(efulOrder.currencyCode);
                if (efulOrder.salesChannelNumber != null) salesChannelRefNumbers.add(efulOrder.salesChannelNumber);
                if (efulOrder.orderDeliveryMethodName != null) orderDeliveryMethodReferenceNumbers.add(efulOrder.orderDeliveryMethodName);
                if (efulOrder.invoices != null) invoices.add(efulOrder.invoices);
                if (efulOrder.billing.firstName != null && efulOrder.billing.lastName != null) accountNames.add(efulOrder.billing.firstName + ' ' + efulOrder.billing.lastName);
                if (efulOrder.billing.email != null) accountEmails.add(efulOrder.billing.email);
                if (efulOrder.billing.firstName != null && efulOrder.billing.lastName != null && efulOrder.billing.email != null) ordersNameEmail.put(efulOrder.billing.firstName.toUppercase() + ' ' + efulOrder.billing.lastName.toUppercase() + ' ' + efulOrder.billing.email.toUppercase(), efulOrder);
                for (OrderProduct orderProduct : efulOrder.orderProducts) {
                    if (orderProduct.productSKU != null) productsSKU.add(orderProduct.productSKU);
                    if (orderProduct.locationExternalReference != null) locationsExternalRef.add(orderProduct.locationExternalReference);
                }
            }
    
            //Check Accounts Existance -- start
            Map<String, Account> accountsMap = new Map<String, Account>();
            List<Account> accountsToCreate = new List<Account>();
            List<Account> accounts = [SELECT Id, Name, FirstName, LastName, personEmail FROM Account WHERE Name IN: accountNames AND personEmail IN: accountEmails];
            if(!accounts.isEmpty() && accounts != null){
                for(Account acc : accounts){
                    accountsMap.put(acc.Name.toUppercase() + ' ' + acc.personEmail.toUppercase(), acc);
                }
            } 
    
            for(String orderNameEmail : ordersNameEmail.keySet()){
                if(!accountsMap.containsKey(orderNameEmail)){
                    Account accountToCreate = new Account(FirstName = ordersNameEmail.get(orderNameEmail).billing.firstName , LastName = ordersNameEmail.get(orderNameEmail).billing.lastName, personEmail = ordersNameEmail.get(orderNameEmail).billing.email, BillingCity = ordersNameEmail.get(orderNameEmail).billing.city, BillingCountry = ordersNameEmail.get(orderNameEmail).billing.country, BillingPostalCode = ordersNameEmail.get(orderNameEmail).billing.postalCode, BillingState = ordersNameEmail.get(orderNameEmail).billing.state, BillingStreet = ordersNameEmail.get(orderNameEmail).billing.street);
                    accountsToCreate.add(accountToCreate);
                }
            }
            insert accountsToCreate;
    
            List<Account> allAccounts = new List<Account>();
            allAccounts.addAll(accounts);
            allAccounts.addAll(accountsToCreate);
    
            for (Account newAcc : allAccounts) {
                if(!accountsMap.containsKey(newAcc.FirstName.toUppercase() + ' ' + newAcc.LastName.toUppercase() + ' ' + newAcc.personEmail.toUppercase())){
                    accountsMap.put(newAcc.FirstName.toUppercase() + ' ' + newAcc.LastName.toUppercase() + ' ' + newAcc.personEmail.toUppercase(), newAcc);
                }
            }
            //Check Accounts Existance -- end
    
            //order
            List<Order> orders = [SELECT ID, OrderReferenceNumber FROM Order WHERE OrderReferenceNumber IN :orderSummaryNumbers];
            for (order order : orders) {
                ordersMap.put(order.OrderReferenceNumber, order);
            }

            //order delivery methods
            List<OrderDeliveryMethod> orderDeliveryMethods = [SELECT ID, ReferenceNumber FROM OrderDeliveryMethod WHERE ReferenceNumber IN :orderDeliveryMethodReferenceNumbers];
            for (OrderDeliveryMethod odm : orderDeliveryMethods) {
                orderDeliveryMethodMap.put(odm.ReferenceNumber, odm);
            }
            //products
            Map<Id, Product2> productsByIdMap = new Map<Id, Product2>([SELECT ID, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :productsSKU]);
            for (Id prdId : productsByIdMap.keySet()) {
                productsMap.put(productsByIdMap.get(prdId).StockKeepingUnit, productsByIdMap.get(prdId));
            }
            //pricebook entries
            List<PricebookEntry> pricebookEntries = [SELECT Id, CurrencyIsoCode, Product2.StockKeepingUnit FROM PricebookEntry WHERE Product2.StockKeepingUnit IN :productsSKU AND CurrencyIsoCode IN :currencies];
            for (PricebookEntry pbEntry : pricebookEntries) {
                pricebookEntriesMap.put(pbEntry.CurrencyIsoCode + '_' + pbEntry.Product2.StockKeepingUnit, pbEntry);
            }
            //salesChannel
            List<SalesChannel> salesChannels = [SELECT Id, SalesChannelName, ExternalChannelNumber FROM SalesChannel WHERE ExternalChannelNumber IN :salesChannelRefNumbers];
            for (SalesChannel sc : salesChannels) {
                salesChannelsMap.put(sc.ExternalChannelNumber, sc);
            }
            //location
            List<SObject> locations = [SELECT ID, ExternalReference FROM Location WHERE ExternalReference IN :locationsExternalRef];
            for (SObject loc : locations) {
                locationsMap.put(String.valueOf(loc.get('ExternalReference')), loc);
            }

            /*** Orders Logic */
            for (Integer i=0; i < request.size(); i++) {
                EfulOrderRequest efulOrder = request.get(i);
                Boolean isKO = false;

                //check order
                if (ordersMap.get(efulOrder.orderSummaryNumber) != null){
                    EfulOrderResponse response = new EfulOrderResponse();
                    response.orderSummaryNumber = efulOrder.orderSummaryNumber;
                    response.status = 'KO';
                    response.errorMessage = 'Order Summary Number ' + efulOrder.orderSummaryNumber + ' already Exists.';
                    efulOrdersResponseList.add(response);
                    Log__c log = createLog(response, new List<EfulOrderRequest>{efulOrder});
                    logs.add(log);
                    continue;
                }
                
                //check order delivery method
                if (orderDeliveryMethodMap.get(efulOrder.orderDeliveryMethodName) == null){
                    EfulOrderResponse response = new EfulOrderResponse();
                    response.orderSummaryNumber = efulOrder.orderSummaryNumber;
                    response.status = 'KO';
                    response.errorMessage = 'Order Delivery Method with Reference Number ' + efulOrder.orderDeliveryMethodName + ' does not exist.';
                    efulOrdersResponseList.add(response);
                    Log__c log = createLog(response, new List<EfulOrderRequest>{efulOrder});
                    logs.add(log);
                    continue;
                }
                    
                //check saleschannel
                if (salesChannelsMap.get(efulOrder.salesChannelNumber) == null){
                    EfulOrderResponse response = new EfulOrderResponse();
                    response.orderSummaryNumber = efulOrder.orderSummaryNumber;
                    response.status = 'KO';
                    response.errorMessage = 'SalesChannel with Number ' + efulOrder.salesChannelNumber + ' does not exist.';
                    efulOrdersResponseList.add(response);
                    Log__c log = createLog(response, new List<EfulOrderRequest>{efulOrder});
                    logs.add(log);
                    continue;
                }
                
                //Create Order
                Order order                       = new Order();
                order.Status                      = SOM_Constants.ORDER_DRAFT_STATUS;
                order.Pricebook2Id                = pricebooks.get(0).Id;
                System.debug('accountsMap' + accountsMap);
                order.AccountId                   = accountsMap.get(efulOrder.billing.firstName.toUppercase() + ' ' + efulOrder.billing.lastName.toUppercase() + ' ' + efulOrder.billing.email.toUppercase()).Id;
                order.OrderReferenceNumber        = efulOrder.orderSummaryNumber;
                order.OrderedDate                 = SOM_DateTimeHelper.convertISO8601ToDateTime(efulOrder.orderedDate);
                order.CurrencyIsoCode             = efulOrder.currencyCode;
                order.SalesChannelId              = salesChannelsMap.get(efulOrder.salesChannelNumber).Id;
                order.invoices__c                 = efulOrder.invoices;
                order.Name                        = efulOrder.billing.firstName + ' ' + efulOrder.billing.lastName;
                order.BillingContactFirstName__c  = efulOrder.billing.firstName;
                order.BillingContactLastName__c   = efulOrder.billing.lastName;
                order.BillingCity                 = efulOrder.billing.city;
                order.BillingCountry              = efulOrder.billing.country;
                order.BillingState                = efulOrder.billing.state;
                order.BillingPostalCode           = efulOrder.billing.postalCode;
                order.BillingStreet               = efulOrder.billing.street;
                order.BillingPhoneNumber          = efulOrder.billing.phone;
                order.BillingEmailAddress         = efulOrder.billing.email;
                order.EffectiveDate               = Date.today();

                //Create OrderDeliveryGroup
                OrderDeliveryGroup odg    = new OrderDeliveryGroup();
                odg.EmailAddress          = efulOrder.delivery.email;
                odg.DeliverToCity         = efulOrder.delivery.city;
                odg.DeliverToCountry      = efulOrder.delivery.country;
                odg.DeliverToName         = efulOrder.delivery.firstName + ' ' + efulOrder.delivery.lastName;
                odg.DeliverToPostalCode   = efulOrder.delivery.postalCode;
                odg.DeliverToState        = efulOrder.delivery.state;
                odg.DeliverToStreet       = efulOrder.delivery.street;
                odg.PhoneNumber           = efulOrder.delivery.phone;
                odg.OrderDeliveryMethodId = orderDeliveryMethodMap.get(efulOrder.orderDeliveryMethodName).Id;
                orderDeliveryGroupToPersistMap.put(i, odg);

                //Create order Items
                Map<Integer, OrderItem> orderItemsMap               = new Map<Integer, OrderItem>();
                Map<Integer, OrderItemTaxLineItem> orderItemsTaxMap = new Map<Integer, OrderItemTaxLineItem>();
                for (Integer j=0 ; j<efulOrder.orderProducts.size() ; j++){
                    OrderProduct orderProduct = efulOrder.orderProducts.get(j);
                    Product2 sourceProduct    = productsMap.get(orderProduct.productSKU);
                    if (sourceProduct == null) {
                        EfulOrderResponse response = new EfulOrderResponse();
                        response.orderSummaryNumber = efulOrder.orderSummaryNumber;
                        response.status = 'KO';
                        response.errorMessage = 'Product with Sku ' + orderProduct.productSKU + ' does not exist.';
                        efulOrdersResponseList.add(response);
                        Log__c log = createLog(response, new List<EfulOrderRequest>{efulOrder});
                        logs.add(log);
                        isKO = true;
                        break;
                    }
                    OrderItem orderItem       = new OrderItem();
                    orderItem.Product2Id      = sourceProduct.Id;
                    orderItem.Type            = orderProduct.type;
                    orderItem.Quantity        = orderProduct.quantity;
                    orderItem.TotalLineAmount = orderProduct.amount - orderProduct.orderProductTax.vat; //Total amount without tax
                    orderItem.Description     = orderProduct.description;
                    orderItem.LineNumber      = orderProduct.lineNumber;
                    orderItem.UnitPrice       = (orderProduct.amount - orderProduct.orderProductTax.vat) / orderProduct.quantity; //unit price without tax
                    orderItem.GrossUnitPrice  = orderProduct.amount / orderProduct.quantity;
                    if (locationsMap.get(orderProduct.locationExternalReference) != null) orderItem.ReservedAtLocationId = (Id)locationsMap.get(orderProduct.locationExternalReference).get('Id');
                    PricebookEntry sourcePriceBookEntry = pricebookEntriesMap.get(efulOrder.currencyCode + '_' + orderProduct.productSKU);
                    if (sourcePriceBookEntry == null) {
                        //create new pricebook entry
                        sourcePriceBookEntry  = new PricebookEntry();
                        sourcePriceBookEntry.CurrencyIsoCode = efulOrder.currencyCode;
                        sourcePriceBookEntry.Pricebook2Id    = pricebooks.get(0).Id; 
                        sourcePriceBookEntry.UnitPrice       = (orderProduct.amount - orderProduct.orderProductTax.vat) / orderProduct.quantity;
                        sourcePriceBookEntry.Product2Id      = sourceProduct.Id;
                        pricebookEntriesToPersistMap.put(efulOrder.currencyCode + '_' + orderProduct.productSKU, sourcePriceBookEntry);
                    } else {
                        orderItem.PricebookEntryId = sourcePriceBookEntry.Id;
                    }
                    orderItemsMap.put(j, orderItem);

                    //create OrderItemTaxLineItem
                    OrderItemTaxLineItem orderItemTax = new OrderItemTaxLineItem();
                    orderItemTax.Name                 = orderProduct.productSKU + ORDER_ITEM_TAX_NAME_SUFFIX;
                    orderItemTax.Type                 = SOM_Constants.ORDER_ITEM_TAX_TYPE_ESTIMATED;
                    orderItemTax.Amount               = orderProduct.orderProductTax.vat;
                    orderItemTax.Rate                 = orderProduct.orderProductTax.vatRate;
                    orderItemTax.TaxEffectiveDate     = Date.today();
                    orderItemsTaxMap.put(j, orderItemTax);
                    
                }
                if(isKO == false){
                    orderItemsToPersistMap.put(i, orderItemsMap);
                    orderItemsTaxToPersistMap.put(i, orderItemsTaxMap);
                    ordersToPersistMap.put(i, order);
                }

                //Create AlternativePaymentMethod
                AlternativePaymentMethod apm = new AlternativePaymentMethod();
                apm.AccountId                = accountsMap.get(efulOrder.billing.firstName.toUppercase() + ' ' + efulOrder.billing.lastName.toUppercase() + ' ' + efulOrder.billing.email.toUppercase()).Id;
                apm.Status                   = SOM_Constants.PAYMENT_METHOD_STATUS_ACTIVE;
                apm.ProcessingMode           = SOM_Constants.PAYMENT_PROCESSING_MODE_EXTERNAL;
                apm.NickName                 = PAYMENT_METHOD_NICKNAME_UNMANAGED;
                paymentMethodsToPersistMap.put(i, apm);

                //Create PaymentGroup
                PaymentGroup paymentGroup    = new PaymentGroup();
                paymentGroup.CurrencyIsoCode = efulOrder.currencyCode;
                paymentGroupsToPersistMap.put(i, paymentGroup);

                //Create Payment
                Decimal amount = 0;
                for (OrderProduct orderProduct:efulOrder.orderProducts) {
                    amount += orderProduct.amount;
                }
                Payment py         = new Payment();
                py.AccountId       = accountsMap.get(efulOrder.billing.firstName.toUppercase() + ' ' + efulOrder.billing.lastName.toUppercase() + ' ' + efulOrder.billing.email.toUppercase()).Id;
                py.Amount          = amount;
                py.CurrencyIsoCode = efulOrder.currencyCode;
                py.Status          = SOM_Constants.PAYMENT_STATUS_PROCESSED;
                py.ProcessingMode  = SOM_Constants.PAYMENT_PROCESSING_MODE_EXTERNAL;
                py.Type            = SOM_Constants.PAYMENT_TYPE_CAPTURE;
                paymentsToPersistMap.put(i, py);


            }

            //persist orders
            insert ordersToPersistMap.values();
            //persist orderDeliveryGroups
            for (Integer idx:orderDeliveryGroupToPersistMap.keySet()) {
                OrderDeliveryGroup odg = orderDeliveryGroupToPersistMap.get(idx);
                odg.OrderId            = ordersToPersistMap.get(idx).Id;
            }
            insert orderDeliveryGroupToPersistMap.values();

            //persist pricebook entries
            insert pricebookEntriesToPersistMap.values();

            //persist order items
            List<OrderItem> allOrderItems = new List<OrderItem>();
            for (Integer idx : orderItemsToPersistMap.keySet()) {
                Map<Integer, OrderItem> orderItemsMap = orderItemsToPersistMap.get(idx);
                for (Integer idx2 : orderItemsMap.keySet()) {
                    OrderItem odi = orderItemsMap.get(idx2);
                    odi.OrderId   = ordersToPersistMap.get(idx).Id;
                    odi.OrderDeliveryGroupId = orderDeliveryGroupToPersistMap.get(idx).Id;
                    if (odi.PricebookEntryId == null) {
                        odi.PricebookEntryId = pricebookEntriesToPersistMap.get(ordersToPersistMap.get(idx).CurrencyIsoCode+ '_' +productsByIdMap.get(odi.Product2Id).StockKeepingUnit).Id;
                    }
                }
                allOrderItems.addAll(orderItemsMap.values());
            }
            insert allOrderItems;

            //persist orderitemTaxLineItem
            List<OrderItemTaxLineItem> allOrderItemsTax = new List<OrderItemTaxLineItem>();
            for (Integer idx : orderItemsTaxToPersistMap.keySet()) {
                Map<Integer, OrderItem> orderItemsMap               = orderItemsToPersistMap.get(idx);
                Map<Integer, OrderItemTaxLineItem> orderItemsTaxMap = orderItemsTaxToPersistMap.get(idx);
                for (Integer idx2 : orderItemsTaxMap.keySet()) {
                    OrderItem odi            = orderItemsMap.get(idx2);
                    OrderItemTaxLineItem oit = orderItemsTaxMap.get(idx2);
                    oit.OrderItemId          = odi.Id;
                }
                allOrderItemsTax.addAll(orderItemsTaxMap.values());
            }
            insert allOrderItemsTax;

            //persist payment Groups
            for (Integer idx:paymentGroupsToPersistMap.keySet()) {
                PaymentGroup pg   = paymentGroupsToPersistMap.get(idx);
                pg.SourceObjectId = ordersToPersistMap.get(idx).Id;
            }
            insert paymentGroupsToPersistMap.values();

            //persist payment methods
            insert paymentMethodsToPersistMap.values();

            //persist payments
            for (Integer idx:paymentsToPersistMap.keySet()) {
                Payment py = paymentsToPersistMap.get(idx);
                py.PaymentGroupId         = paymentGroupsToPersistMap.get(idx).Id;
                py.PaymentMethodId        = paymentMethodsToPersistMap.get(idx).Id;
            }
            insert paymentsToPersistMap.values();
    
            //update orders to activated
            for (Integer idx : ordersToPersistMap.keySet()) {
                Order od  = ordersToPersistMap.get(idx);
                od.Status = SOM_Constants.ORDER_ACTIVATED_STATUS;
            }
            update ordersToPersistMap.values();

            for (Order order:ordersToPersistMap.values()) {
                EfulOrderResponse response = new EfulOrderResponse();
                response.status = 'OK';
                response.orderSummaryNumber = order.OrderReferenceNumber;
                efulOrdersResponseList.add(response);
                Log__c log = createLog(response, new List<EfulOrderRequest>{orderSummaryRequestMap.get(order.OrderReferenceNumber)});
                logs.add(log);
            }

        } catch(Exception e){
            EfulOrderResponse response = new EfulOrderResponse();
            response.status       = 'KO';
            response.errorMessage = e.getMessage();
            efulOrdersResponseList.add(response);
            Log__c log = createLog(response, request);
            logs.add(log);
        }

        insert logs;

        //limits summary
        System.debug('--------- WS_SOM_CreateEfulOrders -- END ');
        System.debug('---------Number of callouts executed is: ' + Limits.getCallouts() + ' in limit: ' + Limits.getLimitCallouts());
        System.debug('---------Number of dml rows executed is: ' + Limits.getDmlRows() + ' in limit: ' + Limits.getLimitDmlRows());
        System.debug('---------Number of dml statments executed is: ' + Limits.getDmlStatements() + ' in limit: ' + Limits.getLimitDmlStatements());
        System.debug('---------Number of queries executed is: ' + Limits.getQueries() + ' in limit: ' + Limits.getLimitQueries());
        System.debug('---------Number of query rows executed is: ' + Limits.getQueryRows() + ' in limit: ' + Limits.getLimitQueryRows());

        return efulOrdersResponseList;
    }

    public static Log__c createLog(EfulOrderResponse res, List<EfulOrderRequest> req){
        Log__c log = new Log__c();
        log.Class_Name__c       = LOG_CLASS_NAME;
        log.Has_Error__c        = res.status == 'OK' ? false : true;
        log.Error_Message__c    = res.errorMessage;
        log.Request__c          = String.valueOf(req);
        log.Response__c         = String.valueOf(res);
        return log;
    }


    global with sharing class EfulOrderRequest{

        public String orderSummaryNumber; 
        public String orderedDate; 
        public String currencyCode; 
        public String salesChannelNumber; 
        public String paymentMeth;
        public String orderDeliveryMethodName; 
        public String invoices;
        public OrderContact delivery;
        public OrderContact billing;
        public List<OrderProduct> orderProducts;
        
    }

    global with sharing class OrderContact{
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

    global with sharing class OrderProduct{
        public String          productSKU;
        public String          type;
        public Integer         quantity;
        public Decimal         amount; 
        public String          description;
        public Integer         lineNumber; 
        public String          locationExternalReference;
        public OrderProductTax orderProductTax;
    }

    global with sharing class OrderProductTax{
        public Decimal vat; 
        public Decimal vatRate; 
    }

    global with sharing class EfulOrderResponse{
        public String orderSummaryNumber;
        public String errorMessage;
        public String status;
    }

}