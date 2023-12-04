import { LightningElement, api,track } from 'lwc';
import LightningModal from "lightning/modal";

export default class ModalRecordCreateForm extends LightningModal {
    @api AccountName;
    @api accountAltFields;
    errors;

    closePopupSuccess(event) {
        this.close(event.detail.id);
        const fields = event.detail.fields;
      }
      handleOkay(){
        this.close('okay');
      }
 
}