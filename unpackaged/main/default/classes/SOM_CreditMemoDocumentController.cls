global with sharing class SOM_CreditMemoDocumentController {
    
    public static final String   CONCAT_CHARACTER = ',';
    public Map<String, String>   creditMemoConfigs { get; set; }
    public CreditMemoDocument    creditMemoDocument { get; set;}
    public Map<Decimal,String> creditMemoTaxLineItems {get; set; }
    public Map<String,String>    countryMap {get; set;}
    public String                quantityColumnName {get; set;}
    public String                SerialNumberColumnName {get; set;}
    public String                AmountsFormat {get; set; }
    
    public SOM_CreditMemoDocumentController() {
        this.countryMap = SOM_Utils.getCountryKeyValueMap(SOM_Constants.ORDER_SUMMARY_NAME, SOM_Constants.ORDER_SUMMARY_COUNTRY_FIELD_NAME);
        this.setCreditMemoDocumentConfigs();
        this.setCreditMemoData(); 
    }
    
    public void setCreditMemoDocumentConfigs(){
        this.creditMemoConfigs = new Map<String, String>();
        String templateCode    = ApexPages.currentPage().getParameters().get('template');
        List<SOM_Invoice_Setting__mdt> invoiceSettings = [SELECT MasterLabel, Value__c, Template__c FROM SOM_Invoice_Setting__mdt WHERE Template__c = :templateCode OR Template__c = : SOM_Constants.TEMPLATE_CoreModel];
        for (SOM_Invoice_Setting__mdt invoiceSetting : invoiceSettings) {
            if(!creditMemoConfigs.containsKey(invoiceSetting.MasterLabel) || invoiceSetting.Template__c != SOM_Constants.TEMPLATE_CoreModel){
                if (invoiceSetting.Value__c == null) {
                    creditMemoConfigs.put(invoiceSetting.MasterLabel, '');
                } else {
                    creditMemoConfigs.put(invoiceSetting.MasterLabel, invoiceSetting.Value__c);
                }
            }
            
        }
    }
    
    public void setCreditMemoData(){
        CreditMemoDocument creditMemoDoc = new CreditMemoDocument();
        CreditMemoContact billingContact = new CreditMemoContact();
        CreditMemoContact deliveryContact = new CreditMemoContact();
        String creditMemoId = ApexPages.currentPage().getParameters().get('creditMemoId');
        List<CreditMemo> creditMemo = [SELECT ID, ReturnOrder__c,ReturnOrder__r.Tech_ShippingFeeRefund__c, Refund__r.RefundOrigin__c, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id, CurrencyIsoCode, Account.Name, OrderNumber, BillingCity, BillingPostalCode, BillingState, BillingContactFirstName__c, 
                                       BillingContactLastName__c, BillingCountry, BillingStreet END, CreditDate, Credit_Memo_Date__c, CreditMemoNumber, DocumentNumber, TotalAmount, TotalAmountWithTax, TotalTaxAmount,
                                       (SELECT ID, Type, RelatedLineId, ReferenceEntityItemTypeCode, Product2.Description, AdjustmentAmountWithTax, AdjustmentAmount, AdjustmentTaxAmount, ChargeTaxAmount, ChargeAmount, ChargeAmountWithTax, ReturnOrderLineItem__c, ReturnOrderLineItem__r.QuantityReturned, ReturnOrderLineItem__r.SerialNumber__c,  
                                        TYPEOF ReferenceEntityItem WHEN OrderItemSummary THEN TaxRate__c, hsCode__c, hsCodeDescription__c, COO__c, Description, LineNumber END FROM CreditMemoLines ) FROM CreditMemo WHERE Id = :creditMemoId];
        if (creditMemo != null && !creditMemo.isEmpty()) {
            if (creditMemo.get(0).ReferenceEntity instanceOf OrderSummary) {
                OrderSummary ordSummary = (OrderSummary) creditMemo.get(0).ReferenceEntity;
                creditMemoDoc.orderNumber  = ordSummary.OrderNumber;
                creditMemoDoc.currencyCode = ordSummary.CurrencyIsoCode;
                creditMemoDoc.paymentType  = this.getPaymentMethod(ordSummary.Id);
                billingContact.name        = ordSummary.BillingContactFirstName__c + ' ' + ordSummary.BillingContactLastName__c;
                billingContact.city        = ordSummary.BillingCity;
                billingContact.country     = countryMap.containsKey(ordSummary.BillingCountry) ? countryMap.get(ordSummary.BillingCountry) : ordSummary.BillingCountry;
                billingContact.address     = ordSummary.BillingStreet;
                billingContact.zipCode     = ordSummary.BillingPostalCode;
                billingContact.state       = ordSummary.BillingState;
                this.AmountsFormat  = setAmountsFormat(ordSummary.BillingCountry);
                //set billing contact
                creditMemoDoc.billingContact = billingContact;
                creditMemoDoc.paymentType = this.getPaymentMethod(ordSummary.Id);
                //Get invoice & delivery address
                OrderSummary order = [SELECT ID, (SELECT Id, InvoiceNumber__c FROM Invoices), (SELECT Id, deliverToName, deliverToStreet, deliverToCity, deliverToCountry, deliverToState, deliverToPostalCode FROM OrderDeliveryGroupSummaries) FROM OrderSummary WHERE Id= :ordSummary.Id];
                if (order.invoices != null && !order.invoices.isEmpty()) {
                    creditMemoDoc.invoiceNumber = order.invoices.get(0).InvoiceNumber__c;
                }
                if (order.OrderDeliveryGroupSummaries != null && !order.OrderDeliveryGroupSummaries.isEmpty()) {
                    deliveryContact.name        = order.OrderDeliveryGroupSummaries.get(0).deliverToName;
                    deliveryContact.city        = order.OrderDeliveryGroupSummaries.get(0).deliverToCity;
                    deliveryContact.country     = countryMap.containsKey(order.OrderDeliveryGroupSummaries.get(0).deliverToCountry) ? countryMap.get(order.OrderDeliveryGroupSummaries.get(0).deliverToCountry) : order.OrderDeliveryGroupSummaries.get(0).deliverToCountry;
                    deliveryContact.address     = order.OrderDeliveryGroupSummaries.get(0).deliverToStreet;
                    deliveryContact.state       = order.OrderDeliveryGroupSummaries.get(0).deliverToState;
                    deliveryContact.zipCode     = order.OrderDeliveryGroupSummaries.get(0).deliverToPostalCode;
                }
            } 
            //set delivery contact
            creditMemoDoc.deliveryContact  = deliveryContact;
            creditMemoDoc.creditMemoNumber = creditMemo.get(0).CreditMemoNumber;
            creditMemoDoc.creditMemoDate   = DateTime.newInstance(creditMemo.get(0).Credit_Memo_Date__c.year(), creditMemo.get(0).Credit_Memo_Date__c.month(), creditMemo.get(0).Credit_Memo_Date__c.day()).format('dd.MM.yyyy');
            creditMemoDoc.netSubTotal      = getTotalFormatted(creditMemo.get(0).TotalAmount,AmountsFormat);
            creditMemoDoc.totalWithTax     = getTotalFormatted(creditMemo.get(0).TotalAmountWithTax,AmountsFormat);
            //product type
            String creditMemoProductType = getCreditMemoProductType(creditMemo.get(0));
            //create credit memo lines
            List<CreditMemoLineItem> lineItems = new List<CreditMemoLineItem>();
            Integer counter = 1;
            for(CreditMemoLine creditMemoLine:creditMemo.get(0).CreditMemoLines) {
                if ((creditMemoLine.Type.equalsIgnoreCase(creditMemoProductType)  && creditMemo.get(0).ReturnOrder__r.Tech_ShippingFeeRefund__c == false )||
                    ( creditMemo.get(0).ReturnOrder__r.Tech_ShippingFeeRefund__c == true && ( creditMemoLine.Type == SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT || creditMemoLine.ReferenceEntityItemTypeCode == SOM_Constants.PRODUCT) )) {
                        //if ((creditMemoLine.Type.equalsIgnoreCase(creditMemoProductType) )|| ( creditMemo.get(0).ReturnOrder__r.Tech_ShippingFeeRefund__c == true && creditMemoLine.Type == 'Adjustment' )) {
                        CreditMemoLineItem lineItem = new CreditMemoLineItem();
                        //Only if attached to a returnLineItem, divide by returnedQuantity 
                        if (creditMemoLine.ReturnOrderLineItem__c != null && creditMemoLine.ReturnOrderLineItem__r.QuantityReturned > 0) {
                            lineItem.quantity     = creditMemoLine.ReturnOrderLineItem__r.QuantityReturned;
                            lineItem.netAmount    = getTotalFormatted(getAmount(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat);
                            lineItem.vat          = getTotalFormatted(getVAT(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat);
                            lineItem.grossAmount  = getTotalFormatted(getAmountWithTax(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat);
                            lineItem.total        = getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat); 
                            lineItem.serialNumber = creditMemoLine.ReturnOrderLineItem__r.SerialNumber__c;
                            this.quantityColumnName     = 'QUANTITY';
                            this.SerialNumberColumnName = 'SERIAL NO.';
                        } 
                        else {
                            //we should use adjustment
                            lineItem.netAmount   = getTotalFormatted(getAmount(creditMemoLine),AmountsFormat);
                            lineItem.vat         = getTotalFormatted(getVAT(creditMemoLine),AmountsFormat);
                            lineItem.grossAmount = getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat);
                            lineItem.total       = getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat);
                        }
                        if (creditMemoLine.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT)) {
                            for(CreditMemoLine creditMemoLineCharge:creditMemo.get(0).CreditMemoLines) {
                                if (creditMemoLine.RelatedLineId == creditMemoLineCharge.Id && creditMemoLineCharge.ReferenceEntityItem instanceOf OrderItemSummary) {
                                    OrderItemSummary orderItem = (OrderItemSummary)creditMemoLineCharge.ReferenceEntityItem;
                                    lineItem.hsCode            = orderItem.hsCode__c;
                                    lineItem.hsCodeDescription = orderItem.hsCodeDescription__c;
                                    lineItem.coo               = orderItem.COO__c;
                                    lineItem.itemDescription   = orderItem.Description;
                                    lineItem.lineNumber   = orderItem.LineNumber;

                                    break;
                                }
                            }
                        } else if (creditMemoLine.ReferenceEntityItem instanceOf OrderItemSummary) {
                            OrderItemSummary orderItem = (OrderItemSummary)creditMemoLine.ReferenceEntityItem;
                            lineItem.hsCode            = orderItem.hsCode__c;
                            lineItem.hsCodeDescription = orderItem.hsCodeDescription__c;
                            lineItem.coo               = orderItem.COO__c;
                            lineItem.itemDescription   = orderItem.Description;
                            lineItem.lineNumber   = orderItem.LineNumber;

                            //lineItem.itemDescription   = creditMemoLine.Product2.Description;
                        }
                        
                        //  lineItem.itemNumber = counter;
                        
                        lineItems.add(lineItem);
                        // counter++;
                    }
            }
            lineItems.sort();
            // List<CreditMemoLineItem> lineItems2 = new List<CreditMemoLineItem>();
            //Adjust lineItems Order
            //Integer i =lineItems.size(), j =1,k=1 ;
            //for(j= i-1 ; j>=0 && i>0 ; i--){
             //   lineItems2.add(lineItems[i-1]);
            //}
            //Adjust itemNumber
            Integer k=1 ; 
            for(CreditMemoLineItem Line : lineItems){
                Line.itemNumber = k;
                k++;
            }
            
            //set credit memo line items
            //lineItems.sort();
            creditMemoDoc.lineItems = lineItems;
            this.creditMemoTaxLineItems = new Map<Decimal, String>();
            //set credit memo line taxes
            this.creditMemoTaxLineItems = getCreditMemoTaxLineItems(creditMemo.get(0), creditMemoProductType);
            this.creditMemoDocument     = creditMemoDoc;
        }
        
    }
    
    
    public String getCreditMemoProductType(CreditMemo creditMemo){
        if (creditMemo.Refund__r.RefundOrigin__c == SOM_Constants.REFUND_ORIGIN_APPEASEMENT )
            return SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT;
        
        return SOM_Constants.INVOICE_LINE_TYPE_CHARGE;
    }
    
    public Decimal getAmount(CreditMemoLine creditMemoLine){
        if (creditMemoLine.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT)) {
            return creditMemoLine.AdjustmentAmount;
        }
        
        return creditMemoLine.ChargeAmount;
    }
    
    public Decimal getVAT(CreditMemoLine creditMemoLine){
        if (creditMemoLine.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT)) {
            return creditMemoLine.AdjustmentTaxAmount;
        }
        
        return creditMemoLine.ChargeTaxAmount;
    }
    
    public Decimal getAmountWithTax(CreditMemoLine creditMemoLine){
        if (creditMemoLine.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT) ) {
            return creditMemoLine.AdjustmentAmountWithTax;
        }
        
        return creditMemoLine.ChargeAmountWithTax;
    }
    
    public Map<Decimal,String> getCreditMemoTaxLineItems(CreditMemo creditMemo, String creditMemoProductType){
        Map<Decimal, Decimal> creditMemoTaxes       = new Map<Decimal, Decimal>();
        Map<Decimal, String> creditMemoTaxesSorted = new Map<Decimal, String>();
        for (CreditMemoLine lineItem:creditMemo.CreditMemoLines) {
            if (lineItem.Type.equalsIgnoreCase(creditMemoProductType) || ( creditMemo.ReturnOrder__r.Tech_ShippingFeeRefund__c == true && lineItem.Type == SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT)) {
                Decimal taxRate = 0;
                if (creditMemoProductType.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT) || lineItem.Type == SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT) {
                    for(CreditMemoLine creditMemoLineCharge:creditMemo.CreditMemoLines) {
                        if (lineItem.RelatedLineId == creditMemoLineCharge.Id && creditMemoLineCharge.ReferenceEntityItem instanceOf OrderItemSummary) {
                            OrderItemSummary orderItem = (OrderItemSummary)creditMemoLineCharge.ReferenceEntityItem;
                            taxRate = orderItem.TaxRate__c;
                            break; 
                        }
                    }
                } else if (lineItem.ReferenceEntityItem instanceOf OrderItemSummary) {
                    OrderItemSummary orderItem = (OrderItemSummary)lineItem.ReferenceEntityItem;
                    taxRate = orderItem.TaxRate__c;
                }
                
                Decimal taxAmount = lineItem.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT) ? lineItem.AdjustmentTaxAmount : lineItem.ChargeTaxAmount;
                if (creditMemoTaxes.containsKey(taxRate)) {
                    creditMemoTaxes.put(taxRate, creditMemoTaxes.get(taxRate)+taxAmount);
                } else {
                    creditMemoTaxes.put(taxRate, taxAmount);
                }
                
            }
        }
        List<Decimal> sortedTaxes = new List<Decimal>();
        sortedTaxes.addAll(creditMemoTaxes.keySet());
        sortedTaxes.sort();
        for(Decimal taxRate: sortedTaxes){
            creditMemoTaxesSorted.put((taxRate),getTotalFormatted(creditMemoTaxes.get(taxRate),AmountsFormat));
        }
        return creditMemoTaxesSorted;
    }
    
   
    
    public String getPaymentMethod(Id orderSummaryId){
        //Get order payment summary
        List<OrderPaymentSummary> paymentSummary = [SELECT Type, PaymentMethodId, PaymentMethod.ImplementorType FROM OrderPaymentSummary WHERE OrderSummaryId = :orderSummaryId];
        if (paymentSummary != null && !paymentSummary.isEmpty()) {
            if (paymentSummary.get(0).PaymentMethod.ImplementorType.equalsIgnoreCase(SOM_Constants.CARD_PAYMENT_METHOD)) {
                CardPaymentMethod cardPaymentMethod = [SELECT CardCategory FROM CardPaymentMethod WHERE Id = :paymentSummary.get(0).PaymentMethodId];
                return cardPaymentMethod.CardCategory;
            } else {
                return paymentSummary.get(0).Type;
            }
        }
        
        return '';
    }
    
    public String setAmountsFormat(String CountryIso) {
            Sales_Channel_Mapping__mdt AmountsFormat = [SELECT AmountsFormat__c FROM Sales_Channel_Mapping__mdt WHERE  Zone__c =: CountryIso];
                return AmountsFormat.AmountsFormat__c;
    }
    
    //Apply the AmountsFormat
    public String getTotalFormatted(Decimal amountToFormat, String AmountsFormat ){
        	Decimal input = amountToFormat;
        	if (amountToFormat.scale() > 2) {
        		input = amountToFormat.setScale(2, RoundingMode.HALF_UP);
            }
           	return formatDecimalNumber((input),AmountsFormat);
    }
    
    	//Apply the AmountsFormat
        public String formatDecimalNumber(Decimal myDecimal, String AmountsFormat){
            if(AmountsFormat == SOM_Constants.AMOUNT_FORMAT1){
                if (myDecimal == null) return '0,00';
                String myDecimalString = myDecimal.toPlainString();
                String intValue = myDecimalString.substringBefore('.');
                List<String> intValueList = new List<String>();
                for(Integer i=intValue.length(); i>0; i-=3) {
                    integer startIndex = i>3?i-3:0;
                    if(intValueList.isEmpty()){
                        intValueList.add(intValue.substring(startIndex, i));
                    }else{
                        intValueList.add(0,intValue.substring(startIndex, i));
                    }
                    
                }
                String valueToReturn = '';
                for(String intValueItem: intValueList){
                    valueToReturn = valueToReturn + intValueItem + '.';
                }
                valueToReturn = valueToReturn.removeEnd('.');
                valueToReturn = valueToReturn + ',' + myDecimalString.substringafter('.');
                
                Return valueToReturn;
                
            }else if(AmountsFormat == SOM_Constants.AMOUNT_FORMAT2){
                if (myDecimal == null) return '0.00';
                String myDecimalString = myDecimal.toPlainString();
                // exemple ###.###,##
                String intValue = myDecimalString.substringBefore('.');
                List<String> intValueList = new List<String>();
                for(Integer i=intValue.length(); i>0; i-=3) {
                    integer startIndex = i>3?i-3:0;
                    if(intValueList.isEmpty()){
                        intValueList.add(intValue.substring(startIndex, i));
                    }else{
                        intValueList.add(0,intValue.substring(startIndex, i));
                    }
                    
                }
                String valueToReturn = '';
                for(String intValueItem: intValueList){
                    valueToReturn = valueToReturn + intValueItem + ',';
                }
                //valueToReturn = valueToReturn.removeEnd('.');
                valueToReturn = valueToReturn + myDecimalString.substringafter('.');
                valueToReturn = valueToReturn.reverse().replaceFirst(',', '.').reverse();
                
                Return valueToReturn;
                
            }else{
            	Return 'Invalid Format';
            }
        }
        
    
    global with sharing class CreditMemoDocument{
        public String                   creditMemoNumber {get; set;}
        public String                   invoiceNumber {get; set;}
        public String                   creditMemoDate {get; set;}
        public String                   orderNumber {get; set;}
        public String                   currencyCode {get; set;}
        public CreditMemoContact        billingContact {get; set;}
        public CreditMemoContact        deliveryContact {get; set;}
        public List<CreditMemoLineItem> lineItems {get; set;}
        public String                   netSubTotal {get; set;}
        public String                   totalWithTax {get; set;}
        public String                   paymentType {get; set;}
    }
    
    global with sharing class CreditMemoContact{
        public String name {get; set;}
        public String company {get; set;} 
        public String zipCode {get; set;}
        public String city {get; set;}
        public String address {get; set;}
        public String state {get; set;}
        public String country {get; set;}
    }
    
    global with sharing class CreditMemoLineItem implements comparable{
        public String  itemDescription {get; set;} 
        public Integer itemNumber {get; set;}
        public String  serialNumber {get; set;}
        public String  hsCode {get; set;} 
        public String  hsCodeDescription {get; set;}
        public String  coo {get; set;}
        public Decimal quantity {get; set;} 
        public String  netAmount {get; set;} 
        public String  vat {get; set;} 
        public String  grossAmount {get; set;}
        public String  total {get; set;} 
        //add number LineNumber
        public Integer  lineNumber {get; set;} 

        public Integer compareTo(Object compareTo) {
            // Cast argument to InvoiceLineItem
            CreditMemoLineItem compareToOppy = (CreditMemoLineItem)compareTo;
            
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