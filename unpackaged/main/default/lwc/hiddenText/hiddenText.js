import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import hiddenTextResource from '@salesforce/resourceUrl/hiddenTextResource';

export default class HiddenText extends LightningElement {
    connectedCallback() {
        loadStyle(this, hiddenTextResource)
            .then(() => {
                console.log('Library loaded');
            })
            .catch(error => {
                console.error('Error loading library:', error);
            });
    }
}