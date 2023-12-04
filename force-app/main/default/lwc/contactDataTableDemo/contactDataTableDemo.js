/* eslint-disable guard-for-in */
/* eslint-disable no-prototype-builtins */
import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRelatedRecords from '@salesforce/apex/ContactEditlwcEditSaveRowCtrl.getContacts';
import saveDraftValues from '@salesforce/apex/ContactEditlwcEditSaveRowCtrl.saveDraftValues';
import getAffiliationRecords from '@salesforce/apex/ContactEditlwcEditSaveRowCtrl.getAffiliationRecords';
import deactivateAffilifiations from '@salesforce/apex/ContactEditlwcEditSaveRowCtrl.deactivateAffilifiations';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import CONTACT_OBJECT from '@salesforce/schema/Contact';

import ModalRecordEditForm from "c/contactNewForm";

const AFF_COLUMNS = [
    {
        label: 'Name', fieldName: 'AffName', type: 'url', wrapText: "true", typeAttributes: {
            label: {
                fieldName: 'Name'
            },
            target: '_blank',
        }
    },
    { label: 'Account', fieldName: 'ZTS_EU_Account_Name_text__c', type: 'text', wrapText: "true" },
    { label: 'Contact', fieldName: 'ZTS_EU_Contact_Name_Text__c', type: 'text', wrapText: "true" },
    { label: 'Affiliation Status', fieldName: 'ZTS_EU_Affiliation_Status__c', type: 'text', wrapText: "true" },
    { label: 'Profession', fieldName: 'ZTS_US_Profession__c', type: 'text', wrapText: "true" },
    { label: 'Job Function', fieldName: 'ZTS_US_Job_Function__c', type: 'text', wrapText: "true" },
];

