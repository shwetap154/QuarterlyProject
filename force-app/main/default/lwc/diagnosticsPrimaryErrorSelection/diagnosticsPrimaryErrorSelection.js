import { LightningElement,api,track } from 'lwc';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import searchPrimaryErrorCodes from '@salesforce/apex/DxPrimaryErrorLookupController.searchPrimaryErrorCodes';
import fetchData from '@salesforce/apex/DxPrimaryErrorLookupController.fetchData';



export default class DiagnosticsPrimaryErrorSelection extends LightningElement {
    @api recordId;

    @track selectedAssetId;
    @track selectedPrimaryConsumableId;
    @track selectedPrimaryErrorCodeId;
    @track selectedPrimaryErrorCode =[];

    isDataLoaded = false;
    renderPrimaryCodeSelector = false;
    formLoaded = false;


    renderErrorCodeLookup(){
        this.renderPrimaryCodeSelector =  (this.isDataLoaded && (this.selectedAssetId || this.selectedPrimaryConsumableId));
        if(!this.renderPrimaryCodeSelector){
            this.selectedPrimaryErrorCodeId =  null;
            this.selectedPrimaryErrorCode = [];
        }
    }

    handlePrimaryConsumableChange(event){
        this.selectedPrimaryConsumableId = event.detail.value.length? event.detail.value[0]: null;
        this.renderErrorCodeLookup();
    }

    handleAssetChange(event){
        this.selectedAssetId = event.detail.value.length? event.detail.value[0]: null;
        this.renderErrorCodeLookup();
    }

    handlePrimaryErrorCodeChange(event){
        this.selectedPrimaryErrorCodeId = event.detail.length? event.detail[0]: null;
        this.renderErrorCodeLookup();
    }


    handleSaveButtonClick(event){
        this.formLoaded = false;
        updateRecord({fields:{Id:this.recordId, AssetId:this.selectedAssetId, ZTS_US_Primary_Consumable__c:this.selectedPrimaryConsumableId, Primary_Error_Code__c:this.selectedPrimaryErrorCodeId}})
        .then(() => {
            this.showToast('success', 'Success','Case updated successfully!');
            this.formLoaded = true;
        })
        .catch(error => {
            this.showToast('error', 'Error!', error.body.message);
            this.formLoaded = true;
        });

    }
    

    handleSearch(event) {
        const lookupElement = event.target;
        searchPrimaryErrorCodes({searchTerm:event.detail.searchTerm,assetId:this.selectedAssetId,primaryConsumableId:this.selectedPrimaryConsumableId})
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                console.error(error);
                this.showToast('error', 'Error!', error.body.message);
            });
    }

    showToast(variant,title,message){
        const event = new ShowToastEvent({
            variant:variant,
            title: title,
            message:message
        });
        this.dispatchEvent(event);
    }

    handleFormLoad(event){
        this.formLoaded = false;
        fetchData({caseId:this.recordId})
            .then(result =>{
                this.selectedAssetId = result.assetId;
                let assetInputField = this.template.querySelector('[data-assetid]');
                if(!result.assetId){
                    assetInputField.reset();
                }else{
                    assetInputField.value  = this.selectedAssetId;
                }

                this.selectedPrimaryConsumableId = result.primaryConsumableId;
                this.template.querySelector('[data-pcid]').value  = result.primaryConsumableId;

                let primaryConsumableInputField = this.template.querySelector('[data-pcid]');
                if(!result.primaryConsumableId){
                    primaryConsumableInputField.reset();
                }else{
                    primaryConsumableInputField.value = this.selectedPrimaryConsumableId;
                }

                if(result.initialPrimaryErrorCode){
                    this.selectedPrimaryErrorCode = result.initialPrimaryErrorCode;
                }else{
                    this.selectedPrimaryErrorCode = [];
                    this.selectedPrimaryErrorCodeId = null;
                }

                this.isDataLoaded = true;
                this.renderErrorCodeLookup();
                this.formLoaded = true;
            }).catch(error=>{
                console.error(error);
                this.showToast('error', 'Error!', error.body.message);
                this.isDataLoaded = true;
                this.renderErrorCodeLookup();
                this.formLoaded = true;
            });
    }

}