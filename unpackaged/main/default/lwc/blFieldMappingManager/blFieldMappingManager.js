import { LightningElement, wire, track } from 'lwc';

import getUseCases from '@salesforce/apex/BL_FieldMappingManagerCtrl.getUseCases';
import getObjectNames from '@salesforce/apex/BL_FieldMappingManagerCtrl.getObjectNames';
import checkDeploymentStatus from '@salesforce/apex/BL_FieldMappingManagerCtrl.checkDeploymentStatus';
import getProfiles from '@salesforce/apex/BL_FieldMappingManagerCtrl.getProfiles';
import getPermissions from '@salesforce/apex/BL_FieldMappingManagerCtrl.getPermissions';
import performTestQuery from '@salesforce/apex/BL_FieldMappingManagerCtrl.performTestQuery';
import getFields from '@salesforce/apex/BL_FieldMappingManagerCtrl.getFields';
import updateFieldMapping from '@salesforce/apex/BL_FieldMappingManagerCtrl.updateFieldMapping';
import updateUseCases from '@salesforce/apex/BL_FieldMappingManagerCtrl.updateUseCases';
import deleteCustomMetadataRecords from '@salesforce/apex/BL_FieldMappingManagerCtrl.deleteCustomMetadataRecords';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


// The columns for all the tables 

const COLS = [
    //{label: 'Use Case',             fieldName: 'UseCase',               type: 'text', sortable: true, cellAttributes: {class: {fieldName: 'Colorclass'}}},
    { label: 'SF API Name', fieldName: 'SFFieldPath', type: 'text', sortable: true, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'SF Label', fieldName: 'SFLabel', type: 'text', sortable: true, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'IOS Field', fieldName: 'Wrapper_Field_Name', type: 'text', sortable: true, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'Field Type', fieldName: 'FieldType', type: 'text', sortable: true, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'Save to SF', fieldName: 'Save_to_SF', type: 'boolean', sortable: false, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'Save to Wrapper', fieldName: 'Send_to_Clienteling_App', type: 'boolean', sortable: false, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'Get Picklist Label', fieldName: 'GetPicklistLabel', type: 'boolean', sortable: false, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'Currency', fieldName: 'IsCurrency', type: 'boolean', sortable: false, cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'Inner Select', fieldName: 'Is_InnerSelect', type: 'boolean', sortable: false, cellAttributes: { class: { fieldName: 'Colorclass' } } }
];

const ACTION_COL = [{
    type: 'action',
    typeAttributes: {
        rowActions: [
            { label: 'Delete', name: 'delete' },
            { label: 'Update', name: 'update' }
        ]
    }
}];

const COLSQUERY = [
    {
        label: 'Field Exists',
        fieldName: 'FieldExists',
        type: 'boolean',
        cellAttributes: { class: { fieldName: 'Colorclass' } }
    }];

const COLSQUERYCONDITION = [
    { label: 'Name', fieldName: 'Name', type: 'text', },
]

const COLPROFILE = [
    { label: 'Read Access', fieldName: 'readAccess', type: 'boolean', cellAttributes: { class: { fieldName: 'Colorclass' } } },
    { label: 'Edit Access', fieldName: 'editAccess', type: 'boolean', cellAttributes: { class: { fieldName: 'Colorclass' } } }
];

const DEFAULT_SORT_FIELD = 'SFFieldPath'

export default class BlFieldMappingManager extends LightningElement {
    @track objectOptions
    @track profiles;
    @track spinner = false;
    @track modalSpinner
    @track mappingView;
    @track sortedBy = DEFAULT_SORT_FIELD
    @track sortDirection = 'asc'
    @track colums;
    @track cannotAllocate = true;
    @track cannotAllocatequery = true;

    @track objectName
    @track displayModal = false;
    @track fieldOptions;
    @track fieldMappingRecord = {}
    @track selectedRowsId
    @track confirmDeleteSelected
    @track fieldMappings
    fieldMappingList;
    @track tempFieldsMappings = [];
    @track mappingsToDelete = [];
    @track currentRowToDelete;
    profilid;
    colprofile = COLPROFILE;
    columshelp = COLS;
    myaction = ACTION_COL;
    @track modalSpinner
    @track testQueryResult = {}

    useCases
    useCasesMap
    @track useCasesOptions
    selectedUseCase
    selectedUseCaseName
    @track useCaseRecord
    @track useCaseFields = {};
    @track useCaseFieldOptions
    @track displayUseCaseModal
    @track confirmDeleteUseCase
    @track confirmDeleteQuerycondition
    objectsFields = {}
    queryConditionColums = COLSQUERYCONDITION
    @track selectedConditions
    @track useCaseConditions = [];
    @track queryConditionText;


    @track displayImportModal
    @track useCaseJson
    @track importAutoSetDevNames

    @track exportFieldsMapping;


