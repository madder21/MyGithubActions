import { LightningElement, api, wire, track } from 'lwc';
import getOrderDelievryGroupDetails from '@salesforce/apex/SOM_LWC_ExchangeOrderController.getOrderDelievryGroupDetails';
import getOrderDelievryMethods from '@salesforce/apex/SOM_LWC_ExchangeOrderController.getOrderDelievryMethods';
import getOrderDelievryMethodName from '@salesforce/apex/SOM_LWC_ExchangeOrderController.getOrderDelievryMethodName';
import getOSDetails from '@salesforce/apex/SOM_LWC_ExchangeOrderController.getOSDetails';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';

export default class Som_ExchangeOrderCreation_Component extends LightningElement {

    objectApiName = 'OrderSummary';
    @api recordId;

    @api osObj = {
        BillingStreet:"",
        BillingPostalCode:"",
        BillingCity:"",
        BillingCountry:"",
        BillingEmailAddress:"",
        BillingPhoneNumber:"",
        BillingContactFirstName__c:"",
        BillingContactLastName__c:"",
        BillingState:"",
        AccountId:"",
        Pricebook2Id:"",
    }

    @api prevOSObj = {}

    @track osEmailAddress;

    @track osPhoneNumber;
    handleBillPhone(event) {
        this.osPhoneNumber = event.target.value;
    }
    @track osFirstName;
    handleBillFirstName(event) {
        this.osFirstName = event.target.value;
    }

    @track osLastName;
    handleBillLastName(event) {
        this.osLastName = event.target.value;
    }

    @track osBillingStreet;
    handleBillStreet(event) {
        this.osBillingStreet = event.target.value;
    }
    @track osBillingPostalCode;
    handleBillPostalCode(event) {
        this.osBillingPostalCode = event.target.value;
    }
    @track osBillingCity;
    handleBillCity(event) {
        this.osBillingCity = event.target.value;
    }
    @track osBillingCountry;
    handleBillCountry(event) {
        this.osBillingCountry = event.target.value;
    }
    @track osBillingState;
    handleBillState(event) {
        this.osBillingState = event.target.value;
    }


    @api selectedODM = {
        Id:"",
        Name:"",
        
    }

    @api prevselectedODM = {}

    selectionODM(event){
        this.selectedODM.Id = event.target.value;
        getOrderDelievryMethodName({ mId: this.selectedODM.Id}).then((data) => {
            this.selectedODM.Name = data.Name;
        })
        .catch((error) => {
            this.error = error;
        });
    }

    @track odms;

    @api odgObj = {
        Description:"",
        EmailAddress:"",
        PhoneNumber:"",
        DeliverToName:"",
        DeliverToStreet:"",
        DeliverToPostalCode:"",
        DeliverToCity:"",
        DeliverToCountry:"",
        DeliverToState:""
    }

    @api prevODGObj = {}
    

    @track odgDescription;
    handleShipDescription(event) {
        this.odgDescription = event.target.value;
    }
    @track odgEmailAddress;
    handleShipEmail(event) {
        this.odgEmailAddress = event.target.value;
    }
    @track odgPhoneNumber;
    handleShipPhone(event) {
        this.odgPhoneNumber = event.target.value;
    }
    @track odgName;
    handleShipName(event) {
        this.odgName = event.target.value;
    }
    @track odgShippingStreet;
    handleShipStreet(event) {
        this.odgShippingStreet = event.target.value;
    }
    @track odgShippingPostalCode;
    handleShipPostalCode(event) {
        this.odgShippingPostalCode = event.target.value;
    }
    @track odgShippingCity;
    handleShipCity(event) {
        this.odgShippingCity = event.target.value;
    }
    @track odgShippingCountry;
    @track odgDeliverToState;
    handleDeliverToState(event) {
        this.odgDeliverToState = event.target.value;
    }

