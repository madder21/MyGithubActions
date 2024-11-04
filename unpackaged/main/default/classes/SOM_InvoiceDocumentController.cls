global with sharing class SOM_InvoiceDocumentController {
    
    public static final String   CONCAT_CHARACTER = ',';
    public Map<String, String>   invoiceConfigs { get; set; }
    public InvoiceDocument       invoiceDoc { get; set;}
    public Map<String,String>    invoiceTaxLineItems {get; set; }
    public Map<String,String>    countryMap {get;set;}
    public String                correctiveInvoiceHeaderMessage {get; set; }
    public String                AmountsFormat {get; set; }
    public InvoiceAddress        invoiceAddress { get; set;}
    
    
    public SOM_InvoiceDocumentController() {
        this.countryMap = SOM_Utils.getCountryKeyValueMap(SOM_Constants.ORDER_SUMMARY_NAME, SOM_Constants.ORDER_SUMMARY_COUNTRY_FIELD_NAME);
        this.setInvoiceDocumentConfigs();
        this.setInvoiceData(); 
    }
    
    public void setInvoiceDocumentConfigs(){
        this.invoiceConfigs = new Map<String,String>();
        String templateCode = ApexPages.currentPage().getParameters().get('template');
        List<SOM_Invoice_Setting__mdt> invoiceSettings = [SELECT MasterLabel, Value__c, Template__c FROM SOM_Invoice_Setting__mdt WHERE Template__c = :templateCode OR Template__c = :'CoreModel'];
        for (SOM_Invoice_Setting__mdt invoiceSetting : invoiceSettings) {
            if(!invoiceConfigs.containsKey(invoiceSetting.MasterLabel) || invoiceSetting.Template__c != 'CoreModel'){
                if (invoiceSetting.Value__c == null) {
                    invoiceConfigs.put(invoiceSetting.MasterLabel, '');
                } else {
                    invoiceConfigs.put(invoiceSetting.MasterLabel, invoiceSetting.Value__c);
                }
            }
        }
    }
    
    public void setInvoiceData(){
        String templateCode = ApexPages.currentPage().getParameters().get('template');
        InvoiceDocument invDoc        = new InvoiceDocument();
        InvoiceAddress invAddress     = new InvoiceAddress();
        InvoiceContact invCtr         = new InvoiceContact();
        CorrectiveInvoice__c cInvoice = null;
        Id invoiceId = ApexPages.currentPage().getParameters().get('invoiceId');
        Boolean isCorrectiveInvoice = invoiceId.getSObjectType().getDescribe().getName() == SOM_Constants.CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME;
        String REPLACEMENT = invoiceConfigs.get('REPLACEMENT');
        if(isCorrectiveInvoice){
            cInvoice = [SELECT Id, Name,OriginalInvoiceId__c, PreviousCorrectiveInvoice__r.Name, CreatedDate, Corrective_Invoice_Date__c FROM CorrectiveInvoice__c WHERE Id = :invoiceId];
            Invoice originalInvoice = [SELECT Id, InvoiceNumber__c FROM Invoice WHERE Id = :cInvoice.OriginalInvoiceId__c];
            String previousInv      = String.isEmpty(cInvoice.PreviousCorrectiveInvoice__r.Name) ? originalInvoice.InvoiceNumber__c : cInvoice.PreviousCorrectiveInvoice__r.Name;
            if(REPLACEMENT != null && REPLACEMENT != ''){
                this.correctiveInvoiceHeaderMessage =  previousInv;
            }
            invoiceId = originalInvoice.Id;        
        }
        
        List<FulfillmentOrder> fulfillmentOrder = [SELECT Invoice.TotalAmount, Invoice.TotalAmountWithTax, Invoice.TotalTaxAmount, Invoice.InvoiceDate, Invoice.Invoice_Timezone_Date__c, Invoice.InvoiceNumber__c, Invoice.DocumentNumber, OrderSummary.Account.Name, OrderSummary.OrderNumber, 
                                                   FulfilledToName, StreetNumber__c, FulfilledToCity, FulfilledToPostalCode, FulfilledToStreet, FulfilledToState, FulfilledToCountry, OrderSummary.BillingCity,OrderSummary.BillingState, OrderSummary.BillingPostalCode, OrderSummary.BillingContactFirstName__c , OrderSummary.BillingContactLastName__c,
                                                   OrderSummary.BillingStreet, OrderSummary.BillingCountry, OrderSummaryId, OrderSummary.Legal_Entity__c, OrderSummary.VAT_ID__c, CurrencyIsoCode, OrderSummary.language__c,OrderSummary.StreetNumber__c,OrderSummary.Complementary__c, (SELECT id, TrackingNumber FROM FulfillmentOrderShipments) FROM FulfillmentOrder WHERE InvoiceId= :invoiceId];
        List<InvoiceLine> invoiceLines = [SELECT Id, Type, TaxRate,TaxAmount, Product2.Description, Quantity, UnitPrice, GrossUnitPrice, ChargeAmountWithTax, ChargeTaxAmount, TYPEOF ReferenceEntityItem WHEN OrderItemSummary THEN hsCode__c,hsCodeDescription__c,COO__c, Description, LineNumber END FROM InvoiceLine WHERE InvoiceId = :invoiceId];
        
        System.debug('fulfillmentOrder.get(0).OrderSummary.Legal_Entity__c ' + fulfillmentOrder.get(0).OrderSummary.VAT_ID__c);
                
        invAddress = setInvoiceAddress (fulfillmentOrder.get(0).OrderSummary.Legal_Entity__c);
        invAddress.VATID = fulfillmentOrder.get(0).OrderSummary.VAT_ID__c;
        
        invDoc.invoiceDate    = isCorrectiveInvoice ? DateTime.newInstance(cInvoice.Corrective_Invoice_Date__c.year(), cInvoice.Corrective_Invoice_Date__c.month(), cInvoice.Corrective_Invoice_Date__c.day()).format('yyyy-MM-dd') : DateTime.newInstance(fulfillmentOrder.get(0).Invoice.Invoice_Timezone_Date__c.year(), fulfillmentOrder.get(0).Invoice.Invoice_Timezone_Date__c.month(), fulfillmentOrder.get(0).Invoice.Invoice_Timezone_Date__c.day()).format('yyyy-MM-dd');
        invDoc.documentNumber = isCorrectiveInvoice ? cInvoice.Name : fulfillmentOrder.get(0).Invoice.InvoiceNumber__c;
        invDoc.Template 	  = templateCode;
        
        if (fulfillmentOrder != null && !fulfillmentOrder.isEmpty()) {
            //AmountsFormat info
            this.AmountsFormat  = setAmountsFormat(fulfillmentOrder.get(0).FulfilledToCountry);
            
            //invoice info
            invDoc.orderNumber    = fulfillmentOrder.get(0).OrderSummary.orderNumber;
            
            if(templateCode == 'JP'){
                invDoc.totalWithTax   = setAmountsJPFormat(SOM_Utils.getTotalFormatted(fulfillmentOrder.get(0).Invoice.TotalAmountWithTax,AmountsFormat));
                invDoc.netSubTotal    = setAmountsJPFormat(SOM_Utils.getTotalFormatted(fulfillmentOrder.get(0).Invoice.TotalAmount,AmountsFormat));
            }else{
                invDoc.totalWithTax   = SOM_Utils.getTotalFormatted(fulfillmentOrder.get(0).Invoice.TotalAmountWithTax,AmountsFormat);
                invDoc.netSubTotal    = SOM_Utils.getTotalFormatted(fulfillmentOrder.get(0).Invoice.TotalAmount,AmountsFormat);
            }
            
            invDoc.currencyCode   = fulfillmentOrder.get(0).CurrencyIsoCode;
            //Invoice lines
            if (invoiceLines != null && !invoiceLines.isEmpty()) {
                invDoc.lineItems = this.getInvoiceLines(invoiceLines, this.getSerialNumbers(FulfillmentOrder),templateCode);
                this.invoiceTaxLineItems = new Map<String, String>();
                this.invoiceTaxLineItems = this.getInvoiceTaxLineItems(invoiceLines, templateCode);
                
            }
            invDoc.paymentType     = this.getPaymentMethod(fulfillmentOrder.get(0));
            invDoc.billingContact  = this.getBillingContact(fulfillmentOrder.get(0));
            invDoc.deliveryContact = this.getDeliveryContact(fulfillmentOrder.get(0));
            invDoc.trackingNumbers = this.getTrackingNumbers(FulfillmentOrder);
            invDoc.TaxID 		   = this.getOrderDeliveryGroupSummary(fulfillmentOrder.get(0).OrderSummaryId);
        } else {
            System.debug('FulfillmentOrder is empty, InvoiceId: ' + invoiceId);
        }
        
        this.invoiceDoc = invDoc;
        this.invoiceAddress = invAddress;
    }
    
    
    
    public Map<Id, List<String>> getSerialNumbers(List<FulfillmentOrder> fulfillmentOrders){
        //construct shipment ids
        List<Id> shipmentIds = new List<Id>();
        for (FulfillmentOrder fulOrder:fulfillmentOrders) {
            List<Shipment> shipments = fulOrder.FulfillmentOrderShipments;
            if (shipments != null) {
                for (Shipment ship:shipments) {
                    shipmentIds.add(ship.Id);
                }
            }
        }
        
        //construct serial numbers map
        Map<Id, List<String>> serialNumbersMap = new Map<Id, List<String>>();
        List<ShipmentItem> shipmentItems = [SELECT Id, OrderItemSummaryId, SerialNumber__c FROM ShipmentItem WHERE ShipmentId IN :shipmentIds];
        for (ShipmentItem shipItem:shipmentItems) {
            List<String> serialNumbers = serialNumbersMap.get(shipItem.OrderItemSummaryId);
            if (serialNumbers == null) {
                serialNumbers = new List<String>();
            }
            if(shipItem.SerialNumber__c != null) {
                serialNumbers.add(shipItem.SerialNumber__c);
            }
            serialNumbersMap.put(shipItem.OrderItemSummaryId, serialNumbers);
        }
        
        return serialNumbersMap;
    }
    
    public String getTrackingNumbers(List<FulfillmentOrder> fulfillmentOrders){
        //shipment tracking numbers ==> One Invoice for all FOs
        Set<String> settrackingNumbers = new Set<String>();
        for (FulfillmentOrder fulOrder:fulfillmentOrders) {
            List<Shipment> shipments = fulOrder.FulfillmentOrderShipments;
            if (shipments != null) {
                for (Shipment ship:shipments) {
                    settrackingNumbers.add(ship.TrackingNumber);
                }
            }
        }
        
        return String.join(new List<String>(settrackingNumbers), CONCAT_CHARACTER);
    }
    
    public InvoiceContact getDeliveryContact(FulfillmentOrder fulfillmentOrder){
        InvoiceContact delivContact = new InvoiceContact();
		String Country = countryMap.containsKey(fulfillmentOrder.FulfilledToCountry) ? countryMap.get(fulfillmentOrder.FulfilledToCountry) : fulfillmentOrder.FulfilledToCountry;
        delivContact.name    = fulfillmentOrder.FulfilledToName;
        delivContact.city    = fulfillmentOrder.FulfilledToCity;
        delivContact.zipCode = fulfillmentOrder.FulfilledToPostalCode;
        if (Country == 'Brazil' && !String.IsBlank(fulfillmentOrder.StreetNumber__c) ){
        	delivContact.address = fulfillmentOrder.FulfilledToStreet + ', ' + fulfillmentOrder.StreetNumber__c ;
        }else{
           delivContact.address = fulfillmentOrder.FulfilledToStreet; 
        }
        delivContact.state   = fulfillmentOrder.FulfilledToState;
        delivContact.country = Country; 
        
        return delivContact;
    }
    
    public InvoiceContact getBillingContact(FulfillmentOrder fulfillmentOrder){
        InvoiceContact billContact = new InvoiceContact();
        String Country = countryMap.containsKey(fulfillmentOrder.OrderSummary.BillingCountry)? countryMap.get(fulfillmentOrder.OrderSummary.BillingCountry) : fulfillmentOrder.OrderSummary.BillingCountry;
        billContact.name    = fulfillmentOrder.OrderSummary.BillingContactFirstName__c + ' ' + fulfillmentOrder.OrderSummary.BillingContactLastName__c;
        billContact.city    = fulfillmentOrder.OrderSummary.BillingCity;
        billContact.zipCode = fulfillmentOrder.OrderSummary.BillingPostalCode;
        if (Country == 'Brazil' && !String.IsBlank(fulfillmentOrder.OrderSummary.StreetNumber__c) && !String.IsBlank(fulfillmentOrder.OrderSummary.Complementary__c)){
        	billContact.address = fulfillmentOrder.OrderSummary.BillingStreet + ', ' + fulfillmentOrder.OrderSummary.StreetNumber__c + ' - ' + fulfillmentOrder.OrderSummary.Complementary__c;
        }else if(Country == 'Brazil' && String.IsBlank(fulfillmentOrder.OrderSummary.StreetNumber__c) && !String.IsBlank(fulfillmentOrder.OrderSummary.Complementary__c)){
        	billContact.address = fulfillmentOrder.OrderSummary.BillingStreet + ' - ' + fulfillmentOrder.OrderSummary.Complementary__c;
        }else if(Country == 'Brazil' && !String.IsBlank(fulfillmentOrder.OrderSummary.StreetNumber__c) && String.IsBlank(fulfillmentOrder.OrderSummary.Complementary__c)){
        	billContact.address = fulfillmentOrder.OrderSummary.BillingStreet + ', ' + fulfillmentOrder.OrderSummary.StreetNumber__c;
        }else{
           billContact.address = fulfillmentOrder.OrderSummary.BillingStreet; 
        }
        billContact.state   = fulfillmentOrder.OrderSummary.BillingState;
        billContact.country = Country;
        this.AmountsFormat  = setAmountsFormat(fulfillmentOrder.FulfilledToCountry);
        
        return billContact;
    }
    
    public List<InvoiceLineItem> getInvoiceLines(List<InvoiceLine> invoiceLines, Map<Id, List<String>> serialNumbersMap, String templateCode){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        for(InvoiceLine invoiceLine:invoiceLines) {
            if (invoiceLine.Type.equalsIgnoreCase(SOM_Constants.INVOICE_LINE_TYPE_CHARGE) && invoiceLine.Quantity>0) {
                InvoiceLineItem lineItem = new InvoiceLineItem();
                lineItem.itemDescription = invoiceLine.Product2.Description;
                lineItem.quantity        = invoiceLine.Quantity;
                if(templateCode == 'JP'){
                    lineItem.netAmount       = setAmountsJPFormat(SOM_Utils.getTotalFormatted(invoiceLine.UnitPrice,AmountsFormat));
                    lineItem.vat             = setAmountsJPFormat(SOM_Utils.getTotalFormatted(invoiceLine.ChargeTaxAmount,AmountsFormat));
                    lineItem.grossAmount     = setAmountsJPFormat(SOM_Utils.getTotalFormatted(invoiceLine.GrossUnitPrice,AmountsFormat));
                    lineItem.total           = setAmountsJPFormat(SOM_Utils.getTotalFormatted(invoiceLine.ChargeAmountWithTax,AmountsFormat));
                }else{
                    lineItem.netAmount       = SOM_Utils.getTotalFormatted(invoiceLine.UnitPrice,AmountsFormat);
                    lineItem.vat             = SOM_Utils.getTotalFormatted(invoiceLine.ChargeTaxAmount,AmountsFormat);
                    lineItem.grossAmount     = SOM_Utils.getTotalFormatted(invoiceLine.GrossUnitPrice,AmountsFormat);
                    lineItem.total           = SOM_Utils.getTotalFormatted(invoiceLine.ChargeAmountWithTax,AmountsFormat);
                }
                if (invoiceLine.ReferenceEntityItem instanceOf OrderItemSummary) {
                    OrderItemSummary orderItem = invoiceLine.ReferenceEntityItem;
                    lineItem.hsCode            = orderItem.hsCode__c;
                    lineItem.hsCodeDescription = orderItem.hsCodeDescription__c;
                    lineItem.coo               = orderItem.COO__c;
                    lineItem.itemDescription   = orderItem.Description;
                    List<String> serialNumbers = serialNumbersMap.get(orderItem.Id);
                    if (serialNumbers != null) {
                        lineItem.serialNumber = String.join(serialNumbers, CONCAT_CHARACTER);
                    }
                    lineItem.lineNumber        = orderItem.LineNumber;
                }
                lineItems.add(lineItem);
            }
        }
        //sort
        lineItems.sort();
        Integer counter = 1;
        for(InvoiceLineItem single : lineItems){
            single.itemNumber = counter;
            counter++;
        }
        return lineItems;
    }
    
    public String getPaymentMethod(FulfillmentOrder fulfillmentOrder){
        //Get order payment summary
        List<OrderPaymentSummary> paymentSummary = [SELECT Type, PaymentMethodId, PaymentMethod.ImplementorType FROM OrderPaymentSummary WHERE OrderSummaryId = :fulfillmentOrder.OrderSummaryId];
        if (paymentSummary != null && !paymentSummary.isEmpty()) {
            List<Payment_Methods_Mapping__mdt> paymentMethodsMapping = [SELECT Id, Value__c, Translation__c, Is_Card_Payment_Method__c FROM Payment_Methods_Mapping__mdt WHERE Value__c = :paymentSummary.get(0).Type AND Language__c = :fulfillmentOrder.OrderSummary.language__c];
            if (paymentMethodsMapping != null && !paymentMethodsMapping.isEmpty()) {
                return paymentMethodsMapping.get(0).Translation__c;
            } else {
                return paymentSummary.get(0).Type;
            }
        }
        
        return '';
    }
    
    public String getOrderDeliveryGroupSummary(String OrderSumId){
        List<OrderDeliveryGroupSummary> OrderDeliveryGroupSum = [SELECT RI_TAX_ID__c FROM OrderDeliveryGroupSummary WHERE OrderSummaryId = :OrderSumId];
        if (OrderDeliveryGroupSum != null && !OrderDeliveryGroupSum.isEmpty()) {
            return OrderDeliveryGroupSum.get(0).RI_TAX_ID__c;
        }        
        return '';
    }
    
    
    public Map<String,String> getInvoiceTaxLineItems(List<InvoiceLine> lineItems, String templateCode){
        Map<Decimal, Decimal> invoiceTaxes       = new Map<Decimal, Decimal>();
        Map<String, String> invoiceTaxesSorted = new Map<String, String>();
        
        for (InvoiceLine lineItem:lineItems) {
            if (lineItem.Type.equalsIgnoreCase(SOM_Constants.INVOICE_LINE_TYPE_TAX)) {
                if (invoiceTaxes.containsKey(lineItem.TaxRate)) {
                    invoiceTaxes.put(lineItem.TaxRate,invoiceTaxes.get(lineItem.TaxRate)+lineItem.TaxAmount);
                } else {
                    invoiceTaxes.put(lineItem.TaxRate, lineItem.TaxAmount);
                }
                
            }
        } 
        
        List<Decimal> sortedTaxes = new List<Decimal>();
        sortedTaxes.addAll(invoiceTaxes.keySet());
        sortedTaxes.sort();
        if (templateCode == 'JP'){
            for(Decimal dec: sortedTaxes){
                invoiceTaxesSorted.put(setAmountsJPFormat(String.valueOf(dec)),setAmountsJPFormat(SOM_Utils.getTotalFormatted(invoiceTaxes.get(dec),AmountsFormat)));
            }
        }else{
            for(Decimal dec: sortedTaxes){
                invoiceTaxesSorted.put(String.valueOf(dec),(SOM_Utils.getTotalFormatted(invoiceTaxes.get(dec),AmountsFormat)));
            }
        }
        return invoiceTaxesSorted;
    }
    
    
    public String setAmountsFormat(String CountryIso) {
        Sales_Channel_Mapping__mdt AmountsFormat = [SELECT AmountsFormat__c FROM Sales_Channel_Mapping__mdt WHERE  Zone__c =: CountryIso];
        return AmountsFormat.AmountsFormat__c;
    } 
    
    public InvoiceAddress setInvoiceAddress(String Code) {
        InvoiceAddress invAddress     = new InvoiceAddress();
        Legal_Entity__c LegalEntity = [SELECT Id, Country__c, Code__c, Name, Address__c, City__c, ZipCode__c, CountryLabel__c,FooterBilling__c FROM Legal_Entity__c WHERE Code__c = :Code limit 1];
        invAddress.name = LegalEntity.Name; 
        invAddress.address = LegalEntity.Address__c ; 
        invAddress.countryLabel = LegalEntity.CountryLabel__c; 
        invAddress.FooterBilling = LegalEntity.FooterBilling__c; 
        return invAddress;
    } 
    
    public String setAmountsJPFormat(String Amount) {
		String AmountJP =  Amount.Substring(0,Amount.length()-3);
        return AmountJP;
    } 

    
    
    global with sharing class InvoiceDocument{
        public String                documentNumber {get; set;} //Invoice: DocumentNumber
        public String                invoiceDate {get; set;} //Invoice : InvoiceDate
        public String                orderNumber {get; set;} //OrderSummary : OrderNumber
        public String                currencyCode {get; set;} //FO : currency
        public InvoiceContact        billingContact {get; set;}
        public InvoiceContact        deliveryContact {get; set;}
        public String                trackingNumbers {get; set;}
        public List<InvoiceLineItem> lineItems {get; set;}
        public String                netSubTotal {get; set;}
        public String                totalWithTax {get; set;}
        public String                paymentType {get; set;}
        public String                Template {get; set;} 
        public String                TaxID {get; set;} 
        public String 				 CROSS_BORDER { get; set; }
    }
    
    
    
    global with sharing class InvoiceAddress{
        public String                name {get; set;} //Invoice: DocumentNumber
        public String                address {get; set;} //Invoice : InvoiceDate
        public String                countryLabel {get; set;} //OrderSummary : OrderNumber
        public String                VATID {get; set;} //FO : currency
        public String                FooterBilling {get; set;}
    }
    
    global with sharing class InvoiceContact{
        public String name {get; set;}
        public String company {get; set;} //mapping of the field??
        public String zipCode {get; set;}
        public String city {get; set;}
        public String address {get; set;}
        public String state {get; set;}
        public String country {get; set;}
    }
    
    //  implements Comparable
    global with sharing class InvoiceLineItem implements Comparable {
        public String  itemDescription {get; set;} //Product2 : description
        public Integer itemNumber {get; set;}//
        public String  serialNumber {get; set;} //serialnumber on shipping object
        public String  hsCode {get; set;} //custom field orderItemSummary
        public String  hsCodeDescription {get; set;}
        public String  coo {get; set;}
        public Decimal quantity {get; set;} //InvoiceLine : Quantity
        public String  netAmount {get; set;} //InvoiceLine : UnitPrice
        public String  vat {get; set;} //InvoiceLine: ChargeTaxAmount
        public String  grossAmount {get; set;} //invoiceLine : TotalAmountWithTax /Quantity
        public String  total {get; set;} //invoiceLine : TotalAmountWithTax
        //add number LineNumber
        public Integer lineNumber {get; set;}
        
        // compareTo method
        public Integer compareTo(Object compareTo) {
            // Cast argument to InvoiceLineItem
            InvoiceLineItem compareToOppy = (InvoiceLineItem)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if ((this.LineNumber == null) && (compareToOppy.LineNumber == null)) {
                // both objects have null LineNumber
                returnValue = 0;
            } else if ((this.LineNumber == null) && (compareToOppy.LineNumber != null)){
                // nulls-first implementation
                returnValue = -1;
            } else if ((this.LineNumber != null) && (compareToOppy.LineNumber == null)){
                // nulls-first implementation
                returnValue = 1;
            } else if (this.LineNumber > compareToOppy.LineNumber) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (this.LineNumber < compareToOppy.LineNumber) {
                // Set return value to a negative value.
                returnValue = -1;
            } 
            return returnValue;
        }
        
        
    }
}