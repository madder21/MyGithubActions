import {LightningElement, api, track} from 'lwc';
import insertMembersFromFile from '@salesforce/apex/CLT_FileUploaderController.insertMembersFromFile';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//custom labels
import uploadInstruction from '@salesforce/label/c.mlu_uploadInstruction';
import fileMaxSize from '@salesforce/label/c.mlu_fileMaxSize';
import uploading from '@salesforce/label/c.mlu_uploading';
import uploadFile from '@salesforce/label/c.mlu_uploadFile';
import nOfFilesUploaded  from '@salesforce/label/c.mlu_nOfFilesUploaded';
import pleaseSelectFileToUpload  from '@salesforce/label/c.mlu_pleaseSelectFileToUpload';
import fileSizeTooLong  from '@salesforce/label/c.mlu_fileSizeTooLong';
import uploadedSuccessfully  from '@salesforce/label/c.mlu_uploadedSuccessfully';
import fileUploadedSuccessfully  from '@salesforce/label/c.mlu_fileUploadedSuccessfully';
import success  from '@salesforce/label/c.mlu_success';
import errorWhileUploadingFile  from '@salesforce/label/c.mlu_errorWhileUploadingFile';

export default class FileUploader extends LightningElement {
    @api recordId;
    @track data;
    @track fileName = '';
    @track UploadFile = uploadFile;
    @track showLoadingSpinner = false;
    @track fileUploadButtonDisable = false;
    selectedRecords;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 500001;

    get acceptedFormats() {
        return [".csv"];
    }

    //labels to use
    label = {
        uploadInstruction,
        fileMaxSize,
        uploading
    };

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        alert(nOfFilesUploaded + uploadedFiles.length);
    }

    // getting file
    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    handleSave() {
        if(this.filesUploaded.length > 0) {
            this.uploadHelper();
        }
        else {
            this.fileName = pleaseSelectFileToUpload;
        }
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        if (this.file.size > this.MAX_FILE_SIZE) {
            window.console.log(fileSizeTooLong);
            return ;
        }
        this.showLoadingSpinner = true;
        // create a FileReader object
        this.fileReader= new FileReader();
        // set onload function of FileReader object
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            console.log(this.fileReader.result);
            let base64 = 'base64,';
            this.content = this.fileContents.indexOf(base64) + base64.length;
            this.fileContents = this.fileContents.substring(this.content);

            // call the uploadProcess method
            this.saveToFile();
        });

        this.fileReader.readAsDataURL(this.file);
    }

    // Calling apex class to insert the file
    saveToFile() {
        insertMembersFromFile({ clientListId: this.recordId, fileName: this.file.name, contentFile: atob(this.fileContents)})
            .then(result => {
                window.console.log('result ====> ' +result);

                this.fileName = this.fileName + uploadedSuccessfully;
                this.UploadFile = fileUploadedSuccessfully;
                this.fileUploadButtonDisable = true;
                this.showLoadingSpinner = false;

                // Showing Success message after file insert
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: success,
                        message: this.file.name + uploadedSuccessfully,
                        variant: 'success',
                    }),
                );
                // location.reload();
            })
            .catch(error => {
                // Showing errors if any while inserting the files
                window.console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: errorWhileUploadingFile,
                        message: (error.body) ? error.body.message : error.message,
                        variant: 'error',
                    }),
                );
                this.fileName = '';
                this.UploadFile = uploadFile;
                this.fileUploadButtonDisable = false;
                this.showLoadingSpinner = false;
            });
    }

}