    connectedCallback() {
        this.showSpinner();
        Promise.all([getUseCases(), getProfiles(), getObjectNames()])
            .then(results => {
                this.initUseCases(results[0]);
                this.initProfiles(results[1]);
                this.initObjects(results[2])
            })
            .catch(error => this.handleError(error))
            .finally(x => {
                this.hideSpinner();
            });
        this.colums = ACTION_COL.concat(COLS); //COLS.concat(ACTION_COL);
    }

    initProfiles(result) {
        this.profiles = result.map(x => ({ label: x.Name, value: x.Id }))
        this.sortByLabel(this.profiles)
    }

    initUseCases(result) {
        this.useCases = result
        this.useCasesMap = {}
        let useCasesMapById = {}
        result.forEach(useCase => {
            this.useCasesMap[useCase.DeveloperName] = useCase
            useCasesMapById[useCase.Id] = useCase
        })
        // create options for combo boxes
        this.useCasesOptions = result.map(x => ({
            label: x.Label + ' (' + x.ObjectName + ')',
            value: x.DeveloperName
        }))

        this.useCases.forEach(useCase => {
            if (useCase.FieldsMappingsJson !== undefined) {
                useCase.FieldsMappings = JSON.parse(useCase.FieldsMappingsJson);
            }
            useCase.FieldsMappings.forEach(function (fieldMapping, index) {
                fieldMapping.Id = index;
                fieldMapping.InnerSelect_UseCase_DeveloperName = fieldMapping.InnerSelect_UseCase !== undefined ? fieldMapping.InnerSelect_UseCase.DeveloperName : '';
                console.log(fieldMapping);
            })
        })
        this.sortByLabel(this.useCasesOptions)
        if (result && result.length) {
            this.setSelectedUseCase(this.selectedUseCaseName || result[0].DeveloperName)
        }
    }

    initObjects(objectNames) {
        this.objectOptions = []
        objectNames.forEach(objectName => {
            this.objectOptions.push({
                label: objectName,
                value: objectName
            })
        })
    }

    handleUseCaseSelect(event) {
        this.setSelectedUseCase(event.detail.value)
    }

    setSelectedUseCase(useCaseName) {
        let useCase = this.useCasesMap[useCaseName] || this.useCases[0]
        this.selectedUseCase = useCase
        this.selectedUseCaseName = useCase.DeveloperName
        this.objectName = useCase.ObjectName
        this.fieldMappings = useCase.FieldsMappings;
        this.sortItems(DEFAULT_SORT_FIELD, 'asc')
        this.colums = ACTION_COL.concat(COLS); //COLS.concat(ACTION_COL);
        this.loadFields(useCase.ObjectName)
        this.testQueryResult = {}
        this.useCaseConditions = useCase.QueryConditionJson !== undefined ? JSON.parse(useCase.QueryConditionJson) : '';
        this.queryConditionText = useCase.QueryCondition //useCase.QueryConditionJson !== undefined ? this.getQueryConditionText(this.useCaseConditions) : '';
    }

    getSelectedUseCase() {
        return this.useCasesMap[this.selectedUseCaseName]
    }



    /******************* Field Mapping Modal and Actions *****************/

    openModalAdd() {
        this.loadFields(this.selectedUseCase.ObjectName)
        this.fieldMappingRecord = {
            UseCaseName: this.selectedUseCaseName
        }
        this.modalSpinner = false
        this.displayModal = true;
    }

    loadFields(objectName) {
        if (this.objectsFields[objectName]) {
            this.fieldOptions = this.objectsFields[objectName]
        } else {
            getFields({ objectName: objectName })
                .then(result => {
                    this.objectsFields[objectName] = result
                    this.fieldOptions = result;
                })
                .catch(error => {
                    this.handleError('getFields: ' + error.body.message)
                })
        }
    }

    handleFormValueChange(event) {
        this.fieldMappingRecord[event.target.name] = event.target.value
    }

    handleSfFieldSelect(event) {
        this.fieldMappingRecord.SFFieldPath = event.target.value
        for (let i = 0; i < this.fieldOptions.length; i++) {
            if (this.fieldOptions[i].value == event.target.value) {
                this.fieldMappingRecord.SFLabel = this.fieldOptions[i].label
                this.fieldMappingRecord.FieldType = this.fieldOptions[i].fieldType
            }
        }
        this.setWrapperFieldName()
    }

    setWrapperFieldName() {
        if (this.fieldMappingRecord.SFFieldPath && !this.fieldMappingRecord.Wrapper_Field_Name) {
            let fieldName = this.fieldMappingRecord.SFFieldPath
            fieldName = fieldName.replace('__c', '').replace('.', '')
            fieldName = fieldName.charAt(0).toLowerCase() + fieldName.substr(1)
            this.fieldMappingRecord.Wrapper_Field_Name = fieldName
        }
    }

    closeModal() {
        this.displayModal = false;
    }

