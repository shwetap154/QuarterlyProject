/******************************************************************************************************************************************
 * Class Name   : FieldSetRecordForm
 * Description  : Lightning web component to create a record detail form from a field set
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 28 February 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     02/28/2020          Created.
 *****************************************************************************************************************************************/

import {LightningElement, api, wire, track} from 'lwc';
import getFieldsByFieldSetName from '@salesforce/apex/FieldSetRecordFormController.getFieldsByFieldSetName';

export default class FieldSetRecordForm extends LightningElement {
    menuOpen = true;

    @api objectApiName;
    @api recordId;
    @api fieldSetName;
    @api sectionHeader;

    @track error = '';
    @track fields = [];

    @track cssClass = '';
    @track iconName = 'utility:chevrondown';

    @wire(getFieldsByFieldSetName, {objectApiName: '$objectApiName', fieldSetName: '$fieldSetName'})
    wiredFields({ error, data }) {
        if (data) {
            let rawFields = [];
            Object.entries(data).forEach(fieldValue => {
                let fieldObject = fieldValue[1];
                rawFields.push({ 'objectApiName': fieldObject.objectApiName, 'fieldApiName': fieldObject.fieldApiName, 'readonly':"true" });
            });
            this.fields = rawFields;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.fields = [];
        }
    }

    handleToggleClick() {
        this.menuOpen = !this.menuOpen; //set to true if false, false if true.
        if(this.menuOpen) {
            this.cssClass = '';
            this.iconName = 'utility:chevrondown';
        }
        else {
            this.cssClass = 'slds-hide';
            this.iconName = 'utility:chevronright';
        }
    }

}