const COLUMNS = [
    {
        label: 'Contact Name',
        fieldName: 'ContName',
        type: 'url',
        wrapText: "true",
        typeAttributes: {
            label: {
                fieldName: 'Full_Contact_Name__c'
            },
            target: '_blank',
        }
    },
    {
        label: 'Account',
        fieldName: 'AccName',
        type: 'url',
        wrapText: "true",
        typeAttributes: {
            label: {
                fieldName: 'Account_Name__c'
            },
            target: '_blank',
        },
        sortable: "true",
    },
    {
        label: 'First Name',
        fieldName: 'FirstName',
        type: 'text',
        editable: true,
        sortable: "true",
        wrapText: "true",
        typeAttributes: null,
    },
    {
        label: 'Last Name',
        fieldName: 'LastName',
        type: 'text',
        editable: true,
        sortable: "true",
        wrapText: "true",
        typeAttributes: null,
    },
    {
        label: 'Colleague Entered Email',
        fieldName: 'Interface_Email__c',
        type: 'text',
        editable: true,
        sortable: "true",
        wrapText: "true",
        typeAttributes: null,
    },
    {
        label: 'Phone',
        fieldName: 'Phone',
        type: 'text',
        editable: true,
        sortable: "true",
        wrapText: "true",
        typeAttributes: null,
    },
    {
        label: 'Title',
        fieldName: 'Title',
        type: 'text',
        editable: true,
        sortable: "true",
        wrapText: "true",
        typeAttributes: null
    }, 
    {
        label: 'Profession',
        fieldName: 'ZTS_US_Profession__c',
        type: 'text',
        wrapText: "true",
        sortable: "true",
        cellAttributes: {
            class: { fieldName: 'professionClass' }
        }
    },
    {
        label: 'Job Function',
        fieldName: 'ZTS_US_Job_Function__c',
        type: 'text',
        wrapText: "true",
        sortable: "true",
        cellAttributes: {
            class: { fieldName: 'jobFunctionClass' }
        }
    },
    {
        label: 'Edit(Profession and Job Function)',
        type: "button-icon",
        typeAttributes: {
            iconName: 'utility:edit',
            name: 'Edit',
            title: 'Edit Profession and Job Function',
            alternativeText: 'Edit Profession and Job Function',
            variant: 'bare'
        },

    },
    {
        label: 'Contact Status',
        fieldName: 'ZTS_EU_Contact_Status__c',
        type: 'picklist',
        sortable: "true",
        typeAttributes: {
            placeholder: 'Choose Status',
            options: [],
            value: { fieldName: 'ZTS_EU_Contact_Status__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Contact Status',
            label: 'Status'
        },
        cellAttributes: {
            class: { fieldName: 'stageClass' }
        }
    }, {
        label: 'Account Influence',
        fieldName: 'ZTS_US_Account_influence__c',
        type: 'text',
        sortable: "true",
        type: 'picklist',
        sortable: "true",
        typeAttributes: {
            placeholder: 'Choose Account Influence',
            options: [],
            value: { fieldName: 'ZTS_US_Account_influence__c' },
            context: { fieldName: 'Id' },
            variant: 'label-hidden',
            name: 'Account Influence',
            label: 'Influence'
        },
        cellAttributes: {
            class: { fieldName: 'influenceClass' }
        }
    },
    {
        label: 'Affiliations',
        type: "button",
        typeAttributes: {
            label: 'Open',
            name: 'Open',
            variant: 'bare',
            iconPosition: 'left'
        },
    },
    {
        label: 'Created Date',
        fieldName: 'CreatedDate',
        type: 'date-local',
        editable: false,
        sortable: "true",
        wrapText: "true",
    }
];

export default class CustomDatatableDemo extends NavigationMixin(LightningElement) {
    columns = COLUMNS;
    affColumns = AFF_COLUMNS;
    @track records =[];
    lastSavedData;
    accountId;
    @track wiredRecords;
    showSpinner = false;
    showAffSaveSpinner = false;
    draftValues = [];
    privateChildren = {};
    @track showProfJobFunceditModal = false;
    @track showAffiliationTablemodal = false;
    @track selectedConProfession = '';
    @track selectedConJobFunction = '';
    @track selectedRowId;
    @track wiredAffRecords;
    @track selectedAffRecords = [];
    @track selectedAffRecordIds = [];


    @track initialConProfession = '';
    @track initialConJobFunction = '';
    @track copyofRecord;

    @track sortBy = 'CreatedDate';
    @track sortDirection = 'desc';
    @track errors = {};

    picklistValuesObject;
    jobfunctionPicklistValues;

    professionOptions = [];
    jobFunctionOptions = [];
    statusOptions = [];
    influenceOptions = [];
    accordionSection = [];
    filterCheck = false;

    @track filters = [];
    targetdatatable;
    @track errors = {};


    get hasDraftData() {
        return this.draftValues.length > 0;
    }

    get hasFilters() {
        return this.filters.length > 0;
    }

    @track columnToAPIName = new Map([
        ['First Name', 'FirstName'],
        ['Last Name', 'LastName'],
        ['Account Name', 'Account_Name__c'],
        ['Email', 'Interface_Email__c'],
        ['Status', 'ZTS_EU_Contact_Status__c']
    ]);

    get filterOptions() {
        return [
            { label: 'First Name', value: 'First Name' },
            { label: 'Last Name', value: 'Last Name' },
            { label: 'Email', value: 'Email' },
            { label: 'Account Name', value: 'Account Name' },
            { label: 'Status', value: 'Status' },
        ];
    }

    addNewFilter(event) {
        if(this.hasDraftData){
            this.showTaostMsg('Warning','Please save yours changes on contact first, else you might lose your changes','warning');
        }else{
            const filterLastIndex = this.filters.length - 1;
            let emptyFilter = {
                fieldName: '',
                searchKey: '',
                fieldAPI: ''
            }
            emptyFilter.index = filterLastIndex + 1;
            this.filters.push(emptyFilter);
        }
    }

    deleteSearchFilter(event) {
        if(this.hasDraftData){
            this.showTaostMsg('Warning','Please save yours changes on contact first, else you might lose your changes','warning');
        }else{
            const itemindex = event.target.dataset.item;
            this.filters = this.filters.filter(item => item.index != itemindex);
            if (this.filters.length > 0) {
                this.handleSearch();
            }
            else{
                this.showSpinner = true;
                this.loadRecords();
            }
        }
    }

    handleSerchKeyColumnChange(event) {
        this.filters.forEach((item) => {
            if (item["index"] == event.target.dataset.item) {
                item["searchKey"] = event.target.value;
            }
        });
    }

    handleSearch() {
        if(this.hasDraftData){
            this.showTaostMsg('Warning','Please save yours changes on contact first, else you might lose your changes','warning');
        }else{
            let isValid = true;
            this.filters.forEach((item) => {
                if ((item["fieldName"] == '') || (item["searchKey"] == '')) {
                    isValid = false;
                }
            });
            if (!isValid) {
                this.showTaostMsg('Error','Please add search column and search key for all filters before applying','error');
                return;
            }

            else {
                this.filterCheck = true;
                this.showSpinner = true;
                this.loadRecords();
            }
        }   
    }

    handlefilterColumnChange(event) {
        this.filters.forEach((item) => {
            if (item["index"] == event.target.dataset.item) {
                item["fieldName"] = event.target.value;
                item["fieldAPI"] = this.columnToAPIName.get(event.detail.value);
            }
        });
    }

    CustomDatatableDemo() {
    }

    renderedCallback() {
        if (!this.isComponentLoaded) {
            window.addEventListener('click', (evt) => {
                this.handleWindowOnclick(evt);
            });
            this.isComponentLoaded = true;
        }
    }

    disconnectedCallback() {
        window.removeEventListener('click', () => { });
    }

    handleWindowOnclick(context) {
        this.resetPopups('c-datatable-picklist', context);
    }

    resetPopups(markup, context) {
        let elementMarkup = this.privateChildren[markup];
        if (elementMarkup) {
            Object.values(elementMarkup).forEach((element) => {
                element.callbacks.reset(context);
            });
        }
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: CONTACT_OBJECT,
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    })
    wiredFields({ error, data }) {
        if (data) {
            this.picklistValuesObject = data.picklistFieldValues;
            this.jobfunctionPicklistValues = this.picklistValuesObject.ZTS_US_Job_Function__c;
            //for pulling profession LOVs
            let rawProfOptions = [];
            let profLovs = data.picklistFieldValues["ZTS_US_Profession__c"].values;
            profLovs.forEach(dataVal => {
                rawProfOptions.push({ 'label': dataVal.label, 'value': dataVal.value });
            });
            this.professionOptions = rawProfOptions;
            //for pulling job function LOVs
            let rawJobFuncOptions = [];
            let jobFuncLovs = data.picklistFieldValues["ZTS_US_Job_Function__c"].values;
            jobFuncLovs.forEach(dataVal => {
                rawJobFuncOptions.push({ 'label': dataVal.label, 'value': dataVal.value });
            });
            this.jobFunctionOptions = rawJobFuncOptions;
            //for pulling contact status LOVs
            let rawStatusOptions = [];
            let statusLovs = data.picklistFieldValues["ZTS_EU_Contact_Status__c"].values;
            statusLovs.forEach(dataVal => {
                rawStatusOptions.push({ 'label': dataVal.label, 'value': dataVal.value });
            });
            this.statusOptions = rawStatusOptions;
            //for pulling account influence LOVs
            let rawInfluenceOptions = [];
            let influenceLovs = data.picklistFieldValues["ZTS_US_Account_influence__c"].values;
            influenceLovs.forEach(dataVal => {
                rawInfluenceOptions.push({ 'label': dataVal.label, 'value': dataVal.value });
            });
            this.influenceOptions = rawInfluenceOptions;
            if ((this.professionOptions.length > 0) && (this.jobFunctionOptions.length > 0) && (this.statusOptions.length > 0) && (this.influenceOptions.length > 0)) {
                this.showSpinner = true;
                this.loadRecords();
            }
        } else if (error) {
            this.notifyUser(
                'Loading Error',
                'An error occured while loading: ' + JSON.stringify(error.body.message),
                'error'
            );
        }
    }

    loadRecords() {
        return getRelatedRecords(
                {filterCriteria: JSON.stringify(this.filters),
                    sortField: this.sortBy,
                    sortOrder: this.sortDirection}).then((result) => {
            if (result) {
                result = JSON.parse(JSON.stringify(result));
                result.forEach(record => {
                    record.AccName = '/' + record.AccountId;
                    record.ContName = '/' + record.Id;
                    record.LastModifiedByName = record.LastModifiedBy.Name;
                    record.stageClass = 'slds-cell-edit';
                    record.professionClass = 'slds-cell-edit';
                    record.jobFunctionClass = 'slds-cell-edit';
                    record.influenceClass = 'slds-cell-edit';
                });

                if(this.filterCheck){
                    this.records.length = 0;
                    this.records = result;
                    this.filterCheck = !this.filterCheck;
                }else
                    this.records = [...this.records, ...result];

                this.columns[10].typeAttributes.options = this.statusOptions;
                this.columns[11].typeAttributes.options = this.influenceOptions;
                this.error = undefined;
            }
            this.lastSavedData = this.records;
            this.showSpinner = false;
        }).catch(error => {
            console.log(error);
        });

    }

    handleProfChange(event) {
        this.selectedConProfession = event.detail.value;
        this.jobFunctionOptions = this.getDependentJobFunctions(this.selectedConProfession);
    }

    getDependentJobFunctions(professionSelected) {
        let controllerValueIndex = this.jobfunctionPicklistValues.controllerValues[professionSelected];
        let jobFuncpicklistvalues = this.picklistValuesObject.ZTS_US_Job_Function__c.values;
        let dependentValues = [];
        jobFuncpicklistvalues.forEach(key => {
            for (let i = 0; i < key.validFor.length; i++) {
                if (controllerValueIndex == key.validFor[i]) {
                    dependentValues.push({
                        label: key.label,
                        value: key.value
                    });
                }
            }
        })
        return dependentValues;
    }

    handleJobFuncChange(event) {
        this.selectedConJobFunction = event.detail.value;

    }

    cancelOnClick(event) {
        this.showProfJobFunceditModal = false;
    }

    saveModalSelections(event) {
        this.showProfJobFunceditModal = false;
        if (this.copyofRecord.ZTS_US_Profession__c !== this.selectedConProfession) {
            let updatedProfItem;
            updatedProfItem = {
                Id: this.selectedRowId,
                ZTS_US_Profession__c: this.selectedConProfession,
            };
            this.setClassesOnData(
                this.selectedRowId,
                'professionClass',
                'slds-cell-edit slds-is-edited'
            );
            this.updateDraftValues(updatedProfItem);
            this.updateDataValues(updatedProfItem);
        }
        if (this.copyofRecord.ZTS_US_Job_Function__c !== this.selectedConJobFunction) {
            let updatedJobFuncItem;
            updatedJobFuncItem = {
                Id: this.selectedRowId,
                ZTS_US_Job_Function__c: this.selectedConJobFunction,
            };
            this.setClassesOnData(
                this.selectedRowId,
                'jobFunctionClass',
                'slds-cell-edit slds-is-edited'
            );

            this.updateDraftValues(updatedJobFuncItem);
            this.updateDataValues(updatedJobFuncItem);
        }
    }

    deactivateAff(event) {
        if (this.selectedAffRecords.length > 0) {
            this.showAffSaveSpinner = true;
            this.selectedAffRecords.forEach(element => {
                this.selectedAffRecordIds.push(element["Id"])
            });
            const param = {
                selectedIdsJson: JSON.stringify(this.selectedAffRecordIds)
            };
            deactivateAffilifiations(param).then((result) => {

                if (result == 'Success') {
                    this.showTaostMsg('Success','Selected Account Contact Affiliations have been inactivated','success');
                    this.showAffSaveSpinner = false;
                    this.showAffiliationTablemodal = false;
                    window.location.reload();
                }
                else {
                    this.showTaostMsg('Error','There was some error while deactivating the affiliations. Please contact your Admin','error');
                    this.showAffSaveSpinner = false;
                    this.showAffiliationTablemodal = false;
                }
            }
            );
        }
        else {
            this.showTaostMsg('Error','Please save yours changes on contact first, else you might lose your changes.','error');
        }
    }

    resetAffSelection(event) {
        this.selectedAffRecords = [];
    }

    closeAffModal(event) {
        this.showAffiliationTablemodal = false;
    }

    handleContactRowAction(event) {
        const actionName = event.detail.action.name;
        this.selectedRowId = event.detail.row.Id;
        this.copyofRecord = event.detail.row;
        const row = event.detail.row;
        switch (actionName) {
            case 'Edit':
                this.showProfJobFunceditModal = true;
                this.records.forEach((row) => {
                    if (row["Id"] === this.selectedRowId) {
                        this.selectedConProfession = row["ZTS_US_Profession__c"];
                        this.selectedConJobFunction = row["ZTS_US_Job_Function__c"];
                        this.jobFunctionOptions = this.getDependentJobFunctions(this.selectedConProfession);
                    }

                });
                break;
            case 'Open':
                if(this.hasDraftData){
                    this.showTaostMsg('Warning','Please save yours changes on contact first, else you might lose your changes.','warning');
                    break;
                }
                this.showSpinner = true;
                const param = {
                    selectedConId: this.selectedRowId
                };
                getAffiliationRecords(param).then((result) => {
                    //alert(result);
                    if (result != '') {
                        this.wiredAffRecords = JSON.parse(JSON.stringify(result));
                        this.wiredAffRecords.forEach(record => {
                            record.AffName = '/lightning/r/ZTS_EU_Affiliations__c/' + record.Id + '/edit?NavigationLocation=RELATED_LIST_ROW';
                        });
                        this.showSpinner = false;
                        this.showAffiliationTablemodal = true;
                    }
                    else {
                        this.showSpinner = false;
                        this.showTaostMsg('Warning','There is no Active Account Affiliation for the contact.','warning');
                    }
                });
                break;

        }
    }

    showTaostMsg(title,msg,varient){
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: varient,
                mode: 'dismissable' 
            })
        );
    }

    handleRowSelection = event => {
        var selectedRows = event.detail.selectedRows;
        selectedRows.forEach((item) =>
            this.selectedAffRecords.push(item)
        );
    }

    handleItemRegister(event) {
        event.stopPropagation();
        const item = event.detail;
        if (!this.privateChildren.hasOwnProperty(item.name))
            this.privateChildren[item.name] = {};
        this.privateChildren[item.name][item.guid] = item;
    }

    handleChange(event) {
        event.preventDefault();
        this.showSpinner = true;
    }

    handleCancel(event) {
        event.preventDefault();
        this.records = JSON.parse(JSON.stringify(this.lastSavedData));
        this.records.forEach( item => {
            item.stageClass = 'slds-cell-edit';
            item.professionClass = 'slds-cell-edit';
            item.jobFunctionClass = 'slds-cell-edit';
            item.influenceClass = 'slds-cell-edit';
        });
        this.handleWindowOnclick('reset');
        this.draftValues = [];
        this.errors = {};
    }

    handleCellChange(event) {
        event.preventDefault();
        this.updateDraftValues(event.detail.draftValues[0]);
    }

    handleValueChange(event) {
        event.stopPropagation();
        let dataRecieved = event.detail.data;
        let updatedItem;
        switch (dataRecieved.label) {
            case 'Status':
                updatedItem = {
                    Id: dataRecieved.context,
                    ZTS_EU_Contact_Status__c: dataRecieved.value,
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'stageClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            case 'Influence':
                updatedItem = {
                    Id: dataRecieved.context,
                    ZTS_US_Account_influence__c: dataRecieved.value,
                };
                this.setClassesOnData(
                    dataRecieved.context,
                    'influenceClass',
                    'slds-cell-edit slds-is-edited'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        }
        this.updateDraftValues(updatedItem);
        this.updateDataValues(updatedItem);
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.records));
        copyData.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
        this.records = [...copyData];
    }

    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = JSON.parse(JSON.stringify(this.draftValues));
        copyDraftValues.forEach((item) => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    handleEdit(event) {
        event.preventDefault();
        let dataRecieved = event.detail.data;
        this.handleWindowOnclick(dataRecieved.context);
        switch (dataRecieved.label) {
            case 'Status':
                this.setClassesOnData(
                    dataRecieved.context,
                    'stageClass',
                    'slds-cell-edit'
                );
                break;
            case 'Influence':
                this.setClassesOnData(
                    dataRecieved.context,
                    'influenceClass',
                    'slds-cell-edit'
                );
                break;
            default:
                this.setClassesOnData(dataRecieved.context, '', '');
                break;
        };
    }

    setClassesOnData(id, fieldName, fieldValue) {
        this.records = JSON.parse(JSON.stringify(this.records));
        this.records.forEach((detail) => {
            if (detail.Id === id) {
                detail[fieldName] = fieldValue;
            }
        });
    }

    checkError(){
        const emailRegex= /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let isValid = true; 
        var rowError = {};
        if (this.draftValues.length > 0) {
            this.draftValues.forEach(record => {
                if(record['Interface_Email__c'] != undefined && record['Interface_Email__c'] != null && record['Interface_Email__c'] != ''){
                    this.records.forEach( item => {
                        if(item.Id === record.Id){
                            let email = record['Interface_Email__c'];
                            if(!email.match(emailRegex)){
                                isValid = false;
                                rowError[item.Id] = {
                                    messages: ['You have entered an invalid format.'],
                                    fieldNames: ['Colleague Entered Email'],
                                    title: 'We have found 1 error'
                                };
                            }
                        }
                    });
                }
            })
        }
        if(!isValid){
            this.errors = {
                rows: rowError
            }
        }else{
            this.errors = {};
        }
        return isValid;
    }

    handleSave(event) {
        event.preventDefault();
        if (this.checkError() && this.draftValues.length > 0) {
            this.showSpinner = true;
            saveDraftValues({ data: this.draftValues })
                .then((result) => {
                    this.showTaostMsg('Success','Record updated successfully','success');
                    this.draftValues = [];
                    this.records.forEach( item => {
                        result.forEach( savedItem => {
                            if(item.Id === savedItem.Id){
                                for(var key in savedItem){
                                    if(key !== 'Id'){
                                        item[key] = savedItem[key];
                                    }
                                    item.stageClass = 'slds-cell-edit';
                                    item.professionClass = 'slds-cell-edit';
                                    item.jobFunctionClass = 'slds-cell-edit';
                                    item.influenceClass = 'slds-cell-edit';
                                }
                            }
                        })
                    });
                    this.lastSavedData = this.records;
                    this.showSpinner = false;
                });
        }
        else if(this.draftValues.length === 0) {
            this.showTaostMsg('Warning','There is no update to save','warning');
        }else{
            this.showTaostMsg('Error','Please check email format','error');
        }
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.showSpinner = true;
        this.loadRecords();
    }

    createNewContact() {
        if(this.hasDraftData){
            this.showTaostMsg('Warning','Please save yours changes on contact first, else you might lose your changes','warning');
        }else{
            ModalRecordEditForm.open({
                size: "medium",
                defaultRecordtypeId: "$objectInfo.data.defaultRecordTypeId"
            }).then((result) => {
                if(result === 'error'){
                    this.showTaostMsg('Error','Failed to create contact, please contact admin..','error');
                }else if(result === 'success' || result === 'duplicate' || result === 'affiliation'){
                    if(result === 'success'){
                        this.showTaostMsg('Success','New contact has been created successfully !!!','success');
                    }else if( result === 'duplicate'){
                        this.showTaostMsg('Success','Duplicate contact has been created successfully!!!','success');
                    }else{
                        this.showTaostMsg('Success','Contact affiliation has been created successfully!!!','success');
                    }
                    setTimeout(() => {
                        window.location.reload();
                    }, 1000);
                }
            });
        }
    }
}