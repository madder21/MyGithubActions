import { LightningElement, track, api } from 'lwc';
import getListLineItems from '@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getListLineItems';
import getTotalLinesRO from '@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getTotalLinesRO';
import getCurrency from '@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getCurrency';
import getLocations from '@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getLocations';
import getProductDetails from '@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getProductDetails';
import getSKUsDelivery from '@salesforce/apex/SOM_LWC_DisplayOrderItems_Controller.getSKUsDelivery';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';




export default class SomLwcDisplayOrderItems extends LightningElement {

    lineIndex;
    incrementIndex = 0;
    @api isFromReturn;
    @api orderSummaryId;
    @api returnOrderId;
    @api countryCode;
    @api priceBookId;
    @api currencyCode;
    @api OutputLineItems;
    @api InputLineItems;
    @track isLoading = false;
    @track customData = [];
    @track customDataDisplay = [];
    skusDelivery = [];
    currentLineKey;
    productLineItem;
    locationPicklist;
    displayNextButton = false;
    skuReplacementLabel;
    @track totalLines = 0;
    @track roTotal = 0;
    @track currencyIso;
    

    
    connectedCallback(){
        
        
        try {
            this.startLoading();
            this.getListLocations();
            this.setSKUReplacementLabel();
            this.getListSkusDelivery();  
            this.getCurrency();    
            if(this.InputLineItems !== undefined && this.InputLineItems !== null && this.InputLineItems.length>0){
                const initialData = this.InputLineItems.map(object => ({ ...object }));
                this.customData = initialData;
                this.customDataDisplay = this.customData;
                this.OutputLineItems = initialData;
                this.endLoading();
                return;
            }
            if(this.isFromReturn){
                this.getListData();
                this.getTotalLinesRO();
            } 
            this.endLoading();
        } catch (error) {
            console.log('** Exception error: ', error);
            this.endLoading();
            this.displayErrorMessage(error);
        }
    }