    connectedCallback(){
        if(Object.keys(this.prevODGObj).length === 0 && Object.keys(this.prevOSObj).length === 0 && Object.keys(this.prevselectedODM).length === 0){
            getOSDetails({ OsId: this.recordId }).then((data) => {
                this.selectedODM.Id   = data.OrderDeliveryGroupSummaries[0].OrderDeliveryMethodId;
                this.selectedODM.Name = data.OrderDeliveryGroupSummaries[0].OrderDeliveryMethod.Name;
                this.osEmailAddress                   = data.BillingEmailAddress;
                this.osPhoneNumber                    = data.BillingPhoneNumber;
                this.osFirstName                      = data.BillingContactFirstName__c;
                this.osLastName                       = data.BillingContactLastName__c;
                this.osBillingStreet                  = data.BillingStreet;
                this.osBillingPostalCode              = data.BillingPostalCode;
                this.osBillingCity                    = data.BillingCity;
                this.osBillingCountry                 = data.BillingCountry;
                this.osBillingState                   = data.BillingState;
                this.osObj.BillingStreet              = this.osBillingStreet;
                this.osObj.BillingPostalCode          = this.osBillingPostalCode;
                this.osObj.BillingCity                = this.osBillingCity;
                this.osObj.BillingCountry             = this.osBillingCountry;
                this.osObj.BillingEmailAddress        = data.BillingEmailAddress;
                this.osObj.BillingPhoneNumber         = this.osPhoneNumber;
                this.osObj.BillingContactFirstName__c = this.osFirstName;
                this.osObj.BillingContactLastName__c  = this.osLastName;
                this.osObj.Pricebook2Id               = data.Pricebook2Id;
                this.osObj.AccountId                  = data.AccountId;
                this.osObj.BillingState               = this.osBillingState;
            })
            .catch((error) => {
                this.error = error;
            });
            getOrderDelievryGroupDetails({ OsId: this.recordId }).then((data) => {
                this.odgDescription        = data.Description;
                this.odgEmailAddress       = data.EmailAddress;
                this.odgPhoneNumber        = data.PhoneNumber;
                this.odgName               = data.DeliverToName;
                this.odgShippingStreet     = data.DeliverToStreet;
                this.odgShippingPostalCode = data.DeliverToPostalCode;
                this.odgShippingCity       = data.DeliverToCity;
                this.odgShippingCountry    = data.DeliverToCountry;
                this.odgDeliverToState     = data.DeliverToState;
                this.odgObj.Description         = this.odgDescription;
                this.odgObj.EmailAddress        = this.odgEmailAddress;
                this.odgObj.PhoneNumber         = this.odgPhoneNumber;
                this.odgObj.DeliverToName       = this.odgName;
                this.odgObj.DeliverToStreet     = this.odgShippingStreet;
                this.odgObj.DeliverToPostalCode = this.odgShippingPostalCode;
                this.odgObj.DeliverToCity       = this.odgShippingCity;
                this.odgObj.DeliverToCountry    = this.odgShippingCountry;
                this.odgObj.DeliverToState      = this.odgDeliverToState;
            })
            .catch((error) => {
                this.error = error;
            });

            //in case of previous button : display the information already entered by the user
        }else{
            this.odgDescription        = this.prevODGObj.Description;
            this.odgEmailAddress       = this.prevODGObj.EmailAddress;
            this.odgPhoneNumber        = this.prevODGObj.PhoneNumber;
            this.odgName               = this.prevODGObj.DeliverToName;
            this.odgShippingStreet     = this.prevODGObj.DeliverToStreet;
            this.odgShippingPostalCode = this.prevODGObj.DeliverToPostalCode;
            this.odgShippingCity       = this.prevODGObj.DeliverToCity;
            this.odgShippingCountry    = this.prevODGObj.DeliverToCountry;
            this.odgDeliverToState     = this.prevODGObj.DeliverToState;
            this.selectedODM.Id                   = this.prevselectedODM.Id;
            this.selectedODM.Name                 = this.prevselectedODM.Name;
            this.osEmailAddress                   = this.prevOSObj.BillingEmailAddress;
            this.osPhoneNumber                    = this.prevOSObj.BillingPhoneNumber;
            this.osFirstName                      = this.prevOSObj.BillingContactFirstName__c;
            this.osLastName                       = this.prevOSObj.BillingContactLastName__c;
            this.osBillingStreet                  = this.prevOSObj.BillingStreet;
            this.osBillingPostalCode              = this.prevOSObj.BillingPostalCode;
            this.osBillingCity                    = this.prevOSObj.BillingCity;
            this.osBillingCountry                 = this.prevOSObj.BillingCountry;
            this.osBillingState                   = this.prevOSObj.BillingState;
            this.odgObj.Description         = this.prevODGObj.Description;
            this.odgObj.EmailAddress        = this.prevODGObj.EmailAddress;
            this.odgObj.PhoneNumber         = this.prevODGObj.PhoneNumber;
            this.odgObj.DeliverToName       = this.prevODGObj.DeliverToName;
            this.odgObj.DeliverToStreet     = this.prevODGObj.DeliverToStreet;
            this.odgObj.DeliverToPostalCode = this.prevODGObj.DeliverToPostalCode;
            this.odgObj.DeliverToCity       = this.prevODGObj.DeliverToCity;
            this.odgObj.DeliverToCountry    = this.prevODGObj.DeliverToCountry;
            this.odgObj.DeliverToState      = this.prevODGObj.DeliverToState;
            this.osObj.BillingStreet              = this.prevOSObj.BillingStreet;
            this.osObj.BillingPostalCode          = this.prevOSObj.BillingPostalCode;
            this.osObj.BillingCity                = this.prevOSObj.BillingCity;
            this.osObj.BillingCountry             = this.prevOSObj.BillingCountry;
            this.osObj.BillingEmailAddress        = this.prevOSObj.BillingEmailAddress;
            this.osObj.BillingPhoneNumber         = this.prevOSObj.BillingPhoneNumber;
            this.osObj.BillingContactFirstName__c = this.prevOSObj.BillingContactFirstName__c;
            this.osObj.BillingContactLastName__c  = this.prevOSObj.BillingContactLastName__c;
            this.osObj.BillingState               = this.prevOSObj.BillingState;
            this.osObj.Pricebook2Id               = this.prevOSObj.Pricebook2Id;
            this.osObj.AccountId                  = this.prevOSObj.AccountId;
        }

    }

