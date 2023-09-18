import { api,track, LightningElement } from 'lwc';
import getFOLItoShip from '@salesforce/apex/SOM_LWC_DisplayFoliToShip_Controller.getFOLItoShip';

const columns = [
    { label: 'Fulfillment Order Product Number', fieldName: 'foliName'},
    { label: 'Product Name', fieldName: 'productName' },
    { label: 'Product SKU', fieldName: 'productSKU'},
    { label: 'Quantity', fieldName: 'qty'},
    { label: 'Quantity Available To Ship', fieldName: 'qtyAvailableToShip'}
];

export default class SomLwcDisplayFoliAvailableToShip extends LightningElement {

    columns = columns;
    @api qtyShipped; 
    @api folisToShip;
    @track wrFOLIS;
    @track selectedRows=[];
    @track currentSelectedRows = [];

    connectedCallback(){
        if(this.folisToShip!=null){
            setTimeout(() => this.selectedRows = this.folisToShip.map(record=>record.id));
        }
        getFOLItoShip({ listQte: this.qtyShipped }).then((data) => {
            this.wrFOLIS = data;
        })
        .catch((error) => {
            this.error = error;
        });  
    }


    handleRowsSelection(event) {
        let currentRows = event.detail.selectedRows;
        this.currentSelectedRows = currentRows;
        this.folisToShip = this.currentSelectedRows;
    }

}