    /**
     * Create/Update Field Mapping
     */
    saveFieldMappingRecord() {
        let valid = true
        this.template.querySelectorAll('.mapping-form-input').forEach(input => {
            input.reportValidity()
            valid = valid && input.checkValidity()
        })

        if (!valid) {
            console.log('invalid form')
            return;
        }
        console.log('valid')
        if (this.fieldMappingRecord.Is_InnerSelect === undefined) {
            this.fieldMappingRecord.Is_InnerSelect = false;
        } else {
            this.fieldMappingRecord.InnerSelect_UseCase = this.getUseCaseByDevName(this.fieldMappingRecord.InnerSelect_UseCase_DeveloperName)
        }
        for (let i = 0; i < this.fieldOptions.length; i++) {
            if (this.fieldMappingRecord.SFLabel === undefined && this.fieldOptions[i].value == this.fieldMappingRecord.SFFieldPath) {
                this.fieldMappingRecord.SFLabel = this.fieldOptions[i].label
            }
            if (this.fieldMappingRecord.FieldType === undefined && this.fieldOptions[i].value == this.fieldMappingRecord.SFFieldPath) {
                this.fieldMappingRecord.FieldType = this.fieldOptions[i].fieldType
            }
        }
        let useCase = { ...this.getSelectedUseCase() };
        //Creating new mapping
        if (this.fieldMappingRecord.UseCase === undefined) {
            if (!this.isMappingExist(this.fieldMappingRecord.SFFieldPath, null)) {
                this.fieldMappingRecord.UseCase = {
                    DeveloperName: useCase.DeveloperName,
                    Id: useCase.Id,
                    Label: useCase.Label
                };

                this.fieldMappingRecord.UseCaseName = useCase.Label;
                this.fieldMappingRecord.Id = useCase.FieldsMappings.length;
                useCase.FieldsMappings.push(this.fieldMappingRecord);
                this.tempFieldsMappings.push(this.fieldMappingRecord);
                this.setSelectedUseCase(useCase.DeveloperName);
                this.closeModal();
            } else {
                alert('A Mapping with this field already exist');
            }
        } else
        //Updating existing mapping
        {
            if (!this.isMappingExist(this.fieldMappingRecord.SFFieldPath, this.fieldMappingRecord.Id)) {
                useCase.FieldsMappings.forEach(mapping => {
                    if (mapping.Id == this.fieldMappingRecord.Id) {
                        mapping.DeveloperName = this.fieldMappingRecord.DeveloperName;
                        mapping.Save_to_SF = this.fieldMappingRecord.Save_to_SF;
                        mapping.Send_to_Clienteling_App = this.fieldMappingRecord.Send_to_Clienteling_App;
                        mapping.SFFieldPath = this.fieldMappingRecord.SFFieldPath;
                        mapping.Wrapper_Field_Name = this.fieldMappingRecord.Wrapper_Field_Name;
                        mapping.Is_InnerSelect = this.fieldMappingRecord.Is_InnerSelect;
                        mapping.InnerSelect_UseCase_DeveloperName = this.fieldMappingRecord.InnerSelect_UseCase_DeveloperName;
                        mapping.InnerSelect_UseCase = this.fieldMappingRecord.InnerSelect_UseCase;
                        mapping.IsCurrency = this.fieldMappingRecord.IsCurrency;
                        mapping.GetPicklistLabel = this.fieldMappingRecord.GetPicklistLabel;
                        mapping.SFLabel = this.fieldMappingRecord.SFLabel;
                        mapping.FieldType = this.fieldMappingRecord.FieldType;
                    }
                    this.setSelectedUseCase(useCase.DeveloperName);
                    this.closeModal();
                })
            } else {
                alert('An other Mapping with this field already exist');
            }
        }
    }

    getUseCaseByDevName(devName) {
        console.log('getUseCaseByDevName devName : ' + devName);
        for (let i = 0; i < this.useCases.length; i++) {
            console.log('this.useCases[i].DeveloperName : ' + this.useCases[i].DeveloperName);
            if (this.useCases[i].DeveloperName == devName) {
                let uc = {};
                uc.Id = this.useCases[i].Id;
                uc.DeveloperName = this.useCases[i].DeveloperName;
                uc.Label = this.useCases[i].Label;
                return uc;
            }
        }
        return {};
    }

    isMappingExist(fieldName, newId) {
        for (let i = 0; i < this.selectedUseCase.FieldsMappings.length; i++) {
            let mapping = this.selectedUseCase.FieldsMappings[i];
            if (mapping.SFFieldPath == fieldName && newId === null) {
                return true;
            }
            if (mapping.SFFieldPath == fieldName && newId !== null && newId != mapping.Id) {
                return true;
            }
        };
        return false;
    }

    deleteMappingBeforeSave() {
        let useCase = { ...this.getSelectedUseCase() };
        let fullDevNames = [];
        this.selectedRowsId = [];
        this.mappingsToDelete.forEach(mapping => {
            if (mapping.UseCase.DeveloperName = useCase.DeveloperName) {
                fullDevNames.push('BL_FieldsMapping.' + mapping.Label);
                this.selectedRowsId.push(mapping.Label);
            }
        });

        this.deleteMetadataRecords('BL_FieldsMapping', fullDevNames, (errorsMap) => {
            var hasErrors = false
            this.selectedRowsId.forEach(devName => {
                let fullDevName = 'BL_FieldsMapping.' + devName
                if (errorsMap[fullDevName]) {
                    this.handleError(devName + ': ' + errorsMap[fullDevName])
                    hasErrors = true
                }
            })

            if (!hasErrors) {
                this.confirmDeleteSelected = false
                this.selectedRowsId = []
            }
        })
    }

