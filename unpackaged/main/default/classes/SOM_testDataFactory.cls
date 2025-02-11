/**
 * @description       : 
 * @author            : BADER EDDINE ELKHAL
 * @group             : 
 * @last modified on  : 08-17-2022
 * @last modified by  : BADER EDDINE ELKHAL
**/
@isTest
public class SOM_testDataFactory {
    /**
    * @description 
    * @author BADER EDDINE ELKHAL | 05-16-2022 
    * @param email 
    * @return Account 
    **/

    public enum OrderType {MIXTE, STANDARD, PREORDER}
    
    public static STWDeliveryMethod__c createStoreOrigin(string storeOrigin) {
			STWDeliveryMethod__c stw = new STWDeliveryMethod__c();
			stw.storeOrigin__c = storeOrigin;
			insert stw;
			return stw;
	}
    
    public static STWDeliveryMethod__c createStwCountry(string country, string ParentId ) {
			STWDeliveryMethod__c stw = new STWDeliveryMethod__c();
			stw.country__c = country;
			stw.parentId__c = ParentId;
			insert stw;
			return stw;
	}
    
    public static STWDeliveryMethod__c createStwPostalCode(string postalCode, string deliveryMethodId, string ParentId ) {
			STWDeliveryMethod__c stw = new STWDeliveryMethod__c();
			stw.deliveryMethodId__c = deliveryMethodId;
			stw.postalCode__c = postalCode;
			stw.parentId__c = ParentId;
			insert stw;
			return stw;
	}




    public static Account createAccount(string email) {
		List<Account> accounts = [SELECT Id, FirstName, LastName , PersonEmail FROM Account WHERE PersonEmail =: email];

		if (accounts?.isEmpty()) {
			Account account = new Account();
			account.FirstName = 'TestFirstName';
			account.LastName = 'TestLastName';
            account.BillingStreet = '153A New Bond Street';
		    account.BillingCity = 'London';
		    account.BillingPostalCode = 'W1S 2TZ';
		    account.BillingCountry = 'AE';
			account.PersonEmail = email;
			account.RecordTypeId = [SELECT Id,SobjectType, DeveloperName FROM RecordType WHERE SobjectType =: SOM_Constants.ACCOUNT AND DeveloperName =: SOM_Constants.PERSON_ACCOUNT AND IsActive = TRUE LIMIT 1][0].Id;
			insert account;
			return account;
		} else {
			return accounts[0];
		}
	}
	/**
	* @description 
	* @author BADER EDDINE ELKHAL | 05-16-2022 
	* @param numberOfRecords 
	* @return Account 
	**/
	public static List<Account> createAccountBulk(Integer numberOfRecords) {
		Id personAccountRecordTypeId = [SELECT Id,SobjectType, DeveloperName FROM RecordType WHERE SobjectType =: SOM_Constants.ACCOUNT AND DeveloperName =: SOM_Constants.PERSON_ACCOUNT AND IsActive = TRUE LIMIT 1][0].Id;
		List<Account> accounts = [SELECT Id, FirstName, LastName , PersonEmail FROM Account];
		List<Account> listAccountToInsert = new List<Account>();
		
		for(Integer i =1; i<=numberOfRecords; i++){
			Account account = new Account();
			account.FirstName = 'Test'+i;
			account.LastName = 'TestName'+i;
            account.BillingStreet = '153A New Bond Street';
		    account.BillingCity = 'London';
		    account.BillingPostalCode = 'W1S 2TZ';
		    account.BillingCountry = 'AE';
			account.PersonEmail = 'TestEmail'+i+'@test.com';
			account.RecordTypeId = personAccountRecordTypeId;
			listAccountToInsert.add(account);
		}
		insert listAccountToInsert;
		return listAccountToInsert;	
		
	}
	/**
	* @description 
	* @author BADER EDDINE ELKHAL | 05-16-2022 
	* @param accountId 
	* @return Contact 
	**/
	public static Contact getContact(Id accountId) {

		List<Contact> contacts = [SELECT Id, Name,Email FROM Contact WHERE AccountId = : accountId];

		if(contacts.isEmpty()){
			return null;
		} else {
			return contacts[0];
		}			
	}
	public static List<Contact> getListOfContacts(List<Account> listAccount) {

		List<Contact> contacts = [SELECT Id, Name,Email FROM Contact WHERE AccountId IN: listAccount];

		if(contacts?.isEmpty()){
			return null;
		} else {
			return contacts;
		}			
	}
	/**
	* @description Creates product
	* @param productCode Product code
	* @return Product
	*/
	public static Product2 createProduct(String productName, String productCode, String sku , Boolean isSerialized) {
		Product2 product = new Product2();
		product.Name = productName;
		product.ProductCode = productCode;
        product.IsActive = true;
        product.StockKeepingUnit = sku;
        product.isSerialized__c = isSerialized;
		return product;
	}
    
    	public static String createProductTEST(String productName, String productCode, String sku , Boolean isSerialized) {
		Product2 product = new Product2();
		product.Name = productName;
		product.ProductCode = productCode;
        product.IsActive = true;
        product.StockKeepingUnit = sku;
        product.isSerialized__c = isSerialized;
            insert product;
		return product.Id;
	}
    
    public static PricebookEntry createPricebookEntry(Decimal unitPrice, Id productId, Id pricebookId) {
		PricebookEntry priceBookEntry = new PriceBookEntry();
		priceBookEntry.UnitPrice = unitPrice;
		priceBookEntry.Pricebook2Id = pricebookId;
		priceBookEntry.Product2Id = productId;
		priceBookEntry.IsActive = true;
        priceBookEntry.CurrencyIsoCode = 'EUR';
		return priceBookEntry;
	
    }

    public static PricebookEntry createPricebookEntryTEST(Decimal unitPrice, Id productId, Id pricebookId) {
		PricebookEntry priceBookEntry = new PriceBookEntry();
		priceBookEntry.UnitPrice = unitPrice;
		priceBookEntry.Pricebook2Id = pricebookId;
		priceBookEntry.Product2Id = productId;
		priceBookEntry.IsActive = true;
        priceBookEntry.CurrencyIsoCode = 'AED';
        insert priceBookEntry;
		return priceBookEntry;
	
    }
    
    public static OrderDeliveryMethod createOrderDeliveryMethod(String name,Id productId, String referenceNumber) {
		OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod();
		orderDeliveryMethod.Name = name;
		orderDeliveryMethod.ProductId = productId;
		orderDeliveryMethod.ReferenceNumber = referenceNumber;
		orderDeliveryMethod.IsActive = true;
		return orderDeliveryMethod;
	}
    public static OrderDeliveryGroup createOrderDeliveryGroup(Id orderId, Id deliveryMethodId) {
		OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup();

		orderDeliveryGroup.OrderId = orderId;
		orderDeliveryGroup.OrderDeliveryMethodId = deliveryMethodId;
		orderDeliveryGroup.DeliverToName = 'TestFirstName TestLastName';
		orderDeliveryGroup.DeliverToCountry = 'AE';
		orderDeliveryGroup.DeliverToPostalCode = 'W1S 2TZ';
		orderDeliveryGroup.DeliverToCity = 'London';
		orderDeliveryGroup.DeliverToStreet = '153A New Bond Street';
		orderDeliveryGroup.EmailAddress = 'test.user@rimowa.com';
		return orderDeliveryGroup;
	}
    public static OrderItem createOrderItem(Id productId, Id orderId, Integer quantity, Decimal unitPrice, Decimal listPrice,Id deliveryGroupId, String orderType,Id priceBookEntryId, Id locationId, Boolean isSerialized, Boolean isPreOrder, DateTime deliveryStartDate) {

		OrderItem orderItem            = new OrderItem();
		orderItem.Product2Id           = productId;
		orderItem.Quantity             = quantity;
		orderItem.UnitPrice            = unitPrice;
		orderItem.ListPrice            = listPrice;
		orderItem.orderId              = orderId;
		orderItem.OrderDeliveryGroupId = deliveryGroupId;
		orderItem.TotalLineAmount      = unitPrice * quantity;
		orderItem.Type                 = orderType;
        orderItem.pricebookEntryId     = priceBookEntryId;
		orderItem.ReservedAtLocationId = locationId;
		orderItem.IsPreOrder__c        = isPreOrder;
		orderItem.DeliveryStartDate__c = deliveryStartDate;
		return orderItem;
	}
    public static Schema.Location createLocation(String name, String externalReference, Boolean shouldSync,String locationType) {
		Schema.Location location = new Schema.Location();
		location.Name = name;
		location.LocationType = locationType;
		location.TimeZone = 'Europe/Paris';
		location.ExternalReference = externalReference;
		location.ShouldSyncWithOci = shouldSync;
        location.WmsFoFileDestination__c = 'AzureFolder';
        location.WmsFoFileNamePrefix__c  = 'wmsfile1';
        location.CustomCountry__c  = 'AE';
       
		return location;
				
	}
    public static Schema.Address createAddress(Id parentId, String addressType, String locationType) {
		Schema.Address address = new Schema.Address();
		address.ParentId = parentId;
		address.LocationType = locationType;
		address.AddressType = addressType;
		address.Street = '153A New Bond Street';
		address.City = 'London';
		address.PostalCode = 'W1S 2TZ';
		address.Country = 'AE';
		return address;
				
	}
    public static LocationGroup createLocationGroup(String name) {
        LocationGroup locationGroup = new LocationGroup();
        locationGroup.LocationGroupName = name;
        locationGroup.ExternalReference = name;
        locationGroup.ShouldSyncWithOci = true;
        return locationGroup;
	}
    public static Order createOrder(Id accountId,String name, Id saleschannelId, String referenceNumber,Id pricebookId, Boolean passedFraudScreening, Boolean captureAtShipment) {
		Order order = new Order();
		order.AccountId = accountId;
		order.Name = name;
		order.EffectiveDate = System.today();
		order.OrderedDate  = System.now();
		order.Status = SOM_Constants.DRAFT;
		order.SalesChannelId = saleschannelId;
        order.OrderReferenceNumber = referenceNumber;
		order.BillingStreet = '153A New Bond Street';
		order.BillingCity = 'London';
		order.BillingPostalCode = 'W1S 2TZ';
		order.BillingCountry = 'US';
		order.BillingEmailAddress = 'test.user@rimowa.com';
		order.BillingPhoneNumber = '0610101010';
        order.pricebook2Id = pricebookId;
        order.passedFraudScreening__c = passedFraudScreening;
        order.captureAtShipment__c = captureAtShipment;
		return order;
	}
    public static Saleschannel createSaleschannel(string salesChannelName, string externalNumber) {
		Saleschannel saleschannel = new Saleschannel();
		saleschannel.SaleschannelName = salesChannelName;
		saleschannel.ExternalChannelNumber = externalNumber;
		return saleschannel;
	}

