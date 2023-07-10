global with sharing class SOM_InvoiceDocumentController {
    
    public static final String   CONCAT_CHARACTER = ',';
    public Map<String, String>   invoiceConfigs { get; set; }
    public InvoiceDocument       invoiceDoc { get; set;}
    public Map<Decimal,Decimal>    invoiceTaxLineItems {get; set; }
    public Map<String,String>    countryMap {get;set;}
    public String                correctiveInvoiceHeaderMessage {get; set; }
    public String                AmountsFormat {get; set; }
    

    public SOM_InvoiceDocumentController() {
        System.debug('start++');
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
        InvoiceDocument invDoc        = new InvoiceDocument();
        InvoiceContact invCtr         = new InvoiceContact();
        CorrectiveInvoice__c cInvoice = null;
        Id invoiceId = ApexPages.currentPage().getParameters().get('invoiceId');
        Boolean isCorrectiveInvoice = invoiceId.getSObjectType().getDescribe().getName() == SOM_Constants.CORRECTIVE_INVOICE_SOBJECT_TYPE_NAME;
        if(isCorrectiveInvoice){
            cInvoice = [SELECT Id, Name,OriginalInvoiceId__c, PreviousCorrectiveInvoice__r.Name, CreatedDate, Corrective_Invoice_Date__c FROM CorrectiveInvoice__c WHERE Id = :invoiceId];
            System.debug('test invoice ++'+cInvoice);
            Invoice originalInvoice = [SELECT Id, InvoiceNumber__c FROM Invoice WHERE Id = :cInvoice.OriginalInvoiceId__c];
            String previousInv      = String.isEmpty(cInvoice.PreviousCorrectiveInvoice__r.Name) ? originalInvoice.InvoiceNumber__c : cInvoice.PreviousCorrectiveInvoice__r.Name;
            this.correctiveInvoiceHeaderMessage = 'This invoice cancels and replaces invoice ' + previousInv;
            invoiceId = originalInvoice.Id;        
        }
        
        List<FulfillmentOrder> fulfillmentOrder = [SELECT Invoice.TotalAmount, Invoice.TotalAmountWithTax, Invoice.TotalTaxAmount, Invoice.InvoiceDate, Invoice.Invoice_Timezone_Date__c, Invoice.InvoiceNumber__c, Invoice.DocumentNumber, OrderSummary.Account.Name, OrderSummary.OrderNumber, 
        FulfilledToName, FulfilledToCity, FulfilledToPostalCode, FulfilledToStreet, FulfilledToState, FulfilledToCountry, OrderSummary.BillingCity,OrderSummary.BillingState, OrderSummary.BillingPostalCode, OrderSummary.BillingContactFirstName__c , OrderSummary.BillingContactLastName__c,
        OrderSummary.BillingStreet, OrderSummary.BillingCountry, OrderSummaryId, CurrencyIsoCode, OrderSummary.language__c, (SELECT id, TrackingNumber FROM FulfillmentOrderShipments) FROM FulfillmentOrder WHERE InvoiceId= :invoiceId];
        List<InvoiceLine> invoiceLines = [SELECT Id, Type, TaxRate,TaxAmount, Product2.Description, Quantity, UnitPrice, GrossUnitPrice, ChargeAmountWithTax, ChargeTaxAmount, TYPEOF ReferenceEntityItem WHEN OrderItemSummary THEN hsCode__c,hsCodeDescription__c,COO__c, Description, LineNumber END FROM InvoiceLine WHERE InvoiceId = :invoiceId];
        
        invDoc.invoiceDate    = isCorrectiveInvoice ? DateTime.newInstance(cInvoice.Corrective_Invoice_Date__c.year(), cInvoice.Corrective_Invoice_Date__c.month(), cInvoice.Corrective_Invoice_Date__c.day()).format('yyyy-MM-dd') : DateTime.newInstance(fulfillmentOrder.get(0).Invoice.Invoice_Timezone_Date__c.year(), fulfillmentOrder.get(0).Invoice.Invoice_Timezone_Date__c.month(), fulfillmentOrder.get(0).Invoice.Invoice_Timezone_Date__c.day()).format('yyyy-MM-dd');
        invDoc.documentNumber = isCorrectiveInvoice ? cInvoice.Name : fulfillmentOrder.get(0).Invoice.InvoiceNumber__c;
        
        if (fulfillmentOrder != null && !fulfillmentOrder.isEmpty()) {
            //invoice info
            invDoc.orderNumber    = fulfillmentOrder.get(0).OrderSummary.orderNumber;
           //invDoc.taxTotal       = getTotalFormatted(fulfillmentOrder.get(0).Invoice.TotalTaxAmount);
            invDoc.totalWithTax   = (fulfillmentOrder.get(0).Invoice.TotalAmountWithTax);
            invDoc.netSubTotal    = (fulfillmentOrder.get(0).Invoice.TotalAmount);
            invDoc.currencyCode   = fulfillmentOrder.get(0).CurrencyIsoCode;
            //Invoice lines
            if (invoiceLines != null && !invoiceLines.isEmpty()) {
                invDoc.lineItems = this.getInvoiceLines(invoiceLines, this.getSerialNumbers(FulfillmentOrder));
                this.invoiceTaxLineItems = new Map<Decimal, Decimal>();
                this.invoiceTaxLineItems = this.getInvoiceTaxLineItems(invoiceLines);

            }
            invDoc.paymentType     = this.getPaymentMethod(fulfillmentOrder.get(0));
            invDoc.billingContact  = this.getBillingContact(fulfillmentOrder.get(0));
            invDoc.deliveryContact = this.getDeliveryContact(fulfillmentOrder.get(0));
            invDoc.trackingNumbers = this.getTrackingNumbers(FulfillmentOrder);
        } else {
            System.debug('FulfillmentOrder is empty, InvoiceId: ' + invoiceId);
        }

        this.invoiceDoc = invDoc;
    }

    public String getTotalFormatted(Decimal taxTotal){
        if (taxTotal == null) return '0,00';
        if (taxTotal.scale() > 2) {
            return formatDecimalNumber(taxTotal.setScale(2, RoundingMode.HALF_UP));
        }

        return formatDecimalNumber(taxTotal);
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
        delivContact.name    = fulfillmentOrder.FulfilledToName;
        delivContact.city    = fulfillmentOrder.FulfilledToCity;
        delivContact.zipCode = fulfillmentOrder.FulfilledToPostalCode;
        delivContact.address = fulfillmentOrder.FulfilledToStreet;
        delivContact.state   = fulfillmentOrder.FulfilledToState;
        delivContact.country = countryMap.containsKey(fulfillmentOrder.FulfilledToCountry) ? countryMap.get(fulfillmentOrder.FulfilledToCountry) : fulfillmentOrder.FulfilledToCountry;
       
        return delivContact;
    }

    public InvoiceContact getBillingContact(FulfillmentOrder fulfillmentOrder){
        InvoiceContact billContact = new InvoiceContact();
        billContact.name    = fulfillmentOrder.OrderSummary.BillingContactFirstName__c + ' ' + fulfillmentOrder.OrderSummary.BillingContactLastName__c;
        billContact.city    = fulfillmentOrder.OrderSummary.BillingCity;
        billContact.zipCode = fulfillmentOrder.OrderSummary.BillingPostalCode;
        billContact.address = fulfillmentOrder.OrderSummary.BillingStreet;
        billContact.state   = fulfillmentOrder.OrderSummary.BillingState;
        billContact.country = countryMap.containsKey(fulfillmentOrder.OrderSummary.BillingCountry)? countryMap.get(fulfillmentOrder.OrderSummary.BillingCountry) : fulfillmentOrder.OrderSummary.BillingCountry;
        this.AmountsFormat  = setAmountsFormat(fulfillmentOrder.FulfilledToCountry);
        System.debug('billContact.country' + AmountsFormat);

        return billContact;
    }

    public List<InvoiceLineItem> getInvoiceLines(List<InvoiceLine> invoiceLines, Map<Id, List<String>> serialNumbersMap){
        List<InvoiceLineItem> lineItems = new List<InvoiceLineItem>();
        for(InvoiceLine invoiceLine:invoiceLines) {
            if (invoiceLine.Type.equalsIgnoreCase(SOM_Constants.INVOICE_LINE_TYPE_CHARGE) && invoiceLine.Quantity>0) {
                InvoiceLineItem lineItem = new InvoiceLineItem();
                //lineItem.itemDescription = invoiceLine.Product2.Description;
                lineItem.quantity        = invoiceLine.Quantity;
                //lineItem.netAmount       = getTotalFormatted(invoiceLine.UnitPrice);
                lineItem.netAmount       = (invoiceLine.UnitPrice);
                lineItem.vat             = (invoiceLine.ChargeTaxAmount);
                lineItem.grossAmount     = (invoiceLine.GrossUnitPrice);
                lineItem.total           = (invoiceLine.ChargeAmountWithTax);
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

    public Map<Decimal,Decimal> getInvoiceTaxLineItems(List<InvoiceLine> lineItems){
        Map<Decimal, Decimal> invoiceTaxes       = new Map<Decimal, Decimal>();
        Map<Decimal, Decimal> invoiceTaxesSorted = new Map<Decimal, Decimal>();

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
        for(Decimal dec: sortedTaxes){
            invoiceTaxesSorted.put((dec),(invoiceTaxes.get(dec)));
        }
    
        return invoiceTaxesSorted;
    }

    public String formatDecimalNumber(Decimal price){
        return String.valueOf(price).replace('.', ',');
    }
    
    public String setAmountsFormat(String CountryIso) {
            Sales_Channel_Mapping__mdt AmountsFormat = [SELECT AmountsFormat__c FROM Sales_Channel_Mapping__mdt WHERE  Zone__c =: CountryIso];
                return AmountsFormat.AmountsFormat__c;
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
        public Decimal                netSubTotal {get; set;}
        public Decimal                totalWithTax {get; set;}
        public String                paymentType {get; set;}
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
        public Decimal  netAmount {get; set;} //InvoiceLine : UnitPrice
        public Decimal  vat {get; set;} //InvoiceLine: ChargeTaxAmount
        public Decimal  grossAmount {get; set;} //invoiceLine : TotalAmountWithTax /Quantity
        public Decimal  total {get; set;} //invoiceLine : TotalAmountWithTax
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
