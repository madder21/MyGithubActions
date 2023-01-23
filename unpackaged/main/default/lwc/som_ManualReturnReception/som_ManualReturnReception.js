import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import getCondtions from '@salesforce/apex/SOM_Manual_RO_Reception_Controller.getCondtions';
import getFollowUps from '@salesforce/apex/SOM_Manual_RO_Reception_Controller.getFollowUps';
import getReturnOrderLineItems from '@salesforce/apex/SOM_Manual_RO_Reception_Controller.getReturnOrderLineItems';
import getShipmentSerialNumbers from '@salesforce/apex/SOM_Manual_RO_Reception_Controller.getShipmentSerialNumbers';



export default class Som_ManualReturnReception extends LightningElement {

    @api recordId;
    @api listOutputLine;
    @api listOutputDataWithDetails;
    @track isLoading = false;
    @track customData;
    displayNextButton = false;
    conditionPicklist;
    followUpPicklist;
    listSkus;
    mapSerialNumberByOis;
    

    connectedCallback(){ 
        console.log('$$ Start Som_ManualReturnReception.connectedCallback $$');
        try {
            console.log(' this.recordId ', this.recordId);
            this.startLoading();
            this.getConditionPicklistValues();
            this.getFollowUpPicklistValues();
            if(this.listOutputDataWithDetails !== undefined && this.listOutputDataWithDetails !== null && this.listOutputDataWithDetails.length>0){
                console.log('listOutputLine not empty ');
                const initialData = this.listOutputDataWithDetails.map(object => ({ ...object }));
                this.customData = initialData;
                this.getSerialNumbers();
                this.endLoading();
                return;
            }
            this.getListInitialROLIsByRoId();
            this.endLoading();
        } catch (error) {
            console.log('** Exception error: ', error);
            this.endLoading(); 
        }
    }

    getConditionPicklistValues() {
        console.log('>> getConditionPicklistValues');
        try {
            getCondtions()
            .then(result => {
                if(result.length === 0){
                    this.displayWarningMessage('Somethings wrong while retrieving Condition Values','No Condtion Value founded');
                    return;
                }
                this.conditionPicklist = result;
            })
            .catch(error => {
                this.error = error;
            });
            return
        } catch (error) {
            console.log('** getConditionPicklistValues error: ', error);
        }  
    }

    getFollowUpPicklistValues() {
        console.log('>> getFollowUpPicklistValues');
        try {
            getFollowUps()
            .then(result => {
                if(result.length === 0){
                    this.displayWarningMessage('Somethings wrong while retrieving FollowUp Values','No FollowUp Value founded');
                    return;
                }
                this.followUpPicklist = result; 
            })
            .catch(error => {
                this.error = error;
            });
            return
        } catch (error) {
            console.log('** getFollowUpPicklistValues error: ', error);
        }  
    }
    

