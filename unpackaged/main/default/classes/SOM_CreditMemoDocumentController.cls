global with sharing class SOM_CreditMemoDocumentController {
    public static final String   CONCAT_CHARACTER = ',';
    public Map<String, String>   creditMemoConfigs { get; set; }
    public CreditMemoDocument    creditMemoDocument { get; set;}
    public Map<String,String> creditMemoTaxLineItems {get; set; }
    public Map<String,String>    countryMap {get; set;}
    public String                quantityColumnName {get; set;}
    public String                SerialNumberColumnName {get; set;}
    public String                AmountsFormat {get; set; }
    public CreditMemoAddress        creditMemoAddress { get; set;}
    
    public SOM_CreditMemoDocumentController() {
            this.countryMap = SOM_Utils.getCountryKeyValueMap(SOM_Constants.ORDER_SUMMARY_NAME, SOM_Constants.ORDER_SUMMARY_COUNTRY_FIELD_NAME);
            this.setCreditMemoDocumentConfigs();
            this.setCreditMemoData();

    }
    public void setCreditMemoDocumentConfigs(){
        try{
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
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','setCreditMemoDocumentConfigs','','');   
        } 
    }
    public void setCreditMemoData(){
        try{
            CreditMemoDocument creditMemoDoc = new CreditMemoDocument();
            CreditMemoContact billingContact = new CreditMemoContact();
            CreditMemoContact deliveryContact = new CreditMemoContact();
            CreditMemoAddress cmAddress       = new CreditMemoAddress();
            String creditMemoId = ApexPages.currentPage().getParameters().get('creditMemoId');
            String templateCode = ApexPages.currentPage().getParameters().get('template');
            creditMemoDoc.Template = templateCode;
            List<CreditMemo> creditMemo = [SELECT ID, ReturnOrder__c,ReturnOrder__r.Tech_ShippingFeeRefund__c, Refund__r.RefundOrigin__c, TYPEOF ReferenceEntity WHEN OrderSummary THEN Id, CurrencyIsoCode, Account.Name, OrderNumber, BillingCity, BillingPostalCode, BillingState, BillingContactFirstName__c,
                                           BillingContactLastName__c, BillingCountry, BillingStreet END, CreditDate, Credit_Memo_Date__c, CreditMemoNumber, DocumentNumber, TotalAmount, TotalAmountWithTax, TotalTaxAmount,
                                           (SELECT ID, Type, RelatedLineId, ReferenceEntityItemTypeCode, Product2.Description, AdjustmentAmountWithTax, AdjustmentAmount, AdjustmentTaxAmount, ChargeTaxAmount, ChargeAmount, ChargeAmountWithTax, ReturnOrderLineItem__c, ReturnOrderLineItem__r.QuantityReturned, ReturnOrderLineItem__r.SerialNumber__c,  
                                            TYPEOF ReferenceEntityItem WHEN OrderItemSummary THEN TaxRate__c, hsCode__c, hsCodeDescription__c, COO__c, Description, LineNumber END FROM CreditMemoLines ) FROM CreditMemo WHERE Id = :creditMemoId];
            Set<Id> setIds = new Set<Id>();
            for(CreditMemo cm : CreditMemo ){
                setIds.add(cm.ReferenceEntityId) ;
            }
            List<fulfillmentOrder> fulfillmentsOrders = [ Select Id,FulfilledToCountry,OrderSummaryId, OrderSummary.Legal_Entity__c, OrderSummary.VAT_ID__c FROM fulfillmentOrder Where OrderSummaryId IN: setIds];
            cmAddress = setCreditMemoAddress (fulfillmentsOrders.get(0).OrderSummary.Legal_Entity__c);
        	cmAddress.VATID = fulfillmentsOrders.get(0).OrderSummary.VAT_ID__c;

            Map<Id,fulfillmentOrder> foMap = new Map<Id,fulfillmentOrder>();
            for (fulfillmentOrder fo : fulfillmentsOrders){
                foMap.put(fo.OrderSummaryId, fo);
            }
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
                    fulfillmentOrder currentFulfillment = foMap.get(ordSummary.Id);
                    this.AmountsFormat  = setAmountsFormat(currentFulfillment.FulfilledToCountry);
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
                if(templateCode == 'JP'){
                    creditMemoDoc.netSubTotal      = setAmountsJPFormat(SOM_Utils.getTotalFormatted(creditMemo.get(0).TotalAmount,AmountsFormat));
                    creditMemoDoc.totalWithTax     = setAmountsJPFormat(SOM_Utils.getTotalFormatted(creditMemo.get(0).TotalAmountWithTax,AmountsFormat));
                }else{
                    creditMemoDoc.netSubTotal      = SOM_Utils.getTotalFormatted(creditMemo.get(0).TotalAmount,AmountsFormat);
                    creditMemoDoc.totalWithTax     = SOM_Utils.getTotalFormatted(creditMemo.get(0).TotalAmountWithTax,AmountsFormat);
                }
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
                                if(templateCode == 'JP'){
                                    lineItem.netAmount    = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getAmount(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat));
                                    lineItem.vat          = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getVAT(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat));
                                    lineItem.grossAmount  = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat));
                                    lineItem.total        = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat));
                                }else{
                                    lineItem.netAmount    = SOM_Utils.getTotalFormatted(getAmount(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat);
                                    lineItem.vat          = SOM_Utils.getTotalFormatted(getVAT(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat);
                                    lineItem.grossAmount  = SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine)/creditMemoLine.ReturnOrderLineItem__r.QuantityReturned,AmountsFormat);
                                    lineItem.total        = SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat);
                                }
                                lineItem.serialNumber = creditMemoLine.ReturnOrderLineItem__r.SerialNumber__c;
                                this.quantityColumnName     = 'QUANTITY';
                                this.SerialNumberColumnName = 'SERIAL NO.';
                            }
                            else {
                                //we should use adjustment
                                if(templateCode == 'JP'){
                                    lineItem.netAmount   = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getAmount(creditMemoLine),AmountsFormat));
                                    lineItem.vat         = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getVAT(creditMemoLine),AmountsFormat));
                                    lineItem.grossAmount = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat));
                                    lineItem.total       = setAmountsJPFormat(SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat));
                                }else{
                                    lineItem.netAmount   = SOM_Utils.getTotalFormatted(getAmount(creditMemoLine),AmountsFormat);
                                    lineItem.vat         = SOM_Utils.getTotalFormatted(getVAT(creditMemoLine),AmountsFormat);
                                    lineItem.grossAmount = SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat);
                                    lineItem.total       = SOM_Utils.getTotalFormatted(getAmountWithTax(creditMemoLine),AmountsFormat);
                                }
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
                this.creditMemoTaxLineItems = new Map<String, String>();
                //set credit memo line taxes
                this.creditMemoTaxLineItems = getCreditMemoTaxLineItems(creditMemo.get(0), creditMemoProductType, templateCode);
                this.creditMemoDocument     = creditMemoDoc;


                this.CreditMemoAddress     = cmAddress;


            }  
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','setCreditMemoData','','');   
        } 

    }
    
    public String getCreditMemoProductType(CreditMemo creditMemo){
        try{  
            if (creditMemo.Refund__r.RefundOrigin__c == SOM_Constants.REFUND_ORIGIN_APPEASEMENT )
                return SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT;
            return SOM_Constants.INVOICE_LINE_TYPE_CHARGE;
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','getCreditMemoProductType','','');   
        }
        return null;
    }
    public Decimal getAmount(CreditMemoLine creditMemoLine){
        try{
            if (creditMemoLine.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT)) {
                return creditMemoLine.AdjustmentAmount;
            }
            return creditMemoLine.ChargeAmount;
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','getAmount','','');   
        }
        return null;
    }
    public Decimal getVAT(CreditMemoLine creditMemoLine){
        try{
            if (creditMemoLine.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT)) {
                return creditMemoLine.AdjustmentTaxAmount;
            }
            return creditMemoLine.ChargeTaxAmount;
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','getVAT','','');   
        }
        return null;
    }
    public Decimal getAmountWithTax(CreditMemoLine creditMemoLine){
        try{
            if (creditMemoLine.Type.equalsIgnoreCase(SOM_Constants.CreditMemo_LINE_TYPE_ADJUSTMENT) ) {
                return creditMemoLine.AdjustmentAmountWithTax;
            }
            return creditMemoLine.ChargeAmountWithTax;
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','getAmountWithTax','','');   
        }
        return null;
    }
    public Map<String,String> getCreditMemoTaxLineItems(CreditMemo creditMemo, String creditMemoProductType, String templateCode){
        Map<Decimal, Decimal> creditMemoTaxes       = new Map<Decimal, Decimal>();
        Map<String, String> creditMemoTaxesSorted = new Map<String, String>();
        try{
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
            /*for(Decimal taxRate: sortedTaxes){
                creditMemoTaxesSorted.put((taxRate),SOM_Utils.getTotalFormatted(creditMemoTaxes.get(taxRate),AmountsFormat));
            } */  
        if (templateCode == 'JP'){
            for(Decimal taxRate: sortedTaxes){
                creditMemoTaxesSorted.put(setAmountsJPFormat(String.valueOf(taxRate)),setAmountsJPFormat(SOM_Utils.getTotalFormatted(creditMemoTaxes.get(taxRate),AmountsFormat)));
            }
        }else{
            for(Decimal taxRate: sortedTaxes){
                creditMemoTaxesSorted.put(String.valueOf(taxRate),SOM_Utils.getTotalFormatted(creditMemoTaxes.get(taxRate),AmountsFormat));
            }
        }
            return creditMemoTaxesSorted;
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','getCreditMemoTaxLineItems','','');   
        }  
        return null;
    }

    
    public String getPaymentMethod(Id orderSummaryId){
        //Get order payment summary
        try{   
            List<OrderPaymentSummary> paymentSummary = [SELECT Type, PaymentMethodId, PaymentMethod.ImplementorType FROM OrderPaymentSummary WHERE OrderSummaryId = :orderSummaryId];
            OrderSummary os = [SELECT Id , language__c FROM OrderSummary WHERE Id =: orderSummaryId LIMIT 1];
            if (paymentSummary != null && !paymentSummary.isEmpty()) {
                List<Payment_Methods_Mapping__mdt> paymentMethodsMapping = [SELECT Id, Value__c, Translation__c, Is_Card_Payment_Method__c FROM Payment_Methods_Mapping__mdt WHERE Value__c = :paymentSummary.get(0).Type AND Language__c = :os.language__c];
                if (paymentMethodsMapping != null && !paymentMethodsMapping.isEmpty()) {
                    return paymentMethodsMapping.get(0).Translation__c;
                } else {
                    return paymentSummary.get(0).Type;
                }
            }

        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','getPaymentMethod','','');   
        }  
        return '';
    }
    public String setAmountsFormat(String CountryIso) {
        try{  
            Sales_Channel_Mapping__mdt AmountsFormat = [SELECT AmountsFormat__c FROM Sales_Channel_Mapping__mdt WHERE  Zone__c =: CountryIso];
            return AmountsFormat.AmountsFormat__c;
        }catch(Exception e){
            Logs.error(e,'SOM_CreditMemoDocumentController','setAmountsFormat','','');   
        }  
        return null;
    }
    
    public CreditMemoAddress setCreditMemoAddress(String Code) {
        CreditMemoAddress CredMeAddress     = new CreditMemoAddress();
        Legal_Entity__c LegalEntity = [SELECT Id, Country__c, Code__c, Name , City__c,Address__c,ZipCode__c,  CountryLabel__c,FooterBilling__c FROM Legal_Entity__c WHERE Code__c = :Code];
        CredMeAddress.name = LegalEntity.Name; 
        CredMeAddress.address = LegalEntity.Address__c ;  
        CredMeAddress.countryLabel = LegalEntity.CountryLabel__c; 
        CredMeAddress.FooterBilling = LegalEntity.FooterBilling__c; 
        return CredMeAddress;
    } 
    
    public String setAmountsJPFormat(String Amount) {
		String AmountJP =  Amount.Substring(0,Amount.length()-3);
        return AmountJP;
    } 
    
    global with sharing class CreditMemoAddress{
        public String                name {get; set;} //Invoice: DocumentNumber
        public String                address {get; set;} //Invoice : InvoiceDate
        public String                countryLabel {get; set;} //OrderSummary : OrderNumber
        public String                VATID {get; set;} //FO : currency
        public String                FooterBilling {get; set;}
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
        public String                   Template {get; set;}
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
