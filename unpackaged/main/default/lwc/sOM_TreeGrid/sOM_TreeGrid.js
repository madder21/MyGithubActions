import { LightningElement, wire,track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { RefreshEvent } from 'lightning/refresh';
import {refreshApex} from '@salesforce/apex';

import ACCOUNT_OBJECT from "@salesforce/schema/STWNurembergDeliveryMethod__c";
import COUNTRY_FIELD from "@salesforce/schema/STWNurembergDeliveryMethod__c.country__c";
import POSTALCODE_FIELD from "@salesforce/schema/STWNurembergDeliveryMethod__c.postalCode__c";
import STOREORIGIN_FIELD from "@salesforce/schema/STWNurembergDeliveryMethod__c.storeOrigin__c";
import DELIVERYMETHOD_FIELD from "@salesforce/schema/STWNurembergDeliveryMethod__c.deliveryMethodId__c";
import DdeliveryMethod_FIELD from "@salesforce/schema/STWNurembergDeliveryMethod__c.deliveryMethod__c";



// Import Apex
import getAllParentCases from "@salesforce/apex/SOM_DynamicTreeGridController.getAllParentCases";
import getChildCases from "@salesforce/apex/SOM_DynamicTreeGridController.getChildCases";
import delSTW from "@salesforce/apex/SOM_DynamicTreeGridController.delSTW";
import getCreateRecordLevel from "@salesforce/apex/SOM_DynamicTreeGridController.getCreateRecordLevel";
import getOrderDeliveryMethod from '@salesforce/apex/SOM_DynamicTreeGridController.getOrderDeliveryMethod';
import createSTW from '@salesforce/apex/SOM_DynamicTreeGridController.createSTW';




const actions = [
    { label: 'New', name: 'add' },
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];

// Global Constants
const COLS = [
	{ fieldName: "storeOrigin__c", label: "Store Origin" },
	{ fieldName: "country__c", label: " Country" },
	{ fieldName: "postalCode__c", label: "Postal Code" },
	{ fieldName: "DeliveryMethodName__c", label: "Delivery Method" },
	{   label: '',
	type: 'action',
	initialWidth:'50px',
	typeAttributes: { rowActions: actions },
},     
];

export default class DynamicTreeGrid extends NavigationMixin(LightningElement) {

	@track isShowModal = false;
    @track showStoreOrigin = false;
	@track showCountry = false;
	@track showDelivery = false;

    hideModalBox() {  
		this.isShowModal = false;
		this.showStoreOrigin = false;
		this.showCountry = false;
		this.showDelivery = false;
	
    }

	accountObject = ACCOUNT_OBJECT;
	@track recId ;
	@track recordID;
	@track Level;

	@track deliveryMethod = DELIVERYMETHOD_FIELD;
	@track storeOrigin = STOREORIGIN_FIELD;
	@track postalCode = POSTALCODE_FIELD;
	@track country = COUNTRY_FIELD;

  	@track rec = {};
	@track locationPicklist;

	

	gridColumns = COLS;
	isLoading = true;
	@track gridData = [];
	hasChildContent = false;
	wiredAccountsResult;

	@wire(getAllParentCases)
    wiredAccounts(result) {
        this.wiredAccountsResult = result;
        if (result.data) {
			this.gridData = result.data.map((caseRecord) => ({
				_children: [],
				...caseRecord
			}));
			this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
			console.error("error loading cases", error);

        }
    }

	/*@wire(getAllParentCases, {})
	parentCase({ error, data }) {
		if (error) {
			console.error("error loading cases", error);
		} else if (data) {
			this.gridData = data.map((caseRecord) => ({
				_children: [],
				...caseRecord
			}));
			this.isLoading = false;
		}
	}*/

	handleOnToggle(event) {
		console.log("event.detail.name"+event.detail.name);
		console.log(event.detail.hasChildrenContent);
		console.log(event.detail.isExpanded);
		const rowName = event.detail.name;
		this.rec.recordID = event.detail.name;
		if (!event.detail.hasChildrenContent && event.detail.isExpanded) {
			//this.hasChildContent = true;
			this.isLoading = true;
			getChildCases({ parentId: rowName })
				.then((result) => {
					console.log(result);
					if (result && result.length > 0) {
						const newChildren = result.map((child) => ({
							_children: [],
							...child
						}));
						this.gridData = this.getNewDataWithChildren(
							rowName,
							this.gridData,
							newChildren
						);
					} else {
						this.dispatchEvent(
							new ShowToastEvent({
								title: "No records",
								message: "No records for the selected STW",
								variant: "warning"
							})
						);
					}
				})
				.catch((error) => {
					console.error("Error loading child cases", error);
					this.dispatchEvent(
						new ShowToastEvent({
							title: "Error Loading Children Cases",
							message: error + " " + error?.message,
							variant: "error"
						})
					);
				})
				.finally(() => {
					this.isLoading = false;
				});
		}
	}

	getNewDataWithChildren(rowName, data, children) {
		return data.map((row) => {
			let hasChildrenContent = false;
			if (
				Object.prototype.hasOwnProperty.call(row, "_children") &&
				Array.isArray(row._children) &&
				row._children.length > 0
			) {
				hasChildrenContent = true;
			}

			if (row.Id === rowName) {
				row._children = children;
			} else if (hasChildrenContent) {
				this.getNewDataWithChildren(rowName, row._children, children);
			}
			return row;
		});
	}


	handlestoreOriginChange(event) {
		this.rec.recordID = this.recId;
        this.rec.storeOrigin = event.target.value;
        console.log("storeOrigin", this.rec.storeOrigin);
    }
    
    handlecountryChange(event) {
        this.rec.recordID = this.recId;
        this.rec.country = event.target.value;
        console.log("country", this.rec.country);
        console.log("recordID", this.rec.recordID);
    }
    
    handlepostalCodeChange(event) {
        this.rec.recordID = this.recId;
        this.rec.postalCode = event.target.value;
        console.log("postalCode", this.rec.postalCode);
    }

	handledeliveryMethodChange(event) {
		//this.rec.recordID = this.recId;
        this.rec.deliveryMethod = event.target.value;
		console.log("deliveryMethod", this.rec.deliveryMethod);
    }




	 callRowAction(event) {
		console.log('event.detail.recId : ' + event.detail.row.Id);
		console.log('event.detail.row : ' + event.detail.row);
		console.log('event.detail.hasChildrenContent : ' + this.hasChildContent);
		console.log('event.detail.action.name: ' + event.detail.action.name);
		const stwList = event.detail.row.Id;
		console.log('>>>>>>>>>>><: ' + stwList);
        this.recId = event.detail.row.Id;
        const actionName = event.detail.action.name;
		const hasChild = this.hasChildContent;
		//this.getCreateRecordLevel();
		//this.getListLocations(recordID);
		const thisLevel = this.Level;
        if (actionName === 'edit') {
            this.handleAction(this.recId, 'edit');
        } else if (actionName === 'delete') {
             this.handleDeleteRow(this.recId);
			//this.dispatchEvent(new RefreshEvent());
        } else if (actionName === 'add' && hasChild === false) {
			console.log('this.Level ' + this.Level);
			this.getListLocations(stwList);
			this.getCreateRecordLevel();
			if (thisLevel === 'L0' || thisLevel === '' || thisLevel === undefined ){
				console.log('TESTTTTT ' + this.Level);
				this.hideModalBox();
			}else{
				//this.getListLocations(recordID);
				this.rec.recordID = this.recId;
				console.log('this.rec.recordID ' + this.rec.recordID);
				this.handleCreateAction(this.recId, 'new');
				this.hasChildContent = false;
			}
        }
		
		//refreshApex(this.getAllParentCases);
		//this.dispatchEvent(new RefreshEvent());
    }

getCreateRecordLevel() {
        try {
            getCreateRecordLevel({recId : this.recId})
            .then(result => {
				console.log('result: ' + result);
                this.Level = result ;
				if (this.Level === 'L1'){
					this.isShowModal = true;
					this.showCountry = true;
				} else if(this.Level === 'L2'){
					this.isShowModal = true;
					this.showDelivery = true;
				}else{
					this.hideModalBox();
				}
	
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('$$ getCreateRecordLevel error: ', error);
        }
    }

    handleAction(recordId, mode) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                //objectApiName: 'STWNurembergDeliveryMethod__c',
                actionName: mode
            },
			state : {
				count: '1',
				nooverride: '1',
				useRecordTypeCheck : '1',
			}
		  
        })
    }

	handleCreateAction(recordId, mode) {
		this.isShowModal = true;
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                //objectApiName: 'STWNurembergDeliveryMethod__c',
                actionName: mode
            },
			state : {
				count: '1',
				nooverride: '1',
				useRecordTypeCheck : '1',
			}
		  
        })*/
    }
    handleDeleteRow(recordIdToDelete) {
        delSTW({ recordIdToDelete: recordIdToDelete })
			.then((result) => {
				//refreshApex(this.getAllParentCases);
				console.log(result);
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Delete Record",
						message: "The record is succefully deleted.",
						variant: "success"
					})
				);
				setTimeout(()=>{

					window.location.reload(true);
				  
				  }, 1000);
		
	}).catch(error => {
                this.error = error;
            });
    }    

	getListLocations(stwList) {
        try {
			console.log('** this.locationPicklist recordID: ', stwList);
            getOrderDeliveryMethod({ stwList: stwList })
            .then(result => {
                if(result.length === 0){
                    this.displayWarningMessage('Somethings wrong while retrieving locations','No location founded');
                    return;
                }
                this.locationPicklist = result;
				console.log('** this.result: ', this.locationPicklist);
				console.log('** this.locationPicklist: ', this.locationPicklist);
            })
            .catch(error => {
                this.error = error;
            });
            return
        } catch (error) {
            console.log('** SOM_ReturnItemsCreation_Component Exception error: ', error);
        }  
    }
 

	refreshData() {
        return refreshApex(this.gridData);
    }

	onRefresh() {
		this.dispatchEvent(new RefreshEvent());
	  }

	handleClick() {
		console.log("JSON.stringify(this.rec)",JSON.stringify(this.rec));
		console.log("(this.rec)",this.rec);
        createSTW({ recordToCreate : JSON.stringify(this.rec) })
            .then(result => {
                /*this.message = result;
                this.error = undefined;
                if(this.message !== undefined) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Account created',
                            variant: 'success',
                        }),
                    );
                }
                */
				
				this.isShowModal = false;
				this.showDelivery = false;
				this.showCountry = false;
				this.showStoreOrigin = false;
                console.log(JSON.stringify(result));
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Create Record",
						message: "The record is succefully created.",
						variant: "success"
					})
				);

				setTimeout(()=>{

					window.location.reload(true);
				  
				  }, 1000);

                //console.log("result", this.message);
            })
            .catch(error => {
                this.message = undefined;
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                console.log("error", JSON.stringify(this.error));
            });
    }

	openNewRecord(){
		//isShowModal
		this.isShowModal = true;
		
		this.showStoreOrigin = true;
		console.log("this.showStoreOrigin", this.showStoreOrigin);
	}
}