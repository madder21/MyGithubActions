import { LightningElement, api, track, wire } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getTranslationContent from '@salesforce/apex/BL_EditTranslationCtrl.getTranslationContent';
import saveTranslationContent from '@salesforce/apex/BL_EditTranslationCtrl.saveTranslationContent';

const COLS = [
    {label: 'Name',         fieldName: 'name', type: 'text', editable: false},
    {label: 'Translation',  fieldName: 'label', type: 'text', editable: true},
];

export default class BlEditTranslation extends LightningElement {
    @api recordId
    @api height = '300'
    @track items   // [{name, label}, ...]
    @track columns = COLS
    labelsMap           // {name => label}
    @track draftValues
    @track spinner
    @track rawContent
    rawContentOriginal
    @track isValidJson
    @track displayRawContent
    @track displayRawContent = false
    @track isEditMode = false;

    get wrapStyle() {
        return 'height: ' + this.height + 'px;'
    }

    @wire(getTranslationContent, { recordId: '$recordId' })
    wiredContent({ error, data }) {
        this.initContent(data)
        if (error) {
            this.handleError(error)
        }
    }

    initContent(data) {
        console.log('initContent:', data)
        this.spinner = true
        this.rawContent = data
        this.rawContentOriginal = data

        this.isValidJson = false
        this.displayRawContent = true
        this.isEditMode = true

        if (data) {
            this.isEditMode = false
            try {
                this.labelsMap = JSON.parse(data)
                this.isValidJson = true
                this.displayRawContent = false
                this.initItems()
            } catch (error) {
                this.isValidJson = false
                this.displayRawContent = true
            }
        }
        this.spinner = false
    }

    initItems() {
        this.items = []
        for (let key in this.labelsMap) {
            if (Object.prototype.hasOwnProperty.call(this.labelsMap, key)) {
                this.items.push({
                    name: key,
                    label: this.labelsMap[key]
                })
            }
        }
    }

    switchToRaw() {
        this.displayRawContent = true
    }

    edit() {
        this.isEditMode = true
    }

    handleContentChange(event) {
        this.rawContent = event.target.value
    }

    backToJson() {
        this.displayRawContent = false
    }

    cancelEdit() {
        this.rawContent = this.rawContentOriginal
        this.isEditMode = false
        // rerender text area
        setTimeout(() => {
            //this.displayRawContent = true
        }, 50)
    }

    save(event) {
        console.log('save:', JSON.stringify(event.detail.draftValues))
        this.spinner = true
        let content = this.rawContent
        if (!this.displayRawContent) {
            // stringify items as object
            let contentObj = {}
            this.items.forEach(item => {
                contentObj[item.name] = item.label
            })
            // take updates from draftValues
            event.detail.draftValues.forEach(item => {
                contentObj[item.name] = item.label
            });
            content = JSON.stringify(contentObj, null, 2)
        }
        //console.log('update content:', content)
        saveTranslationContent({ recordId: this.recordId, content: content })
        .then(() => {
            console.log('done')
            this.initContent(this.rawContent)
            this.spinner = false
            this.isEditMode = false
            eval("$A.get('e.force:refreshView').fire();")
        }).catch(error => {
            this.spinner = false
            this.handleError(error)
        })
    }

    handleError(error) {
        if (error.body && error.body.message) {
            error = error.body.message
        }
        console.error(error)
        this.showToast(error);
    }

    showToast(message, title, variant, mode) {
        const evt = new ShowToastEvent({
            title: title || 'Error',
            message: message,
            variant: variant || 'error',
            mode: mode || 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}