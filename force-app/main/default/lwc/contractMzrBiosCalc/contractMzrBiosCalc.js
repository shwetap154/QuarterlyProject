import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import {getRecord,updateRecord,generateRecordInputForUpdate,getFieldValue} from 'lightning/uiRecordApi';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getDocRecords from '@salesforce/apex/CustomContractControllerLwc.getDocList';

export default class ContractMzrBiosCalc extends NavigationMixin(LightningElement) {

    @api recordId;

    @wire(getDocRecords)
    getDocRecords({error, data}) {
        if(data) {
            window.console.log('data', {data});
            console.log('data  ::: '+data);
        }
        else if(error) {
            window.console.log('error', {error});
            const toastEvent = new ShowToastEvent({ 
                title: 'Query Error.', 
                message: 'Error something something', 
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