    deleteSelected() {
        let selectedRecords = []
        if (this.currentRowToDelete !== undefined) {
            selectedRecords.push(this.currentRowToDelete);
        } else {
            selectedRecords = this.template.querySelectorAll('lightning-datatable')[0].getSelectedRows();
        }
        this.selectedRowsId = selectedRecords;
        let useCase = { ...this.getSelectedUseCase() };
        console.log('selectedRecords before remove : ' + JSON.stringify(selectedRecords, null, 2));
        console.log('useCase.FieldsMappings : ' + JSON.stringify(useCase.FieldsMappings, null, 2));
        //remove the temporary mapping 
        for (let j = 0; j < this.selectedRowsId.length; j++) {
            let row = this.selectedRowsId[j];
            for (let i = 0; i < this.tempFieldsMappings.length; i++) {
                let tmp = this.tempFieldsMappings[i];
                if (tmp.Id == row.Id && tmp.UseCaseName == row.UseCaseName) {
                    this.tempFieldsMappings.splice(i, 1);
                    selectedRecords.splice(j, 1);
                    useCase.FieldsMappings.forEach(function (mapping, index) {
                        if (mapping.Id == row.Id && mapping.UseCaseName == row.UseCaseName) {
                            useCase.FieldsMappings.splice(index, 1);
                        }
                    });
                }
            };
        };
        console.log('selectedRecords after remove tmp : ' + JSON.stringify(selectedRecords, null, 2));
        console.log('selectedRecords length : ' + selectedRecords.length);
        try {
            //remove mapping from the current usecase (client side) and collect mappings to delete on saving
            if (selectedRecords.length > 0) {
                let recTodel = [];
                selectedRecords.forEach(function (rec, rIndex) {
                    if (rec !== undefined) {
                        useCase.FieldsMappings.forEach(function (mapping, index) {
                            if (mapping.Id == rec.Id && mapping.UseCaseName == rec.UseCaseName) {
                                recTodel.push(mapping);
                                selectedRecords.splice(rIndex, 1);
                                useCase.FieldsMappings.splice(index, 1);
                            }
                        });
                    }
                })
                console.log('selectedRecords after remove from usecase : ' + JSON.stringify(selectedRecords, null, 2));
                this.mappingsToDelete = recTodel;
            } else {
                console.log('else');
            }
        } catch (err) {
            console.log('Error : ' + err);
        }
        this.setSelectedUseCase(useCase.DeveloperName);
        this.confirmDeleteSelected = false
        this.currentRowToDelete = null;
    }

    openConfirmDeleteSelected() {
        let selectedRecords = this.template.querySelectorAll('lightning-datatable')[0].getSelectedRows()
        if (!selectedRecords.length) {
            return
        }
        this.selectedRowsId = selectedRecords;
        this.fieldMappingRecord = {}
        this.confirmDeleteSelected = true
    }

    deleteMetadataRecords(cmdType, devNames, callback) {
        deleteCustomMetadataRecords({ cmdType: cmdType, devNames: devNames })
            .then(errorsMap => {
                callback(errorsMap)
            }).catch(error => {
                this.handleError(error)
            })
    }

    handleSort(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        this.sortItems(fieldName, sortDirection)
    }

    sortItems(fieldName, sortDirection) {
        if (!this.fieldMappings) {
            return
        }
        let items = [...this.fieldMappings]
        items.sort((item1, item2) => {
            let compareResult
            if (!item1[fieldName]) {
                compareResult = 1
            } else {
                compareResult = item1[fieldName].localeCompare(item2[fieldName])
            }
            return (sortDirection == 'asc' ? compareResult : compareResult * -1)
        })
        this.fieldMappings = items
        this.sortedBy = fieldName
        this.sortDirection = sortDirection
    }

    //This function is called when selecting an action (Edit, Delete).
    handleRowAction(event) {
        const row = event.detail.row;
        switch (event.detail.action.name) {
            case 'delete':
                this.currentRowToDelete = row;
                this.selectedRowsId = [row]
                this.confirmDeleteSelected = true
                break;
            case 'update':
                console.log('update item:', JSON.stringify(row))
                this.fieldMappingRecord = {
                    ...row,
                    UseCaseName: this.selectedUseCaseName
                }
                console.log('fieldMappingRecord : ' + JSON.stringify(this.fieldMappingRecord));
                this.displayModal = true
                break;
            default:
        }
    }

    handleFormCheckboxChange(event) {
        this.fieldMappingRecord[event.target.name] = event.target.checked
        if (event.target.name == 'Is_InnerSelect') {
            if (!event.target.checked) {
                this.fieldMappingRecord.InnerSelect_UseCase = null
            }
        }
    }

