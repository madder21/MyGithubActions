import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

import getReturnReasons from '@salesforce/apex/somLwcProductChangesSelection_Controller.getReturnReasons';
import getCurrency from '@salesforce/apex/somLwcProductChangesSelection_Controller.getCurrency';


export default class SomLwcProductChangesSelection extends LightningElement {

    @api orderSummaryId;
    @api selectedOrderItemSummaries; 
    @api OutputLineItems;
    @track customData = [];
    @track customOutputData = [];
    @track ammountType = true; 
    @track percentType = false; 
    @track amountId = 'sku001';
    @track percentId= 'sku002';
    currentLineId;
    currentLineKey;
    currentLineValue;
    ReturnReasonPicklist;

    connectedCallback(){ 
        try {
            this.startLoading();
            this.customData = this.selectedOrderItemSummaries;
            this.customOutputData = this.OutputLineItems;
            const initialData = this.OutputLineItems.map(object => ({ ...object }));
            this.getCurrency();
            this.prepareOutPutForNextScreen();
            this.getReturnReasonsPicklistValues();
            //this.getLineItems();
            this.endLoading();
        } catch (error) {
            console.log('** Exception error: ', error);
            this.endLoading(); 
        }
    }

    handleClickType(event){
        this.currentLineKey = event.target.value;
        for(let i=0; i<this.customOutputData.length; i++){
            if(this.customData[i].taxType === false && this.customData[i].amountId === this.currentLineKey){
                this.customOutputData[i].lineTotal = 0;
                this.customOutputData[i].taxType = true;
                this.customData[i].taxType = true;
                this.customData[i].discountType = 'AmountWithTax';
                this.currentLineKey = '';
                this.refresOutPutData();
                break;
            }
            else if(this.customData[i].taxType === true && this.customData[i].percentId === this.currentLineKey){
                this.customOutputData[i].lineTotal = 0;
                this.customOutputData[i].taxType = false;
                this.customData[i].taxType = false;
                this.customData[i].discountType = 'Percentage';
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
            let getDiscountValue = this.template.querySelector('.DiscountValue11');
            if( this.customData[i].taxType === true && this.customData[i].sku === this.currentLineKey){
                //let getDiscountValue = this.template.querySelector('.DiscountValue11');
                if(valEntered > this.customData[i].TotalPrice ){
                    getDiscountValue.setCustomValidity('The number is too high.');
                    this.customOutputData[i].lineTotal = 0;
                    this.displayToastError();
                }else{
                    getDiscountValue.setCustomValidity('');
                this.customData[i].taxValue = valEntered;
                this.customData[i].lineTotal = valEntered ;
                this.customData[i].discountValue = -valEntered;
                this.customOutputData[i].lineTotal = valEntered;
                
                
                this.currentLineKey = '';
                this.refresOutPutData();
                
                break;   
                } 
                getDiscountValue.reportValidity();
            }  
            else if( this.customData[i].taxType === false && this.customData[i].sku === this.currentLineKey){
                if(valEntered > 100 ){
                    getDiscountValue.setCustomValidity('The number is too high.');
                    this.customOutputData[i].lineTotal = 0;
                }else{
                    getDiscountValue.setCustomValidity('');
                itemTaxVal = (valEntered * this.customData[i].TotalPrice) / (100);
                this.customData[i].taxRate = valEntered;
                this.customData[i].lineTotal = itemTaxVal;
                this.customOutputData[i].lineTotal = itemTaxVal;
                this.customData[i].discountValue = -valEntered;
                this.currentLineKey = '';
                this.refresOutPutData();
                
                break;    
                }
                getDiscountValue.reportValidity();
            }  
        }
        
    }

    handleReturnReasonChange(event){
        this.currentLineKey = event.target.accessKey;
        this.currentLineValue = event.target.value;
        for(let i=0; i<this.customData.length; i++){
            if(  this.customData[i].sku === this.currentLineKey){
                this.customData[i].reason = this.currentLineValue ;
                this.currentLineKey = '';
                this.refresOutPutData();
                
                break;   
                } 
            }  
    }

    handleDiscountNoteChange(event){
        this.currentLineKey = event.target.accessKey;
        this.currentLineValue = event.target.value;
        for(let i=0; i<this.customData.length; i++){
            if(  this.customData[i].sku === this.currentLineKey){
                this.customData[i].discountNote = this.currentLineValue ;
                this.currentLineKey = '';
                this.refresOutPutData();
                
                break;   
                } 
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
    getReturnReasonsPicklistValues() {
        try {
            getReturnReasons()
            .then(result => {
                if(result.length === 0){
                    this.displayWarningMessage('Somethings wrong while retrieving FollowUp Values','No FollowUp Value founded');
                    return;
                }
                this.ReturnReasonPicklist = result; 
            })
            .catch(error => {
                this.error = error;
            });
            return
        } catch (error) {
            console.log('** getFollowUpPicklistValues error: ', error);
        }  
    }

    prepareOutPutForNextScreen(){
        
        try{
            const initialData = this.OutputLineItems.map(object => ({ ...object }));
                this.customOutputData = initialData;
                this.customData = initialData;

            for(let i=0; i<this.selectedOrderItemSummaries.length; i++){ 
                this.customOutputData[i].sku = this.selectedOrderItemSummaries[i].StockKeepingUnit ;
                this.customOutputData[i].description = this.selectedOrderItemSummaries[i].Name;
                this.customOutputData[i].orderItemSummaryId = this.selectedOrderItemSummaries[i].Id;
                this.customOutputData[i].discountType = 'AmountWithTax';
                this.customOutputData[i].discountValue = 0; 
                this.customOutputData[i].reason = '';
                this.customOutputData[i].discountNote = '';
                this.customOutputData[i].taxType = true,
                this.customOutputData[i].lineTotal = 0;
                this.customOutputData[i].amountId = 'sku' + i + '001';
                this.customOutputData[i].percentId = 'sku' + i + '002';
                this.customOutputData[i].TotalPrice = this.selectedOrderItemSummaries[i].AdjustedLineAmtWithTax;
            }   
                //this.customOutputData.push(newLine);
            this.customData = this.customOutputData;
        }catch(error){
            this.endLoading();
            console.log('** error: ', error);
            //this.displayErrorMessage(JSON.stringify(error),'Error');
        }
    } 
    getLineItems(){
        // const initialData = this.OutputLineItems.map(object => ({ ...object }));
        //          this.customOutputData = initialData;
        try {
            getLineItems({selectedOrderItemSummaries : this.selectedOrderItemSummaries})
            .then(result => {
                this.OutputLineItems = JSON.parse(result);

            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('*SomLwcDisplayOrderItems* SomLwcDisplayOrderItems Exception error: ', error);
        }
    }
    startLoading(){
        this.isLoading = true;
    }
    endLoading(){
        this.isLoading = false;
    }

    refresOutPutData(){
        try {
            this.OutputLineItems = JSON.parse(JSON.stringify(this.customData));
        } catch (error) {
            console.log('**$$** error: ', error);  
        }
    }
    displayToastError() {
        const toastEvt = new ShowToastEvent({
            title: 'Error',
            message: 'Some Error Occurred',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(toastEvt);
    }
    
}