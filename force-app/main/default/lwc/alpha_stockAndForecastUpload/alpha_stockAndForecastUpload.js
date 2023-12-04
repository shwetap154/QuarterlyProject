/**
 * @description       : JavaScript file for uploading Stock Entries and Forecasts via CSV files.
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 04-01-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   08-28-2021   Unknown                     Initial Version
 * 1.1   04-01-2022   Ethan Hirsch @ Zoetis Inc   Fix an error where Stock Entries fell under the same validation as Forecast and could only be created for the next 3-27 months
**/
import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProductList from '@salesforce/apex/alphaDistExcelController.getProductList';
import parseForecastExcelJson from '@salesforce/apex/alphaDistExcelController.parseForecastExcelJson';
import parseStockExcelJson from '@salesforce/apex/alphaDistExcelController.parseStockExcelJson';

import forecastSheet from '@salesforce/resourceUrl/ForecastSheet';
import stockSheet from '@salesforce/resourceUrl/StockSheet';
import papaParse from '@salesforce/resourceUrl/PapaParse';

const monthValues = ['January','February','March','April','May','June','July','August','September','October','November','December'];

export default class StockAndForecastUpload extends NavigationMixin(LightningElement) {
    @api componentType;

    // Added as a part of SC-009462
    @track disableUpload = 'uploadDisable';
    lockedMonths = [];
    validMonths = [];
    
