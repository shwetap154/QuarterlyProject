import { LightningElement, api, track, wire } from 'lwc';
import getColumns from '@salesforce/apex/RelatedListController.getColumns';
import getData from '@salesforce/apex/RelatedListController.getData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RelatedList extends LightningElement {

    @api recordId;
    @api fieldSetName;
    @api objectApi;
    @api filterField;
    @api iconName; 
    @api title;

    @track columns = [];
    @track data = [];
    @track displayTable = false;

    get header() {
        const numRecords = this.data.length <= 6 ? this.data.length : '6+';
        return this.title + ' (' + numRecords + ')';
    }

    // @wire(getColumns, {fieldSetName: '$fieldSetName', objectApiName: '$objectApi'})
    @wire(getColumns, {fieldSetName: '$fieldSetName', objectApiName: '$objectApi'})
    wiredColumns({ error, data }) {
        if (data) {
            let flattenedFieldNameColumns = [];
            Object.entries(data).forEach(fieldValue => {
                let colCopy = JSON.parse(JSON.stringify(fieldValue[1])); 
                let fieldApiName = colCopy.fieldName; 
                let fieldValueMap = {};
                fieldValueMap[fieldApiName] = "";
                colCopy.fieldName = fieldApiName.replace(/\./g, '');
                if(this.objectApi == "Competitor_Call__c" ) {
                if(fieldApiName=="Competitor__r.Date_Contract_Expires__c"){
                colCopy.type = 'date-local';
                }
                }
                if(this.objectApi == "Task"){
                if(fieldApiName == "ActivityDate"){
                colCopy.type = 'date-local';
                    }
                }
                
                flattenedFieldNameColumns.push(colCopy);
            });

            this.columns = flattenedFieldNameColumns;
        } else if (error) {
            this.notifyUser(
                'Loading Error',
                'An error occured while retrieving columns: ' + JSON.stringify(error.body.message),
                'error'
            );
        }
    }

    // @wire(getColumns, {fieldSetName: '$fieldSetName', objectApiName: '$objectApi', filterId: '$recordId', filterField: '$filterField'})
    @wire(getData, {fieldSetName: '$fieldSetName', objectApiName: '$objectApi', filterId: '$recordId', filterField: '$filterField'})
    wiredData({ error, data }) {
        if (data) {
            let parsedData = JSON.parse(data);
            if(this.objectApi == "ZTS_EU_Discussion__c") {
                parsedData = Array.from(new Set(parsedData.map(a => a.Name)))
                                  .map(name => { return parsedData.find(a => a.Name === name) }); // get unique names for discussions
            }
        
            let flattenedObject = [];
            parsedData.forEach((record) => {
                //console.log('parse currData => ', JSON.stringify(record));
                flattenedObject.push(this.flatten(record));
            });
            this.data = flattenedObject;

    
            this.displayTable = flattenedObject.length > 0;
        } else if (error) {
            this.notifyUser(
                'Loading Error',
                'An error occured while retrieving columns: ' + JSON.stringify(error.body.message),
                'error'
            );
        }
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
    
    flatten(obj) {
        let flattenedObject = {};
        this.traverseAndFlatten(obj, flattenedObject);
        return flattenedObject;
    }

    traverseAndFlatten(currentNode, target, flattenedKey) {
        for (let key in currentNode) {
            if (currentNode.hasOwnProperty(key)) {
                let newKey;
                    if (flattenedKey === undefined) {
                        newKey = key;
                    } else {
                        newKey = flattenedKey + this.capitalize(key);
                    
                    }
        
                    let value = currentNode[key];
                    if (typeof value === "object") {
                        this.traverseAndFlatten(value, target, newKey);
                    } else {
            
                        target[newKey] = value;
                    }
            }
        }
    }

    capitalize(s) {
        if (typeof s !== 'string') return '';
        return s.charAt(0).toUpperCase() + s.slice(1);
    }
    
    
}