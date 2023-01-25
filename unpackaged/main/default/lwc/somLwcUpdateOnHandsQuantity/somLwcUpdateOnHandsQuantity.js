import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLocations from '@salesforce/apex/SOM_LWC_Update_OnHands_Controller.getLocations';
import getOnHand from '@salesforce/apex/SOM_LWC_Update_OnHands_Controller.getOnHand';
import getValidSkus from '@salesforce/apex/SOM_LWC_Update_OnHands_Controller.getValidSkus';
import updateOnHand from '@salesforce/apex/SOM_LWC_Update_OnHands_Controller.updateOnHand';
 
export default class SomLwcUpdateOnHandsQuantity extends LightningElement {
    locationPicklist;
    @track isLoading = false;
    @track isLoadingModal = false; 
    @api skuText = '';
    @api selectedLocation = '';
    @api oldOnHands = '';
    @api newOnHands;
    @track isShowModal = false;
    @api inventoryWr = {onHand : '',
                        effectiveDate:'',
                        safetyStockCount:''
                        };
    @api validSkusList = [];
                  
    showModalBox() {  
        this.isShowModal = true;
    }

    hideModalBox() {  
        this.isShowModal = false;
    }

    startLoading(){
        this.isLoading = true;
    }
    endLoading(){
        this.isLoading = false;
    }

    startLoadingModal(){
        this.isLoadingModal = true; 
    }

    endLoadingModal(){
        this.isLoadingModal = false; 
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    connectedCallback(){
        this.getListLocations();
        this.getListValidSkus();
    }

    getListValidSkus(){
        getValidSkus()
        .then(result => {
            if(result.length === 0){
                return;
            }
            this.validSkusList = result;
            
        })
        .catch(error => {
            this.error = error;
        });
        return
    }


    getListLocations() {

        getLocations()
        .then(result => {
            if(result.length === 0){
                return;
            }
            this.locationPicklist = result;
            
        })
        .catch(error => {
            this.error = error;
        });
        return
        
    }

    handleSKU(event){
        
        const skuValue = event.target.value;
        this.skuText = skuValue;
        if( skuValue === null || skuValue === undefined || skuValue === ''){
            this.oldOnHands = '';
            return;
        }
        if( this.selectedLocation === null || this.selectedLocation === undefined || this.selectedLocation === ''){
            this.oldOnHands = '';
            return;
        }

        if(!this.validSkusList.includes(this.skuText)){
            this.oldOnHands = '';
            return;
        }
        this.startLoading();
        getOnHand({locationEntry : this.selectedLocation, skuEntry :skuValue})
        .then(result => {
            if(result.length === 0){
                this.oldOnHands = '';
                return;
            }
            this.inventoryWr = result;
            this.oldOnHands = result.onHand;
            this.endLoading();
        })
        .catch(error => {
            this.oldOnHands = '';
            this.error = error;
            if(error.body.message.includes('LocationDoesNotExist')){
                this.showToast('Invalid Location', 'No Location Exist with ID: '+ this.selectedLocation + '. Please select another one.', 'error');
                this.selectedLocation = "";
                this.endLoading();
            }
            else{
                this.showToast('Something went wrong', 'We couldn\'t fetch the actual On Hand quantity. Please refresh the page and try again.', 'error');
                this.endLoading(); 
            }
        });
        
        return
   
    }

    handleLocation(event){
        const locationValue = event.target.value;
        this.selectedLocation = locationValue;
        if(locationValue === null || locationValue === ''){
            this.oldOnHands = '';
            return;
        }

        if( this.skuText === null || this.skuText === undefined || this.skuText === ''){
            this.oldOnHands = '';
            return;
        }

        if(!this.validSkusList.includes(this.skuText)){
            this.oldOnHands = '';
            return;
        }
        this.startLoading();
        getOnHand({locationEntry : locationValue, skuEntry : this.skuText})
        .then(result => {
            if(result.length === 0){
                this.oldOnHands = '';
                return;
            }
            this.inventoryWr = result;
            this.oldOnHands = result.onHand;
            this.endLoading();
            
        })
        .catch(error => {
            this.oldOnHands = '';
            this.error = error;
            if(error.body.message.includes('LocationDoesNotExist')){
                this.showToast('Invalid Location', 'No Location Exist with ID: '+ locationValue + '. Please select another one.', 'error');
                this.selectedLocation = "";
                this.endLoading();
            }
            else{
                this.showToast('Something went wrong', 'We couldn\'t fetch the actual On Hand quantity. Please refresh the page and try again.', 'error');
                this.selectedLocation = "";
                this.endLoading(); 
            }
            
            console.log('** Exception error: ', error);
        }); 
        
        return;
    }

    handleNewOnHands(event){
        this.newOnHands = event.target.value;
        
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleNextButton(){
        if(!this.validSkusList.includes(this.skuText)){
            this.showToast('Invalid SKU', 'You entered a product SKU that does not exist.','Warning');
            return;
        }
        if(this.isInputValid()) {
            this.showModalBox();
        }
        
    }

    updateOCI(){
        this.startLoadingModal();
        updateOnHand({locationEntry : this.selectedLocation, skuEntry : this.skuText, newOnHands : this.newOnHands, invRecord : this.inventoryWr})
        .then(result => {
            if(result == true){
                this.showToast('Success', 'The On Hand quantity was updated successfully ', 'success');
            }
            else if(result == false){
                this.showToast('Something went wrong', 'An error occured while updating OCI, please refer to your Administrator', 'error');
            }
            this.hideModalBox();
            this.endLoadingModal();
            return;
    
        })
        .catch(error => {
            this.error = error;
            this.showToast('Something went wrong', error.body.message , 'error');
            this.hideModalBox();
            this.endLoadingModal();
            
        }); 
    }
    

}