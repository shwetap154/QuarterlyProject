import { LightningElement, api, track, wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import currentUserId from '@salesforce/user/Id';
import speciesField from '@salesforce/schema/ContentVersion.Applicable_Species__c';
import marketField from '@salesforce/schema/ContentVersion.Applicable_Markets__c';
import productLineField from '@salesforce/schema/ContentVersion.Product_Line__c';
import fileTypeField from '@salesforce/schema/ContentVersion.Library_File_Type__c';

import getMarket from '@salesforce/apex/alphaCustomLibraryController.getMarket';
import getFiles from '@salesforce/apex/alphaCustomLibraryController.getFiles';
import accountSearch from '@salesforce/apex/alphaCustomLibraryController.accountSearch';
import saveFiles from '@salesforce/apex/alphaCustomLibraryController.saveFiles';
import uploadFile from '@salesforce/apex/alphaCustomLibraryController.uploadFile';
import getFileLibraries from '@salesforce/apex/alphaCustomLibraryController.getFileLibraries';
import getLibraries from '@salesforce/apex/alphaCustomLibraryController.getLibraries';
import deleteFile from '@salesforce/apex/alphaCustomLibraryController.deleteFile';
import downloadFile from '@salesforce/apex/alphaCustomLibraryController.downloadFile';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const libraryNames = ['Library Content', 'Legal Content'];

export default class AlphaCustomLibrary extends LightningElement {
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
    @track allFiles = [];
    filters = '';
    currentMarket = '';
    deletionFile;
    downLoadOneFile;
    showUploadModal = false;
    showDeleteModal = false;
    loading = true;
    speciesList = [];
    marketList = [];
    productLineList = [];
    libraryList = [];
    fileTypeList = [];
    
    // 0123k000000zt0fAAA is the record type of Library Content in the Content Version (Files) object
    @wire(getPicklistValues, {recordTypeId: '0123k000000zt0fAAA', fieldApiName: speciesField}) getSpeciesListValues ({error, data}) {
        if (data) {
            this.speciesList = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: '0123k000000zt0fAAA', fieldApiName: marketField}) getMarketListValues ({error, data}) {
        if (data) {
            this.marketList = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: '0123k000000zt0fAAA', fieldApiName: productLineField}) getProductLineListValues ({error, data}) {
        if (data) {
            this.productLineList = data.values;
        }
    }

    @wire(getPicklistValues, {recordTypeId: '0123k000000zt0fAAA', fieldApiName: fileTypeField}) getFileTypeListValues ({error, data}) {
        if (data) {
            this.fileTypeList = data.values;
        }
    }

    @wire (getLibraries, {validLibraries: libraryNames}) getLibraries({error, data}) {
        if (data) {
            this.libraryList = JSON.parse(JSON.stringify(data));
            for (let i = 0; i < this.libraryList.length; i++) {
                this.libraryList[i]['label'] = this.libraryList[i].Name;
                this.libraryList[i]['value'] = this.libraryList[i].Id;
            }
        }
        else if (error) {
            console.log(error);
        }
    }

    connectedCallback() {
        getMarket({userId: currentUserId})
        .then(market => {
            this.currentMarket = market;

            let marketArray = this.stringToArray(market);
            this.filters = ' AND Account.ZTS_EU_Market__c IN (';
            for (let i = 0; i < marketArray.length; i++) {
                this.filters += '\'' + marketArray[i] + '\',';
            }
            this.filters = this.filters.substring(0, this.filters.length - 1) + ')';
            
            this.filterMarkets(marketArray);
            this.getEditableFiles();
        }).catch(error => {
            this.filterMarkets([]);
            this.getEditableFiles();
        })
    }

    filterMarkets(userMarkets) {
        let newMarketList = [];
        for (let i = 0; i < this.marketList.length; i++) {
            if (userMarkets.includes(this.marketList[i].value)) {
                newMarketList.push(this.marketList[i]);
            }
            else {
                let newMarketOption = Object.assign({}, this.marketList[i]);
                newMarketOption.isDisabled = true;
                newMarketList.push(newMarketOption);
            }
        }
        this.marketList = newMarketList;
    }
    
    getEditableFiles() {
        getFiles({'userId': currentUserId, 'findEditable': true}).then(result => {
            for (let i = 0; i < result.length; i++) {
                let file = this.processFileInput(result[i]);

                file.disabled = false; // Find a way to filter files by which market they're in, and use this variable to determine whether it can be edited or not
                // Since profiles are not implemented yet, use file owner for now
                this.allFiles.push(file);
            }
            this.getLockedFiles();
        });
    }

    getLockedFiles() {
        getFiles({'userId': currentUserId, 'findEditable': false}).then(result => {
            for (let i = 0; i < result.length; i++) {
                let file = this.processFileInput(result[i]);

                file.disabled = true;

                // Special checking for markets: If a document is set for all by its original owner, we don't want other admins to restrict access to only their own market
                if (!file.Applicable_Markets__c || file.Applicable_Markets__c.length == 0) {
                    file.marketDisabled = true;
                }

                this.allFiles.push(file);
            }
            this.getLibraryValues();
        });
    }

    processFileInput(result) {
        let importedSpecies = this.stringToArray(result.Applicable_Species__c);
        result.Applicable_Species__c = this.arraySearch(importedSpecies, this.speciesList);

        if (!result.Applicable_Markets__c) {
            result.Applicable_Markets__c = [];
        }
        else {
            let importedMarkets = this.stringToArray(result.Applicable_Markets__c);
            result.Applicable_Markets__c = this.arraySearch(importedMarkets, this.marketList);
        }

        result.initDistributors = result.Applicable_Distributors__c;
        result.Applicable_Distributors__c = [];

        if (!result.FileType.includes('doctype:')) {
            result.FileType = 'doctype:' + result.FileType.toLowerCase();
        }

        return result;
    }

    getLibraryValues() {
        let fileIdList = [];
        for (let i = 0; i < this.allFiles.length; i++) {
            fileIdList.push(this.allFiles[i].Id);
        }

        getFileLibraries({contentVersionIds: fileIdList})
        .then(fileLibraries => {
            console.log(JSON.stringify(fileLibraries));
            for (let i = 0; i < this.allFiles.length; i++) {
                this.allFiles[i].Library = fileLibraries[this.allFiles[i].Id];
            }
            console.log(JSON.stringify(this.allFiles));
            
            this.checkDistributors();
        });
    }

    checkDistributors() {
        for (let i = 0; i < this.allFiles.length; i++) {
            this.allFiles[i].showPillContainer = false;
            if (this.allFiles[i].initDistributors) {
                // Apex call within a for loop probably isn't a great idea, optimize this in the future.
                accountSearch({'accountIds': this.stringToArray(this.allFiles[i].initDistributors)})
                .then(accountList => {
                    for (let j = 0; j < accountList.length; j++) {
                        accountList[j].label = accountList[j].Name;
                        accountList[j].name = accountList[j].Id;
                        accountList[j].type = 'icon';
                        accountList[j].iconName = 'standard:account'
                    }
                    this.allFiles[i].Applicable_Distributors__c = accountList;
                    this.allFiles[i].showPillContainer = true;
                });
            }
        }
        this.loading = false; // Might want to move this to a seperate function to be called after
    }

    sharePicklistValues() {
        let childComponent = this.template.querySelector('c-alpha-custom-library-file-upload');
        childComponent.speciesList = this.speciesList;
        // childComponent.marketList = this.marketList;
        childComponent.marketList = this.marketList.filter(market => market.isDisabled != true);
        childComponent.productLineList = this.productLineList;
        childComponent.filters = this.filters;
        childComponent.libraryList = this.libraryList;
        childComponent.fileTypeList = this.fileTypeList;
    }

    handleValueChange(event) {
        let ctrlName = event.currentTarget.dataset.name;
        let key = event.currentTarget.dataset.id;
        switch(ctrlName){
            case 'title':
                this.allFiles[key].Title = event.target.value;
                break;
            case 'library':
                this.allFiles[key].Library = event.target.value;
                break;
            case 'fileType':
                this.allFiles[key].Library_File_Type__c = event.target.value;
                break;
            case 'species':
                this.allFiles[key].Applicable_Species__c = this.arraySearch(event.detail, this.speciesList);
                break;
            case 'productLine':
                this.allFiles[key].Product_Line__c = event.target.value;
                break;
            case 'market':
                this.allFiles[key].Applicable_Markets__c = this.arraySearch(event.detail, this.marketList);
                break;
            case 'distributor':
                this.allFiles[key].Applicable_Distributors__c = event.detail;
                break;
        }
    }

    handleSave() {
        console.log(JSON.stringify(this.allFiles));

        this.loading = true;
        saveFiles({'dataJson' : this.allFiles})
        .then(() => {
            this.loading = false;
            let toastEvent = new ShowToastEvent({
                title: 'Success',
                message: 'Data saved successfully.',
                variant: 'success',
            });
            this.dispatchEvent(toastEvent);
        })
        .catch(error => {
            console.log(error);
            this.loading = false;
            let toastEvent = new ShowToastEvent({
                title: 'Error When Saving',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
        });
    }

    handleUploadFile() {
        let childComponent = this.template.querySelector('c-alpha-custom-library-file-upload');
        if (childComponent.validation) {
            this.loading = true;
            let fileData = {
                'title': (childComponent.title ? childComponent.title : childComponent.selectedFileName),
                'library': childComponent.library,
                'fileType': childComponent.fileType,
                'path': childComponent.selectedFilePath,
                'productLine': childComponent.productLine,
                'species': childComponent.species,
                'distributor': childComponent.distributor,
                'market': childComponent.market
               
            }
            console.log('fileData',fileData);
            uploadFile({'file': childComponent.selectedFile, 'fileData': fileData})
            .then(uploadedFile => {
                this.loading = false;
                this.hideUploadModal();
                this.updateTable(uploadedFile, childComponent.library);
                console.log('updateTable',  this.updateTable);
                
                let toastEvent = new ShowToastEvent({
                    title: 'Success',
                    message: 'New file uploaded.',
                    variant: 'success',
                });
                this.dispatchEvent(toastEvent);
            })
            .catch(error => {
                this.loading = false;
                console.log(error);
                let toastEvent = new ShowToastEvent({
                    title: 'Error Uploading File',
                    message: error.body.message,
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);
            })
        }
    }

    updateTable(newFile, libraryId) {
        newFile.disabled = false;
        newFile.Applicable_Species__c = this.arraySearch(this.stringToArray(newFile.Applicable_Species__c), this.speciesList);

        if (!newFile.Product_Line__c) {
            newFile.Product_Line__c = '';
        }

        if (!newFile.Applicable_Markets__c) {
            newFile.Applicable_Markets__c = [];
        }
        else {
            newFile.Applicable_Markets__c = this.arraySearch(this.stringToArray(newFile.Applicable_Markets__c), this.marketList);
        }

        newFile.Library = libraryId;
        newFile.Library_File_Type__c = newFile.Library_File_Type__c;

        newFile.showPillContainer = false;
        if (!newFile.Applicable_Distributors__c) {
            newFile.Applicable_Distributors__c = [];


            
            newFile.FileType = 'doctype:' + newFile.FileType.toLowerCase();
    
            // Inserts the new file at the bottom of the editable files
            let insertIndex = this.allFiles.findIndex(file => file.disabled == true);
            if (insertIndex < 0) {
                insertIndex = 0;
            }
            this.allFiles.splice(insertIndex, 0, newFile);
        }
        else {
            newFile.showPillContainer = true;
            newFile.initDistributors = newFile.Applicable_Distributors__c;
            accountSearch({'accountIds': this.stringToArray(newFile.Applicable_Distributors__c)})
            .then(accountList => {
                for (let i = 0; i < accountList.length; i++) {
                    accountList[i].label = accountList[i].Name;
                    accountList[i].name = accountList[i].Id;
                    accountList[i].type = 'icon';
                    accountList[i].iconName = 'standard:account'
                }
                newFile.Applicable_Distributors__c = accountList;



                newFile.FileType = 'doctype:' + newFile.FileType.toLowerCase();
        
                // Inserts the new file at the bottom of the editable files
                let insertIndex = this.allFiles.findIndex(file => file.disabled == true);
                if (insertIndex < 0) {
                    insertIndex = 0;
                }
                this.allFiles.splice(insertIndex, 0, newFile);
            })
        }
    }

    handleDeleteClick(event) {
        let key = event.currentTarget.dataset.id;
         this.deletionFile = this.allFiles[key];
        if (!this.deletionFile.disabled) {
            this.displayDeleteModal();
        }
    }

    confirmDeleteFile() {
        this.hideDeleteModal();
        this.loading = true;
        deleteFile({fileId: this.deletionFile.Id})
        .then(x => {
            location.reload();
        })
        .catch(error => {
            let toastEvent = new ShowToastEvent({
                title: 'Error Deleting File',
                message: error.body.pageErrors[0].message,
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
        })
    }

    displayUploadModal() {
        this.showUploadModal = true;
    }

    hideUploadModal() {
        this.showUploadModal = false;
    }

    displayDeleteModal() {
        this.showDeleteModal = true;
    }

    hideDeleteModal() {
        this.showDeleteModal = false;
    }

    // Salesforce stores multi-picklist values as semicolon seperated strings. We convert these to an array of values, then to an array made up of picklist options that correspond to those values. This second array is an array of dictionaries. We pass this array to alphaMultiPicklist, which requires this format. The component returns an array of values, which we must convert back to a list of picklist options before sending it back to the component.
    stringToArray(string) {
        return string.split(';');
    }

    arrayToString(array) {
        let string = '';
        array.forEach(entry => string += entry);
    }

    // Converts an array of string values, searchValues, to an array of dictionaries, with the dictionary values coming from searchOptions.
    arraySearch(searchValues, searchOptions) {
        let returnList = [];
        for (let i = 0; i < searchValues.length; i++) {
            let option = searchOptions.find(option => option.value === searchValues[i]);
            if (option) {
                returnList.push(option); // Values not found will not be passed on, so make sure there's no case where a field has a value that the picklist does not support 
            }
        }
        return returnList;
    }

      
  // handleDownloadClick function will work for downloading the file.
    handleDownloadClick(event){
        debugger
        this.loading = true;
        let key = event.currentTarget.dataset.id;
      this.downLoadOneFile = this.allFiles[key];
      downloadFile({fileId :this.downLoadOneFile.Id})
           .then(result => {
            const fileInfo = result;
            const ContentDocumentId = fileInfo[0].ContentDocumentId;
            const Title = fileInfo[0].Title;
            var urlString = window.location.href;
            var baseURL = urlString.substring(0, urlString.indexOf('force.com/')+10);
            const url = baseURL + `sfc/servlet.shepherd/document/download/` + ContentDocumentId ;
            const link = document.createElement('a');
            link.href = url;
            link.download = Title;
            link.click();
            URL.revokeObjectURL(url);
            this.loading = false;  
            })
           .catch(error => {
            let toastEvent = new ShowToastEvent({
                title: 'Error Downloading File',
                message: error.body.pageErrors[0].message,
                variant: 'error',
            });
            this.dispatchEvent(toastEvent);
            this.loading = false;  
        })
    } 
}