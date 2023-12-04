import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Reflabs_Error_Message from '@salesforce/label/c.RefLabs_Ship_To_Address_Error';
import Reflabs_Multiple_ShiptTo_Error_Message from '@salesforce/label/c.Reflabs_Multiple_ShiptTo_Error_Message';
import isAccountWithNoShipTo from '@salesforce/apex/ReflabsNoShipToErrorMessageController.isAccountWithNoShipTo';
export default class RefLabsNoShipToErrorMessage extends LightningElement {

    @api recordId;
    @wire(getRecord, { recordId: '$recordId', fields: [ 'Case.Id'] })
    
    getCaserecord({ data, error }) {

        if (data) {
            this.checkIsAccountWithNoShipTo();
        } 
        else if (error) {
            console.error('ERROR => ', JSON.stringify(error)); 
        }
    }

    checkIsAccountWithNoShipTo() {

        isAccountWithNoShipTo({caseId : this.recordId})
            .then(result => {
                
                if(result){
                    this.showErrorToast();
                }
                else {
                    this.showShipToErrorToast();
                }
                
            })
            .catch(error => {
                this.error = error;
            });
    }
    
    showErrorToast() {

        const evt = new ShowToastEvent({
            title: 'WARNING',
            message: Reflabs_Error_Message,
            variant: 'Error',
            mode: 'Sticky'
        });
        this.dispatchEvent(evt);
    }

    showShipToErrorToast() {

        const evt = new ShowToastEvent({
            title: 'WARNING',
            message: Reflabs_Multiple_ShiptTo_Error_Message,
            variant: 'Error',
            mode: 'Sticky'
        });
        this.dispatchEvent(evt);
    }
}