    closeConfirmModal() {
        this.confirmDeleteSelected = false
    }

    checkDeploymentStatus(jobId, callback) {
        let num = 5;
        let intervalID = setInterval(async jobId => {
            num--;
            console.log('checking status for jobId:', jobId)
            let result = await checkDeploymentStatus({ jobId: jobId });
            console.log('result:', num, result);
            if (!result.deployResult) {
                this.showToast("ERROR", result[0].message, 'error')
                clearInterval(intervalID);
                this.modalSpinner = false
                return;
            }
            result = result.deployResult
            console.log('status:', result && result.status);
            if (num < 0) {
                this.showToast("Timeout", "Deployment takes too long, Please check later", 'info');
                clearInterval(intervalID);
                this.modalSpinner = false
                return;
            }
            if (result.status === "InProgress" || result.status === "Pending") {
                //num--;
            }
            else {
                clearInterval(intervalID);
                if (result.success) {
                    //this.showToast("SUCCESS", "The record was saved successfully ", 'success');
                    this.modalSpinner = false
                    callback();
                }
                else {
                    this.hideSpinner()
                    this.modalSpinner = false
                    if (result.details.componentFailures.length) {
                        let errorMessage = result.details.componentFailures[0].problem
                        console.log(errorMessage)
                    }
                    this.showToast("ERROR", result.details.componentFailures.filter(x => x.componentType == "CustomMetadata")[0].problem, 'error');
                }
            }
        }, 3000, jobId);
    }


    //This function is called when you press on a button TestQuery (Checks which fields exist)
    testQuery() {
        this.colums = this.myaction.concat(this.columshelp).concat(COLSQUERY);
        this.showSpinner();
        performTestQuery({ useCaseName: this.selectedUseCase.Label })
            .then(result => {
                //console.log('performTestQuery: result:', JSON.stringify(result))
                this.testQueryResult = result
                result.queryResultSfJson = JSON.stringify(result.queryResultSf, null, 2)
                result.queryResultWrapperJson = JSON.stringify(result.queryResultWrapper, null, 2)
                this.hideSpinner();
                this.fieldMappings = JSON.parse(JSON.stringify(this.fieldMappings));
                this.fieldMappings.forEach(item => {
                    item.FieldExists = result.fieldResults[item.SFFieldPath]
                    item.Colorclass = (item.FieldExists ? '' : 'slds-theme_error');
                });
                if (result.success === true) {
                    this.showToast("SUCCESS", "The Query working successfully", 'success');
                } else {
                    this.showToast("ERROR", "The Query failed:  \n" + result.errorMessage, 'error', 'sticky');
                }
            }).catch(error => {
                this.hideSpinner();
                this.handleError(error);
            });
    }

    //This function is called when selecting an profile from Combobox.
    handleChangeProfile(event) {
        this.profilid = event.detail.value;
    }

    // This function is called when you press on a button Check Profile (Checks  for which fields the selected profile has access)
    checkProfileAccess() {
        this.colums = this.myaction.concat(this.columshelp).concat(this.colprofile);
        if (this.profilid != null) {
            this.showSpinner();
            getPermissions({ profileId: this.profilid, useCaseName: this.selectedUseCaseName })
                .then(result => {
                    console.log('getPermissions:', JSON.stringify(result))
                    this.fieldMappings = JSON.parse(JSON.stringify(this.FieldMappingsJson));
                    this.hideSpinner();
                    this.fieldMappings.forEach(value => {
                        Object.assign(value, result.fieldsPermissions[value.SFFieldPath]);
                        if (!value.readAccess && !value.editAccess) {
                            value.workingCSSClass = 'slds-theme_error';
                            value.Colorclass = 'slds-theme_error';
                        }
                    });
                    if (result.found === false) {
                        this.showToast("WARNING", " There are no field access privileges for this profile ", 'warning');
                    }
                }).catch(error => {
                    this.hideSpinner();
                    if (error) {
                        this.handleError(error);
                    }
                });
        }
    }

    /******************* Import-Export *****************/

    openImportModal() {
        let useCase = { ...this.getSelectedUseCase() }
        // delete useCase.Id
        // useCase.FieldsMappings.forEach(fieldMapping => {
        //     delete fieldMapping.Id
        //     delete fieldMapping.UseCaseName
        // })
        // this.useCaseJson = JSON.stringify(useCase, null, 2)
        this.exportFieldsMapping = 'SF API Name,SF Label,IOS Field,Type';
        for (let i = 0; i < useCase.FieldsMappings.length; i++) {
            let label = useCase.FieldsMappings[i].SFLabel === undefined ? '' : useCase.FieldsMappings[i].SFLabel;
            let ftype = useCase.FieldsMappings[i].FieldType === undefined ? '' : useCase.FieldsMappings[i].FieldType;
            for (let j = 0; j < this.fieldOptions.length; j++) {
                if (useCase.FieldsMappings[i].SFLabel === undefined && this.fieldOptions[j].value == useCase.FieldsMappings[i].SFFieldPath) {
                    label = this.fieldOptions[j].label
                }
                if (useCase.FieldsMappings[i].FieldType === undefined && this.fieldOptions[j].value == useCase.FieldsMappings[i].SFFieldPath) {
                    ftype = this.fieldOptions[j].fieldType
                }
            }
            this.exportFieldsMapping += '\n'
                + useCase.FieldsMappings[i].SFFieldPath + ','
                + label + ','
                + useCase.FieldsMappings[i].Wrapper_Field_Name + ','
                + ftype;
        }
        this.displayImportModal = true;
    }

