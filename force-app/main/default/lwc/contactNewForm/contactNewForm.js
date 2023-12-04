import { LightningElement, api, track, wire } from 'lwc';
import LightningModal from "lightning/modal";
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import getDupContactList from '@salesforce/apex/CreateDuplicateRecordUtil.getDupContactDetails';
import createContact from '@salesforce/apex/CreateDuplicateRecordUtil.createDuplicateRecord';
import createAffliation from '@salesforce/apex/CreateDuplicateRecordUtil.createAffiliation';

export default class ContactNewForm extends LightningModal{
    errors;
    @api defaultRecordtypeId;
    @track showDupContactModal = false;
    @track showDupContactTable = false;
    @track duplicateContactMessage = '';
    @track conRecords = [];
    @track matchingIdJSON;
    @api showDuplicateScreen = false;
    @track contactInstance = {};
    @track showLoading = true;
    @track selectedConRecordId;
    @track noSelectionErrorMsg;

    // Store input field values in temporary instance, helps in retaining the data while rendering
    handleChange(event){
        this.contactInstance[event.target.name] = event.target.value;
    }

    // runs after the form is fully loaded 
    handleLoad(event){
        this.showLoading = false;
        this.noSelectionErrorMsg = '';
    }

    // Columns for the duplicate contact data table
    get conColumns() {
         return [
             { label: 'Contact Name', fieldName: 'Full_Contact_Name__c' },
             { label: 'Account Name', fieldName: 'Account_Name__c' },
             { label: 'Status', fieldName: 'ZTS_EU_Contact_Status__c' },
             { label: 'Email', fieldName: 'Interface_Email__c' },
             { label: 'Phone', fieldName: 'Phone' },
             { label: 'Profession', fieldName: 'ZTS_US_Profession__c' },
             { label: 'Job Function', fieldName: 'ZTS_US_Job_Function__c' },
 
         ];
     };

    // fires on cancel button event
    handleCreateContactCancel(event){
        this.close();
    }

    // fires on submit/save button click event
    handleCreateContactSubmit(event){
        this.showLoading = true;
    }

    // runs after successful contact/record creation
    handleCreateContactSuccess(event){
        this.close('success');
    }

    // to check duplicate contacts and query the revelant data to show in table
    handleCreateContactError(event){
         let confMsg;
         let matchingids = [];
         let matchingcontacts = [];
         let selection;
         this.noSelectionErrorMsg = '';
         if (JSON.stringify(event.detail.output.errors[0]).includes('duplicateRecordError')) {
             confMsg = "This record looks like an existing contact. ";
             confMsg = confMsg + "Please make sure to check any potential duplicate records before creating this contact. Use radio button to select an existing Contact if applicable.";
             confMsg = confMsg + " If the contact you select is showing a different account name, it will create a new affiliation to the account you are entering for."; 
             this.duplicateContactMessage = confMsg;
             let dupContactCount;
             dupContactCount = event.detail.output.errors[0].duplicateRecordError.matchResults[0].matchRecordIds.length;
             if (dupContactCount >= 1) {
                 this.showDupContactTable = true;
                 for (let i = 0; i < dupContactCount; i++) {
                     matchingids.push(event.detail.output.errors[0].duplicateRecordError.matchResults[0].matchRecordIds[i]);
                 }
                 this.matchingIdJSON = JSON.stringify(matchingids);
             }
             this.showLoading = false;
             this.toggleScreen();
         }else {
             this.close('error');
         }
    }

    @wire(getDupContactList, { selectedIdsJson: '$matchingIdJSON' })
        getCon({ error, data }) {
            if (data) {
                this.conRecords = data;
            } else if (error) {
                this.close('error');
            }
     }

    // to switch between form or duplicate record table view
    toggleScreen(){
        this.showDuplicateScreen = !this.showDuplicateScreen;
    }

    // capture event on radio button check event on duplicate contact table
    handleRowSelection = event => {
         var selectedRows = event.detail.selectedRows;
         this.selectedConRecordId = selectedRows[0].Id;
         this.noSelectionErrorMsg = '';
    }

    // fires on cancel button on duplicate contacts screen
    cancelDuplicateContact(event){
        this.toggleScreen();
        this.noSelectionErrorMsg = '';
    }

    // bypass duplicate check logic and create a duplicate contact record
    saveDuplicateContact(event) {
        this.showLoading = true;
        this.contactInstance.ZTS_EU_Market__c = 'United States';
        let objson = JSON.stringify(this.contactInstance);
        const param = {
            sObjectRecord: objson,
            objectName: 'Contact'
        };
        let conId; 
        createContact(param).then((result) => {
            if (result !== 'ERROR') {
                this.close('duplicate');
            }
            this.showLoading = false;
        }).catch((error) => {
            this.showLoading = false;
            this.close('error');
        });
     }
     
     // if the account selected while creating new contact is different then the duplicate contact, logic will create a new affiliation
     createNewAffiliation(event) {
         this.showLoading = true;
         const accountField = this.contactInstance.AccountId;

         if (this.selectedConRecordId !== undefined) {
             const createContactParam = {
                 contactId: this.selectedConRecordId,
                 accountId: accountField 
             };
             createAffliation(createContactParam)
                 .then(results => {
                    this.showLoading = false;
                    this.close('affiliation');
                 })
                 .catch(error => {
                     this.showLoading = false;
                     this.close('error');
                 });
         }
         else {
            this.showLoading = false;
            this.noSelectionErrorMsg = 'Error: Please select a contact from the list.';
         }
     }
}