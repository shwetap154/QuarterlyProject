/******************************************************************************************************************************************
 * Class Name   : Lookup
 * Description  : Lightning web component for lookup
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 24 March 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     03/24/2020          Created.
 *****************************************************************************************************************************************/
 import { LightningElement, track, api, wire } from 'lwc';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { getObjectInfo } from 'lightning/uiObjectInfoApi';

 import SAMPLE_OBJECT from '@salesforce/schema/ZTS_EU_Sample__c';
 import SAMPLEDROP_OBJECT from '@salesforce/schema/Sample_Drop__c';
 import CONTACT_OBJECT from '@salesforce/schema/Contact';
 
 const MINIMAL_SEARCH_TERM_LENGTH = 2; // Min number of chars required to search
 const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, perform search
 const SUBMIT_DELAY = 1; // Wait 1 ms after user stops typing then, perform search
 
 import updateContact from '@salesforce/apex/SalesCallLWCController.updateContact';
 
 export default class Lookup extends LightningElement {
     @api label;
     @api selection = [];
     @api objects = '';
     @api placeholder = '';
     @api isMultiEntry = false;
     @api displayType = "pill";
     @api errors = [];
     @api scrollAfterNItems;
     @api customKey;
     @api componentIndex = 0; 
     @api isDisabled = false;
 
     @track searchTerm = '';
     @track searchResults = [];
     @track hasFocus = false;
     @track isProcessing = false;
     @track loading = false;

     @track sampleObjectInfo;
     @track sampleDropObjectInfo;
     @track contactObjectInfo;
 
     cleanSearchTerm;
     blurTimeout;
     searchThrottlingTimeout;
 
     // EXPOSED FUNCTIONS
 
     @api
     setSearchResults(results) {
         // Reset the spinner
         this.loading = false;
 
         this.searchResults = results.map(result => {
             // Clone and complete search result if icon is missing
             if (typeof result.icon === 'undefined') {
                 const { id, sObjectType, title, subtitle } = result;
                 return {
                     id,
                     sObjectType,
                     icon: 'standard:default',
                     title,
                     subtitle
                 };
             }
             return result;
         });
     }
 
     @api
     getSelection() {
         return this.selection;
     }
 
     @api
     setSelection(newSelection) {
         this.selection = newSelection;
     }
 
     @api
     getkey() {
         return this.customKey;
     }

     @wire(getObjectInfo,{ objectApiName: SAMPLE_OBJECT})
     sampleObjectInfo;

     @wire(getObjectInfo,{ objectApiName: SAMPLEDROP_OBJECT})
     sampleDropObjectInfo;

     @wire(getObjectInfo,{ objectApiName: CONTACT_OBJECT})
     contactObjectInfo;

     get SampleIdLabel() {
        return this.sampleObjectInfo?.data?.fields?.Name?.label ?? 'Sample Id';
    }
    get ProductNameLabel() {
       return this.sampleDropObjectInfo?.data?.fields?.ZTS_EU_Product__c?.label ?? 'Product Name';
    }
    get ContactNameLabel() {
       return this.sampleDropObjectInfo?.data?.fields?.ZTS_EU_Contact__c?.label ?? 'Contact Name';
    }
    get OnHandBalanceLabel() {
       return this.sampleObjectInfo?.data?.fields?.ZTS_EU_On_Hand_Balance__c?.label ?? 'On Hand Balance';
    }
    get QtyDroppedLabel() {
        return this.sampleDropObjectInfo?.data?.fields?.ZTS_EU_Quantity__c?.label ?? 'Quantity Dropped';
    }
    get AttendeeNameLabel() {
        return this.contactObjectInfo?.data?.fields?.Name?.label ?? 'Attendee Name';
    }
    get EmailLabel() {
        return this.contactObjectInfo?.data?.fields?.Email?.label ?? 'Email';
    }
    get OptOutEMailLabel() {
        return this.contactObjectInfo?.data?.fields?.ZTS_EU_Opt_Out_Email__c?.label ?? 'Opt Out Email';
    }
    get OptOutPhoneLabel() {
        return this.contactObjectInfo?.data?.fields?.ZTS_EU_Opt_Out_Phone__c?.label ?? 'Opt Out Phone';
    }
    get ContactTypeLabel() {
        return this.contactObjectInfo?.data?.fields?.ZTS_EU_Contact_type__c?.label ?? 'Contact Type';
    }
    get ProfessionLabel() {
        return this.contactObjectInfo?.data?.fields?.ZTS_EU_Profession__c?.label ?? 'Profession';
    }
     // INTERNAL FUNCTIONS
 
     updateSearchTerm(newSearchTerm) {
         this.searchTerm = newSearchTerm;
         const objectApiNamesList = this.objects.split(',');
         // Compare clean new search term with current one and abort if identical
         const newCleanSearchTerm = newSearchTerm
             .trim()
             .replace(/\*/g, '')
             .toLowerCase();
         if (this.cleanSearchTerm === newCleanSearchTerm) {
             return;
         }
 
         // Save clean search term
         this.cleanSearchTerm = newCleanSearchTerm;
 
         // Ignore search terms that are too small
         if (newCleanSearchTerm.length < MINIMAL_SEARCH_TERM_LENGTH) {
             this.searchResults = [];
             return;
         }
 
         // Apply search throttling (prevents search if user is still typing)
         if (this.searchThrottlingTimeout) {
             clearTimeout(this.searchThrottlingTimeout);
         }
         // eslint-disable-next-line @lwc/lwc/no-async-operation
         this.searchThrottlingTimeout = setTimeout(() => {
             // Send search event if search term is long enougth
             if (this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                 // Display spinner until results are returned
                 this.loading = true;
                 const searchEvent = new CustomEvent('search', {
                     detail: {
                         searchTerm: this.cleanSearchTerm,
                         selectedIdsJson: JSON.stringify(this.selection.map(element => element.id)),
                         searchObjectApisJson: JSON.stringify(objectApiNamesList),
                         index: this.componentIndex
                     }
                 });
                 this.dispatchEvent(searchEvent);
             }
             this.searchThrottlingTimeout = null;
         }, SEARCH_DELAY);
     }
 
     isSelectionAllowed() {
         if (this.isMultiEntry) {
             return true;
         }
         return !this.hasSelection();
     }
 
     hasResults() {
         return this.searchResults.length > 0;
     }
 
     hasSelection() {
         return this.selection.length > 0;
     }
 
     // EVENT HANDLING
 
     handleInput(event) {
         // Prevent action if selection is not allowed
         if (!this.isSelectionAllowed()) {
             return;
         }
         this.updateSearchTerm(event.target.value);
     }
 
     handleResultClick(event) {
         const recordId = event.currentTarget.dataset.recordid;
 
         // Save selection
         let selectedItem = this.searchResults.filter(
             result => result.id === recordId
         );
         if (selectedItem.length === 0) {
             return;
         }
         selectedItem = selectedItem[0];
         const newSelection = [...this.selection];
         newSelection.push(selectedItem);
         this.selection = newSelection;
 
         // Reset search
         this.searchTerm = '';
         this.searchResults = [];
 
         // Notify parent components that selection has changed
         const saveEvent = new CustomEvent('selectionchange',{
             detail: {
                 selectedItem: selectedItem,
                 isRemoved: false,
                 filteredSelection: [],
                 index: this.componentIndex
             }   
         });
         this.dispatchEvent(saveEvent);
     }
 
     handleComboboxClick() {
         // Hide combobox immediatly
         if (this.blurTimeout) {
             window.clearTimeout(this.blurTimeout);
         }
         this.hasFocus = false;
     }
     
     handleContactUpdate(event) {
        const fieldChanged = event.target.fieldName;
        const contactId = event.target.dataset.item;
        const newFieldValue = event.target.value;//fetching the updated value here and sending to contact update
        //alert('Value changed 1-->'+newFieldValue);
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName === fieldChanged) {
                    //alert('Value changed 2-->'+newFieldValue);
                    console.log("field name: ",JSON.stringify(field.fieldName));
                    console.log("fieldChanged: ",JSON.stringify(fieldChanged));
                    console.log("field.value: ",JSON.stringify(newFieldValue));
                    if(field.reportValidity()) {
                        if (this.searchThrottlingTimeout) {
                            clearTimeout(this.searchThrottlingTimeout);
                        }
                
                        this.searchThrottlingTimeout = setTimeout(() => {
                            this.isProcessing = true;
                            // this.template.querySelectorAll('lightning-record-edit-form')[formIndex].submit(fields);
                
                            const updateContactParam = {
                                contactId : contactId,
                                fieldToUpdate : fieldChanged,
                                newValue : newFieldValue
                            };
                            //alert(JSON.stringify(updateContactParam));
                            updateContact(updateContactParam)
                                .then(results => {
                                    console.log('results: ',JSON.parse(JSON.stringify(results)));
                                    this.isProcessing = false;
                                })
                                .catch(error => {
                                    this.isProcessing = false;
                                    this.notifyUser(
                                        'Create Contact Error',
                                        // 'An error occured while searching: ' + JSON.stringify(error.body.message),
                                        'An error occured while searching: ' + JSON.stringify(error.body.message),
                                        'error'
                                    );
                                });
                
                            this.searchThrottlingTimeout = null;
                            
                        }, SUBMIT_DELAY);
                    }
                }
            });
        }
          

    }
 
     validateQuantityDrop(event) {
 
         const fieldChanged = event.target.fieldName;
         const newFieldValue = event.detail.value;
         
         const formIndex = event.target.dataset.index;
         const sampleDropId = event.target.dataset.item;
         const selectedRecord = this.selection[formIndex];
 
         // if(newFieldValue) {
         //     if(newFieldValue > selectedRecord.record.ZTS_US_On_Hand_Balance__c) {
         //         this.notifyUser(
         //             'Quantity Dropped Error',
         //             // 'An error occured while searching: ' + JSON.stringify(error.body.message),
         //             'Quantity Dropped Cannot be greater than On Hand Balance',
         //             'error'
         //             );
         //     }
         // }
         this.selection[formIndex].ZTS_US_Quantity__c = newFieldValue; 
         //console.log('sampleDropId '+ sampleDropId);
         //console.log('fieldChanged  '+fieldChanged);
 
     }
 
     validateQuantityDropINTL(event) {
 
         const fieldChanged = event.target.fieldName;
         const newFieldValue = event.detail.value;
         
         const formIndex = event.target.dataset.index;
         const sampleDropId = event.target.dataset.item;
         const selectedRecord = this.selection[formIndex];
 
         // if(newFieldValue) {
         //     if(newFieldValue > selectedRecord.record.ZTS_US_On_Hand_Balance__c) {
         //         this.notifyUser(
         //             'Quantity Dropped Error',
         //             // 'An error occured while searching: ' + JSON.stringify(error.body.message),
         //             'Quantity Dropped Cannot be greater than On Hand Balance',
         //             'error'
         //             );
         //     }
         // }
         this.selection[formIndex].ZTS_EU_Quantity__c = newFieldValue; 
         //console.log('sampleDropId '+ sampleDropId);
         //console.log('fieldChanged  '+fieldChanged);
 
     }
 
     handleFocus() {
         // Prevent action if selection is not allowed
         if (!this.isSelectionAllowed()) {
             return;
         }
         this.hasFocus = true;
     }
 
     handleBlur() {
         // Prevent action if selection is not allowed
         if (!this.isSelectionAllowed()) {
             return;
         }
         // Delay hiding combobox so that we can capture selected result
         // eslint-disable-next-line @lwc/lwc/no-async-operation
         this.blurTimeout = window.setTimeout(() => {
             this.hasFocus = false;
             this.blurTimeout = null;
         }, 300);
     }
 
     handleRemoveSelectedItem(event) {
         if(!this.isDisabled) {
             const index = event.target.dataset.index;
 
             const recordId = event.target.dataset.recordId;
 
             const selectedItem = this.selection[index];
 
             const filteredSelection = this.selection.filter(item => item.id !== recordId);
 
             // Notify parent components that selection has changed
             const selectionChangeEvent = new CustomEvent('selectionchange', {
                 detail: {
                     selectedItem: selectedItem,
                     isRemoved: true,
                     filteredSelection: filteredSelection, 
                     index: this.componentIndex
                 }
             });
             this.dispatchEvent(selectionChangeEvent);
         }
         else {
             alert('No longer allowed to edit this call.');
         }
     }
 
     handleClearSelection(event) {
         this.selection = [];
         // Notify parent components that selection has changed
         const selectionChangeEvent = new CustomEvent('selectionchange', {
             detail: {
                 selectedItem: null,
                 isRemoved: true,
                 filteredSelection: null, 
                 index: this.componentIndex
             }
         });
         this.dispatchEvent(selectionChangeEvent);
     }
 
     handleSaveSubmit(event) {
         const detail = event.detail;
         const fields = event.detail.fields;
         console.log("in handle save submit");
         console.log("detail: ",JSON.parse(JSON.stringify(detail)));
         
         this.isProcessing = true;
         const attendeeIndex = event.target.dataset.item;
     }
 
     handleKeyDown(event){
         if (event.which == 13){
             event.preventDefault();
         }
     }
 
     handleSaveSuccess(event) {
         this.isProcessing = false;
     }
 
     handleSaveError(event) {
         this.isProcessing = false;
     }
     // STYLE EXPRESSIONS
 
     get showAttendeeTable() {
         if(this.displayType == "attendee") {
             return true;
         }
         return false;
     }
 
     get showINTLAttendeeTable() {
         if(this.displayType == "intl_attendee") {
             return true;
         }
         return false;
     }
     
     get showPill() {
         if(this.displayType == "pill" || this.displayType == null) {
             return true;
         }
         return false;
     }
 
     get showSampleTable() {
         if(this.displayType == "sample") {
             return true;
         }
         return false;
     }
 
     get showINTLSampleTable() {
         if(this.displayType == "intl_sample") {
             return true;
         }
         return false;
     }
 
     get getContainerClass() {
         let css = 'slds-combobox_container slds-has-inline-listbox ';
         if (this.hasFocus && this.hasResults()) {
             css += 'slds-has-input-focus ';
         }
         if (this.errors.length > 0) {
             css += 'has-custom-error';
         }
         return css;
     }
 
     get getDropdownClass() {
         let css =
             'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
         if (
             this.hasFocus &&
             this.cleanSearchTerm &&
             this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH
         ) {
             css += 'slds-is-open';
         }
         return css;
     }
 
     get getInputClass() {
         let css =
             'slds-input slds-combobox__input has-custom-height ' +
             (this.errors.length === 0 ? '' : 'has-custom-error ');
         if (!this.isMultiEntry) {
             css +=
                 'slds-combobox__input-value ' +
                 (this.hasSelection() ? 'has-custom-border' : '');
         }
         return css;
     }
 
     get getComboboxClass() {
         let css = 'slds-combobox__form-element slds-input-has-icon ';
         if (this.isMultiEntry) {
             css += 'slds-input-has-icon_right';
         } else {
             css += this.hasSelection()
                 ? 'slds-input-has-icon_left-right'
                 : 'slds-input-has-icon_right';
         }
         return css;
     }
 
     get getSearchIconClass() {
         let css = 'slds-input__icon slds-input__icon_right ';
         if (!this.isMultiEntry) {
             css += this.hasSelection() ? 'slds-hide' : '';
         }
         return css;
     }
 
     get getClearSelectionButtonClass() {
         return (
             'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
             (this.hasSelection() ? '' : 'slds-hide')
         );
     }
 
     get getSelectIconName() {
         return this.hasSelection()
             ? this.selection[0].icon
             : 'standard:default';
     }
 
     get getSelectIconClass() {
         return (
             'slds-combobox__input-entity-icon ' +
             (this.hasSelection() ? '' : 'slds-hide')
         );
     }
 
     get getInputValue() {
         if (this.isMultiEntry) {
             return this.searchTerm;
         }
         return this.hasSelection() ? this.selection[0].title : this.searchTerm;
     }
 
     get getInputTitle() {
         if (this.isMultiEntry) {
             return '';
         }
 
         return this.hasSelection() ? this.selection[0].title : '';
     }
 
     get getListboxClass() {
         return (
             'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid ' +
             (this.scrollAfterNItems
                 ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems
                 : '')
         );
     }
 
     get isInputReadonly() {
         if (this.isMultiEntry) {
             return false;
         }
         return this.hasSelection();
     }
 
     get isExpanded() {
         return this.hasResults();
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