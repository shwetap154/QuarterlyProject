import { LightningElement, api } from 'lwc';
import getAccountList from '@salesforce/apex/AccountHelper.getAccountList';
export default class lwcDataTableChild extends LightningElement {
    @api tableData;
    @api tableColumns;
    @api filterColumnsAPINames=["Theraupeutic_Group__c","Applicable_Product_Lines__c", "Product_Sales__c"];
    @api filterColumnLabels=["Theraupeutic Group","Product", "Product_Sales"];
    filterData = [];
    tableDataCopy;
    pillData = [];
connectedCallback() {
        // Fetch the list of accounts
        getAccountList()
        .then(result => {
            this.tableData = result;
            // Keeping a copy of the actual data set
            this.tableDataCopy = JSON.parse(JSON.stringify(this.tableData));
            // Based on the result set update the filter picklists.
            this.updatePicklistValues();
        });
    }
updatePicklistValues() {
        // Logic to populate the filter picklists.
        this.filterColumnsAPINames.forEach((currentElement, index) => {
            this.filterData = [
                ...this.filterData,
                {
                    fieldIndex: index,
                    fieldName: currentElement,
                    fieldLabel: this.filterColumnLabels[index],
                    fieldValue: "",
                    fieldOptions: this.getFieldOptions(currentElement)
                }
            ];
        });
        // console.log('this.filterData ===> ' + JSON.stringify(this.filterData));
    }
changeHandler (event) {
        // Logic to update the data inside the datatable based on the values selected in the picklist.
        let currentFieldName = event.target.name;
        let currentFieldValue = event.target.value;
        let currentFieldLabel = event.target.label;
        let localTableDataList = [];
        this.tableData.forEach((currentElement) => {
            if (currentElement[currentFieldName] == currentFieldValue) {
                localTableDataList = [...localTableDataList, currentElement];
            }
        });
        this.tableData = localTableDataList;
        this.emptyAllFieldOptions ();
        this.updatePicklistValues();
        console.log('this.tableData ===> ' + JSON.stringify(this.tableData));
        console.log('this.filterData ===> ' + JSON.stringify(this.filterData));
// Generate Pill Data on selection / change of values from the filter picklist
      /*  this.pillData = [...this.pillData,{
            fieldIndex: this.pillData.length,
            fieldValue: currentFieldValue,
            fieldName: currentFieldName,
            fieldLabel: currentFieldLabel + ':' + currentFieldValue
        }]; */
    }
getFieldOptions (fieldApiName) {
        // Logic to keep only unique values in the filter picklist
        let toReturn = [];
        let tempValueArray = [];
        this.tableData.forEach((currentElement, index) => {
            if (tempValueArray.indexOf(currentElement[fieldApiName]) < 0) {
                tempValueArray.push(currentElement[fieldApiName]);
                toReturn = [...toReturn, {
                    label: currentElement[fieldApiName],
                    value: currentElement[fieldApiName],
                }];
            }
        });
        return toReturn;
    }
 
    resetAll(event) {
        // Clear all the data present in the filtered data array.
        this.emptyAllFieldOptions();
        // Clear all the selections in the filter picklist
        this.template.querySelectorAll('lightning-combobox').forEach((currentElement) => {
            currentElement.value = null;
        });
        // Reset table data to the original values.
        this.tableData = JSON.parse(JSON.stringify(this.tableDataCopy));
        // Remove all the pills from the screen.
        this.pillData = [];
        // Reset all the available options inside the filter picklist
        this.updatePicklistValues();
    }
emptyAllFieldOptions () {
        // Clear all the data present in the filtered data array.
        this.filterData = [];
    }
removeHandler (event) {
        let currentFieldLabel = event.target.label;
        let currentFieldName = event.target.name;
        let currentFieldValue = event.target.dataset.value;
        let currentFieldIndex = event.target.dataset.index;
// Remove this pill from pillData array.
        this.pillData.splice(currentFieldIndex, 1);
        // If there are no pills that means nothing selected from the picklist
        // and hence we should reset the data inside the datatable to the original
        // dataset.
        if (this.pillData.length === 0)
            this.tableData = JSON.parse(JSON.stringify(this.tableDataCopy));
        // Else there are some selections still remaining and hence we should show
        // the data inside the datatable based on the remaining selection
        else
            this.updateTableDataBasedOnAvailablePills();
        // Reset the value selected for the corresponding filter picklist to NONE.
        this.template.querySelectorAll('lightning-combobox').forEach((currentElement, index) => {
            if (currentElement.name == currentFieldName)
                currentElement.value = null;
        });
        // At first clear the filtered Data array.
        this.emptyAllFieldOptions();
        // Then reset it based on the selected values in the remaining filter picklist
        this.updatePicklistValues();
    }
updateTableDataBasedOnAvailablePills () {
        // Logic to update the data inside the datatable based on the available pill values.
        let localTableDataList = [];
        this.tableDataCopy.forEach((currentTableDataElement, currentTableDataIndex) => {
            let matchCount = 0;
            this.pillData.forEach((currentPillDataElement, currentPillDataIndex) => {
                if (currentTableDataElement[currentPillDataElement.fieldName] === currentPillDataElement.fieldValue) {
                    matchCount++;
                }
            });
            // If the number of matches per row of the Account Record is equals the number of pills present
            // that means we can consider that record as part of the datatable
            if (matchCount == this.pillData.length)
                localTableDataList = [...localTableDataList, currentTableDataElement];
        });
        this.tableData = localTableDataList;
    }

}