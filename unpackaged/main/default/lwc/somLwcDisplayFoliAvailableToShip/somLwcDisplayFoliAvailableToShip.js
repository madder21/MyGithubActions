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
            console.log('id ' + this.selectedRows);
            console.log('id ' + JSON.stringify(this.selectedRows));

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
        // if (this.currentSelectedRows.length > 0) {
        //     let selectedIds = currentRows.map(row => row.id);
        //     let unselectedRows = this.currentSelectedRows.filter(row => !selectedIds.includes(row.id));
        //     console.log('unselected'+ unselectedRows);
            
        // }
        this.currentSelectedRows = currentRows;
        this.folisToShip = this.currentSelectedRows;
        console.log('selected action ' + JSON.stringify(this.currentSelectedRows));
    }

}