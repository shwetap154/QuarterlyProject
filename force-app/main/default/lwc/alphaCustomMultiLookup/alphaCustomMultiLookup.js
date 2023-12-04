import { LightningElement,api,track } from 'lwc';
import findRecords from '@salesforce/apex/UtilityController.findRecordsModular';
export default class AlphaCustomLookup extends LightningElement {
       // public property with default value 
      
    @api objectName = 'Account';
    @api fieldName  = 'Name';
    @api iconname   = 'standard:record';
    @api label      = 'Account';
    @api additionalFields = '';
    @api filters    = '';
    @api market = ''; // This variable is required alphaCustomLibrary. If you are reusing this component, feel free to ignore it.
    
    // private property 
    @api disabled;
    @track records;
    @api selectedRecords = [];
    searching = false;

    
    //this method calls apex method and gets the data..
    handleSearch(event) {
        let searchVal = event.detail.value;
        let additionalFields = this.filters;
        if (this.selectedRecords.length > 0) {
            additionalFields += ' AND Id NOT IN (';
            for (let i = 0; i < this.selectedRecords.length; i++) {
                additionalFields += '\'' + this.selectedRecords[i].Id + '\',';
            }
            additionalFields = additionalFields.substring(0, additionalFields.length - 1) + ')';
        }
        additionalFields += ' LIMIT 6';
        
        findRecords({
            searchKey : searchVal, 
            objectName : this.objectName, 
            searchField : this.fieldName,
            additionalFields : this.additionalFields,
            conditions : additionalFields
        })
        .then(result => {
            this.records = result; //.slice(0, 6);
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.fieldName];
            }
            this.error = undefined;
            this.conditions = '';
        })
        .catch(error => {
            this.error = error;
            this.records = undefined;
            this.conditions = '';
        });
    }

    // selection of the record from dropdown..
    handleSelect(event) {
        let selectedVal = event.detail.selRec;
        selectedVal.label = selectedVal.Name;
        selectedVal.name = selectedVal.Id;
        selectedVal.type = 'icon';
        selectedVal.iconName = this.iconname;

        // Sometimes when value is assigned, it is set as a proxy, which does not accept a push. We must first clone the array, push to the cloned array, then reassign it to value
        // this.selectedRecords.push(selectedVal);
        this.selectedRecords = Object.assign([], this.selectedRecords);
        this.selectedRecords.push(selectedVal);

        let finalrecevent = new CustomEvent('recselect', {
            detail : this.selectedRecords
        });
        this.dispatchEvent(finalrecevent); // hook for the component which will consume..

        this.records = undefined;
        // this.searchValue = '';
        this.template.querySelector('c-alpha-child-search-bar-comp').reset();
    } 

    //removal of the record from the dropdown..
    handleRemove(event) {
        if (this.disabled) {
            // Because there's no way to disable a pill container, we just reassign this.selectedRecords to cancel out a pill being removed
            this.selectedRecords = Object.assign([], this.selectedRecords);
        }
        else if (this.market) {
            // Special case for alphaCustomLibrary
            let removedMarket = event.detail.item.ZTS_EU_Market__c;
            if (removedMarket !== this.market) {
                this.selectedRecords = Object.assign([], this.selectedRecords);
            }
            else {
                this.selectedRecords = Object.assign([], this.selectedRecords);
                this.selectedRecords.splice(this.selectedRecords.findIndex(record => record.Id == event.detail.item.Id), 1);
        
                let finalremevent = new CustomEvent('recselect', {
                    detail : this.selectedRecords
                });
                this.dispatchEvent(finalremevent); // hook for the component which will consume..
            }
        }
        else {
            this.selectedRecords = Object.assign([], this.selectedRecords);
            this.selectedRecords.splice(this.selectedRecords.findIndex(record => record.Id == event.detail.item.Id), 1);
    
            let finalremevent = new CustomEvent('recselect', {
                detail : this.selectedRecords
            });
            this.dispatchEvent(finalremevent); // hook for the component which will consume..
        }
    }

    // When the search field is empty, clear the search entries
    handleClearField(event) {
        this.records = undefined;
    }
}