/******************************************************************************************************************************************
 * Class Name   : lwc_EventSubmitForApprovalBtn
 * Description  : Lightning web component for Events custom object
 * Created By   : Slalom/Art Smorodin
 * Created Date : 28 April 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin(Slalom)     04/28/2020          Created.
 * Yadagiri Avula           06/08/2023          Updated as part of TPDEV-483
 *****************************************************************************************************************************************/

import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import {getRecord,updateRecord,generateRecordInputForUpdate,getFieldValue} from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getEventRec from '@salesforce/apex/CustomEventLWCController.getSingleRecord';
import evtSendApproval from '@salesforce/apex/EventApproval.submitEventApprovalRequest';
import { getObjectInfo  } from 'lightning/uiObjectInfoApi';

import accountevents from '@salesforce/schema/ZTS_Events__c.ZTS_US_Number_of_Event_Account_Records__c';
import productevents from '@salesforce/schema/ZTS_Events__c.ZTS_US_Number_of_Event_Product_Records__c';
import eventinvitees from '@salesforce/schema/ZTS_Events__c.ZTS_US_Total_Event_Invitees__c';
import eventcatagory from '@salesforce/schema/ZTS_Events__c.ZTS_US_Event_Category__c';
import eventstatus from '@salesforce/schema/ZTS_Events__c.ZTS_US_Status__c';
import totalexpenses from '@salesforce/schema/ZTS_Events__c.ZTS_US_Sum_of_Total__c';



export default class Lwc_EventSubmitForApprovalBtn extends NavigationMixin(LightningElement) {

    disabled = false;
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    @track error;
    @track value;
    @api recordId;
    @track openmodel = false;
    @track noRecursion = false;
    


    @wire(getRecord, { recordId: '$recordId',fields : [accountevents,productevents,eventinvitees,eventcatagory,eventstatus,totalexpenses]})
    Eventrecord({error, data}) {
        if (this.noRecursion == false)
        {
            if(data) {
                var acc = data.fields.ZTS_US_Number_of_Event_Account_Records__c.value;
                var prd = data.fields.ZTS_US_Number_of_Event_Product_Records__c.value;
                var eventInvitees = data.fields.ZTS_US_Total_Event_Invitees__c.value;
                var speakers = data.fields.No_of_speakers__c;
                var cat = data.fields.ZTS_US_Event_Category__c.value;
                var status = data.fields.ZTS_US_Status__c.value;
                var totalexpense = data.fields.ZTS_US_Sum_of_Total__c.value;



                //Event must be Approved or Complete and Payment Requested check box is unchecked to do the update
                //else throw an error. 
                    if (cat === 'Speaker Event - Online Registration' && (acc==0 || prd ==0 || eventInvitees ==0  || totalexpense == 0)){                    this.notifyUser(
                        'Error',
                        'You must add at least one Product, one Account, one Event Invitee and one Speaker and one Expense to the event in order to submit',
                        'error'
                    );
                    this.closeQuickAction();
                }
                else if(acc==0 || prd ==0 || totalexpense ==0){
                    this.notifyUser(
                        'Error',
                        'You must add at least one Product and one Account and one Expense to the event in order to submit.',
                        'error'
                    );
                    this.closeQuickAction();
                }

                else if(status !== 'New' && status !== 'Re-approval Required' && status !== 'Rejected'){
                    this.notifyUser(
                        'Error',
                        'Event status should be New,Re-approval Required or Rejected in order to submit',
                        'error'
                    );
                    this.closeQuickAction();
                }
                else{
                    this.openmodel = true;
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

    closeQuickAction() {
        //refreshApex(this.getEventRec());
        const close = new CustomEvent('close');
        this.dispatchEvent(close);
        
    }

    closeModal() {
        this.openmodel = false;
        this.closeQuickAction();
    } 

    continueMethod() {
        evtSendApproval({ event: this.recordId})
                    .then(result => {
                        console.log("Approval created");
                        this.closeQuickAction();
                    })
                    .catch(error => {
                        this.notifyUser(
                            'Approval Creation Failed',
                            'An error ocurred while creating an Approval, Please contact System Administrator ', 
                            'error'
                            //+ JSON.stringify(error.body.message),
                        );
                        this.closeQuickAction();
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