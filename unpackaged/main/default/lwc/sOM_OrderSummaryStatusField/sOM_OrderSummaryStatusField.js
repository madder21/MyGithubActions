/*import { LightningElement, track, api } from 'lwc';
import UpdateOrderSummaryStatus from '@salesforce/apex/SOM_OrderSummaryStatusFieldController.UpdateOrderSummaryStatus';


export default class sOM_OrderSummaryStatusField extends LightningElement {

    @api recordId;    

    connectedCallback(){ 
        try {
            this.UpdateStatus();
        } catch (error) {
            console.log('** Exception error: ', error);
            this.endLoading(); 
        }
    }

    

    UpdateStatus() {
        try {
            UpdateOrderSummaryStatus({OrderSummId : this.recordId})
            .then(result => {
                console.log('** OK ');
            })
            .catch(error => {
                console.log('** error: ', error);
            });
        } catch (error) {
            console.log('$$ getListInitialROLIsByRoId error: ', error);
        }
    }

}*/
import { LightningElement, api } from 'lwc';
import UpdateOrderSummaryStatus from '@salesforce/apex/SOM_OrderSummaryStatusFieldController.UpdateOrderSummaryStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class sOM_OrderSummaryStatusField extends LightningElement {
    @api recordId;

    connectedCallback() {
        this.updateStatus();
    }

    updateStatus() {
        UpdateOrderSummaryStatus({ OrderSummId: this.recordId })
            .then(() => {
                console.log('** OK ');
            })
            .catch(error => {
                this.showToast('Error', 'Error updating order status', 'error');
                console.error('Error: ', error);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
}