    getListSkusDelivery(){
        try {
            getSKUsDelivery()
            .then(result => {
                this.skusDelivery = result;
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('*SomLwcDisplayOrderItems* SomLwcDisplayOrderItems Exception error: ', error);
        }
    }
    getListData() {
        try {
            getListLineItems({orderSumId : this.orderSummaryId, returnOrdId : this.returnOrderId, isFromRo : this.isFromReturn})
            .then(result => {
                this.customData = JSON.parse(result);
                this.customDataDisplay = this.customData;
                this.OutputLineItems = JSON.parse(result);
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('*SomLwcDisplayOrderItems* SomLwcDisplayOrderItems Exception error: ', error);
        }
    }

    getTotalLinesRO(){
        try {
            getTotalLinesRO({returnOrdId : this.returnOrderId, isFromRo : this.isFromReturn})
            .then(result => {
                this.roTotal = result;
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('*SomLwcDisplayOrderItems* SomLwcDisplayOrderItems Exception error: ', error);
        }
    }

    getCurrency(){
        try {
            getCurrency({orderSumId : this.orderSummaryId})
            .then(result => {
                this.currencyIso = result;
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('*SomLwcDisplayOrderItems* SomLwcDisplayOrderItems Exception error: ', error);
        }
    }


    handleProdctChange(event){
        this.startLoading();
        const lineKey = event.target.accessKey;
        if( lineKey === null || lineKey === undefined || lineKey === ''){
            this.truncateProductId(lineKey);
            return;
        }
        this.currentLineKey = event.target.accessKey;
        const productIdValue = event.target.value;
        if(productIdValue === undefined || productIdValue === null || productIdValue === ''){
            this.truncateProductId(lineKey);
            return;
        }
        const filteredLines = this.customData.filter(element => element.productId === productIdValue);
        if(filteredLines.length > 0){
            this.truncateProductId(lineKey);
            this.displayWarningMessage('The product SKU that you select is already exist on other line','Duplicated SKU');
            return;
        }
        this.getProductDetails(this.currentLineKey, productIdValue, null);
       
        
    }

    handleClickType(event){
        this.currentLineKey = event.target.value;
        for(let i=0; i<this.customData.length; i++){
            if(this.customData[i].taxType === false && this.customData[i].amountId === this.currentLineKey){
                this.customDataDisplay[i].taxType = true;
                this.customData[i].taxType = true;
                this.customData[i].taxValue = this.customData[i].taxRate;
                this.customDataDisplay[i].taxValue = this.customData[i].taxRate;
                var rateToVal = this.customData[i].taxRate;
                // this.customDataDisplay[i].taxValue = rateToVal;
                this.customData[i].taxRate = rateToVal / (this.customData[i].unitPrice - rateToVal) * 100;
                this.customDataDisplay[i].taxRate = this.customData[i].taxRate;
                // this.customData[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity;
                // this.customDataDisplay[i].lineTotal = this.customData[i].lineTotal;
                this.currentLineKey = '';
                this.refresOutPutData();
                break;
            }
            else if(this.customData[i].taxType === true && this.customData[i].percentId === this.currentLineKey){
                this.customDataDisplay[i].taxType = false;
                this.customData[i].taxType = false;
                this.customData[i].taxRate = this.customData[i].taxValue;
                this.customDataDisplay[i].taxRate = this.customData[i].taxValue;
                var valToRate = this.customData[i].taxValue;
                //this.customDataDisplay[i].taxValue = valToRate;
                this.customData[i].taxValue = (valToRate * this.customData[i].unitPrice) / (100 + valToRate);
                this.customDataDisplay[i].taxValue = this.customData[i].taxValue;
                // this.customData[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity;
                // this.customDataDisplay[i].lineTotal = this.customData[i].lineTotal;
                this.currentLineKey = '';
                this.refresOutPutData();
                break;
            }
        }
    }

    handleUnitPrice(event){

        this.currentLineKey = event.target.accessKey;
        var unitPric = parseFloat(event.target.value);
        for(let i=0; i<this.customData.length; i++){
            if(this.customData[i].sku === this.currentLineKey){
                this.customData[i].lineTotal = unitPric * this.customData[i].quantity;
                this.customDataDisplay[i].lineTotal = unitPric * this.customData[i].quantity;
                this.customData[i].unitPrice = unitPric;
                this.customDataDisplay[i].unitPrice = unitPric;
                this.calculateTotalLines();
                this.currentLineKey = '';
                this.refresOutPutData();
                break;    
            }  
        }   
    }
   
    
    handleTaxValue(event){
        this.currentLineKey = event.target.accessKey;
        var valEntered = parseFloat(event.target.value);
        var itemTaxVal = 0;
        for(let i=0; i<this.customData.length; i++){
            if( this.customData[i].taxType === true && this.customData[i].sku === this.currentLineKey){
                this.customData[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity ;
                this.customDataDisplay[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity;
                this.customData[i].taxValue = valEntered;
                if(this.customData[i].unitPrice == 0){
                    this.customData[i].taxRate = 0;
                }
                else {
                    //this.customData[i].taxRate = (taxVal/ (this.customData[i].unitPrice * this.customData[i].quantity)) * 100;
                    this.customData[i].taxRate = valEntered / (this.customData[i].unitPrice - valEntered) * 100;
                    this.customDataDisplay[i].taxRate = this.customData[i].taxRate;
                }
                this.customDataDisplay[i].taxValue = valEntered;
                this.calculateTotalLines();
                this.currentLineKey = '';
                this.refresOutPutData();
                
                break;    
            }  
            else if( this.customData[i].taxType === false && this.customData[i].sku === this.currentLineKey){
                //itemTaxVal = this.customData[i].unitPrice * (taxVal/100) * this.customData[i].quantity;
                itemTaxVal = (valEntered * this.customData[i].unitPrice) / (100 + valEntered);
                this.customData[i].taxRate = valEntered;
                this.customData[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity;
                this.customDataDisplay[i].lineTotal = this.customData[i].lineTotal;
                this.customData[i].taxValue = itemTaxVal;
                this.customDataDisplay[i].taxValue = this.customData[i].taxValue;
                this.customDataDisplay[i].taxRate = valEntered;
                this.calculateTotalLines();
                this.currentLineKey = '';
                this.refresOutPutData();
                
                break;    
            }  
        }
        
    }

    

    calculateTotalLines(){
        this.totalLines = 0;
        for(let i=0; i<this.customData.length; i++){
            this.totalLines += this.customData[i].lineTotal;
            
        }
        for(let i=0; i<this.customData.length; i++){
            this.customData[i].totalLines = this.totalLines;
            this.customDataDisplay[i].totalLines = this.totalLines;
        }

    }   
    
    
    handleLocationChange(event) {
        if(event.target.accessKey === undefined || event.target.accessKey === null || event.target.accessKey === ''){
            return;
        }
        this.startLoading();
        this.currentLineKey = event.target.accessKey;
        const locationValue = event.target.value;

        if(locationValue === null || locationValue === ''){
            return;
        }
        this.startLoading();
        this.getProductDetails(this.currentLineKey, null, locationValue);
        
    }

    handleQuantityChange(event) {
        if(event.target.accessKey === undefined || event.target.accessKey === null || event.target.accessKey === ''){
            return;
        }
        this.currentLineKey = event.target.accessKey;
        const quantityValue = event.target.value;
        if(quantityValue === undefined || quantityValue === null || quantityValue === ''){
            return;
        }
        for(let i=0; i<this.customData.length; i++){
            if( this.customData[i].sku === this.currentLineKey){
                this.customData[i].quantity = parseInt(quantityValue);
                this.customDataDisplay[i].quantity = parseInt(quantityValue);
                this.customData[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity;
                this.customDataDisplay[i].lineTotal = this.customData[i].lineTotal;
                this.calculateTotalLines();
                this.currentLineKey = '';
                this.refresOutPutData();
                break;
            }
            
        }
    }
    incrementQuantity(event){
        //event.preventDefault();
        if(event.target.accessKey === undefined || event.target.accessKey === null || event.target.accessKey === ''){
            return;
        }
        this.currentLineKey = event.target.accessKey;
        var listData = this.customData.map(object => ({ ...object }));
        for(let i=0; i<this.customData.length; i++){
            if( this.customData[i].sku === this.currentLineKey){
                var quantityVal = parseInt(listData[i].quantity);
                listData[i].quantity = quantityVal + 1;
                this.customData = listData;
                this.customDataDisplay = listData;
                this.customData[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity;
                this.customDataDisplay[i].lineTotal = this.customData[i].lineTotal;
                this.calculateTotalLines();
                this.currentLineKey = '';
                this.refresOutPutData();
                break;
            }
    
        }

    }
    decrementQuantity(event){
        if(event.target.accessKey === undefined || event.target.accessKey === null || event.target.accessKey === ''){
            return;
        }
       
        this.currentLineKey = event.target.accessKey;
        var listData = this.customData.map(object => ({ ...object }));
        for(let i=0; i<this.customData.length; i++){
            if( this.customData[i].sku === this.currentLineKey){
                var quantityVal = parseInt(listData[i].quantity);
                if(quantityVal > 0){
                    listData[i].quantity = quantityVal - 1;
                }
                this.customData = listData;
                this.customDataDisplay = listData;
                this.customData[i].lineTotal = this.customData[i].unitPrice * this.customData[i].quantity;
                this.customDataDisplay[i].lineTotal = this.customData[i].lineTotal;
                this.calculateTotalLines();
                this.currentLineKey = '';
                this.refresOutPutData();
                break;
            }
            
        }

    }

    getListLocations() {
        try {
            getLocations({ countryCode : this.countryCode })
            .then(result => {
                if(result.length === 0){
                    this.displayWarningMessage('Somethings wrong while retrieving locations','No location founded');
                    return;
                }
                this.locationPicklist = result;
                
            })
            .catch(error => {
                this.error = error;
            });
            return
        } catch (error) {
            console.log('** SOM_ReturnItemsCreation_Component Exception error: ', error);
        }  
    }
    truncateProductId(itemKey){
        for(let i=0; i<this.customData.length; i++){
            if( this.customData[i].sku === itemKey){
                this.customData[i].ats = 0;
                this.customData[i].description = '';
                this.customData[i].pbEntryId = '';
                this.customData[i].productId = '';

                this.customDataDisplay[i].ats = 0;
                this.customDataDisplay[i].description = '';
                this.customDataDisplay[i].pbEntryId = '';
                this.customDataDisplay[i].productId = '';
                const inputFields = this.template.querySelectorAll('lightning-input-field');
                inputFields.forEach(field => {
                    if(field.accessKey === itemKey){
                        field.reset();
                    }
                        
                    
                });
                
                
                this.endLoading();
                break;
            }
            
        }
        
    }
    
    /**
     * method description ----
     * @param {*} itemKey      : 
     * @param {*} newProdId    :
     * @param {*} newLocation  : 
     * @returns 
     */
    getProductDetails(itemKey, newProdId, newLocation) {
        try{
            if(itemKey === null || itemKey === undefined || itemKey === ''){
                this.endLoading();
                return;
            }
            for(let i=0; i<this.customData.length; i++){
                if( this.customData[i].sku === itemKey){
                    const listData = this.customData.map(object => ({ ...object }));
                    this.productLineItem = listData[i];
                    
                    if(newProdId !== null){
                        this.customData[i].productId = newProdId;
                        this.customDataDisplay[i].productId = newProdId;
                    }
                    if(newLocation !== null){
                        this.customData[i].location = newLocation;
                        this.customDataDisplay[i].location = newLocation;
                    }
                    if(this.customData[i].productId === null || this.customData[i].productId === ''){
                        this.endLoading();
                       // this.displayWarningMessage('You need to specify a SKU remplacement for this line', 'Cannot update Ats');
                        return;
                    }
                    if(this.customData[i].location === null || this.customData[i].location === ''){
                        this.endLoading();
                      //  this.displayWarningMessage('You need to specify a location for this line', 'Cannot update Ats');
                        return;
                    }
                    this.lineIndex = i;
                    break;
                }
                
            }
            if(this.productLineItem === null || this.productLineItem === ''){
                this.endLoading();
                return;
            }
            getProductDetails({productLine : JSON.stringify(this.customData[this.lineIndex]) , currencyCode : this.currencyCode, priceBookId : this.priceBookId})
            .then(result => {
                const responseData = JSON.parse(result);
                if(responseData === undefined || responseData === null || responseData.length === 0 ){
                    if(newProdId !== null){
                        this.customData[this.lineIndex].productId = this.productLineItem.productId;
                        this.customDataDisplay[this.lineIndex].productId = this.productLineItem.productId;

                    }
                    this.endLoading();
                    this.displayWarningMessage('Selected product not linked to any pricebook', 'Cannot use selected product');
                    return;
                }
                this.customData[this.lineIndex].ats = responseData.ats;
                this.customData[this.lineIndex].pbEntryId = responseData.pbEntryId;
                this.customData[this.lineIndex].description = responseData.description;
                this.customData[this.lineIndex].skuExchange = responseData.skuExchange;
                this.customData[this.lineIndex].family = responseData.family;

                this.customDataDisplay[this.lineIndex].ats = responseData.ats;
                this.customDataDisplay[this.lineIndex].pbEntryId = responseData.pbEntryId;
                this.customDataDisplay[this.lineIndex].description = responseData.description;
                this.customDataDisplay[this.lineIndex].skuExchange = responseData.skuExchange;
                this.refresOutPutData();
                this.refreshAttributes();
                this.endLoading();
                
            })
            .catch(error => {
                this.customData[lineIndex].productId = this.productLineItem.productId;
                this.customDataDisplay[lineIndex].productId = this.productLineItem.productId;
                this.error = error;
                console.log('** SOM_ReturnItemsCreation_Component Exception error: ', error);
                this.refreshAttributes();
                this.endLoading();
                this.displayErrorMessage(error);
                
            });
        }
        catch (error) {
            console.log('** Exception error: ', error);
            this.refreshAttributes();
            this.endLoading();
            this.displayErrorMessage(error);
        }
         
    }

    handleNextButton() {
        this.startLoading();
        var countValidItem = 0;
        var listLines = this.customData.map(object => ({ ...object }));
        for(let i=0; i<this.customData.length; i++){
            const lineItem = JSON.parse(JSON.stringify(this.customData[i]))
            const itemValid = this.verifyLineItemValidation(lineItem);
            /*if(this.skusDelivery.includes(this.customData[i].skuExchange)){
                this.displayWarningMessage('shipping service products are not allowed','Warning');
                this.endLoading(); 
                return;
            }*/
            if(!itemValid && !this.isFromReturn && countValidItem > 0 ){
                this.displayWarningMessage('Select the missing Location or SKU, or delete the line.','Warning');
                this.endLoading(); 
                return;
            }

            if(itemValid){
                countValidItem ++;
                continue;
            }
            listLines = listLines.filter(element => element.sku !== lineItem.sku);
            
            
        }
        if(countValidItem <= 0){
            this.displayWarningMessage('Should provide at least one Line with valid data (SKU, Quantity and Location are mandatory) to process order creation.','Warning');
            this.endLoading();
            return;
        }
        this.OutputLineItems = listLines.map(object => ({ ...object }));
        this.endLoading();
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);

        
    }
    handlePreviousButton(){
        this.InputLineItems = this.OutputLineItems;
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    verifyLineItemValidation(lineItem){
        if(lineItem.quantity === null  || lineItem.quantity <= 0 || lineItem.productId === undefined){
            return false;
        }
        if(lineItem.productId === null  || lineItem.productId === '' || lineItem.productId === undefined){
            return false;
        }
        if(lineItem.location === null  || lineItem.location === '' || lineItem.location === undefined){
            return false;
        }
        return true;
    }

    handleRemoveItem(event){
        this.startLoading();
        this.currentLineKey = event.target.accessKey;
        
        for(let i=0; i<this.customData.length; i++){
            if( this.customData[i].sku === this.currentLineKey){
                const lineItem = JSON.parse(JSON.stringify(this.customData[i]));
                this.deleteArrayLineItem(lineItem);
                this.currentLineKey = '';
                this.refresOutPutData();
                this.endLoading();
                break;
            }
            
        }
        this.refresOutPutData();
        this.endLoading();

    }
    handleAddProduct(event){
        this.startLoading();
        var listLines = this.customData.map(object => ({ ...object }));
        listLines = listLines.filter(element => { return element.sku === event.target.accessKey || element.productId === '';});
        if(listLines.length > 0){
            this.displayWarningMessage('please complete the empty lines before creating new ones','Warning');
            this.endLoading();
            return;
        }
        this.incrementIndex ++;
        const newLine = {
            
            sku: 'sku'+this.incrementIndex,
            ats: 0,
            description: null,
            lineNumber: this.incrementIndex,
            location: '',
            originalQuantity: 1,
            pbEntryId: null,
            productId: '',
            family: '',
            quantity: 1,
            taxType: true,
            unitPrice: 0,
            taxValue: 0,
            taxRate: 0,
            lineTotal: 0,
            amountId: 'sku' + this.incrementIndex + '001',
            percentId: 'sku' + this.incrementIndex + '002',
        }
        
        
        
        this.customData.push(newLine);
        // this.customData = this.customData.map(rec => {
        //     return {
        //          ...rec,
        //          uniqueId: rec.sku + '001'
        //     }
        // })
        this.customDataDisplay = this.customData;
        this.refresOutPutData();
        this.endLoading();
    }

    deleteArrayLineItem(item){
            const lines = JSON.parse(JSON.stringify(this.customData));
            this.customData = lines.filter(element => element.sku !== item.sku);
            this.customDataDisplay = lines.filter(element => element.sku !== item.sku);

    }


    
    refreshAttributes(){
        this.currentLineKey = '';
        this.productLineItem = '';
        this.lineIndex = null;
    }
    refresOutPutData(){
        this.OutputLineItems = JSON.parse(JSON.stringify(this.customData));
        if(this.OutputLineItems.length > 0){
            this.displayNextButton = false;
        }else{
            this.displayNextButton = true;
        }
    }
    startLoading(){
        this.isLoading = true;
    }
    endLoading(){
        this.isLoading = false;
    }
    
    setSKUReplacementLabel(){
        if(this.isFromReturn){
            this.skuReplacementLabel = 'SKU Replacement';
        }else{
            this.skuReplacementLabel = 'SKU';
        }
        
    }

    displayErrorMessage(msgError){
        const evt = new ShowToastEvent({
            title: 'Error',
            message: msgError,
            variant: 'Error',
        });
        this.dispatchEvent(evt);
    }
    displayWarningMessage(msgError, tiltleMsg){
        const evt = new ShowToastEvent({
            title: tiltleMsg,
            message: msgError,
            variant: 'Warning',
        });
        this.dispatchEvent(evt);
    }

    

}