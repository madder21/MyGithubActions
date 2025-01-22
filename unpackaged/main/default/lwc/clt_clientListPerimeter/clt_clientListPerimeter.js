import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getCountryValuesFromSelectedRegions from '@salesforce/apex/CLT_ClientListPerimeterCtrl.getCountryValuesFromSelectedRegions';
import getStoreValuesFromSelectedCountries from '@salesforce/apex/CLT_ClientListPerimeterCtrl.getStoreValuesFromSelectedCountries';
import updateClientListPerimeter from '@salesforce/apex/CLT_ClientListPerimeterCtrl.updateClientListPerimeter';
import getInitializationPerimeter from '@salesforce/apex/CLT_ClientListPerimeterCtrl.getInitializationPerimeter';
//custom labels
import perimeterUpdateSuccess from '@salesforce/label/c.CLT_CLPerimeterUpdateSuccess';
import success from '@salesforce/label/c.CLT_Success';
import errorLabel from '@salesforce/label/c.CLT_Error';
import region from '@salesforce/label/c.CLT_Region';
import country from '@salesforce/label/c.CLT_Country';
import store from '@salesforce/label/c.CLT_Store';
import cancel from '@salesforce/label/c.CLT_Cancel';
import done from '@salesforce/label/c.CLT_Done';
import edit from '@salesforce/label/c.CLT_Edit';

export default class Clt_clientListPerimeter extends LightningElement {
    @api recordId;
    
    @track regionList;
    @track countryList;
    @track storeList;
    @track initRegions;
    @track initCountries;
    @track initStores;

    @track countryOptions = [];
    @track filteredCountryOptions = [];
    @track storeOptions = [];
    @track isEditMode = false;

    @track selectedRegions = [];
    @track defaultRegions = [];
    @track selectedCountries = [];
    @track defaultCountries = [];
    @track selectedStores = [];
    @track defaultStores = [];
    @track isReadOnly = !this.isEditMode;

    //labels to use
    label = {
        region,
        country,
        store,
        cancel,
        done,
        edit
    };

    constructor() {
        super();
    }

    @wire(getInitializationPerimeter, {
        clientListId: '$recordId'
    })
    wireGetInitializationPerimeter({error, data}){
        if(data){
            this.regionList = data.regions.map(v => { return { value: v.value, label: v.label }});
            this.countryList = data.countries.map(v => { return { value: v.value, label: v.label }});
            this.storeList = data.stores.map(v => { return { value: v.value, label: v.label }});
            this.initRegions = this.regionList;
            this.initCountries = this.countryList;
            this.initStores = this.storeList;
            this.selectedRegions = data.selectedRegions;
            this.defaultRegions = data.selectedRegions;
            this.template.querySelector('.region-multi-select').setDefaultValues(this.selectedRegions);
            this.selectedCountries = data.selectedCountries;
            this.defaultCountries = data.selectedCountries;
            this.template.querySelector('.country-multi-select').setDefaultValues(this.selectedCountries);
            this.selectedStores = data.selectedStores;
            this.defaultStores = data.selectedStores;
            this.template.querySelector('.store-multi-select').setDefaultValues(this.selectedStores);
        }
        if(error){
            console.log(error);
        }
    }

    handleRegionSet(event) {
        this.selectedRegions = event.target ? event.target.selectedValues : event;
        getCountryValuesFromSelectedRegions({
            regions: this.selectedRegions
        })
        .then((result) => {
            this.countryList = result.map(v => { return { value: v.value, label: v.label }});
            if(this.countryList.length === 0) {
                this.selectedCountries = [];
            }
            else if(this.selectedCountries.length > 0) {
                let countriesToSelect = [];
                this.countryList.forEach(element => {
                    if(this.selectedCountries.includes(element.value)) {
                        countriesToSelect.push(element.value);
                    }
                });
                this.selectedCountries = countriesToSelect;
            }
            this.template.querySelector('.country-multi-select').setSelectedValues(this.selectedCountries);
            this.handleCountrySet(this.selectedCountries);
        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleCountrySet(event) {
        this.selectedCountries = event.target ? event.target.selectedValues : event;
        getStoreValuesFromSelectedCountries({
            countries: this.selectedCountries
        })
        .then((result) => {
            this.storeList = result.map(v => { return { value: v.value, label: v.label }});
            if(this.storeList.length === 0) {
                this.selectedStores = [];
            }
            else if(this.selectedStores.length > 0) {
                let storesToSelect = [];
                this.storeList.forEach(element => {
                    if(this.selectedStores.includes(element.value)) {
                        storesToSelect.push(element.value);
                    }
                });
                this.selectedStores = storesToSelect;
            }
            this.template.querySelector('.store-multi-select').setSelectedValues(this.selectedStores);
        })
        .catch((error) => {
            console.log(error);
        });
    }

    handleStoreSet(event) {
        this.selectedStores = event.target ? event.target.selectedValues : event;
    }

    handleOpenList(event) {
        const sourceId = event.detail.source;
        const multiSelectComponents = this.template.querySelectorAll('c-clt_multi-select');
        multiSelectComponents.forEach(component => {
            if (component.uniqueId !== sourceId) {
                component.closeListIfOpened();
            }
        });
    }

    handleEditClick() {
        this.isEditMode = true;
        this.isReadOnly = false;
    }

    handleCancelClick() {
        this.regionList = this.initRegions;
        this.selectedRegions = this.defaultRegions;
        this.template.querySelector('.region-multi-select').setDefaultValues(this.selectedRegions);
        this.countryList = this.initCountries;
        this.selectedCountries = this.defaultCountries;
        this.template.querySelector('.country-multi-select').setDefaultValues(this.selectedCountries);
        this.storeList = this.initStores;
        this.selectedStores = this.defaultStores;
        this.template.querySelector('.store-multi-select').setDefaultValues(this.selectedStores);
        this.isEditMode = false;
        this.isReadOnly = true;
    }

    handleDoneClick() {
        this.isEditMode = false;
        this.isReadOnly = true;
        updateClientListPerimeter({
            clientListId: this.recordId, 
            regions: this.selectedRegions, 
            countries: this.selectedCountries, 
            stores: this.selectedStores
        })
        .then(result => {
            // Showing Success message after perimeter update
            this.dispatchEvent(
                new ShowToastEvent({
                    title: success,
                    message: perimeterUpdateSuccess,
                    variant: 'success',
                }),
            );
            // location.reload();
        })
        .catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: errorLabel,
                    message: (error.body) ? error.body.message : error.message,
                    variant: 'error',
                }),
            );
        });
    }
}