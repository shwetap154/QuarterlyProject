import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import NAME_FIELD from '@salesforce/schema/Contact.Name';
import ID_FIELD from '@salesforce/schema/Contact.ID';
import getContactRec from '@salesforce/apex/CustomContactLWCController.getSingleRecord';
import STATUS_FIELD from '@salesforce/schema/Contact.ZTS_EU_Contact_Status__c';

import {getRecord,updateRecord,generateRecordInputForUpdate,getFieldValue} from 'lightning/uiRecordApi';
import {CurrentPageReference} from 'lightning/navigation';
//const fields = [STATUS_FIELD];

export default class Updaterecord extends LightningElement {
    disabled = false;
    @track error;
    @api recordId;

    @wire(getContactRec, { recordId: '$recordId'})
    getContactRec({error, data}) {

        if(data) {
            var callStatus = data.ZTS_EU_Contact_Status__c;
            window.console.log('status', callStatus);
            if (callStatus === 'Rep Action'){
                let record = {
                    fields: {
                        Id: this.recordId,
                        Name: this.name,
                        ZTS_EU_Contact_Status__c: 'Pending',
                    },
                };
                updateRecord(record)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Record Is Updated',
                                variant: 'success',
                            }),
                        );
                        this.closeQuickAction();
                    })
                    .catch(error => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error on data save',
                                message: error.message.body,
                                variant: 'error',
                            }),
                        );
                        this.closeQuickAction();
                    });
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error on data save',
                        message: 'Only Contacts with status Rep Action can be resubmitted',
                        variant: 'error',
                    }),
                );
                this.closeQuickAction();
            }
        }
        else if(error) {
            window.console.log('error', {error});
            const toastEvent = new ShowToastEvent({ 
                title: 'Query Error.', 
                message: 'Error occurred while getting data from Contact', 
                variant: 'error' 
            });
            this.dispatchEvent(toastEvent);
        }
    }

    closeQuickAction() {
        window.console.log('closeQuickAction triggered');
        const close = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(close);
    }

}