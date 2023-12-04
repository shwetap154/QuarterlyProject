/******************************************************************************************************************************************
 * Class Name   : lwc_EventRequestPaymentBtn
 * Description  : Lightning web component for Events custom object
 * Created By   : Slalom/Art Smorodin
 * Created Date : 26 April 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     04/26/2020          Created.
 *****************************************************************************************************************************************/

import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord,updateRecord,generateRecordInputForUpdate,getFieldValue} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getEventRec from '@salesforce/apex/CustomEventLWCController.getSingleRecord';
import evtSendEmail from '@salesforce/apex/RequestPayment.paymentRequestOnEvent';
import PAYMENT_REQUESTED from'@salesforce/schema/ZTS_Events__c.Payment_Requested__c'
import STATUS from'@salesforce/schema/ZTS_Events__c.ZTS_US_Status__c'
export default class  Updaterecord extends NavigationMixin(LightningElement) {

    disabled = false;
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    @track error;
    @track value;
    @api recordId;
    @track openmodel = false;
    @track noRecursion = false;

    @wire(getRecord, { recordId: '$recordId', fields: [PAYMENT_REQUESTED, STATUS] })
    getEventRec(value) {
        const { data, error } = value;
        if (this.noRecursion == false)
        {
            if(data) {
                var eveStatus = data.fields.ZTS_US_Status__c.value;
                var eveIsRequested = data.fields.Payment_Requested__c.value;
                //Event must be Approved or Complete and Payment Requested check box is unchecked to do the update
                //else throw an error. 
                if (eveStatus === 'Approved' || eveStatus === 'Complete'){
                    if(eveIsRequested == true){
                        this.notifyUser(
                            'Error on record update',
                            'Payment has already been requested for this event. Please contact PEI Support directly if there are additional items related to this PEI that need to be paid. Payment status updates will appear in your Chatter feed.',
                            'error'
                        );
                        this.closeQuickAction();
                    }
                    else{
                        this.openmodel = true;
                    }
                }
                else{
                    this.notifyUser(
                        'Error on record update',
                        'Payment can only be requested once the Event Status is Approved or Completed.',
                        'error'
                    );
                    this.closeQuickAction();
                }
                this.noRecursion = true;
            }
            else if(error) {
                this.notifyUser(
                    'Query Error.',
                    'Error occurred while getting data from this Event',
                    'error'
                );
                this.noRecursion = true;
            }
        }
    }

    closeModal() {
        this.openmodel = false;
        this.closeQuickAction();
    } 

    saveMethod() {
        var inp=this.template.querySelector("lightning-input");
        this.value=inp.value;
        if( this.value ){
            this.updateRecordMethod();  
        }
        else this.notifyUser(
            'Save Error',
            'An error occurred while saving: No instructions provided',
            'error'
        );
        this.closeQuickAction();
    }

    updateRecordMethod(){
        let record = {
            fields: {
                Id: this.recordId,
                Specific_Payment_Information__c: this.value,
                Payment_Requested__c: true,
            },
        };

        updateRecord(record)
            .then(() => {
                this.notifyUser(
                    'Success',
                    'Record was Updated',
                    'success'
                );
                evtSendEmail({ event: this.recordId})
                    .then(result => {
                        console.log("Email was sent");
                    })
                    .catch(error => {
                        this.notifyUser(
                            'Email Notification Failed',
                            'An error ocurred while sending an email: ' + JSON.stringify(error.body.message),
                            'error'
                        );
                    }); 
                this.dispatchEvent(new CustomEvent('recordChange'));
            })
            .catch(error => {
                this.notifyUser(
                    'Error on data save',
                    error.message.body,
                    'error'
                );
                
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
            console.log('in toastevent: ')
            this.dispatchEvent(toastEvent);
        }
    }

    closeQuickAction() {
        const close = new CustomEvent('close');
        this.dispatchEvent(close);
    }
}