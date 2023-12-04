import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
// import ACCOUNT_OBJECT from '@salesforce/schema/Account';
// import NAME_FIELD from '@salesforce/schema/Account.Name';
// import ID_FIELD from '@salesforce/schema/Account.ID';
// import FIRSTNAME_FIELD from '@salesforce/schema/Account.ZTS_EU_Account_Status__c';
import getAccountRec from '@salesforce/apex/CustomActionsAccountController.getSingleAccount';


import {getRecord,updateRecord,generateRecordInputForUpdate,getFieldValue} from 'lightning/uiRecordApi';
import {CurrentPageReference} from 'lightning/navigation';
     
     
export default class Updaterecord extends LightningElement {
    disabled = false;
    @track error;
    @api recordId;

    @wire(getAccountRec, { recordId: '$recordId' })
    getAccountRec({error, data}) {

        if(data) {
            let record = {
                fields: {
                    Id: this.recordId,
                    Name: this.name,
                    ZTS_EU_Account_Status__c: 'Pending',
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
        else if(error) {
            const toastEvent = new ShowToastEvent({ 
                                    title: 'Query Error.', 
                                    message: 'Error occurred while getting data from Account', 
                                    variant: 'error' 
                                });
            this.dispatchEvent(toastEvent);
        }
    }

    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(closeQA);
    }
    
}