    closeImportModal() {
        this.displayImportModal = false;
    }

    handleUseCaseJsonChange(event) {
        this.useCaseJson = event.target.value
    }

    handleImportCheckboxChange(event) {
        this.importAutoSetDevNames = event.target.checked
    }

    /**
     * Save the usecase record with mapping in JSON format
     */
    saveMapping() {
        let useCaseRecord = { ...this.getSelectedUseCase() }
        delete useCaseRecord.Id
        useCaseRecord.FieldsMappings.forEach(fieldMapping => {
            delete fieldMapping.Id
            delete fieldMapping.UseCaseName
            delete fieldMapping.DeveloperName
        })
        this.useCaseJson = JSON.stringify(useCaseRecord, null, 2)
        let useCase = JSON.parse(this.useCaseJson);
        if (useCase.FieldsMappings) {
            for (let j = 0; j < useCase.FieldsMappings.length; j++) {
                let fieldMapping = useCase.FieldsMappings[j];
                fieldMapping.UseCaseName = useCase.DeveloperName
                delete fieldMapping.DeveloperName
                if (this.importAutoSetDevNames) {
                    delete fieldMapping.Label
                }
                fieldMapping.Is_InnerSelect = fieldMapping.Is_InnerSelect === undefined ? false : fieldMapping.Is_InnerSelect;
                fieldMapping.IsCurrency = fieldMapping.IsCurrency === undefined ? false : fieldMapping.IsCurrency;
                fieldMapping.Save_to_SF = fieldMapping.Save_to_SF === undefined ? false : fieldMapping.Save_to_SF;
                fieldMapping.Send_to_Clienteling_App = fieldMapping.Send_to_Clienteling_App === undefined ? false : fieldMapping.Send_to_Clienteling_App;
                fieldMapping.GetPicklistLabel = fieldMapping.GetPicklistLabel === undefined ? false : fieldMapping.GetPicklistLabel;

                for (let i = 0; i < this.fieldOptions.length; i++) {
                    if (fieldMapping.SFLabel === undefined && this.fieldOptions[i].value == fieldMapping.SFFieldPath) {
                        fieldMapping.SFLabel = this.fieldOptions[i].label
                    }
                    if (fieldMapping.FieldType === undefined && this.fieldOptions[i].value == fieldMapping.SFFieldPath) {
                        fieldMapping.FieldType = this.fieldOptions[i].fieldType
                    }
                }

            }
        }
        useCase.FieldsMappingsJson = JSON.stringify(useCase.FieldsMappings, null, 2);
        this.spinner = true;
        updateUseCases({ useCases: [useCase] })
            .then(jobId => {
                // check status
                this.checkDeploymentStatus(jobId, () => {
                    this.spinner = true;

                    getUseCases()
                        .then(result => {
                            this.spinner = false
                            this.initUseCases(result)
                            this.tempFieldsMappings = [];
                            this.displayUseCaseModal = false
                        })
                });
            }).catch(error => {
                this.spinner = false
                console.log('error:', JSON.stringify(error))
                this.handleError(error)
            })
    }

    importUseCase() {
        let useCase = JSON.parse(this.useCaseJson)
        if (useCase.FieldsMappings) {
            useCase.FieldsMappings.forEach(fieldMapping => {
                fieldMapping.UseCaseName = useCase.DeveloperName
                if (this.importAutoSetDevNames) {
                    delete fieldMapping.DeveloperName
                    delete fieldMapping.Label
                }
            })
        }
        useCase.FieldsMappingJson = useCase.FieldsMappingsJson;

        this.modalSpinner = true
        updateUseCases({ useCases: [useCase] })
            .then(jobId => {
                // check status
                this.checkDeploymentStatus(jobId, () => {
                    this.modalSpinner = true

                    // create field mappings
                    updateFieldMapping({ mappings: useCase.FieldsMappings })
                        .then(jobId => {
                            // check status
                            this.checkDeploymentStatus(jobId, () => {
                                // reload data
                                getUseCases()
                                    .then(useCases => {
                                        this.initUseCases(useCases)
                                        // select new use case
                                        this.setSelectedUseCase(useCase.DeveloperName)
                                    }).finally(() => {
                                        this.modalSpinner = false
                                        this.displayImportModal = false
                                    })
                            })
                        }).catch(error => {
                            this.modalSpinner = false
                            console.log('error:', JSON.stringify(error))
                            this.handleError(error)
                        })
                    getUseCases()
                        .then(result => {
                            this.modalSpinner = false
                            this.initUseCases(result)
                            this.displayUseCaseModal = false
                        })
                });
            }).catch(error => {
                this.modalSpinner = false
                console.log('error:', JSON.stringify(error))
                this.handleError(error)
            })
    }