    @wire(getOrderDelievryMethods, { country: '$odgShippingCountry'})
    odmList({ error, data }) {
        if (data) {
            this.odms = data.filter((dataitem) => dataitem.Id != this.selectedODM.Id);
        } else if (error) {
            console.log('Something went wrong:', error);
        }

    }
    regInpPhone() {
        var isValidVal = true;
        var inputFields = this.template.querySelectorAll('.checks');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValidVal = false;
            }
        });
        return isValidVal;
    }

    handleGoNext() {
        if(this.regInpPhone()) {            
            var inputFields = this.template.querySelectorAll('.checks');
            inputFields.forEach(inputField => {               
                inputField.value="";
            });
            this.odgObj.Description = this.odgDescription;
            this.odgObj.PhoneNumber = this.odgPhoneNumber;
            this.odgObj.EmailAddress = this.odgEmailAddress;
            this.odgObj.DeliverToStreet = this.odgShippingStreet;
            this.odgObj.DeliverToPostalCode = this.odgShippingPostalCode;
            this.odgObj.DeliverToCity = this.odgShippingCity;
            this.odgObj.DeliverToName = this.odgName;
            this.odgObj.DeliverToState = this.odgDeliverToState;
            this.osObj.BillingStreet              = this.osBillingStreet;
            this.osObj.BillingPostalCode          = this.osBillingPostalCode;
            this.osObj.BillingCity                = this.osBillingCity;
            this.osObj.BillingCountry             = this.osBillingCountry;
            this.osObj.BillingPhoneNumber         = this.osPhoneNumber;
            this.osObj.BillingContactFirstName__c = this.osFirstName;
            this.osObj.BillingContactLastName__c  = this.osLastName;
            this.osObj.BillingState               = this.osBillingState;
            this.prevOSObj = this.osObj;
            this.prevODGObj = this.odgObj;
            this.prevselectedODM = this.selectedODM;
            const navigateNextEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            
        }

    }


}