    //Create PaymentGroup
    public static PaymentGroup createPaymentGroup(Id sourceObjectId) {
		PaymentGroup paymentGroup = new PaymentGroup();
		paymentGroup.SourceObjectId = sourceObjectId;
		
        return paymentGroup;
	}
    //Create CardPaymentMethod
    public static CardPaymentMethod createCardPaymentMethod(Id accountId, String cardCatgory, String cardType, String RI_PaymentMethodId, String getwayTokenValue) {
        CardPaymentMethod cardPayMethod = new CardPaymentMethod();
		cardPayMethod.AccountId = accountId;
        cardPayMethod.CardCategory = cardCatgory;
        cardPayMethod.CardHolderName = 'TestFirstName TestLastName';
        cardPayMethod.CardType = cardType;
        cardPayMethod.ExpiryMonth =  System.today().month();
        cardPayMethod.ExpiryYear = System.today().year() ;
        cardPayMethod.ProcessingMode = SOM_Constants.EXTERNAL_MODE;
        cardPayMethod.Status = SOM_Constants.ACTIVE;
        cardPayMethod.RI_PaymentMethodId__c = RI_PaymentMethodId;
        cardPayMethod.GatewayToken = getwayTokenValue;
        
		return cardPayMethod;
	}
    public static CardPaymentMethod createCardPaymentMethod(Id accountId, String cardCatgory, String cardType) {
        CardPaymentMethod cardPayMethod = new CardPaymentMethod();
		cardPayMethod.AccountId = accountId;
        cardPayMethod.CardCategory = cardCatgory;
        cardPayMethod.CardHolderName = 'TestFirstName TestLastName';
        cardPayMethod.CardType = cardType;
        cardPayMethod.ExpiryMonth =  System.today().month();
        cardPayMethod.ExpiryYear = System.today().year() ;
        cardPayMethod.ProcessingMode = SOM_Constants.EXTERNAL_MODE;
        cardPayMethod.Status = SOM_Constants.ACTIVE;
        
        
		return cardPayMethod;
	}
    public static PaymentAuthorization createPaymentAuthorization(Id accountId, 
                                                                Double amount, 
                                                                Id paymentGrpId, 
                                                                Id paymentMtdId,
                                                                String customerToken) {
        PaymentAuthorization paymentAtuth = new PaymentAuthorization();
		paymentAtuth.AccountId = accountId;
        paymentAtuth.Amount = amount;
        paymentAtuth.PaymentGroupId = paymentGrpId;
        paymentAtuth.PaymentMethodId = paymentMtdId;
        paymentAtuth.ProcessingMode = SOM_Constants.EXTERNAL_MODE;
        paymentAtuth.Status = SOM_Constants.PROCESSED;
        paymentAtuth.CustomerToken__c = customerToken;
        
		return paymentAtuth;
	}

    //Create Shipments
    public static Map<Id, Shipment> createShipments(Map<Id, FulfillmentOrder> listFulfillmentOrders){

        Map<Id, Shipment> shipmentToInsertByFoId = new Map<Id, Shipment>();
        Map<Id, Shipment> shipmentToReturnByFoId = new Map<Id, Shipment>();
        List<ShipmentItem> listShipmentItemsToInsert = new List<ShipmentItem>();

       
        //Add It to Fulfillment Query then delete It
        /*List<FulfillmentOrderLineItem> listFOLiToCreateShiprment = [Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c
            FROM FulfillmentOrderLineItem 
            WHERE Type !=: SOM_Constants.DELIVERY_CHARGE AND Quantity>0 AND FulfillmentOrderId IN : listFulfillmentOrders.keySet()];*/
        
        //start creation of shipement
        for(FulfillmentOrder foToShip : listFulfillmentOrders.values()){
            if(foToShip.FulfillmentOrderLineItems?.isEmpty()){
                continue;
            }
            
            Shipment shipementToInsert = new Shipment();
            shipementToInsert.DeliveryMethodId = foToShip.DeliveryMethodId;
            shipementToInsert.FulfillmentOrderId = foToShip.Id;
            shipementToInsert.OrderSummaryId = foToShip.OrderSummaryId;
            shipementToInsert.ShipFromCity = foToShip.FulfilledFromLocation?.VisitorAddress.City;
            shipementToInsert.ShipFromStreet = foToShip.FulfilledFromLocation?.VisitorAddress.Street;
            shipementToInsert.ShipFromPostalCode = foToShip.FulfilledFromLocation?.VisitorAddress.PostalCode;
            shipementToInsert.ShipFromState = foToShip.FulfilledFromLocation?.VisitorAddress.State;
            shipementToInsert.ShipFromCountry = foToShip.FulfilledFromLocation?.VisitorAddress.Country;
            shipementToInsert.SourceLocationId = foToShip.FulfilledFromLocationId;
            shipementToInsert.ShipToName = foToShip.FulfilledToName;
            shipementToInsert.DispatchDate__c = System.now().addDays(25);
            shipementToInsert.WMSShipmentId__c = 'EXTId'+ String.valueOf(foToShip.Id);
            shipementToInsert.TrackingNumber = 'TrcNbr'+ String.valueOf(foToShip.Id);
            shipementToInsert.Carrier__c = 'ClsTestCarrier';
            shipementToInsert.ShippingService__c = 'ClsTestShippingService';
            if(foToShip.type.equalsIgnoreCase('Store')){
                shipementToInsert.ShipToCity = foToShip.FulfilledFromLocation?.VisitorAddress.City;
                shipementToInsert.ShipToStreet = foToShip.FulfilledFromLocation?.VisitorAddress.Street;
                shipementToInsert.ShipToPostalCode = foToShip.FulfilledFromLocation?.VisitorAddress.PostalCode;
                shipementToInsert.ShipToState = foToShip.FulfilledFromLocation?.VisitorAddress.State;
                shipementToInsert.ShipToCountry = foToShip.FulfilledFromLocation?.VisitorAddress.Country;

            }    
            if(foToShip.type.equalsIgnoreCase('Warehouse')){
                shipementToInsert.ShipToCity = foToShip.FulfilledToCity;
                shipementToInsert.ShipToStreet = foToShip.FulfilledToStreet;
                shipementToInsert.ShipToPostalCode = foToShip.FulfilledToPostalCode;
                shipementToInsert.ShipToState = foToShip.FulfilledToState;
                shipementToInsert.ShipToCountry = foToShip.FulfilledToCountry;
                
            }
            shipementToInsert.Status = SOM_Constants.SHIPMENT_SHIPPED;
            shipmentToInsertByFoId.put(foToShip.Id, shipementToInsert);

        }
        if(shipmentToInsertByFoId.values().isEmpty()){
            return new Map<Id, Shipment>();
        }

        insert shipmentToInsertByFoId.values();
        
        for(FulfillmentOrder fulmOrder : listFulfillmentOrders.values()){
            if(!shipmentToInsertByFoId.containsKey(fulmOrder.Id)){
                continue;
            }
            for(FulfillmentOrderLineItem foliLine : fulmOrder.FulfillmentOrderLineItems){
                ShipmentItem shipmentItem = new ShipmentItem();
                shipmentItem.ShipmentId = shipmentToInsertByFoId.get(fulmOrder.Id).Id;
                shipmentItem.Product2Id = foliLine.Product2Id;
                shipmentItem.Quantity = foliLine.Quantity;
                shipmentItem.FulfillmentOrderLineItemId = foliLine.Id;
                shipmentItem.OrderItemSummaryId = foliLine.OrderItemSummaryId;
                if(foliLine.OrderItemSummary.isSerialized__c) shipmentItem.SerialNumber__c = 'SrNbr'+String.valueOf(foliLine.Id);
                listShipmentItemsToInsert.add(shipmentItem);
            }
            shipmentToReturnByFoId.put(fulmOrder.Id, shipmentToInsertByFoId.get(fulmOrder.Id));
        }        
        if(!listShipmentItemsToInsert.isEmpty()) insert listShipmentItemsToInsert;


        SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs arg = new SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs();
        List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs> args = new List<SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderArgs>();
        arg.foIds = new List<Id>();
        arg.foIds.addAll(shipmentToReturnByFoId.keySet());
        arg.doUpdateOSStatus = true;
        args.add(arg);
        List<SOM_CloseFulfillmentOrderResponseWr> listFoIdResponse = SOM_ClosingFulfillmentOrderAction.UpdateFulfillmentOrderStatus(args);
        return shipmentToReturnByFoId;
    }

    public static List<OrderSummary> getListOrderSummaries(Id originalOrderId){
		List<OrderSummary> orderSummries = [SELECT Id, LastModifiedDate, CreatedDate, OrderNumber, OriginalOrderId, AccountId, 
            BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, BillingAddress, BillingEmailAddress, 
            TotalTaxAmount, Status, SalesChannelId, CaptureStatus__c, (SELECT Id, status FROM FulfillmentOrders),
            (SELECT Id, status, Type, Name FROM OrderItemSummaries)
			FROM OrderSummary WHERE OriginalOrderId =: originalOrderId];

		if(orderSummries?.isEmpty()){
			return new List<OrderSummary>();
		}
		return orderSummries;
		
	}
    public static List<OrderSummary> getListOrderSummaryByOrder(List<Order> listOrders){
		List<OrderSummary> orderSummries = [SELECT Id, OrderNumber, OriginalOrderId, AccountId, BillingStreet, BillingCity, 
			BillingState, BillingPostalCode, BillingCountry, BillingAddress, BillingEmailAddress, TotalTaxAmount, 
			Status, SalesChannelId, CaptureStatus__c, captureAtShipment__c,  On_Hold__c, CreateFulfillmentOrderImmediatly__c, OrderLifeCycleType,
            (SELECT Id, status FROM FulfillmentOrders)
			FROM OrderSummary WHERE OriginalOrderId =: listOrders];

		if(orderSummries?.isEmpty()){
			return new List<OrderSummary>();
		}
		return orderSummries;
		
	}
    @isTest
    public static OrderSummary generateOrderSummary(){
        List<Id> listIds = new List<Id>();
        //Create Account
        Account acc = createAccount('test.user@rimowa.com');

        //Create Contact
        Contact contact= getContact(acc.Id);

        
        List<Product2> listProducts = new List<Product2>();
        //Create products
        Product2 product = createProduct('produit 1', '10012002', 'sku10001',true);
        listProducts.add(product);

        Product2 product2 = createProduct('Standard delivery', 'ProductCode1','sku10002',false);
        listProducts.add(product2);

        Product2 product3 = createProduct('produit 3', '10013003', 'sku10003',false);
		listProducts.add(product3);

		Product2 product4 = createProduct('produit 4', '10014004', 'sku10004',false);
        listProducts.add(product4);
        insert listProducts;

        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> listPriceEntries = new List<PricebookEntry>();
        PricebookEntry priceentry = createPricebookEntry(79.2, listProducts[0].Id, pricebookId);
        listPriceEntries.add(priceentry);
        PricebookEntry priceentry2 = createPricebookEntry(0, listProducts[1].Id, pricebookId);
        listPriceEntries.add(priceentry2);
        PricebookEntry priceentry3 = createPricebookEntry(255.2, listProducts[2].Id, pricebookId);
        listPriceEntries.add(priceentry3);
		PricebookEntry priceentry4 = createPricebookEntry(255.2, listProducts[3].Id, pricebookId);
        listPriceEntries.add(priceentry4);
        insert listPriceEntries;

        SalesChannel saleschannel = createSaleschannel('Rimowa','SOM');
        insert saleschannel;
        
        List<Schema.Location> listLocations = new List<Schema.Location>();
        Schema.Location location1 = createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        listLocations.add(location1);
        Schema.Location location2 = createLocation('AE01','inventory_1010501', false, 'Store');
        listLocations.add(location2);
        insert listLocations;

        List<Schema.Address> listAddress = new List<Schema.Address>();
        Schema.Address address1 = createAddress(listLocations[0].Id,'Home', SOM_Constants.WAREHOUSE);
        listAddress.add(address1);

        Schema.Address address2 = createAddress(listLocations[1].Id,'Shipping', SOM_Constants.STORE);
        listAddress.add(address2);
        insert listAddress;

        listLocations[0].VisitorAddressId = listAddress[0].Id;
        listLocations[1].VisitorAddressId = listAddress[1].Id;
        update listLocations;

        Order order = createOrder(acc.Id,'Order1011',saleschannel.Id,'Order1011',pricebookId, true, false);
        insert order;

        PaymentGroup paymentgrp = createPaymentGroup(order.Id);
        insert paymentgrp;
        CardPaymentMethod cardPayMethod = createCardPaymentMethod(acc.Id, 'CreditCard', 'Visa');
        insert cardPayMethod;
        PaymentAuthorization paymentAuth = createPaymentAuthorization(acc.Id, 1000, paymentgrp.Id, cardPayMethod.Id, 'DFEB7B92BF462697E053AF598E0A4E9C');
        insert paymentAuth;
        OrderDeliveryMethod oDeliveryMethod = createOrderDeliveryMethod('standard_AE',listProducts[1].Id,'standard_AE');
        insert oDeliveryMethod;

        OrderDeliveryGroup oDG = createOrderDeliveryGroup(order.Id,oDeliveryMethod.Id);
        insert oDG;

        List<OrderItem> listOrderItems =new List<OrderItem>();
        OrderItem orderItem1 = createOrderItem(listProducts[0].Id, order.Id, 1, 79.2,79.2, oDG.Id, SOM_Constants.ORDER_PRODUCT, listPriceEntries[0].Id, listLocations[0].Id, true,false,null);
        listOrderItems.add(orderItem1);

        OrderItem orderItem2 = createOrderItem(listProducts[1].Id, order.Id, 1, 0, 0, oDG.Id, SOM_Constants.DELIVERY_CHARGE, listPriceEntries[1].Id, listLocations[0].Id, false,false,null);
        //listOrderItems.add(orderItem2);

        OrderItem orderItem3 = createOrderItem(listProducts[2].Id, order.Id, 2, 255.2, 255.2, oDG.Id, SOM_Constants.ORDER_PRODUCT,listPriceEntries[2].Id, listLocations[0].Id, false,false,null);
        //listOrderItems.add(orderItem3);
        insert listOrderItems;

        order.Status = 'Activated';
        update order;

        List<OrderSummary> oS = getListOrderSummaries(order.Id);
        
        
        OrderSummary orderSumm = oS[0];

        
      return orderSumm;
        
       
    }


