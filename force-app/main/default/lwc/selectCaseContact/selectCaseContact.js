import { LightningElement, track, api, wire } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import getCaseDetail from '@salesforce/apex/CasesSelector.getCaseDetail';
import getContactsByCaseId from '@salesforce/apex/ContactSelector.getContactsByCaseId';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ID_FIELD from '@salesforce/schema/Case.Id';
import CONTACTID_FIELD from '@salesforce/schema/Case.ContactId';
import NO_CONTACT_FIELD from '@salesforce/schema/Case.No_Contact__c';
import { getRecord } from 'lightning/uiRecordApi';

export default class SelectCaseContact extends NavigationMixin(LightningElement) {
    @api recordId;
    @api selectedContactId;
    caseRecord;
    contactsData = [];

    @track wiredContactList;

    @track searchText = '';
    @track selectedContactId = null;
    @track isNoContact = false;
    @track showLoading = false;


    get resultData() {
        var data = [];
        if (this.contactsData != undefined) {
            this.contactsData.forEach(currentItem => {
                var row = JSON.parse(JSON.stringify(currentItem));
                if (row.Id == this.selectedContactId || this.searchText == '' || this.searchText == null || row.Name.toLowerCase().includes(this.searchText.toLowerCase())) {
                    row.isChecked = (row.Id == this.selectedContactId);
                    data.push(row);
                }
            });
        }
        return data;
    }

    connectedCallback() {
    }

    @wire(getRecord, { recordId: '$recordId', fields: ['Case.Id', 'Case.AccountId', 'Case.ContactId', 'Case.No_Contact__c'] })
    caseRec({ data, error }) {
        if (data) {
            this.caseRecord = {
                Id: data.fields.Id.value,
                No_Contact__c: data.fields.No_Contact__c.value,
                ContactId: data.fields.ContactId.value
            };
            if (this.caseRecord.No_Contact__c == true) {
                this.isNoContact = true;
            }
            if (this.caseRecord.ContactId != null) {
                this.selectedContactId = this.caseRecord.ContactId;
            }
            this.refresh();
        } else if (error) {
            console.error('ERROR => ', JSON.stringify(error));
        }
    }

    @wire(getContactsByCaseId, { caseId: '$recordId' }) conList(result) {
        this.wiredContactList = result;
        if (result.data) {
            this.contactsData = result.data;
        } else if (result.error) {
        }
    }

    refresh() {
        refreshApex(this.wiredContactList);
    }

    fetchContactsData() {
        getContactsByCaseId({ caseId: this.recordId })
            .then(result => {
                this.contactsData = result;
            })
            .catch(error => {
                console.error('Error fetching contacts', error);
            });
    }

    handleSearch(event) {
        this.searchText = event.target.value;

    }

    handleSelection(event) {
        this.selectedContactId = '';
        if (event.target.checked == true) {
            this.selectedContactId = event.target.value;
            this.dispatchEvent(new FlowAttributeChangeEvent('selectedContactId', this.selectedContactId));
        }
        this.isNoContact = (this.selectedContactId == 'no-contact');
    }
    handleSave() {
        this.showLoading = true;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[NO_CONTACT_FIELD.fieldApiName] = (this.isNoContact == true);
        fields[CONTACTID_FIELD.fieldApiName] = (this.isNoContact == false && this.selectedContactId != null) ? this.selectedContactId : null;

        const recordInput = { fields };
        console.log(recordInput);
        updateRecord(recordInput)
            .then(() => {
                this.showToast('Success!!', 'Case updated successfully!!', 'success', 'dismissable');
                this.showLoading = false;
            })
            .catch(error => {
                this.showLoading = false;
                this.showToast('Error!!', error.body.message, 'error', 'dismissable');
            });
    }

    redirectToRecord(event) {
        var recordId = event.currentTarget.dataset.id;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

}