    /***************************************************/


    handleError(error) {
        if (error.body && error.body.message) {
            error = error.body.message
        }
        console.error(JSON.stringify(error))
        if (error) {
            this.showToast("Error", error);
        }
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title || 'Error',
            message: message,
            variant: variant || 'error',
            mode: mode || 'dismissable',
            duration: ' 1000'
        });
        this.dispatchEvent(evt);
    }

    showSpinner() {
        this.spinner = true;
    }

    hideSpinner() {
        this.spinner = false;
    }

    sortByLabel(items) {
        items.sort((item1, item2) => {
            return item1.label.localeCompare(item2.label)
        })
    }

    /***************** Use Case Modal *************************/


    loadUsecaseFields(objectName) {
        if (this.useCaseFields[objectName]) {
            this.fieldOptions = this.objectsFields[objectName]
        } else {
            getFields({ objectName: objectName })
                .then(result => {
                    this.useCaseFields[objectName] = result
                    this.useCaseFieldOptions = result;
                })
                .catch(error => {
                    this.handleError('getFields: ' + error.body.message)
                })
        }
    }

    openNewUseCaseModal() {
        this.useCaseRecord = {}
        this.displayUseCaseModal = true
        this.confirmDeleteUseCase = false
        this.useCaseConditions = [];
        this.queryConditionText = '';
    }

    openUseCaseModal(event) {
        let useCase = this.getSelectedUseCase() || {}
        this.loadUsecaseFields(useCase.ObjectName);
        this.useCaseRecord = { ...useCase }
        if (event.target.name == 'cloneUsecase') {
            delete this.useCaseRecord.Id;
        }
        this.displayUseCaseModal = true
        this.confirmDeleteUseCase = false
        this.useCaseConditions = useCase.QueryConditionJson !== undefined ? JSON.parse(useCase.QueryConditionJson) : '';
        this.queryConditionText = useCase.QueryCondition !== undefined ? useCase.QueryCondition : ''; //useCase.QueryConditionJson !== undefined ? this.getQueryConditionText(this.useCaseConditions) : '';
    }

    handleUseCaseFormValueChange(event) {
        this.useCaseRecord[event.target.name] = event.target.value
        if (event.target.name == 'ObjectName') {
            this.loadUsecaseFields(event.target.value);
        }
        if (event.target.name == 'queryConditionText') {
            this.queryConditionText = event.target.value;
        }
    }

    handleUseCaseDevNameBlur(event) {
        if (event.target.name == 'DeveloperName' && !this.useCaseRecord.Label) {
            this.useCaseRecord.Label = event.target.value
        }
    }

    closeUseCaseModal() {
        this.displayUseCaseModal = false
    }

    addConditionToUsecase() {
        let useCase = this.getSelectedUseCase() || {}
        try {
            if (this.useCaseConditions === undefined || !Array.isArray(this.useCaseConditions)) {
                this.useCaseConditions = [];
            }
            let condition = {};
            condition.Id = this.numberOfConditions(this.useCaseConditions, 0);
            condition.Name = this.useCaseRecord.QueryField + this.useCaseRecord.QueryCondition;
            condition.fieldName = this.useCaseRecord.QueryField;
            condition.condition = this.useCaseRecord.QueryCondition;
            condition.isGroup = false;
            this.useCaseConditions = [...this.useCaseConditions, condition];
            this.useCaseRecord.QueryConditionJson = this.useCaseConditions;
            this.queryConditionText += ' ' + this.useCaseRecord.QueryField + ' ' + this.useCaseRecord.QueryCondition; //this.getQueryConditionText(this.useCaseConditions);
            //this.useCaseRecord.QueryCondition = this.queryConditionText;
        } catch (err) {
            console.log(err);
        }
    }

    copyToClipboard(event) {
        var hiddenInput = document.createElement("input");
        hiddenInput.setAttribute("value", this.useCaseRecord.QueryField);
        document.body.appendChild(hiddenInput);
        hiddenInput.select();
        document.execCommand("copy");
        document.body.removeChild(hiddenInput);
    }

    addGroup(event) {
        let btnName = event.target.name;
        let groupOperator = btnName.split("-")[0];
        this.selectedConditions = this.template.querySelectorAll('lightning-tree-grid')[0].getSelectedRows();
        try {
            if (this.selectedConditions.length > 0) {
                let children = [];
                for (let i = 0; i < this.selectedConditions.length; i++) {
                    for (let j = 0; j < this.useCaseConditions.length; j++) {
                        if (this.selectedConditions[i].Id == this.useCaseConditions[j].Id) {
                            children.push(this.useCaseConditions[j]);
                        }
                    }
                }
                let group = {
                    Id: this.numberOfConditions(this.useCaseConditions, 0),
                    Name: groupOperator.toUpperCase() + ' GROUP',
                    _children: children,
                    operator: groupOperator.toUpperCase(),
                    isGroup: true
                };
                for (let i = 0; i < this.useCaseConditions.length; i++) {
                    for (let j = 0; j < this.selectedConditions.length; j++) {
                        if (this.selectedConditions[j].Id == this.useCaseConditions[i].Id) {
                            this.useCaseConditions.splice(i, 1);
                        }
                    }
                };
                this.useCaseConditions = [...this.useCaseConditions, group];
                this.queryConditionText = this.getQueryConditionText(this.useCaseConditions);
                this.selectedUseCase.QueryCondition = this.queryConditionText;
            } else {
                alert('please select at least one row to create group');
            }
        } catch (err) {
            console.log('error');
            console.log(err);
        }
    }

    getQueryConditionText(conditions) {
        let textQuery = ''
        console.log('conditions : ' + JSON.stringify(conditions, null, 2));
        try {
            for (let j = 0; j < conditions.length; j++) {
                let cond = conditions[j];
                console.log('cond.isGroup : ' + cond.isGroup);
                if (cond.isGroup) {
                    console.log('if : ' + JSON.stringify(cond._children, null, 2));
                    let childCond = [];
                    for (let i = 0; i < cond._children.length; i++) {
                        childCond.push(this.getQueryConditionText([cond._children[i]]));
                    };
                    console.log('chilcond : ' + JSON.stringify(childCond, null, 2));
                    textQuery += '(' + childCond.join(' ' + cond.operator + ' ') + ')';
                } else {
                    console.log('else : ' + cond.Name);
                    textQuery += cond.Name;
                }
            };
        } catch (err) {
            console.log(err);
        }
        return textQuery;
    }

    numberOfConditions(conditions, initialCount) {
        for (let i = 0; i < conditions.length; i++) {
            initialCount += 1;
            if (conditions[i].isGroup) {
                initialCount += this.numberOfConditions(conditions[i]._children, initialCount);
            }
        }
        return initialCount;
    }

    openConfirmDeleteConditions() {
        this.confirmDeleteQuerycondition = true
    }

    closeConditionsConfirmModal() {
        this.confirmDeleteQuerycondition = false;
    }

    deleteQueryconditions() {
        this.selectedConditions = this.template.querySelectorAll('lightning-tree-grid')[0].getSelectedRows();
        for (let i = 0; i < this.useCaseConditions.length; i++) {
            for (let j = 0; j < this.selectedConditions.length; j++) {
                if (this.selectedConditions[j].Id == this.useCaseConditions[i].Id) {
                    this.useCaseConditions.splice(i, 1);
                }
            }
        };
        this.useCaseConditions = [...this.useCaseConditions];
        this.confirmDeleteQuerycondition = false;
        this.useCaseRecord.QueryConditionJson = this.useCaseConditions;
        this.queryConditionText = this.getQueryConditionText(this.useCaseConditions);
        this.useCaseRecord.QueryCondition = this.queryConditionText;
    }

    saveUseCaseRecord() {
        console.log('saveUseCaseRecord:', JSON.stringify(this.useCaseRecord))
        this.modalSpinner = true
        this.useCaseRecord.QueryConditionJson = JSON.stringify(this.useCaseConditions, null, 2);
        this.useCaseRecord.QueryCondition = this.queryConditionText;
        updateUseCases({ useCases: [this.useCaseRecord] })
            .then(jobId => {
                console.log('jobId:', jobId)
                this.checkDeploymentStatus(jobId, () => {
                    getUseCases()
                        .then(result => {
                            this.modalSpinner = false
                            this.initUseCases(result)
                            this.displayUseCaseModal = false
                            this.setSelectedUseCase(this.useCaseRecord.DeveloperName)
                        })
                });
            }).catch(error => {
                this.modalSpinner = false
                console.log('error:', JSON.stringify(error))
                this.handleError(error)
            })
    }

    showConfirmDeleteUseCase() {
        if (this.useCaseRecord.FieldsMappings && this.useCaseRecord.FieldsMappings.length) {
            this.showToast('Cannot delete Use Case', 'Use Case contins field mapping records', 'error');
        } else {
            this.confirmDeleteUseCase = true
        }
    }

    deleteUseCase() {
        this.modalSpinner = true
        let devName = this.useCaseRecord.DeveloperName
        let fullDevName = 'BL_UseCase.' + this.useCaseRecord.DeveloperName
        let fullDevNames = [fullDevName]
        this.deleteMetadataRecords('BL_UseCase', fullDevNames, (errorsMap) => {
            this.modalSpinner = false
            if (errorsMap[fullDevName]) {
                this.handleError(errorsMap[fullDevName][0])
            } else {
                this.showToast({ title: "SUCCESS", variant: 'success', message: "The record has been deleted" });
                this.displayUseCaseModal = false
                this.selectedUseCase = null
                this.useCases = this.useCases.filter(x => x.DeveloperName !== devName);
                this.initUseCases(this.useCases)
            }
        })
    }
}