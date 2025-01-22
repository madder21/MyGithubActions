import { LightningElement, track, api } from 'lwc';

//custom labels
import cancel from '@salesforce/label/c.CLT_Cancel';
import done from '@salesforce/label/c.CLT_Done';
import selectAll from '@salesforce/label/c.CLT_SelectAll';
import selectAnOption from '@salesforce/label/c.CLT_SelectAnOption';

export default class Clt_multiSelect extends LightningElement {
    @track _isDisabled = false;
    @track fieldoption;
    @api label;
    @api ploptions = [];
    @api selectAllAvailable = false;
    @api selectedValues = [];
    @api defaultValues = [];
    @api placeholderValue = selectAnOption;
    @api isReadOnly = false;
    @api uniqueId;

    //labels to use
    labelObj = {
        cancel,
        done
    };

    hasRendered = false; // To ensure setDefaultValues is called once

    @api 
    get isDisable() {
        return this._isDisabled;
    }
    set isDisable(value) {
        this._isDisabled = value;
    }

    get options() {
        if (this.ploptions != null && this.ploptions.length > 0) {
            let localPlOptions = [...this.ploptions];
            if (this.selectAllAvailable && !this.isReadOnly) {
                localPlOptions.unshift({
                    value: '#ALL',
                    label: selectAll
                });
            }
            return localPlOptions;
        } else if (this.fieldoption != null && this.fieldoption.length > 0) {
            return this.fieldoption;
        }
        return [];
    }

    @api
    selectAll() {
        let elements = this.template.querySelectorAll("[name='options'], [name='hidden-options']");
        let localSelectedValues = [];
        elements.forEach(function(op) {
            op.checked = true;
            if (!localSelectedValues.includes(op.value) && op.value !== '#ALL') {
                localSelectedValues.push(op.value);
            }
        });
        this.selectedValues = localSelectedValues;
        this.placeholderValue = `${this.selectedValues.length} options selected`;
    }

    @api
    setDefaultValues(defaultValues) {
        // Delay execution to ensure DOM is fully rendered
        window.setTimeout(() => {
            let elements = this.template.querySelectorAll("[name='options'], [name='hidden-options']");
            elements.forEach(function (op) {
                if (defaultValues.includes(op.value)) {
                    op.checked = true;
                }
                else {
                    op.checked = false;
                }
            });
            this.selectedValues = defaultValues;
            this.placeholderValue = `${this.selectedValues.length} options selected`;
        }, 0);
    }

    @api
    setSelectedValues(selectedValues) {
        // Delay execution to ensure DOM is fully rendered
        window.setTimeout(() => {
            let elements = this.template.querySelectorAll("[name='options'], [name='hidden-options']");
            elements.forEach(function (op) {
                if (selectedValues.includes(op.value)) {
                    op.checked = true;
                }
                else {
                    op.checked = false;
                }
            });
            this.selectedValues = selectedValues;
            this.placeholderValue = this.selectedValues.length > 0 ? `${this.selectedValues.length} ` + 'options selected' : selectAnOption;
            if (this.selectedValues.length > 0) {
                this.dispatchEvent(new CustomEvent("filterset"));
            }
        }, 0);
    }

    handleClick() {
        let filterList = this.template.querySelector(".filters-selection");
        const wasHidden = filterList.classList.toggle("slds-hide");
        if(wasHidden) {
            this.setDefaultValues(this.defaultValues);
            this.placeholderValue = this.selectedValues.length > 0 ? `${this.selectedValues.length} ` + 'options selected' : selectAnOption;
        }
        else {
            this.dispatchEvent(new CustomEvent("openedlist", { detail: { source: this.uniqueId } }));
        }
    }

    @api
    closeListIfOpened() {
        let filterList = this.template.querySelector(".filters-selection");
        if(!filterList.classList.contains("slds-hide")) {
            this.handleClick();
        }
    }

    handleSelection(param) {
        if (this.selectAllAvailable && param.target?.value === '#ALL') {
            if (param.target?.checked) {
                this.selectAll();
            } else {
                this.removeSelected();
            }
        } else {
            if (param.target?.checked) {
                this.template.querySelector(".filters-holder").classList.remove("slds-has-error");
                this.selectedValues = [...this.selectedValues, param.target.value];
                this.selectedValues = [...new Set(this.selectedValues)];
                this.placeholderValue = `${this.selectedValues.length} options selected`;
            } else if (Array.isArray(param)) {
                this.selectedValues = param;
                this.placeholderValue = `${this.selectedValues.length} options selected`;
            } else {
                this.selectedValues = this.selectedValues.filter((value) => value !== param.target.value);
                let options = this.template.querySelectorAll("[name='options']");
                options.forEach(option => {
                    if (option.value === '#ALL' && option.checked) {
                        option.checked = false;
                    }
                });
                this.placeholderValue = `${this.selectedValues.length} options selected`;
            }
        }
    }

    removeSelected() {
        let elements = this.template.querySelectorAll("[name='options'], [name='hidden-options']");
        elements.forEach(function(value) {
            value.checked = false;
        });
        this.placeholderValue = selectAnOption;
        this.selectedValues = [];
    }

    handleSelected() {
        this.template.querySelector(".filters-selection").classList.toggle("slds-hide");
        this.placeholderValue = this.selectedValues.length > 0 ? `${this.selectedValues.length} ` + 'options selected' : selectAnOption;
        this.dispatchEvent(new CustomEvent("filterset"));
    }

    handleCancel() {
        this.setDefaultValues(this.defaultValues);
        this.template.querySelector(".filters-selection").classList.toggle("slds-hide");
        this.placeholderValue = this.selectedValues.length > 0 ? `${this.selectedValues.length} ` + 'options selected' : selectAnOption;
        if (this.selectedValues.length > 0) {
            this.dispatchEvent(new CustomEvent("filterset"));
        }
    }

    @api
    clear() {
        this.removeSelected();
    }

    renderedCallback() {
        if (!this.hasRendered) {
            this.hasRendered = true;
            this.setDefaultValues(this.defaultValues);
        }
    }
}