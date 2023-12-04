import { LightningElement,api,wire,track } from 'lwc';
import { FlowAttributeChangeEvent} from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import checkDuplicate from '@salesforce/apex/CreateDuplicateRecordUtil.checkDuplicateRecords'; 
import createContact from '@salesforce/apex/CreateDuplicateRecordUtil.createDuplicateRecord';
import createAffiliation from '@salesforce/apex/CreateDuplicateRecordUtil.createAffiliation';
import CONTACT_FIRSTNAME from '@salesforce/schema/Contact.FirstName';
import CONTACT_LASTNAME from '@salesforce/schema/Contact.LastName';
import CONTACT_SALUTATION from '@salesforce/schema/Contact.Salutation';
import CONTACT_PROFESSION from '@salesforce/schema/Contact.ZTS_US_Profession__c';
import CONTACT_JOB_FUNCTION from '@salesforce/schema/Contact.ZTS_US_Job_Function__c';
import CONTACT_RECORDTYPEID from '@salesforce/schema/Contact.RecordTypeId';
import CONTACT_ACCOUNTID from '@salesforce/schema/Contact.AccountId';
import CONTACT_INTERFACE_EMAIL from '@salesforce/schema/Contact.Interface_Email__c';

export default class DuplicateContactChoice extends LightningElement {
    @api firstName;
    @api lastName;
    @api salutation;
    @api recordTypeId;
    @api jobFunction;
    @api profession;
    @api accountId;
    @api interfaceEmail;

    @api selectedContact;

    @track conRecords;
    @track wiredRecords;
    @track isLoaded = false;

    newContact;
    notifyViaAlerts = false;

    connectedCallback(){
        let contactRec = {
            [CONTACT_FIRSTNAME.fieldApiName] : this.firstName,
            [CONTACT_LASTNAME.fieldApiName] : this.lastName,
            [CONTACT_RECORDTYPEID.fieldApiName] : this.recordTypeId,
            [CONTACT_ACCOUNTID.fieldApiName] : this.accountId,
            [CONTACT_PROFESSION.fieldApiName] : this.profession,
            [CONTACT_JOB_FUNCTION.fieldApiName] : this.jobFunction,
            [CONTACT_SALUTATION.fieldApiName] : this.salutation,
            [CONTACT_INTERFACE_EMAIL.fieldApiName] : this.interfaceEmail
        };
        this.newContact = contactRec;
        checkDuplicate({contactRecord : contactRec})
            .then(result => {
                result = JSON.parse(JSON.stringify(result));
                this.wiredRecords = [...result];
                let i=0;
                result.forEach(rec => {
                    if(i == 0)
                        this.selectedContact = rec.Id;

                    rec.checked = i++ == 0 ? true: false;
                    rec.contactRef = '/' + rec.Id; 
                });
                this.conRecords = result;
                this.isLoaded = true;
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
    }

    handleRowSelection(event){
        let val = event.target.name;
        this.template
            .querySelectorAll('[data-element="ExistingContact"]')
            .forEach((element) => {
                element.checked = element.name == val;
            });

        this.wiredRecords.forEach(record => {
            if(record.Id == val)
                this.selectedContact = record.Id;
        });
    }

    addContactToCall(){
        const createContactParam = {
            contactId: this.selectedContact,
            accountId: this.accountId
        };

        createAffiliation(createContactParam)
            .then(results => {
            this.notifyUser(
                'Success',
                'Existing contact is selected, click Next.',
                'success'
            );
            const attributeChangeEvent = new FlowAttributeChangeEvent('customObject', 
            this.selectedContact);
            this.dispatchEvent(attributeChangeEvent);
            });
    }

    saveDuplicateContact(){
        this.isLoaded = false;
        this.newContact.ZTS_EU_Market__c = 'United States';
        let objson = JSON.stringify(this.newContact);
        const param = {
            sObjectRecord: objson,
            objectName: 'Contact'
        };
        createContact(param).then((result) => {
            if (result !== 'ERROR') {
                this.notifyUser(
                    'Success',
                    'The duplicate contact has been created, click Next.',
                    'success'
                );
                this.selectedContact = result;
            }
            else {
                this.selectedContact = null;
            }
        }).then(res => {
            const attributeChangeEvent = new FlowAttributeChangeEvent('customObject', 
            this.selectedContact);
            this.dispatchEvent(attributeChangeEvent);
            this.isLoaded = true;
        });
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }
}