import { LightningElement } from 'lwc';
import launchBatch from '@salesforce/apex/LaunchEmailTemplatesJSONBatchController.launchEmailTemplatesJSONBatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_LaunchEmailTemplatesJSONBatch extends LightningElement {
    handleClick(event) {
        launchBatch()
        .then(result => {
            this.showSuccess()
            console.log( result)
        })
        .catch(error => {
            this.error = error;
        });
    }

    showSuccess() {
        const evt = new ShowToastEvent({
            title: 'Success',
            message: 'Job is launched, email templates will be refreshed shorthly',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}