    getListInitialROLIsByRoId() {
        console.log('$$ getListInitialROLIsByRoId');
        try {
            getReturnOrderLineItems({returnOrderId : this.recordId})
            .then(result => {
                console.log('** result: ', JSON.parse(result));
                this.customData = JSON.parse(result);
                this.getSerialNumbers();
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('$$ getListInitialROLIsByRoId error: ', error);
        }
    }
    getSerialNumbers() {
        console.log('$$ getSerialNumbers');
        try {
            this.listSkus = [];
            this.customData.forEach(lineItem =>{
                if(lineItem.OrderItemSummary.isSerialized__c){
                    this.listSkus.push(lineItem.OrderItemSummaryId);
                }  
            });
            console.log('list Sku : ', this.listSkus);
            getShipmentSerialNumbers({listIds : JSON.stringify(this.listSkus)})
            .then(result => {
                const resData = JSON.parse(result);
                this.mapSerialNumberByOis = [];
                for (let key in resData) {
                    this.mapSerialNumberByOis.push({value:resData[key], key:key});
                }
                console.log('** this.mapSerialNumberByOis ', this.mapSerialNumberByOis);
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('$$ getSerialNumbers error: ', error);
        }
    }

    handleSerialNumberChange(event){
        console.log('$$ handleSerialNumberChange');
        try{
            this.startLoading();
            const lineId = event.target.accessKey;
            const newSerialNumberValue = event.target.value;
            var lineItem = this.customData.filter(element => element.Id === lineId);
            lineItem[0].SerialNumber__c = newSerialNumberValue;
            const inputSerialNumbers = (newSerialNumberValue||'').split(';');
            console.log('inputSerialNumbers',inputSerialNumbers);
            this.endLoading();
        
        }
        catch(error){
            console.log('>> error ',error);
            this.endLoading();
        }

        
    }

    handleConditionChange(event){
        try{
            console.log('$$ handleConditionChange');
            this.startLoading();
            const lineId = event.target.accessKey;
            const newConditionValue = event.target.value;
            var lineItem = this.customData.filter(element => element.Id === lineId);
            lineItem[0].ConditionId__c = newConditionValue;
            this.endLoading();
        }
        catch(error){
            console.log('>> error ',error);
            this.endLoading();
        }
    }

    handleFollowUpChange(event){
        console.log('$$ handleFollowUpChange');
        try{
            this.startLoading();
            const lineId = event.target.accessKey;
            const newFollowUpValue = event.target.value;
            var lineItem = this.customData.filter(element => element.Id === lineId);
            lineItem[0].RepaymentMethod = newFollowUpValue;
            this.endLoading();
        }
        catch(error){
            console.log('>> error ',error);
            this.endLoading();
        }
    }

    handleQuantityRecievedChange(event){
        console.log('$$ handleQuantityRecievedChange');
        try{
            this.startLoading();
            const lineId = event.target.accessKey;
            const newQuantityValue = parseInt(event.target.value);
            var lineItem = this.customData.filter(element => element.Id === lineId);
            const receivedQte = lineItem[0].QuantityReceived;
            // if(newQuantityValue === 0){
            //     this.displayWarningMessage('Quantity Received should be greater than 0 ','Bad value for Quantity Received');
            // }
            lineItem[0].QuantityReceived = newQuantityValue;

            this.endLoading();
        
        }
        catch(error){
            console.log('>> error ',error);
            this.endLoading();
        }

    }
    prepareOutPutForNextScreen(){
        try{
            console.log('> prepareOutPutForNextScreen  ');
            this.listOutputLine = [];
            this.listOutputDataWithDetails = [];
            var listData = this.customData.map(object => ({ ...object }));
            var globalErrorMsg = '';
            var countQ0 = 0;
            var inputSerialNumberEmpty = false;
            for(let i=0; i<listData.length; i++){
                const existLine = listData[i];
                if(existLine.QuantityReceived === 0){
                    countQ0 ++;
                }
                if(existLine.OrderItemSummary.isSerialized__c){ 
                    if(existLine.SerialNumber__c !== '' && (existLine.SerialNumber__c === undefined || existLine.SerialNumber__c === null || existLine.SerialNumber__c === '')){
                        //display warning
                        inputSerialNumberEmpty = true;
                        continue;
                    }
                    if(inputSerialNumberEmpty){
                        continue;
                    }
                    var LineData = this.mapSerialNumberByOis.filter(element => element.key === existLine.OrderItemSummaryId);
                    if(LineData.length === 0){
                        //display warning
                        globalErrorMsg = 'unable to find a shipment Item with serial Number match the  ReturnOrderLineItem with SKU '+ existLine.Sku__c + '\n';
                    }
                    if(globalErrorMsg !== ''){
                        continue;
                    }
                    var srNbrValid = true;
                    var errorMessage = '';
                    var inputSerialNumbers = [];
                    if(existLine.SerialNumber__c !== ''){
                        inputSerialNumbers = (existLine.SerialNumber__c||'').split(';');
                    }
                    if(inputSerialNumbers.length !== existLine.QuantityReceived){
                        globalErrorMsg = globalErrorMsg + 'Entered Serial Numbers ' + errorMessage + ' should match the Quantity Received for the SKU '+existLine.Sku__c+' | ';
                        continue;
                    }
                    if(globalErrorMsg !== ''){
                        continue;
                    }
                    inputSerialNumbers.forEach(sNumber =>{
                        var filterSkus = LineData[0].value.filter(element => element === sNumber);
                        if(filterSkus.length === 0){
                            srNbrValid = false;
                            errorMessage = errorMessage + sNumber + ';';
                        }
                    });
                    if(errorMessage !== ''){
                        // dipslay error message
                        globalErrorMsg = globalErrorMsg + 'Entered Serial Numbers ' + errorMessage + ' are not matching the existing on shipment Items related to SKU '+existLine.Sku__c+' | ';
                        continue;
                    }
                    if(globalErrorMsg !== ''){
                        continue;
                    }
                }
                const newLine = { 
                    ConditionId__c: existLine.ConditionId__c,
                    Description: existLine.Description,
                    Id: existLine.Id,
                    OrderItemSummaryId: existLine.OrderItemSummaryId,
                    QuantityReceived: existLine.QuantityReceived,
                    QuantityExpected: existLine.QuantityReceived,
                    RepaymentMethod: existLine.RepaymentMethod,
                    ReturnOrderLineItemNumber: existLine.ReturnOrderLineItemNumber,
                    Sku__c: existLine.Sku__c,
                    SerialNumber__c: existLine.SerialNumber__c
                }
                this.listOutputLine.push(newLine);
                this.listOutputDataWithDetails.push(existLine);
            }

            if(countQ0 == listData.length){
                this.displayWarningMessage('at least one line must have quantity greater than zero','Warning');
                this.endLoading();
                return false;
            }
            if(inputSerialNumberEmpty){
                this.displayWarningMessage('a value for Serial Number is required','Manadatory inputs are missing');
                this.endLoading();
                return false;
            }
            if(globalErrorMsg !== ''){
                this.displayWarningMessage(globalErrorMsg, 'Warning');
                this.endLoading();
                return false;
            }
            return true;
            
        }
        catch(error){
            this.endLoading();
            this.displayErrorMessage(JSON.stringify(error),'Error');
        }
    }
    handleNextButton() {
        this.startLoading();
        const isSuccess = this.prepareOutPutForNextScreen();
        if(!isSuccess){
            return;
        }
         

        this.endLoading();
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
        
    }
    handlePreviousButton(){

        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    startLoading(){
        this.isLoading = true;
    }
    endLoading(){
        this.isLoading = false;
    }
    
    refresOutPutLines(){
        this.listOutputLine = JSON.parse(JSON.stringify(this.customData));
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