    downloadButtonLabel = 'Upload Form';
    zs_fc_downloadicon = Zoetis_Static_Resources + '/images/icons/download_icon.png';  
    zs_fc_uploadicon = Zoetis_Static_Resources + '/images/icons/cloud_upload.png'; 
    renderedCallback() {

        Promise.all([
            loadScript(this, Zoetis_Static_Resources + '/js/jquery.min.js'),
            loadScript(this, Zoetis_Static_Resources + '/js/zoetis_global_scripts.js'),
            loadStyle(this, Zoetis_Static_Resources + '/css/zoetis_global_styles.css'),
        ])
            .then(() => {
                //alert('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }
    showSpinner = false;

    monthValue;
    yearValue;

    monthOptions = monthValues.map((item) => {
        return {label: item, value: item};
    });

    get yearOptions()
    {
        let currYear = new Date().getFullYear();
        currYear = currYear - 1;
        let tempOptions = []
            for(let i = 0; i < 4; i++)
            {
                tempOptions.push({label: currYear + i, value: (currYear + i).toString()});
            }
        return tempOptions;
    }

    parserInitialized = false;
    connectedCallback() {
        // Calculate current month plus two to prevent editing. SC-009462
        let today = new Date();
        let month = today.getMonth();
        let year = today.getFullYear();
        this.lockedMonths.push(monthValues[month] + ' ' + year);
        for (let i = 0; i < 2; i++) {
            month += 1;
            if (month >= 12) {
                month = 0;
                year += 1;
            }
            this.lockedMonths.push(monthValues[month] + ' ' + year);
        }
        for (let i = 0; i < 24; i++) {
            month += 1;
            if (month >= 12) {
                month = 0;
                year += 1;
            }
            this.validMonths.push(monthValues[month] + ' ' + year);
        }

        if(!this.parserInitialized){
            loadScript(this, papaParse)
            .then(() => {
                this.parserInitialized = true;
            })
            .catch(error => console.error('Failed to initialze parser: ' + error));
        }
        this.downloadButtonLabel = 'Upload Your ' + this.componentType + ' Entry Form';
    }

    handleDownloadClickDemo() {
        let excelDocument = 'https://touchpointeca--atgalpha--c.visualforce.com';
        switch(this.componentType) {
            case 'Forecast':
                excelDocument += forecastSheet;
                break;
            case 'Stock':
                excelDocument += stockSheet;
                break;
        }

        this[NavigationMixin.Navigate](
            {
                type: 'standard__webPage',
                attributes: {
                    url: excelDocument,
                }
            }, false
        )
    }

    handleDownloadClick() {
        debugger
        this.showSpinner = true;
        let dataArray = [];
        switch(this.componentType) {
            case 'Forecast':
                dataArray.push(['SAP Material Code', 'Product Description', 'Unit of Measure', 'Distributor Product Code','Distributor Product Name', 'Distributor Price', 'Currency',/* 'Month', 'Year', */'Quantity']);
                break;
            case 'Stock':
                dataArray.push(['SAP Material Code', 'Product Description', 'Unit of Measure', 'Distributor Product Code', 'Distributor Product Name', 'Batch/Lot Number', 'Expiry Date',/* 'Month', 'Year', */'Quantity']);
                break;
        }

        getProductList({objectType: this.componentType})

        .then(result => {
            console.log(JSON.stringify(result));
            for (let i = 0; i < result.length; i++) {
                let product = result[i];
                switch(this.componentType) {
                    case 'Forecast':
                        dataArray.push([product['SAP Material Code'], product['Product Description'], product['Unit of Measure'], product['Distributor Product Code'], product['Distributor Product Name'], product['Distributor Price'], product['Currency'],/* '', '', */product['Quantity']]);
                        break;
                    case 'Stock':
                        dataArray.push([product['SAP Material Code'], product['Product Description'], product['Unit of Measure'], product['Distributor Product Code'], product['Distributor Product Name'], product['Batch/Lot Number'], product['Expiry Date'],/* '', '', */product['Quantity']]);
                        break;
                }
            }

            let dataCsv = Papa.unparse(dataArray, {
                delimiter: ",",
                header: true,
                skipEmptyLines: true
            });
            
            let a = document.createElement("a");
            let blob = new Blob([dataCsv], {type: 'text/plain'});
            let url = URL.createObjectURL(blob);
            a.href = url;
            a.download = this.componentType + ' Form.csv';
            document.body.appendChild(a);
            a.click();
            setTimeout(function () {
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
            }, 0);
        });

        setTimeout(() => { this.showSpinner = false; }, 1000);
    }

    handleFileSelected(event) {
        this.showSpinner = true;
        let fileUpload = event.target.files[0];
        let fileExtension = fileUpload.name.split('.').slice(-1)[0];
        let failedRecords = {};
        let uploadError;
        let resultsComplete = false;

        // Check if file type is valid
        console.log(fileExtension);
        if (fileExtension != 'csv') {
            this.showSpinner = false;
            let resultToast = new ShowToastEvent({
                title: 'Invalid File Type',
                message: 'Uploaded file must be in .csv format.',
                variant: 'error',
            });
            this.dispatchEvent(resultToast);
            return;
        }

        // Check if month and date are entered
        if (!this.validateFields()) {
            this.showSpinner = false;
            let resultToast = new ShowToastEvent({
                title: 'Invalid Month/Year Combination',
                message: 'Must have a month and year selected. Forecasts cannot be entered for the past.',
                variant: 'error',
            });
            this.dispatchEvent(resultToast);
            return;
        }

        // Generate metadata for use in creating stock/forecast
        let metadata = {};
        metadata['Month'] = this.monthValue;
        metadata['Year'] = this.yearValue;
        
        switch(this.componentType) {
            case 'Forecast':
                Papa.parse(fileUpload, {
                    header: true,
                    skipEmptyLines: 'greedy',
                    complete: function(results, file) {
                        parseForecastExcelJson({csvJson: JSON.stringify(results.data), forecastData: metadata})
                        .then(result => {
                            failedRecords = result;
                            resultsComplete = true;
                        })
                        .catch(error => {
                            console.log(error);
                            uploadError = error;
                            resultsComplete = true;
                        });
                    }
                })
                break;
            case 'Stock':
                Papa.parse(fileUpload, {
                    header: true,
                    skipEmptyLines: 'greedy',
                    complete: function(results, file) {
                        console.log(metadata);
                        parseStockExcelJson({csvJson: JSON.stringify(results.data), stockData: metadata})
                        .then(result => {
                            failedRecords = result;
                            resultsComplete = true;
                        })
                        .catch(error => {
                            console.log(error);
                            uploadError = error;
                            resultsComplete = true;
                        });
                    }
                });
                break;
        }

        // Papa.parse changes the context of 'this', which means we can't call functions in the 'complete' block. This crude timeout block will delay execution so that hopefully the asynchronous function will finish.
        // Checks after 1 second and 5 seconds.
        setTimeout(() => {
            if (resultsComplete) {
                this.checkOutput(failedRecords, uploadError);
            }
            else {
                setTimeout(() => {
                    if (resultsComplete) {
                        this.checkOutput(failedRecords, uploadError);
                    }
                    else {
                        this.showSpinner = false;
                    }
                }, 4000)
            }
        }, 1000);
    }

    checkOutput(failedRecords, uploadError) {
        console.log(uploadError);
        let resultToast;
        if (failedRecords.length > 0) {
            resultToast = new ShowToastEvent({
                title: 'CSV Was Not Uploaded',
                message: 'There was an error processing your upload. The records that have caused an error are in the file provided.',
                variant: 'error',
            });

            let dataCsv = Papa.unparse(failedRecords, {
                delimiter: ",",
                header: false,
                skipEmptyLines: true
            });
            
            let a = document.createElement("a");
            let blob = new Blob([dataCsv], {type: 'text/plain'});
            let url = URL.createObjectURL(blob);
            a.href = url;
            a.download = this.componentType + ' Errors.csv';
            document.body.appendChild(a);
            a.click();
            setTimeout(function () {
                document.body.removeChild(a);
                window.URL.revokeObjectURL(url);
            }, 0);
        }
        else if (uploadError) {
            resultToast = new ShowToastEvent({
                title: 'CSV Was Not Uploaded',
                message: uploadError.body.message,
                variant: 'error',
            });
        }
        else {
            resultToast = new ShowToastEvent({
                title: 'CSV Uploaded Successfully',
                message: 'Your upload is being processed and should be visible soon.',
                variant: 'success',
            });
        }
        this.dispatchEvent(resultToast);
        this.showSpinner = false;
    }

    handleValueChange(event){
        let ctrlName = event.currentTarget.dataset.name;
       
        switch(ctrlName){
            case 'objectMonth':
                this.monthValue = event.target.value;
                this.enableDisableUploadButton();
                break;
            case 'objectYear':
                this.yearValue = event.target.value;
                this.enableDisableUploadButton();
                break;
        }
    }

    enableDisableUploadButton() {
        this.disableUpload = 'uploadEnable';
        // The validations below only apply to Forecasts
        if (!this.monthValue || !this.yearValue || this.componentType != 'Forecast') {
            return;
        }
        else if (this.lockedMonths.includes(this.monthValue + ' ' + this.yearValue)) {
            const evt = new ShowToastEvent({
                title: "Locked Forecast",
                message: "Forecasts cannot be entered for the current month or the two following months. Please select a different month and year combination.",
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            this.disableUpload = 'uploadDisable';
            return;
        }
        else if (!this.validMonths.includes(this.monthValue + ' ' + this.yearValue)) {
            const evt = new ShowToastEvent({
                title: "Locked Forecast",
                message: "Forecasts can only be entered for the next 3 to 27 months. Please select a different month and year combination.",
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            this.disableUpload = 'uploadDisable';
            return;
        }
    }
    
	validateFields() {
        // Validate entries
        let errorStatus = true;
        errorStatus = this.template.querySelector('[data-name=\'objectMonth\']').reportValidity() && errorStatus;
        errorStatus = this.template.querySelector('[data-name=\'objectYear\']').reportValidity() && errorStatus;

        if (errorStatus && this.componentType == 'Forecast') {
            let today = new Date();
            let todayYear = today.getFullYear().toString();
            let todayMonth = today.getMonth();
            if (this.yearValue < todayYear) {
                errorStatus = false;
            }
            else if (this.yearValue === todayYear) {
                let selectedMonth = monthValues.indexOf(this.monthValue);
                if (selectedMonth < todayMonth) {
                    errorStatus = false;
                }
            }
        }
        return errorStatus;
    }
}