    public static List<OrderSummary> createSTWOrderSummaryBulk(Boolean isPickUpOrder, OrderType typeOfOrders, Integer numberOfOrderToCreate){
        List<Id> listIds = new List<Id>();
        List<Order> listOfOrderToCreate = new List<Order>();
        List<Product2> listProducts = new List<Product2>();
        List<PricebookEntry> listPriceEntries = new List<PricebookEntry>();
        List<Schema.Location> listLocations = new List<Schema.Location>();
        List<Schema.Address> listAddress = new List<Schema.Address>();
        Map<Id, PaymentGroup> listPaymentGrpsByOrderId = new  Map<Id, PaymentGroup>();
        Map<Id, CardPaymentMethod> listCardPayMethodbyOrderId = new  Map<Id, CardPaymentMethod>();
        Map<Id, OrderDeliveryMethod> listOrderDlvryMthdByOrderId = new Map<Id, OrderDeliveryMethod>();
        Map<Id, PaymentAuthorization> listPaymentAuthByOrderId = new Map<Id, PaymentAuthorization>();
        Map<Id, OrderDeliveryGroup> listOrderDlvryGrpByOrderId = new Map<Id, OrderDeliveryGroup>();
        List<OrderItem> listOrderItemsByOrderId = new  List<OrderItem>();

        //Create Account
        Account account = createAccount('test2.user@rimowa.com');
        //Create products
        //Order Product 
        Product2 product = createProduct('produit 1', '10012002', 'sku10004',true);
        listProducts.add(product);
        //Shipping Product 
        Product2 product2 = createProduct('Standard delivery', 'ProductCode1','sku10005',false);
        listProducts.add(product2);
        //Order Product 
        Product2 product3 = createProduct('produit 3', '10013003', 'sku10006',false);
        listProducts.add(product3);
        insert listProducts;
        //Get getStandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        //Create PriceBookEntries
        PricebookEntry priceentry = createPricebookEntry(79.2, listProducts[0].Id, pricebookId);
        listPriceEntries.add(priceentry);
        PricebookEntry priceentry2 = createPricebookEntry(0, listProducts[1].Id, pricebookId);
        listPriceEntries.add(priceentry2);
        PricebookEntry priceentry3 = createPricebookEntry(255.2, listProducts[2].Id, pricebookId);
        listPriceEntries.add(priceentry3);
        insert listPriceEntries;
        //Create SalesChannel
        SalesChannel saleschannel = createSaleschannel('CEGID','CEGID');
        insert saleschannel;
        //Create Locations
        Schema.Location location1 = createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        listLocations.add(location1);
        Schema.Location location2 = createLocation('AE01','inventory_1010501', false, 'Store');
        listLocations.add(location2);
        insert listLocations;
        //Create Addresses
        Schema.Address address1 = createAddress(listLocations[0].Id,'Home', SOM_Constants.WAREHOUSE);
        listAddress.add(address1);
        Schema.Address address2 = createAddress(listLocations[1].Id,'Shipping', SOM_Constants.STORE);
        listAddress.add(address2);
        insert listAddress;
        listLocations[0].VisitorAddressId = listAddress[0].Id;
        listLocations[1].VisitorAddressId = listAddress[1].Id;
        update listLocations;
        //Create Orderes
        for(Integer i=1; i<=numberOfOrderToCreate; i++){
            Order order = createOrder(account.Id,'Order101'+i,saleschannel.Id,'Order101'+i ,pricebookId, true, false);
            listOfOrderToCreate.add(order);
        }
        insert listOfOrderToCreate;

        for(Order createdOrder : listOfOrderToCreate){
            //Create PaymentGroup
            PaymentGroup paymentgrp = createPaymentGroup(createdOrder.Id);
            listPaymentGrpsByOrderId.put(createdOrder.Id, paymentgrp);
            //Create CardPaymentMethod
            CardPaymentMethod cardPayMethod = createCardPaymentMethod(account.Id, 'CreditCard', 'Visa');
            listCardPayMethodbyOrderId.put(createdOrder.Id, cardPayMethod);
            //Create OrderDeliveryMethod
            OrderDeliveryMethod oDeliveryMethod = createOrderDeliveryMethod('standard_AE',listProducts[1].Id,'standard_AE');
            listOrderDlvryMthdByOrderId.put(createdOrder.Id, oDeliveryMethod);
        }
        insert listPaymentGrpsByOrderId.values();
        insert listCardPayMethodbyOrderId.values();
        insert listOrderDlvryMthdByOrderId.values();
        Id locationId = isPickUpOrder ? listLocations[1].Id : listLocations[0].Id;
        //prepare flags for products
        List<Boolean> listProductFlags;
        if(typeOfOrders == OrderType.STANDARD){
            listProductFlags = new List<Boolean>{false, false};
        }
        if(typeOfOrders == OrderType.MIXTE){
            listProductFlags = new List<Boolean>{true, false};
        }
        if(typeOfOrders == OrderType.PREORDER){
            listProductFlags = new List<Boolean>{true, true};
        }
        for(Order createdOrder : listOfOrderToCreate){
            
            PaymentAuthorization paymentAuth = createPaymentAuthorization(account.Id, 1000, listPaymentGrpsByOrderId.get(createdOrder.Id).Id, listCardPayMethodbyOrderId.get(createdOrder.Id).Id, 'DFEB7B92BF462697E053AF598E0A4E9C');
            listPaymentAuthByOrderId.put(createdOrder.Id, paymentAuth);
            OrderDeliveryGroup oDG = createOrderDeliveryGroup(createdOrder.Id,listOrderDlvryMthdByOrderId.get(createdOrder.Id).Id);
            listOrderDlvryGrpByOrderId.put(createdOrder.Id, oDG);
        }
        insert listPaymentAuthByOrderId.values();
        insert listOrderDlvryGrpByOrderId.values();

        for(Order createdOrder : listOfOrderToCreate){
            OrderItem orderItem1 = createOrderItem(listProducts[0].Id, createdOrder.Id, 1, 79.2,79.2, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.ORDER_PRODUCT, listPriceEntries[0].Id, locationId, true,listProductFlags[0],listProductFlags[0]? System.now().addDays(30):null);
            listOrderItemsByOrderId.add(orderItem1);
            OrderItem orderItem2 = createOrderItem(listProducts[1].Id, createdOrder.Id, 1, 0, 0, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.DELIVERY_CHARGE, listPriceEntries[1].Id, locationId, false,false,null);
            listOrderItemsByOrderId.add(orderItem2);
            OrderItem orderItem3 = createOrderItem(listProducts[2].Id, createdOrder.Id, 2, 255.2, 255.2, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.ORDER_PRODUCT,listPriceEntries[2].Id, locationId, false,listProductFlags[1],listProductFlags[0]? System.now().addDays(30):null);
            listOrderItemsByOrderId.add(orderItem3);
            
            //Change Order Status
            createdOrder.Status = SOM_Constants.ACTIVATED; 
        }
    
        insert listOrderItemsByOrderId;
        List<OrderItemTaxLineItem> ListeOITLI = new List<OrderItemTaxLineItem>(); 
        OrderItemTaxLineItem OITLI1 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[0].Id);
        ListeOITLI.add(OITLI1);
        OrderItemTaxLineItem OITLI2 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[1].Id);
        ListeOITLI.add(OITLI2);
        OrderItemTaxLineItem OITLI3 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[2].Id);
        ListeOITLI.add(OITLI3);
        insert ListeOITLI;

        //Activate Orders
        update listOfOrderToCreate;
        List<OrderSummary> orderSummaries = getListOrderSummaryByOrder(listOfOrderToCreate);
        Set<Id> osIds = (new Map<Id,OrderSummary>(orderSummaries)).keySet();

        for(OrderSummary os : orderSummaries){
        }
        return orderSummaries;    
       
    }
    
    public static List<OrderSummary> createOrderSummaryBulk(Boolean isPickUpOrder, OrderType typeOfOrders, Integer numberOfOrderToCreate){
        List<Id> listIds = new List<Id>();
        List<Order> listOfOrderToCreate = new List<Order>();
        List<Product2> listProducts = new List<Product2>();
        List<PricebookEntry> listPriceEntries = new List<PricebookEntry>();
        List<Schema.Location> listLocations = new List<Schema.Location>();
        List<Schema.Address> listAddress = new List<Schema.Address>();
        Map<Id, PaymentGroup> listPaymentGrpsByOrderId = new  Map<Id, PaymentGroup>();
        Map<Id, CardPaymentMethod> listCardPayMethodbyOrderId = new  Map<Id, CardPaymentMethod>();
        Map<Id, OrderDeliveryMethod> listOrderDlvryMthdByOrderId = new Map<Id, OrderDeliveryMethod>();
        Map<Id, PaymentAuthorization> listPaymentAuthByOrderId = new Map<Id, PaymentAuthorization>();
        Map<Id, OrderDeliveryGroup> listOrderDlvryGrpByOrderId = new Map<Id, OrderDeliveryGroup>();
        List<OrderItem> listOrderItemsByOrderId = new  List<OrderItem>();

        //Create Account
        Account account = createAccount('test.user@rimowa.com');
        //Create products
        //Order Product 
        Product2 product = createProduct('produit 1', '10012002', 'sku10001',true);
        listProducts.add(product);
        //Shipping Product 
        Product2 product2 = createProduct('Standard delivery', 'ProductCode1','sku10002',false);
        listProducts.add(product2);
        //Order Product 
        Product2 product3 = createProduct('produit 3', '10013003', 'sku10003',false);
        listProducts.add(product3);
        insert listProducts;
        //Get getStandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        //Create PriceBookEntries
        PricebookEntry priceentry = createPricebookEntry(79.2, listProducts[0].Id, pricebookId);
        listPriceEntries.add(priceentry);
        PricebookEntry priceentry2 = createPricebookEntry(0, listProducts[1].Id, pricebookId);
        listPriceEntries.add(priceentry2);
        PricebookEntry priceentry3 = createPricebookEntry(255.2, listProducts[2].Id, pricebookId);
        listPriceEntries.add(priceentry3);
        insert listPriceEntries;
        //Create SalesChannel
        SalesChannel saleschannel = createSaleschannel('Rimowa','SOM');
        insert saleschannel;
        //Create Locations
        Schema.Location location1 = createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        listLocations.add(location1);
        Schema.Location location2 = createLocation('AE01','inventory_1010501', false, 'Store');
        listLocations.add(location2);
        insert listLocations;
        //Create Addresses
        Schema.Address address1 = createAddress(listLocations[0].Id,'Home', SOM_Constants.WAREHOUSE);
        listAddress.add(address1);
        Schema.Address address2 = createAddress(listLocations[1].Id,'Shipping', SOM_Constants.STORE);
        listAddress.add(address2);
        insert listAddress;
        listLocations[0].VisitorAddressId = listAddress[0].Id;
        listLocations[1].VisitorAddressId = listAddress[1].Id;
        update listLocations;
        //Create Orderes
        for(Integer i=1; i<=numberOfOrderToCreate; i++){
            Order order = createOrder(account.Id,'Order101'+i,saleschannel.Id,'Order101'+i ,pricebookId, true, false);
            listOfOrderToCreate.add(order);
        }
        insert listOfOrderToCreate;

        for(Order createdOrder : listOfOrderToCreate){
            //Create PaymentGroup
            PaymentGroup paymentgrp = createPaymentGroup(createdOrder.Id);
            listPaymentGrpsByOrderId.put(createdOrder.Id, paymentgrp);
            //Create CardPaymentMethod
            CardPaymentMethod cardPayMethod = createCardPaymentMethod(account.Id, 'CreditCard', 'Visa');
            listCardPayMethodbyOrderId.put(createdOrder.Id, cardPayMethod);
            //Create OrderDeliveryMethod
            OrderDeliveryMethod oDeliveryMethod = createOrderDeliveryMethod('standardAE',listProducts[1].Id,'standardAE');
            listOrderDlvryMthdByOrderId.put(createdOrder.Id, oDeliveryMethod);
        }
        insert listPaymentGrpsByOrderId.values();
        insert listCardPayMethodbyOrderId.values();
        insert listOrderDlvryMthdByOrderId.values();
        Id locationId = isPickUpOrder ? listLocations[1].Id : listLocations[0].Id;
        //prepare flags for products
        List<Boolean> listProductFlags;
        if(typeOfOrders == OrderType.STANDARD){
            listProductFlags = new List<Boolean>{false, false};
        }
        if(typeOfOrders == OrderType.MIXTE){
            listProductFlags = new List<Boolean>{true, false};
        }
        if(typeOfOrders == OrderType.PREORDER){
            listProductFlags = new List<Boolean>{true, true};
        }
        for(Order createdOrder : listOfOrderToCreate){
            
            PaymentAuthorization paymentAuth = createPaymentAuthorization(account.Id, 1000, listPaymentGrpsByOrderId.get(createdOrder.Id).Id, listCardPayMethodbyOrderId.get(createdOrder.Id).Id, 'DFEB7B92BF462697E053AF598E0A4E9C');
            listPaymentAuthByOrderId.put(createdOrder.Id, paymentAuth);
            OrderDeliveryGroup oDG = createOrderDeliveryGroup(createdOrder.Id,listOrderDlvryMthdByOrderId.get(createdOrder.Id).Id);
            listOrderDlvryGrpByOrderId.put(createdOrder.Id, oDG);
        }
        insert listPaymentAuthByOrderId.values();
        insert listOrderDlvryGrpByOrderId.values();

        for(Order createdOrder : listOfOrderToCreate){
            OrderItem orderItem1 = createOrderItem(listProducts[0].Id, createdOrder.Id, 1, 79.2,79.2, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.ORDER_PRODUCT, listPriceEntries[0].Id, locationId, true,listProductFlags[0],listProductFlags[0]? System.now().addDays(30):null);
            listOrderItemsByOrderId.add(orderItem1);
            OrderItem orderItem2 = createOrderItem(listProducts[1].Id, createdOrder.Id, 1, 0, 0, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.DELIVERY_CHARGE, listPriceEntries[1].Id, locationId, false,false,null);
            listOrderItemsByOrderId.add(orderItem2);
            OrderItem orderItem3 = createOrderItem(listProducts[2].Id, createdOrder.Id, 2, 255.2, 255.2, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.ORDER_PRODUCT,listPriceEntries[2].Id, locationId, false,listProductFlags[1],listProductFlags[0]? System.now().addDays(30):null);
            listOrderItemsByOrderId.add(orderItem3);
            
            //Change Order Status
            createdOrder.Status = SOM_Constants.ACTIVATED; 
            createdOrder.Tech_CreateOS__c = true;

        }
    
        insert listOrderItemsByOrderId;
        List<OrderItemTaxLineItem> ListeOITLI = new List<OrderItemTaxLineItem>(); 
        OrderItemTaxLineItem OITLI1 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[0].Id);
        ListeOITLI.add(OITLI1);
        OrderItemTaxLineItem OITLI2 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[1].Id);
        ListeOITLI.add(OITLI2);
        OrderItemTaxLineItem OITLI3 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[2].Id);
        ListeOITLI.add(OITLI3);
        insert ListeOITLI;

        //Activate Orders
        update listOfOrderToCreate;
        List<OrderSummary> orderSummaries = getListOrderSummaryByOrder(listOfOrderToCreate);
        Set<Id> osIds = (new Map<Id,OrderSummary>(orderSummaries)).keySet();

        for(OrderSummary os : orderSummaries){
        }
        return orderSummaries;    
       
    }

    /**
    * @description 
    * @author Fatima-ezzahra LAFTOUMI | 16-09-2022 
    * @param orderSumm
    * @return FulfillmentOrder 
    **/
    public static FulfillmentOrder createFO(OrderSummary orderSumm){
        //Set<Id> osIds = (new Map<Id,OrderSummary>(orderSummaries)).keySet();

        OrderDeliveryGroupSummary odgs = [SELECT Id,OrderSummaryId FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSumm.Id];
        List<OrderItemSummary> orderItemSummries = [SELECT Id, OrderSummaryId, ReservedAtLocationId, QuantityAvailableToReturn,
                                                        Type, Product2Id, Quantity,Status
                                                        FROM OrderItemSummary WHERE OrderSummaryId =: orderSumm.Id];


        List<ConnectApi.OrderItemSummaryInputRepresentation> ListorderItemSummariesInputRep = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        for(OrderItemSummary oIS : orderItemSummries){
            ConnectApi.OrderItemSummaryInputRepresentation orderItemSummaryInputRep = new ConnectApi.OrderItemSummaryInputRepresentation();
            orderItemSummaryInputRep.orderItemSummaryId = oIS.Id;
                orderItemSummaryInputRep.Quantity = oIS.Quantity;
                ListorderItemSummariesInputRep.add(orderItemSummaryInputRep);
        }
        ListorderItemSummariesInputRep.remove(ListorderItemSummariesInputRep.size() - 1);

        ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroupInputRep = new ConnectApi.FulfillmentGroupInputRepresentation();
        List<ConnectApi.FulfillmentGroupInputRepresentation> listFulfillmentGroupInputReps = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
        ConnectApi.FulfillmentOrderInputRepresentation fulfilementOrderInputRep = new ConnectApi.FulfillmentOrderInputRepresentation();
        List<ConnectApi.FulfillmentOrderInputRepresentation> listFulfilementOrderInputReps = new List<ConnectApi.FulfillmentOrderInputRepresentation>();
        //FulfillmentGroupInputRepresentation
        fulfillmentGroupInputRep.fulfilledFromLocationId = orderItemSummries[0].ReservedAtLocationId;
        Schema.Location location = [select id , LocationType from location where id =: orderItemSummries[0].ReservedAtLocationId LIMIT 1];
        if(location.LocationType == 'Warehouse')
            fulfillmentGroupInputRep.fulfillmentType = 'Warehouse';
        else {
            fulfillmentGroupInputRep.fulfillmentType = 'store';
        }
        fulfillmentGroupInputRep.orderItemSummaries = ListorderItemSummariesInputRep;
        fulfillmentGroupInputRep.referenceId = '1';
        listFulfillmentGroupInputReps.add(fulfillmentGroupInputRep);
        //FulfillmentOrderInputRepresentation
        fulfilementOrderInputRep.fulfillmentGroups = listFulfillmentGroupInputReps;
        fulfilementOrderInputRep.orderDeliveryGroupSummaryId = odgs.Id;
        fulfilementOrderInputRep.orderSummaryId = orderSumm.Id;
        listFulfilementOrderInputReps.add(fulfilementOrderInputRep);
        ConnectApi.MultipleFulfillmentOrderInputRepresentation multipleFulfillmentOrderInputRep = new ConnectApi.MultipleFulfillmentOrderInputRepresentation();
        multipleFulfillmentOrderInputRep.fulfillmentOrders = listFulfilementOrderInputReps;
        ConnectApi.FulfillmentOrderOutputRepresentation result = ConnectAPI.FulfillmentOrder.createFulfillmentOrders(fulfilementOrderInputRep);
        
        List<FulfillmentOrder> listFulfillmentOrders = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId =: orderSumm.Id];

        // if(orderSumm.captureAtShipment__c == false && orderSumm.CaptureStatus__c == 'Not Applicable'){
        //     listFulfillmentOrders[0].Capture_Status__c = 'To capture';
        // }else{
            listFulfillmentOrders[0].Capture_Status__c = 'Not Applicable';
            listFulfillmentOrders[0].Status = 'Allocated';
        // }
        update listFulfillmentOrders[0];
        return listFulfillmentOrders[0];

    }


        /**
    * @description 
    * @author Bouchaib Naimy | 23-09-2022 
    * @param orderSumm
    * @return FulfillmentOrder 
    **/

    public static List<FulfillmentOrder> createMultipleFO(OrderSummary orderSumm){

        OrderDeliveryGroupSummary odgs = [SELECT Id,OrderSummaryId FROM OrderDeliveryGroupSummary WHERE OrderSummaryId =: orderSumm.Id];
        List<OrderItemSummary> orderItemSummries = [SELECT Id, OrderSummaryId, ReservedAtLocationId, QuantityAvailableToReturn,
                                                        Type, Product2Id, Quantity
                                                        FROM OrderItemSummary WHERE OrderSummaryId =: orderSumm.Id];


        List<ConnectApi.OrderItemSummaryInputRepresentation> ListorderItemSummariesInputRep = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        List<ConnectApi.OrderItemSummaryInputRepresentation> ListorderItemSummariesInputRep1 = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
        for(Integer counter = 0 ; counter < orderItemSummries.size() ; counter++){
            if(orderItemSummries.size() - counter == 1) {
                ConnectApi.OrderItemSummaryInputRepresentation orderItemSummaryInputRep1 = new ConnectApi.OrderItemSummaryInputRepresentation();
                orderItemSummaryInputRep1.orderItemSummaryId = orderItemSummries[counter].Id;
                orderItemSummaryInputRep1.Quantity = orderItemSummries[counter].Quantity;
                ListorderItemSummariesInputRep1.add(orderItemSummaryInputRep1);
                break;
            }
            ConnectApi.OrderItemSummaryInputRepresentation orderItemSummaryInputRep = new ConnectApi.OrderItemSummaryInputRepresentation();
            orderItemSummaryInputRep.orderItemSummaryId = orderItemSummries[counter].Id;
            orderItemSummaryInputRep.Quantity = orderItemSummries[counter].Quantity;
            ListorderItemSummariesInputRep.add(orderItemSummaryInputRep);
        }

        ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroupInputRep = new ConnectApi.FulfillmentGroupInputRepresentation();
        ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroupInputRep2 = new ConnectApi.FulfillmentGroupInputRepresentation();
        List<ConnectApi.FulfillmentGroupInputRepresentation> listFulfillmentGroupInputReps = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
        List<ConnectApi.FulfillmentGroupInputRepresentation> listFulfillmentGroupInputReps2 = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
        ConnectApi.FulfillmentOrderInputRepresentation fulfilementOrderInputRep = new ConnectApi.FulfillmentOrderInputRepresentation();
        ConnectApi.FulfillmentOrderInputRepresentation fulfilementOrderInputRep2 = new ConnectApi.FulfillmentOrderInputRepresentation();
        List<ConnectApi.FulfillmentOrderInputRepresentation> listFulfilementOrderInputReps = new List<ConnectApi.FulfillmentOrderInputRepresentation>();
        //FulfillmentGroupInputRepresentation
        fulfillmentGroupInputRep.fulfilledFromLocationId = orderItemSummries[0].ReservedAtLocationId;
        fulfillmentGroupInputRep2.fulfilledFromLocationId = orderItemSummries[0].ReservedAtLocationId;
        Schema.Location location = [select id , LocationType from location where id =: orderItemSummries[0].ReservedAtLocationId LIMIT 1];
        if(location.LocationType == 'Warehouse')
            fulfillmentGroupInputRep.fulfillmentType = 'Warehouse';
        else {
            fulfillmentGroupInputRep.fulfillmentType = 'store';
        }
        if(location.LocationType == 'Warehouse')
            fulfillmentGroupInputRep2.fulfillmentType = 'Warehouse';
        else {
            fulfillmentGroupInputRep2.fulfillmentType = 'store';
        }
        fulfillmentGroupInputRep.orderItemSummaries = ListorderItemSummariesInputRep;
        fulfillmentGroupInputRep2.orderItemSummaries = ListorderItemSummariesInputRep1;
        fulfillmentGroupInputRep.referenceId = '1';
        fulfillmentGroupInputRep2.referenceId = '2';
        listFulfillmentGroupInputReps.add(fulfillmentGroupInputRep);
        listFulfillmentGroupInputReps2.add(fulfillmentGroupInputRep2);
        //FulfillmentOrderInputRepresentation
        fulfilementOrderInputRep.fulfillmentGroups = listFulfillmentGroupInputReps;
        fulfilementOrderInputRep.orderDeliveryGroupSummaryId = odgs.Id;
        fulfilementOrderInputRep.orderSummaryId = orderSumm.Id;

        fulfilementOrderInputRep2.fulfillmentGroups = listFulfillmentGroupInputReps2;
        fulfilementOrderInputRep2.orderDeliveryGroupSummaryId = odgs.Id;
        fulfilementOrderInputRep2.orderSummaryId = orderSumm.Id;
        listFulfilementOrderInputReps.add(fulfilementOrderInputRep);
        listFulfilementOrderInputReps.add(fulfilementOrderInputRep2);
        ConnectApi.MultipleFulfillmentOrderInputRepresentation multipleFulfillmentOrderInputRep = new ConnectApi.MultipleFulfillmentOrderInputRepresentation();
        multipleFulfillmentOrderInputRep.fulfillmentOrders = listFulfilementOrderInputReps;
        ConnectApi.MultipleFulfillmentOrderOutputRepresentation result = ConnectAPI.FulfillmentOrder.createMultipleFulfillmentOrder(multipleFulfillmentOrderInputRep);
        
        List<FulfillmentOrder> listFulfillmentOrders = [SELECT Id, Type, Status FROM FulfillmentOrder
                                                            WHERE OrderSummaryId = : orderSumm.Id];

        // if(orderSumm.captureAtShipment__c == false && orderSumm.CaptureStatus__c == 'Not Applicable'){
        //     listFulfillmentOrders[0].Capture_Status__c = 'To capture';
        // }else{
            for(FulfillmentOrder fo : listFulfillmentOrders){
                fo.Capture_Status__c = 'Not Applicable';
                fo.Status = 'Allocated';
            }
        // }
        update listFulfillmentOrders;
        return listFulfillmentOrders;

    }


	@isTest
	public static void testBulkOrderSummariesCreation(){
		
        
        Test.startTest();
        //System.debug('**** HomeDELIVERY and Mixte  :::: ');
        //SOM_testDataFactory.createOrderSummaryBulk(true, orderType.MIXTE, 3);
        //System.debug('**** PickUp and STANDARD  :::: ');
        //SOM_testDataFactory.createOrderSummaryBulk(true, orderType.STANDARD, 5);
        //System.debug('**** HomeDELIVERY and PREORDER  :::: ');
        //SOM_testDataFactory.createOrderSummaryBulk(true, orderType.PREORDER, 8);
        //createOrderSummaryBulk Change Method type to return list of orderSummaries
        SOM_testDataFactory.createOrderSummaryBulk(false, orderType.STANDARD, 5);
        Test.stopTest();

        //we should add check by OrderSummaryId to avoid using environement records !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        Map<Id, FulfillmentOrder> fulfillmentOrders = new Map<Id, FulfillmentOrder>();
        for(FulfillmentOrder foRec : [SELECT Id, FulfillmentOrderNumber, AccountId, DeliveryMethodId, FulfilledFromLocationId, FulfilledFromLocation.VisitorAddress.City,
                                FulfilledFromLocation.VisitorAddress.PostalCode, FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
                                FulfilledToName, FulfilledToStreet, FulfilledToCity, FulfilledToState, FulfilledToPostalCode, FulfilledToCountry, FulfilledFromLocation.VisitorAddress.Street,
                                FulfilledToLatitude, FulfilledToLongitude, FulfilledToGeocodeAccuracy, FulfilledToAddress, FulfilledToEmailAddress, 
                                FulfilledToPhone, ItemCount, Status, Type , OrderSummaryId, OrderSummary.Status, DeliveryMethod.Carrier, DeliveryMethod.ReferenceNumber,
                                (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                                OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c
                                FROM FulfillmentOrderLineItems
                                WHERE Type !=: SOM_Constants.DELIVERY_CHARGE AND Quantity>0)
                                FROM FulfillmentOrder WHERE Status =: SOM_Constants.FULFILLMENT_ORDER_PARTIALLY_FULFILLED OR Status =: SOM_Constants.FULFILLMENT_ORDER_FULFILLING]){

            fulfillmentOrders.put(foRec.Id,foRec);
        }
        Map<Id, Shipment> listOfCreatedShipments;
        if(!fulfillmentOrders.isEmpty()){
            listOfCreatedShipments = SOM_testDataFactory.createShipments(fulfillmentOrders);
        }
        

	}

    // TODO: shipment; return;


    
    public static OrderSummary customOrderSummaryCreation(String OrderNumber, String RI_PaymentMethodId, String getwayTokenValue, Boolean passedFraudScreening, Boolean captureAtShipment){
        List<Id> listIds = new List<Id>();
        //Create Account
        Account acc = createAccount('test.user@rimowa.com');

        //Create Contact
        Contact contact= getContact(acc.Id);

        
        List<Product2> listProducts = new List<Product2>();
        //Create products
        List<String> listOfSKU = generateRandomSKU(6, 4);
        Product2 product = createProduct('produit 1', listOfSKU[0], 'SKU' + listOfSKU[0],true);
        listProducts.add(product);

        Product2 product2 = createProduct('Standard delivery', listOfSKU[1],  'SKU' + listOfSKU[1],false);
        listProducts.add(product2);

        Product2 product3 = createProduct('produit 3', listOfSKU[2],  'SKU' + listOfSKU[2],false);
		listProducts.add(product3);

		Product2 product4 = createProduct('produit 4', listOfSKU[3],  'SKU' + listOfSKU[3],false);
        listProducts.add(product4);
        insert listProducts;
        Id pricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> listPriceEntries = new List<PricebookEntry>();
        PricebookEntry priceentry = createPricebookEntry(79.2, listProducts[0].Id, pricebookId);
        listPriceEntries.add(priceentry);
        PricebookEntry priceentry2 = createPricebookEntry(0, listProducts[1].Id, pricebookId);
        listPriceEntries.add(priceentry2);
        PricebookEntry priceentry3 = createPricebookEntry(255.2, listProducts[2].Id, pricebookId);
        listPriceEntries.add(priceentry3);
		PricebookEntry priceentry4 = createPricebookEntry(255.2, listProducts[3].Id, pricebookId);
        listPriceEntries.add(priceentry4);
        insert listPriceEntries;

        SalesChannel saleschannel = createSaleschannel('Rimowa','SOM');
        insert saleschannel;
        
        List<Schema.Location> listLocations = new List<Schema.Location>();
        Schema.Location location1 = createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        listLocations.add(location1);
        Schema.Location location2 = createLocation('AE01','inventory_1010501', false, 'Store');
        listLocations.add(location2);
        insert listLocations;

        List<Schema.Address> listAddress = new List<Schema.Address>();
        Schema.Address address1 = createAddress(listLocations[0].Id,'Home', SOM_Constants.WAREHOUSE);
        listAddress.add(address1);

        Schema.Address address2 = createAddress(listLocations[1].Id,'Shipping', SOM_Constants.STORE);
        listAddress.add(address2);
        insert listAddress;

        listLocations[0].VisitorAddressId = listAddress[0].Id;
        listLocations[1].VisitorAddressId = listAddress[1].Id;
        update listLocations;

        Order order = createOrder(acc.Id, OrderNumber, saleschannel.Id, OrderNumber, pricebookId, passedFraudScreening, captureAtShipment);
        insert order;

        PaymentGroup paymentgrp = createPaymentGroup(order.Id);
        insert paymentgrp;

        Id repaymentMethodId;
        if(RI_PaymentMethodId.equalsIgnoreCase(SOM_Constants.RI_REPAYMENT_METHOD_C_KLARNA)){
            DigitalWallet digitalWallet = new DigitalWallet();
            digitalWallet.type = 'KLARNA_PAYLATER';
            digitalWallet.AccountId = acc.Id;
            digitalWallet.ProcessingMode = 'External';
            digitalWallet.RI_PaymentMethodId__c = RI_PaymentMethodId;
            digitalWallet.Status = 'Active';
            insert digitalWallet;
            repaymentMethodId = digitalWallet.Id;   
        }
        else if(RI_PaymentMethodId.equalsIgnoreCase(SOM_Constants.RI_REPAYMENT_METHOD_C_CREDIT_CARD)){
            CardPaymentMethod cardPayMethod = createCardPaymentMethod(acc.Id, 'CreditCard', 'Visa', RI_PaymentMethodId, getwayTokenValue);
            repaymentMethodId = cardPayMethod.Id;
            
        }
        
        PaymentAuthorization paymentAuth = createPaymentAuthorization(acc.Id, 1000, paymentgrp.Id, repaymentMethodId, getwayTokenValue);
        insert paymentAuth;
        OrderDeliveryMethod oDeliveryMethod = createOrderDeliveryMethod('standard_AE',listProducts[1].Id,'standard_AE');
        insert oDeliveryMethod;
        OrderDeliveryGroup oDG = createOrderDeliveryGroup(order.Id,oDeliveryMethod.Id);
        insert oDG;

        List<OrderItem> listOrderItems =new List<OrderItem>();
        OrderItem orderItem1 = createOrderItem(listProducts[0].Id, order.Id, 1, 79.2,79.2, oDG.Id, SOM_Constants.ORDER_PRODUCT, listPriceEntries[0].Id, listLocations[0].Id, false,false,null);
        listOrderItems.add(orderItem1);

        OrderItem orderItem2 = createOrderItem(listProducts[1].Id, order.Id, 1, 0, 0, oDG.Id, SOM_Constants.DELIVERY_CHARGE, listPriceEntries[1].Id, listLocations[0].Id, false,false,null);
        //listOrderItems.add(orderItem2);

        OrderItem orderItem3 = createOrderItem(listProducts[2].Id, order.Id, 2, 255.2, 255.2, oDG.Id, SOM_Constants.ORDER_PRODUCT,listPriceEntries[2].Id, listLocations[0].Id, false,false,null);
        //listOrderItems.add(orderItem3);
        insert listOrderItems;

        order.Status = 'Activated';
        update order;

        List<OrderSummary> oS = getListOrderSummaries(order.Id);
        
        
        OrderSummary orderSumm = oS[0];

        
      return orderSumm;
        
       
    }
    @IsTest
    public static void testSingleOrderSummary(){
        OrderSummary os = customOrderSummaryCreation('454545554', 'C_KLARNA', 'E4C294A4ED2CCF54E053AF598E0A061C', false, false);
       
    }

    public static List<String> generateRandomSKU(Integer codelen, Integer NumberOfLines) {
        List<String> listOfCodes = new List<String>();
        for(Integer i=0; i<NumberOfLines; i++){
            //String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
            String chars = '1234567890';
            String[] result = new String[codelen];
            Integer idx = 0;
            while(idx < codelen) {
                Integer chr = Math.mod(Math.abs(Crypto.getRandomInteger()), 10);
                result[idx++] = chars.substring(chr, chr+1);
            }
            listOfCodes.add(String.join(result,''));
        }
        return listOfCodes; 
    }

    /**
    * @description 
    * @author Fatima-ezzahra LAFTOUMI | 12-08-2022 
    * @param invoices 
    * @return Map<Id,CorrectiveInvoice__c> 
    **/
    public static Map<Id,CorrectiveInvoice__c> createCorrectiveInvoices(Map<Id,Invoice> invoices){
        List<CorrectiveInvoice__c> cInToCreate   = new List<CorrectiveInvoice__c>();
        Map<Id,CorrectiveInvoice__c> cInvCreated = new Map<Id,CorrectiveInvoice__c>();
        for(Invoice inv : invoices.values()){
            CorrectiveInvoice__c cInv = new CorrectiveInvoice__c();
            cInv.OriginalInvoice__c     = inv.InvoiceNumber__c;
            cInv.PDFGenerationStatus__c = 'Not Started';
            cInv.CurrencyIsoCode        = inv.CurrencyIsoCode;
            cInv.OriginalInvoiceId__c   = inv.Id;
            cInv.Name                   = 'CI' + inv.InvoiceNumber__c;
            cInv.Corrective_Invoice_Date__c  = system.today();
            cInToCreate.add(cInv);
        }
        insert cInToCreate;
        for(CorrectiveInvoice__c cinv : cInToCreate){
            cInvCreated.put(cinv.Id, cinv);
            InvoiceCreated__e ev = new InvoiceCreated__e();
            ev.Invoice_Id__c     =  cinv.Id;
        }
         
        return cInvCreated;
    }

    /**
    * @description 
    * @author Fatima-ezzahra LAFTOUMI | 06-09-2022 
    * @param os 
    * @return ReturnOrder
    **/
    public static ReturnOrder createReturnOrder(OrderSummary os){
        List<OrderItemSummary> listOrderItemSummForReturn = [SELECT Id, OrderSummaryId, Type, Product2Id , Quantity, QuantityAllocated, QuantityAvailableToFulfill, QuantityAvailableToReturn, QuantityFulfilled, QuantityShipped, QuantityReturned
                                                                FROM OrderItemSummary WHERE Type != 'Delivery Charge' AND QuantityAvailableToReturn != 0
                                                                AND OrderSummaryId = : os.Id];

                                                       
        ConnectApi.ReturnOrderLineItemInputRepresentation SingleChangeItem = new ConnectApi.ReturnOrderLineItemInputRepresentation();
        List<ConnectApi.ReturnOrderLineItemInputRepresentation> changeLines = new List<ConnectApi.ReturnOrderLineItemInputRepresentation>();
        SingleChangeItem.orderItemSummaryId = listOrderItemSummForReturn[0].Id;
        SingleChangeItem.quantityExpected = 1;
        SingleChangeItem.quantityReceived = 0;
        SingleChangeItem.reasonForReturn = 'RE01';
        SingleChangeItem.canReduceShipping = false;
        changeLines.add(SingleChangeItem);

        ConnectApi.ReturnOrderInputRepresentation changeInputRepresentation = new ConnectApi.ReturnOrderInputRepresentation();
        List<ConnectApi.ReturnOrderInputRepresentation> listChangeInputs = new List<ConnectApi.ReturnOrderInputRepresentation>();
        changeInputRepresentation.returnOrderLifeCycleType = 'MANAGED';
        changeInputRepresentation.returnOrderLineItems = changeLines;
        changeInputRepresentation.orderSummaryId = listOrderItemSummForReturn[0].OrderSummaryId;
        changeInputRepresentation.Status = 'Submitted';
        listChangeInputs.add(changeInputRepresentation);


        ConnectApi.ReturnOrderOutputRepresentation outRep =  ConnectApi.ReturnOrder.createReturnOrder(changeInputRepresentation);

        ReturnOrder returnOrder = [SELECT Id, AccountId,CurrencyIsoCode, ReturnOrderNumber, Status, OrderSummaryId,LifeCycleType FROM ReturnOrder WHERE Id =: outRep.returnOrderId LIMIT 1];

        ReturnOrderLineItem returnOrderLineItemToUpdate = [SELECT Id, OrderItemSummary.Product2.StockKeepingUnit, QuantityReceived, QuantityRejected, QuantityExpected,Description,ReasonForRejection
                                                                FROM ReturnOrderLineItem 
                                                                WHERE returnOrderId =: returnOrder.Id LIMIT 1];
        returnOrderLineItemToUpdate.QuantityReceived   = 1;
        returnOrderLineItemToUpdate.QuantityRejected   = 0;
        returnOrderLineItemToUpdate.QuantityExpected   = 1;
        returnOrderLineItemToUpdate.Description        = 'no description';
        returnOrderLineItemToUpdate.ReasonForRejection = 'Damaged Item';
        returnOrderLineItemToUpdate.RepaymentMethod    = 'Refund';
        update returnOrderLineItemToUpdate;

        return returnOrder;

    }
    /**
    * @description 
    * @author Fatima-ezzahra LAFTOUMI | 06-09-2022 
    * @param os 
    * @return ReturnOrder
    **/
    public static ReturnOrder createReturnOrderSubmitted(OrderSummary os){
        List<OrderItemSummary> listOrderItemSummForReturn = [SELECT Id, OrderSummaryId, Type, Product2Id , Quantity, QuantityAllocated, QuantityAvailableToFulfill, QuantityAvailableToReturn, QuantityFulfilled, QuantityShipped, QuantityReturned
                                                                FROM OrderItemSummary WHERE Type != 'Delivery Charge' AND QuantityAvailableToReturn != 0
                                                                AND OrderSummaryId = : os.Id];

                                                       
        ConnectApi.ReturnOrderLineItemInputRepresentation SingleChangeItem = new ConnectApi.ReturnOrderLineItemInputRepresentation();
        List<ConnectApi.ReturnOrderLineItemInputRepresentation> changeLines = new List<ConnectApi.ReturnOrderLineItemInputRepresentation>();
        SingleChangeItem.orderItemSummaryId = listOrderItemSummForReturn[0].Id;
        SingleChangeItem.quantityExpected = 1;
        SingleChangeItem.quantityReceived = 0;
        SingleChangeItem.reasonForReturn = 'RE01';
        SingleChangeItem.canReduceShipping = false;
        changeLines.add(SingleChangeItem);

        ConnectApi.ReturnOrderInputRepresentation changeInputRepresentation = new ConnectApi.ReturnOrderInputRepresentation();
        List<ConnectApi.ReturnOrderInputRepresentation> listChangeInputs = new List<ConnectApi.ReturnOrderInputRepresentation>();
        changeInputRepresentation.returnOrderLifeCycleType = 'MANAGED';
        changeInputRepresentation.returnOrderLineItems = changeLines;
        changeInputRepresentation.orderSummaryId = listOrderItemSummForReturn[0].OrderSummaryId;
        changeInputRepresentation.Status = 'Submitted';
        listChangeInputs.add(changeInputRepresentation);


        ConnectApi.ReturnOrderOutputRepresentation outRep =  ConnectApi.ReturnOrder.createReturnOrder(changeInputRepresentation);

        ReturnOrder returnOrder = [SELECT Id, AccountId,CurrencyIsoCode, ReturnOrderNumber, Status, OrderSummaryId,LifeCycleType FROM ReturnOrder WHERE Id =: outRep.returnOrderId LIMIT 1];

        ReturnOrderLineItem returnOrderLineItemToUpdate = [SELECT Id, OrderItemSummary.Product2.StockKeepingUnit, QuantityReceived, QuantityRejected, QuantityExpected,Description,ReasonForRejection
                                                                FROM ReturnOrderLineItem 
                                                                WHERE returnOrderId =: returnOrder.Id LIMIT 1];
        returnOrderLineItemToUpdate.QuantityReceived   = 0;
        returnOrderLineItemToUpdate.QuantityRejected   = 0;
        returnOrderLineItemToUpdate.QuantityExpected   = 1;
        returnOrderLineItemToUpdate.Description        = 'no description';
        returnOrderLineItemToUpdate.ReasonForRejection = 'Damaged Item';
        returnOrderLineItemToUpdate.RepaymentMethod    = 'Refund';
        update returnOrderLineItemToUpdate;

        return returnOrder;

    }
    
     /**
    * @description 
    * @author MME | 01-06-2023 
    * @param os 
    * @return ReturnOrder
    **/
    public static ReturnOrder createReturnOrderEXCHANGEROI(OrderSummary os){
        List<OrderItemSummary> listOrderItemSummForReturn = [SELECT Id, OrderSummaryId, Type, Product2Id , Quantity, QuantityAllocated, QuantityAvailableToFulfill, QuantityAvailableToReturn, QuantityFulfilled, QuantityShipped, QuantityReturned
                                                                FROM OrderItemSummary WHERE Type != 'Delivery Charge' AND QuantityAvailableToReturn != 0
                                                                AND OrderSummaryId = : os.Id];

                                                       
        ConnectApi.ReturnOrderLineItemInputRepresentation SingleChangeItem = new ConnectApi.ReturnOrderLineItemInputRepresentation();
        List<ConnectApi.ReturnOrderLineItemInputRepresentation> changeLines = new List<ConnectApi.ReturnOrderLineItemInputRepresentation>();
        SingleChangeItem.orderItemSummaryId = listOrderItemSummForReturn[0].Id;
        SingleChangeItem.quantityExpected = 1;
        SingleChangeItem.quantityReceived = 0;
        SingleChangeItem.reasonForReturn = 'RE01';
        SingleChangeItem.canReduceShipping = false;
        changeLines.add(SingleChangeItem);

        ConnectApi.ReturnOrderInputRepresentation changeInputRepresentation = new ConnectApi.ReturnOrderInputRepresentation();
        List<ConnectApi.ReturnOrderInputRepresentation> listChangeInputs = new List<ConnectApi.ReturnOrderInputRepresentation>();
        changeInputRepresentation.returnOrderLifeCycleType = 'MANAGED';
        changeInputRepresentation.returnOrderLineItems = changeLines;
        changeInputRepresentation.orderSummaryId = listOrderItemSummForReturn[0].OrderSummaryId;
        changeInputRepresentation.Status = 'Submitted';
        listChangeInputs.add(changeInputRepresentation);


        ConnectApi.ReturnOrderOutputRepresentation outRep =  ConnectApi.ReturnOrder.createReturnOrder(changeInputRepresentation);

        ReturnOrder returnOrder = [SELECT Id, AccountId,CurrencyIsoCode, ReturnOrderNumber, Status, OrderSummaryId,LifeCycleType FROM ReturnOrder WHERE Id =: outRep.returnOrderId LIMIT 1];

        ReturnOrderLineItem returnOrderLineItemToUpdate = [SELECT Id, OrderItemSummary.Product2.StockKeepingUnit, QuantityReceived, QuantityRejected, QuantityExpected,Description,ReasonForRejection
                                                                FROM ReturnOrderLineItem 
                                                                WHERE returnOrderId =: returnOrder.Id LIMIT 1];
        returnOrderLineItemToUpdate.QuantityReceived   = 1;
        returnOrderLineItemToUpdate.QuantityRejected   = 0;
        returnOrderLineItemToUpdate.QuantityExpected   = 1;
        returnOrderLineItemToUpdate.Description        = 'no description';
        returnOrderLineItemToUpdate.ReasonForRejection = 'Damaged Item';
        returnOrderLineItemToUpdate.RepaymentMethod    = SOM_Constants.EXCHANGE;
        returnOrderLineItemToUpdate.FollowUpProcessed__c = false ;
        update returnOrderLineItemToUpdate;

        return returnOrder;

    }

    
    /**
    * @description This method creates Attachment record
    * @author Hicham TALBI | 04-09-2023 
    * @param Attachment fields 
    * @return null
    **/

    public static void createAttachment(String Name, String parentId, String Body){
        Attachment att = new Attachment();
        att.Name = Name;
        att.ParentId = parentId;
        att.Body = Blob.valueOf(Body);
        insert att;
    }
    
    
    /**
    * @description This method creates Attachment record
    * @author Hicham TALBI | 04-09-2023 
    * @param OrderSummary Id 
    * @return Map<Id, FulfillmentOrder>
    **/

    public static Map<Id, FulfillmentOrder> prepareFulfillmentOrderMap(String orderSummaryId){
        List<FulfillmentOrder> lFO = [SELECT Id,Status, DeliveryMethodId,OrderSummaryId,Type,FulfilledFromLocationId,FulfilledFromLocation.VisitorAddress.City,FulfilledFromLocation.VisitorAddress.Street,FulfilledFromLocation.VisitorAddress.PostalCode,
        FulfilledFromLocation.VisitorAddress.State,FulfilledFromLocation.VisitorAddress.Country,
        FulfilledToName,FulfilledToCity,FulfilledToStreet,FulfilledToPostalCode,FulfilledToState,FulfilledToCountry,
                    (SELECT Id, FulfillmentOrderLineItemNumber, FulfillmentOrderId, Product2.StockKeepingUnit,
                    OrderItemSummaryId, Quantity, Product2Id, OrderItemSummary.isSerialized__c FROM FulfillmentOrderLineItems WHERE Type !=: SOM_Constants.DELIVERY_CHARGE)
                    FROM FulfillmentOrder WHERE OrderSummaryId = :orderSummaryId];
        Map<Id, FulfillmentOrder> foMap = new Map<Id, FulfillmentOrder>(lFO);
        return foMap;
    }
    

    /**
    * @description 
    * @author Fatima-ezzahra LAFTOUMI | 07-09-2022 
    * @param os 
    * @return ReturnOrder
    **/
    public static Refund createRefundWithCreditMemo(OrderSummary os , Boolean attachedRO , Boolean Discount){
        ConnectApi.AdjustOrderItemSummaryInputRepresentation adjustOrderInput = new ConnectApi.AdjustOrderItemSummaryInputRepresentation();
        ConnectApi.CreateCreditMemoInputRepresentation creditMemoInput = new ConnectApi.CreateCreditMemoInputRepresentation();
        List<ConnectApi.AdjustItemInputRepresentation> listeAdjustItems = new List<ConnectApi.AdjustItemInputRepresentation>();
        ConnectApi.AdjustItemInputRepresentation AdjustItem = new ConnectApi.AdjustItemInputRepresentation();
        ConnectApi.CreateCreditMemoOutputRepresentation creditMemoOutput = new ConnectApi.CreateCreditMemoOutputRepresentation();
        ConnectApi.CreateCreditMemoOutputRepresentation creditMemoOutputAdjustment  = new ConnectApi.CreateCreditMemoOutputRepresentation();
        Refund ref = new Refund();
        ReturnOrderLineItem roliHandler = new ReturnOrderLineItem();
        ReturnOrder ro = new ReturnOrder();
        if(Discount == true) {
            OrderItemSummary ois = [SELECT Id , Type , Quantity FROM OrderItemSummary WHERE Type <> 'Delivery Charge' and Quantity > 0 and OrderSummaryId =: os.Id LIMIT 1];
            // FulfillmentOrder foWithDiscount = createFO(os);
            // Map<Id,FulfillmentOrder> mapFO = new Map<Id,FulfillmentOrder>();
            // mapFO.put(foWithDiscount.Id,foWithDiscount);
            // Map<Id, Shipment> shipmentMap = createShipments(mapFO);
            // System.debug('debug foWithDiscount'+foWithDiscount);
            AdjustItem.adjustmentType = 'AmountWithoutTax';
            AdjustItem.amount = 50-100;
            AdjustItem.orderItemSummaryId = ois.Id;
            AdjustItem.reason = 'RE01';
            listeAdjustItems.add(AdjustItem);
            adjustOrderInput.adjustItems = listeAdjustItems;
            ConnectApi.AdjustOrderSummaryOutputRepresentation adjustOutput = ConnectApi.Ordersummary.adjustSubmit(os.Id,adjustOrderInput);
            creditMemoInput.changeOrderIds = new List<String>{ adjustOutput.postFulfillmentChangeOrderId };
            creditMemoOutputAdjustment = ConnectApi.OrderSummary.createCreditMemo(os.Id, creditMemoInput);
            OrderPaymentSummary ops = [SELECT Id, PaymentMethodId , CurrencyIsoCode FROM OrderPaymentSummary WHERE OrderSummaryId =: os.Id];
            ref.Amount                  = 50.0;
            ref.CurrencyIsoCode         = ops.CurrencyIsoCode;
            ref.Date                    = System.today();
            ref.EffectiveDate           = System.today();
            ref.OrderPaymentSummaryId   = ops.Id;
            ref.PaymentMethodId         = ops.PaymentMethodId;
            ref.ProcessingMode          = 'External';
            ref.RefundOrigin__c         = SOM_Constants.REFUND_ORIGIN_APPEASEMENT;
            ref.Status                  = 'Draft';
            ref.Type                    = 'Referenced';
            insert ref;
        }
        else {
        ro = createReturnOrder(os);
        ro.Status = 'Received';
        update ro;
        ReturnOrderLineItem roli = [SELECT Id, ReturnOrderId, QuantityReceived, QuantityRejected, RepaymentMethod, FollowUpProcessed__c, OrderItemSummary.TotalAmtWithTax, OrderItemSummary.OrderSummaryId FROM ReturnOrderLineItem 
                                                                WHERE returnOrderId =: ro.Id AND RepaymentMethod = 'Refund' 
                                                                AND FollowUpProcessed__c = false LIMIT 1];
        roliHandler = roli ;

        ConnectApi.ReturnOrderItemInputRepresentation roliInputRep = new ConnectApi.ReturnOrderItemInputRepresentation();
        roliInputRep.returnOrderLineItemId  = roli.Id;
        roliInputRep.quantityReceived       = roli.QuantityReceived;
        roliInputRep.quantityRejected       = roli.QuantityRejected;
        roliInputRep.quantityReturned       = roli.QuantityReceived;
        roliInputRep.quantityToCancel       = roli.QuantityRejected;
        List<ConnectApi.ReturnOrderItemInputRepresentation> CroliInputRep = new List<ConnectApi.ReturnOrderItemInputRepresentation>();
        CroliInputRep.add(roliInputRep); 

        OrderPaymentSummary ops = [SELECT Id, PaymentMethodId FROM OrderPaymentSummary WHERE OrderSummaryId =: ro.OrderSummaryId];
        ref.AccountId               = ro.AccountId;
        ref.Amount                  = roli.OrderItemSummary.TotalAmtWithTax * roli.QuantityReceived;
        ref.CurrencyIsoCode         = ro.CurrencyIsoCode;
        ref.Date                    = System.today();
        ref.EffectiveDate           = System.today();
        ref.OrderPaymentSummaryId   = ops.Id;
        ref.PaymentMethodId         = ops.PaymentMethodId;
        ref.ProcessingMode          = 'External';
        ref.RefundOrigin__c         = 'Return';
        ref.Status                  = 'Draft';
        ref.Type                    = 'Referenced';
        insert ref;
        ro.Already_Refunded__c      = true;
        update ro;
        roli.FollowUpProcessed__c   = true;
        update roli;

        ConnectApi.ReturnItemsInputRepresentation inpRep = new ConnectApi.ReturnItemsInputRepresentation();
        inpRep.returnOrderItems = CroliInputRep;
        
        ConnectApi.ReturnItemsOutputRepresentation outRep = ConnectApi.ReturnOrder.returnItems(ro.Id, inpRep);
        creditMemoInput.changeOrderIds = new List<String>{ outRep.changeOrderId };
        creditMemoOutputAdjustment = ConnectApi.OrderSummary.createCreditMemo(roli.OrderItemSummary.OrderSummaryId, creditMemoInput);
    }
        CreditMemo creditMemo = [SELECT Id, TotalAmountWithTax FROM CreditMemo WHERE Id=: creditMemoOutputAdjustment.creditMemoId];
            // ConnectApi.EnsureRefundsAsyncInputRepresentation refundInput = new ConnectApi.EnsureRefundsAsyncInputRepresentation();
            // refundInput.creditMemoId = creditMemoOutput.creditMemoId;
            // ConnectApi.EnsureRefundsAsyncOutputRepresentation refundOutput = ConnectApi.OrderSummary.ensureRefundsAsync(listOrderItemSummForReturn[1].orderSummaryId, refundInput);
        creditMemo.CreditMemoNumber         = 'CM0003231';
        creditMemo.DocumentNumber__c        = 'CM0003231';   
        creditMemo.PDFGenerationStatus__c   = 'Not Started';
        creditMemo.Refund__c                = ref.Id;
        if(ro != null){
        creditMemo.ReturnOrder__c           = ro.Id;
        }
        update creditMemo;
        List<CreditMemoLine> crl1 = [SELECT ReturnOrderLineItem__c , ChargeAmount , Type FROM CreditMemoLine where CreditMemoId =: creditMemo.Id];
        if(attachedRO == true) {
            List<CreditMemoLine> crl = [SELECT ReturnOrderLineItem__c , ChargeAmount , Type FROM CreditMemoLine where CreditMemoId =: creditMemo.Id];
            for(CreditMemoLine cr : crl){
                if(roliHandler != null) {

                cr.ReturnOrderLineItem__c = roliHandler.Id;
                }
            }
            update crl;
        }
        return ref;
    }
    
    public static OrderDeliveryMethod createOrderDeliveryMethod(String name, String referenceNumber, String DeliveryType) {
		OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod();
		orderDeliveryMethod.Name = name;
		//orderDeliveryMethod.ProductId = productId;
		orderDeliveryMethod.ReferenceNumber = referenceNumber;
		orderDeliveryMethod.IsActive = true;
        orderDeliveryMethod.Delivery_Type__c = DeliveryType;
        Insert orderDeliveryMethod;
		return orderDeliveryMethod;
	}
    
        public static List<OrderSummary> createOrderSummaries(Boolean isPickUpOrder, OrderType typeOfOrders, Integer numberOfOrderToCreate){
        List<Id> listIds = new List<Id>();
        List<Order> listOfOrderToCreate = new List<Order>();
        List<Product2> listProducts = new List<Product2>();
        List<PricebookEntry> listPriceEntries = new List<PricebookEntry>();
        List<Schema.Location> listLocations = new List<Schema.Location>();
        List<Schema.Address> listAddress = new List<Schema.Address>();
        Map<Id, PaymentGroup> listPaymentGrpsByOrderId = new  Map<Id, PaymentGroup>();
        Map<Id, CardPaymentMethod> listCardPayMethodbyOrderId = new  Map<Id, CardPaymentMethod>();
        Map<Id, OrderDeliveryMethod> listOrderDlvryMthdByOrderId = new Map<Id, OrderDeliveryMethod>();
        Map<Id, PaymentAuthorization> listPaymentAuthByOrderId = new Map<Id, PaymentAuthorization>();
        Map<Id, OrderDeliveryGroup> listOrderDlvryGrpByOrderId = new Map<Id, OrderDeliveryGroup>();
        List<OrderItem> listOrderItemsByOrderId = new  List<OrderItem>();

        //Create Account
        Account account = createAccount('test.user@rimowa.com');
        //Create products
        //Order Product 
        Product2 product = createProduct('produit 1', '10012002', 'sku10001',true);
        listProducts.add(product);
        //Shipping Product 
        Product2 product2 = createProduct('Standard delivery', 'ProductCode1','sku10002',false);
        listProducts.add(product2);
        //Order Product 
        Product2 product3 = createProduct('produit 3', '10013003', 'sku10003',false);
        listProducts.add(product3);
        insert listProducts;
        //Get getStandardPricebookId
        Id pricebookId = Test.getStandardPricebookId();
        //Create PriceBookEntries
        PricebookEntry priceentry = createPricebookEntry(79.2, listProducts[0].Id, pricebookId);
        listPriceEntries.add(priceentry);
        PricebookEntry priceentry2 = createPricebookEntry(0, listProducts[1].Id, pricebookId);
        listPriceEntries.add(priceentry2);
        PricebookEntry priceentry3 = createPricebookEntry(255.2, listProducts[2].Id, pricebookId);
        listPriceEntries.add(priceentry3);
        insert listPriceEntries;
        //Create SalesChannel
        SalesChannel saleschannel = createSaleschannel('Rimowa','Rimowa');
        insert saleschannel;
        //Create Locations
        Schema.Location location1 = createLocation('WH_AE','rimowa-inventory-ae', true, 'Warehouse');
        listLocations.add(location1);
        Schema.Location location2 = createLocation('AE01','inventory_1010501', false, 'Store');
        listLocations.add(location2);
        insert listLocations;
        //Create Addresses
        Schema.Address address1 = createAddress(listLocations[0].Id,'Home', SOM_Constants.WAREHOUSE);
        listAddress.add(address1);
        Schema.Address address2 = createAddress(listLocations[1].Id,'Shipping', SOM_Constants.STORE);
        listAddress.add(address2);
        insert listAddress;
        listLocations[0].VisitorAddressId = listAddress[0].Id;
        listLocations[1].VisitorAddressId = listAddress[1].Id;
        update listLocations;
        //Create Orderes
        for(Integer i=1; i<=numberOfOrderToCreate; i++){
            Order order = createOrder(account.Id,'Order101'+i,saleschannel.Id,'Order101'+i ,pricebookId, true, false);
            listOfOrderToCreate.add(order);
        }
        insert listOfOrderToCreate;

        for(Order createdOrder : listOfOrderToCreate){
            //Create PaymentGroup
            PaymentGroup paymentgrp = createPaymentGroup(createdOrder.Id);
            listPaymentGrpsByOrderId.put(createdOrder.Id, paymentgrp);
            //Create CardPaymentMethod
            CardPaymentMethod cardPayMethod = createCardPaymentMethod(account.Id, 'CreditCard', 'Visa');
            listCardPayMethodbyOrderId.put(createdOrder.Id, cardPayMethod);
            //Create OrderDeliveryMethod
            OrderDeliveryMethod oDeliveryMethod = createOrderDeliveryMethod('standard_AE',listProducts[1].Id,'standard_AE');
            listOrderDlvryMthdByOrderId.put(createdOrder.Id, oDeliveryMethod);
        }
        insert listPaymentGrpsByOrderId.values();
        insert listCardPayMethodbyOrderId.values();
        insert listOrderDlvryMthdByOrderId.values();
        Id locationId = isPickUpOrder ? listLocations[1].Id : listLocations[0].Id;
        //prepare flags for products
        List<Boolean> listProductFlags;
        if(typeOfOrders == OrderType.STANDARD){
            listProductFlags = new List<Boolean>{false, false};
        }
        if(typeOfOrders == OrderType.MIXTE){
            listProductFlags = new List<Boolean>{true, false};
        }
        if(typeOfOrders == OrderType.PREORDER){
            listProductFlags = new List<Boolean>{true, true};
        }
        for(Order createdOrder : listOfOrderToCreate){
            
            PaymentAuthorization paymentAuth = createPaymentAuthorization(account.Id, 1000, listPaymentGrpsByOrderId.get(createdOrder.Id).Id, listCardPayMethodbyOrderId.get(createdOrder.Id).Id, 'DFEB7B92BF462697E053AF598E0A4E9C');
            listPaymentAuthByOrderId.put(createdOrder.Id, paymentAuth);
            OrderDeliveryGroup oDG = createOrderDeliveryGroup(createdOrder.Id,listOrderDlvryMthdByOrderId.get(createdOrder.Id).Id);
            listOrderDlvryGrpByOrderId.put(createdOrder.Id, oDG);
        }
        insert listPaymentAuthByOrderId.values();
        insert listOrderDlvryGrpByOrderId.values();

        for(Order createdOrder : listOfOrderToCreate){
            OrderItem orderItem1 = createOrderItem(listProducts[0].Id, createdOrder.Id, 1, 79.2,79.2, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.ORDER_PRODUCT, listPriceEntries[0].Id, locationId, true,listProductFlags[0],listProductFlags[0]? System.now().addDays(30):null);
            listOrderItemsByOrderId.add(orderItem1);
            OrderItem orderItem2 = createOrderItem(listProducts[1].Id, createdOrder.Id, 1, 0, 0, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.DELIVERY_CHARGE, listPriceEntries[1].Id, locationId, false,false,null);
            listOrderItemsByOrderId.add(orderItem2);
            OrderItem orderItem3 = createOrderItem(listProducts[2].Id, createdOrder.Id, 2, 255.2, 255.2, listOrderDlvryGrpByOrderId.get(createdOrder.Id).Id, SOM_Constants.ORDER_PRODUCT,listPriceEntries[2].Id, locationId, false,listProductFlags[1],listProductFlags[0]? System.now().addDays(30):null);
            listOrderItemsByOrderId.add(orderItem3);
            
            //Change Order Status
            createdOrder.Status = SOM_Constants.ACTIVATED; 
        }
    
        insert listOrderItemsByOrderId;
        List<OrderItemTaxLineItem> ListeOITLI = new List<OrderItemTaxLineItem>(); 
        OrderItemTaxLineItem OITLI1 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[0].Id);
        ListeOITLI.add(OITLI1);
        OrderItemTaxLineItem OITLI2 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[1].Id);
        ListeOITLI.add(OITLI2);
        OrderItemTaxLineItem OITLI3 = new OrderItemTaxLineItem(Name = '97352004 - Tax',Type	= 'Estimated',Amount=20,Rate=20.0,TaxEffectiveDate=Date.today(),CreatedDate=System.now(),	OrderItemId = listOrderItemsByOrderId[2].Id);
        ListeOITLI.add(OITLI3);
        insert ListeOITLI;

        //Activate Orders
        update listOfOrderToCreate;
        List<OrderSummary> orderSummaries = getListOrderSummaryByOrder(listOfOrderToCreate);
        Set<Id> osIds = (new Map<Id,OrderSummary>(orderSummaries)).keySet();

        for(OrderSummary os : orderSummaries){
        }
        return orderSummaries;    
       
    }

 
}
