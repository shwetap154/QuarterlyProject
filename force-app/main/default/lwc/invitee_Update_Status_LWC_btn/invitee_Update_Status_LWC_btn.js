import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import INVITEE_OBJECT from '@salesforce/schema/ZTS_US_Event_Invitee__c';
import getInviteeRec from '@salesforce/apex/EventInviteeListController.getRecords';
import STATUS_FIELD from '@salesforce/schema/ZTS_US_Event_Invitee__c.ZTS_US_Invitation_Status__c';

import {getRecord,updateRecord,generateRecordInputForUpdate,getFieldValue} from 'lightning/uiRecordApi';
import {CurrentPageReference} from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';

export default class testasdas extends NavigationMixin(LightningElement) {

    disabled = false;
    @track error;
    @api eventId;
    @api idList;
    @api status;

    @wire(getInviteeRec, { idList: '$idList'})
    getInviteeRec(result) { 

        if (result.data) {
            var object1 = result.data;
            var recsToUpdate = [];
            for(var item in object1){
                console.log('this is recId >>> ' + object1[item].Id);
                console.log('this is event >>> ' + object1[item].ZTS_US_Event__c);
                // this.eventId = object1[item].ZTS_US_Event__c;
                var recId = Object.values(Object.values(object1)[item])[0];
                var record = {
                    fields: {
                        Id: recId,
                        ZTS_US_Invitation_Status__c: this.status,
                    },
                };

                updateRecord(record)
                    .then(() => {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Record(s) Is Updated',
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
        }
        else if(result.error) {
            window.console.log('error', result.error);
            const toastEvent = new ShowToastEvent({ 
                title: 'Database query error has occurred', 
                message: 'Please select at least one Event Invitee record to update', 
                variant: 'error' 
            });
            this.dispatchEvent(toastEvent);
            this.closeQuickAction();
        }
    }

    closeQuickAction() {
        window.console.log('closeQuickAction triggered');
        console.log(' eventId ::: ' + this.eventId);
        (this.eventId != 'null') ? this.recordRedirectAction() :this.listRedirectAction();
    }

    listRedirectAction(){
        const close = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(close);
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'ZTS_US_Event_Invitee__c',
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: 'All' // or by 18 char '00BT0000002TONQMA4'
            }
        });
    }

    recordRedirectAction(){
        const close = new CustomEvent('close');
        // Dispatches the event.
        this.dispatchEvent(close);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.eventId,
                objectApiName: 'ZTS_Events__c', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
    
}