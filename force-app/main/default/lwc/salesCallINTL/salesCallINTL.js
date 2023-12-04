/******************************************************************************************************************************************
 * Class Name   : salesCallINTL
 * Description  : Lightning web component for SalesCallINTL page
 * Created By   : Aritra (Cognizant)
 * Created Date : 12-April-2021 
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Aritra (Cognizant)     12-April-2021         Created.
 *****************************************************************************************************************************************/

import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import { getUserPreferenceInfo, getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';


import NAME_FIELD from '@salesforce/schema/Call__c.Name';
import SUBTYPE_CALL_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Sub_Type__c';
import STATUS_CALL_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Status__c';
import SUBMITTED_DATE_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Submitted_Date__c';
import ACCOUNT_CALL_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Account__c';
import CALL_START_DATE_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Start_Date_Time__c';
import STATUS_TASK_FIELD from '@salesforce/schema/Task.Status';
import PRIORITY_TASK_FIELD from '@salesforce/schema/Task.Priority';
import CALL_OBJECT from '@salesforce/schema/Call__c';
import CALL_STATUS_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Status__c';

import lookupSearch from '@salesforce/apex/SalesCallLWCController.search';
import saveResults from '@salesforce/apex/SalesCallLWCController.saveLookupResults';
import getCall from '@salesforce/apex/SalesCallLWCController.getCallRecordAndRelatedRecords';
import removeItem from '@salesforce/apex/SalesCallLWCController.removeItem';
import createContactLookup from '@salesforce/apex/SalesCallLWCController.createContactLookup';
import getFieldsByFieldSetName from '@salesforce/apex/FieldSetRecordFormController.getFieldsByFieldSetName';
import getTaskStatusOptions from '@salesforce/apex/SalesCallLWCController.getTaskStatus';
import getTaskPriorityOptions from '@salesforce/apex/SalesCallLWCController.getTaskPriority';


import isRestrictedFromCreatingContact from '@salesforce/apex/SalesCallLWCController.isContactCreationRestrictedMarket';
import getSubPortalType  from '@salesforce/apex/SalesCallLWCController.getSubTypes';

import AttendeeHeadingLabel from '@salesforce/label/c.ZTS_GL_Call_Invitees';
import AddContactButtonLabel from '@salesforce/label/c.ZTS_EU_Add_Contact';
import SaveButtonLabel from '@salesforce/label/c.ZTS_EU_Save';
import CancelButtonLabel from '@salesforce/label/c.ZTS_EU_Cancel';
import DiscussionHeadingLabel from '@salesforce/label/c.ZTS_GL_Call_Add_Product';
import ColleagueHeadingLabel from '@salesforce/label/c.ZTS_EU_Colleagues';
import SampleDropHeadingLabel from '@salesforce/label/c.ZTS_EU_SampleDrops';
import FollowUpActivityHeadingLabel from '@salesforce/label/c.ZTS_GL_Follow_Up_Activities_Header';
import AddGiftButtonLabel from '@salesforce/label/c.ZTS_EU_AddGifts';
import CompleteButtonLabel from '@salesforce/label/c.ZTS_EU_Complete';
import OpportuntiesLabel from '@salesforce/label/c.ZTS_EU_Opportunities';
import AddFollowUpActivityButtonLabel from '@salesforce/label/c.ZTS_EU_Add_Follow_Up_Activtiy';
import GiftsHeadingLabel from '@salesforce/label/c.ZTS_EU_Gift';
import NextCallHeadingLabel from '@salesforce/label/c.ZTS_EU_Next_Call';

import FUAAssignedToHeaderLabel from '@salesforce/label/c.ZTS_EU_Task_Assigned_To';
import FUADueDateHeaderLabel from '@salesforce/label/c.ZTS_EU_Task_Due_Date';
import FUAItemHeaderLabel from '@salesforce/label/c.ZTS_EU_Task_Follow_Up_Item';
import FUAPriorityHeaderLabel from '@salesforce/label/c.ZTS_EU_Task_Priority';
import FUAStatusHeaderLabel from '@salesforce/label/c.ZTS_EU_Task_Status';
import FUASubjectHeaderLabel from '@salesforce/label/c.ZTS_EU_Task_Subject';

import AttendeeSearchHelpText from '@salesforce/label/c.ZTS_EU_Attendee_Search_HelpText';
import DiscussionSearchHelpText from '@salesforce/label/c.ZTS_EU_Discussion_Search_HelpText';
import ColleagueSearchHelpText from '@salesforce/label/c.ZTS_EU_Colleague_Search_HelpText';
import OpptySearchHelpText from '@salesforce/label/c.ZTS_EU_Opportunity_Search_HelpText';
import SampleSearchHelpText from '@salesforce/label/c.ZTS_EU_Sample_Search_HelpText';
import UserSearchHelpText from '@salesforce/label/c.ZTS_EU_User_Search_HelpText';
import ProductSearchHelpText from '@salesforce/label/c.ZTS_EU_Product_Search_HelpText';
import ContactSearchHelpText from '@salesforce/label/c.ZTS_EU_Contact_Search_HelpText';
import CallErrorMessage1 from '@salesforce/label/c.Call_Cant_Be_Submitted_Before_Activity_Date';
import CallErrorMessage2 from '@salesforce/label/c.Call_Should_Have_One_Attendee_Discussion';
import CallErrorMessage3 from '@salesforce/label/c.Call_Missing_Account';
import CallErrorMessage4 from '@salesforce/label/c.Call_Cant_Be_Submitted_After_14_Days';
import CallSubmitConfirmPrompt from '@salesforce/label/c.Call_Submit_Confirmation_Prompt';
import CallInfSectionHeading from '@salesforce/label/c.Call_Information_Section_Heading';
import CallHeadingPrefixCreate from '@salesforce/label/c.Call_Page_Heading_Prefix_Create';
import CallHeadingPrefixEdit from '@salesforce/label/c.Call_Page_Heading_Prefix_Edit';
import SalesCallText from '@salesforce/label/c.Sales_Call';


import FOLLOWUPACTIVITY_OBJECT from '@salesforce/schema/Event';
import GIFT_OBJECT from '@salesforce/schema/ZTS_EU_Gift__c';

 
// import USER_PREF_OBJECT from '@salesforce/schema/UserPreference';

export default class SalesCall extends NavigationMixin(LightningElement) {
   wiredCallResults;
    // Use alerts instead of toast to notify user
    @api notifyViaAlerts = false;
    @api recordId;
    @api objectApiName;
     
    @track initialDiscussions = [];
    @track initialAttendees = [];
    @track initialColleagues = [];
    @track opportunities = [];
    @track initialSampleDrops = [];
    @track followUpActivities = [];
    @track gifts = [];

    @track discussionErrors = [];
    @track attendeeErrors = [];
    @track colleagueErrors = [];
    @track opportunityErrors = [];
    @track sampleDropErrors = [];
    @track taskErrors = [];
    @track giftErrors = [];

    @track processing = false;
    @track showNewContactform = false;
    @track isContactProcessing = false;
    // @track showActivityForm = false;
    @track fields = [];
    @track callRecord = {};

    @track record;

    @track priorityOptions;
    @track statusOptions;

    DEFAULT_SUBTYPE_CALL = 'Account Call';
    @track subTypeValue = this.DEFAULT_SUBTYPE_CALL;
    @track subTypeOptions = [];

    @track isContactCreationRestricted = false;

    @track followupObjectInfo;
    @track giftObjectInfo;

   //Added to load the Task table piclist values
    connectedCallback() {
       getTaskPriorityOptions()
           .then(data => {
               this.priorityOptions = data;
           })
           .catch(error => {
               this.displayError(error);
           });

       getTaskStatusOptions()
           .then(data => {
               this.statusOptions = data;
           })
           .catch(error => {
               this.displayError(error);
           });
   }
 
    isSubmit = false;
    isConfirmed = true;

    ATTENDEE_INDEX = 0;
    DISCUSSION_INDEX = 1;
    COLLEAGUE_INDEX = 2;
    OPPORTUNITY_INDEX = 3;
    SAMPLE_DROP_INDEX = 4;
    TASK_INDEX_START = 5; // Number of c-lookup components on page before follow up activity section
    TASK_ITEM_INDEX_START = 6; // Number of the first c-lookup component for follow up items (Added by Morgan Marchese)     
     
    salesCall = {
        callId : this.callRecord.id,
        attendees: [],
        discussionItems: [],
        campaigns: [],
        products: [],
        colleagues: [],
        samples: [],
        sampleDrops: [],
        SamplesINTL: [],//Added by Aritra (SC-004726)
        sampleDropsINTL: [], //Added by Aritra (SC-004726)
        contacts: [], 
        affiliations: [], //added by Aritra(SC-008075)
        users: [],
        followUpActivities: [],
        gifts: [], //added by Aritra (SC-004726)
        opportunities: [], //added by Aritra for SC-008128
        initialIds: []
    };

    label ={
       AttendeeHeadingLabel,
       AddContactButtonLabel,
       SaveButtonLabel,
       CancelButtonLabel,
       DiscussionHeadingLabel,
       ColleagueHeadingLabel,
       SampleDropHeadingLabel,
       FollowUpActivityHeadingLabel,
       AddGiftButtonLabel,
       CompleteButtonLabel,
       OpportuntiesLabel,
       AddFollowUpActivityButtonLabel,
       GiftsHeadingLabel,
       NextCallHeadingLabel,
       FUAAssignedToHeaderLabel,
       FUADueDateHeaderLabel,
       FUAItemHeaderLabel,
       FUAPriorityHeaderLabel,
       FUAStatusHeaderLabel,
       FUASubjectHeaderLabel,
       AttendeeSearchHelpText,
       DiscussionSearchHelpText,
       ColleagueSearchHelpText,
       OpptySearchHelpText,
       SampleSearchHelpText,
       UserSearchHelpText,
       ProductSearchHelpText,
       ContactSearchHelpText,
       CallErrorMessage1,
       CallErrorMessage2,
       CallErrorMessage3,
       CallErrorMessage4,
       CallSubmitConfirmPrompt,
       CallInfSectionHeading,
       CallHeadingPrefixCreate,
       CallHeadingPrefixEdit,
       SalesCallText

    };
 
    firstTime = true;
    errors = [];
 
    editLabel = 'Save';
    createLabel = 'Save';
 
    editTitle = 'Saves changes to call and closes modal';
    createTitle = 'Creates call record and closes modal';
 
    CREATE_TITLE_SUFFIX = this.label.SalesCallText;
 
    COMPLETED_STATUS = 'Completed'; 
    ALLOWED_DAYS = 14;
 
    CONTACT_FIELDSET = 'New_Contact_INTL';
 
     
    DEFAULT_PRIORITY_TASK = 'Normal';
    DEFAULT_STATUS_TASK = 'Not Started';
 
    SUBMITTED_DATE_ERROR = this.label.CallErrorMessage1;
    NUM_ATTENDEE_DISCUSSION_ERROR = this.label.CallErrorMessage2;
    ACCOUNT_ID_ERROR = this.label.CallErrorMessage3;
    VIEW_ONLY_MESSAGE = this.label.CallErrorMessage4;
    CONFIRMATION_MESSAGE = this.label.CallSubmitConfirmPrompt;
    // @wire(getUserPreferenceInfo, { objectApiName: USER_PREF_OBJECT })
    //     getUserPref({error, data}) {
    //         if(data) {
    //         }
    //     }
     
    get callRecordId() { 
        let recId = this.recordId;
        if(this.recordId) {
            if(this.recordId.substring(0,3) == '001') { // Can be called from Account page as quick action
                recId = '';
            }
            else if(this.recordId.substring(0,3) == '006') { // Can be called from Oppty page as quick action
               recId = '';
           }
        }
        return recId; 
    }
     
    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATUS_TASK_FIELD })
    /*get priorityOptions() {
        return [
            {label: 'High', value: 'High'},
            {label: 'Normal', value: 'Normal'},
            {label: 'Low', value: 'Low'},
        ];
    }; */
 
    // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PRIORITY_TASK_FIELD })
    /*get statusOptions() {
        return [
            {label: 'Acknowledged, No Action', value: 'Acknowledged, No Action'},
            {label: 'Closed Due to Age', value: 'Closed Due to Age'},
            {label: 'Completed', value: 'Completed'},
            {label: 'Deferred', value: 'Deferred'},
            {label: 'In Progress', value: 'In Progress'},
            {label: 'Not Started', value: 'Not Started'},
            {label: 'Open', value: 'Open'},
            {label: 'Waiting on customer', value: 'Waiting on customer'},
            {label: 'Waiting on someone else', value: 'Waiting on someone else'},
        ];
    }; */
   //This below code will prepopulate the Call start date with current date when it is  a new record
   @wire(getRecord, { recordId: '$callRecordId', fields: [CALL_START_DATE_FIELD] })
   record;
   get currentDateTime() {
       if(!this.recordId)
           return new Date().toISOString();
       else
           return this.record.data ? getFieldValue(this.record.data, CALL_START_DATE_FIELD) : "";
   }
 
    get headerClass() {
        let cssClasses = '';
        if(this.recordId) {
            cssClasses = 'slds-modal__header sticky-top';
        }
        else {
            cssClasses = 'slds-modal__header';
        }
        return cssClasses;
    }
     
    get titleClass() {
        let cssClasses = '';
        if(this.recordId) {
            cssClasses = 'slds-modal__title slds-hyphenate';
        }
        else {
            cssClasses = 'slds-hyphenate large-font-size';
        }
        return cssClasses;
    }
 
    get footerClass() {
        let cssClasses = '';
        if(this.recordId) {
            cssClasses = 'slds-modal__footer sticky-bottom';
        }
        else {
            cssClasses = 'slds-modal__footer';
        }
        return cssClasses;
    }
 
    get contentClass() {
        let cssClasses = '';
        if(this.recordId) {
            cssClasses = 'slds-modal__content modal-content-override';
        }
        else {
            cssClasses = 'slds-modal__content slds-p-horizontal_large';
        }
        return cssClasses;
    }
 
    get formContainer() {
        let cssClasses = '';
        if(this.recordId) {
            cssClasses = '';
        }
        else {
            cssClasses = 'form-container';
        }
        return cssClasses;
    }
 
    get spinnerClass() {
        let cssClasses = '';
        if(this.recordId) {
            cssClasses = 'medium-height';
        }
        else {
            cssClasses = 'medium-height';
            // cssClasses = 'medium-height slds-is-relative';
        }
    } 
 
    @wire(getFieldsByFieldSetName, {objectApiName: 'Contact', fieldSetName: '$CONTACT_FIELDSET'})
    wiredFields({ error, data }) {
        if (data) {
 
           let rawFields = [];
 
           Object.entries(data).forEach(fieldValue => {
                let fieldObject = fieldValue[1];
                rawFields.push({ 'objectApiName': fieldObject.objectApiName, 'fieldApiName': fieldObject.fieldApiName });
            });
            this.fields = rawFields;
            this.error = undefined;
        } else if (error) {
            this.notifyUser(
                'Loading Error',
                'An error occured while loading: ' + JSON.stringify(error.body.message),
                'error'
            );
            this.errors = error;
            this.fields = [];
        }
    }
 
     @wire(getRecord, { recordId: '$callRecordId', fields: [NAME_FIELD, STATUS_CALL_FIELD, SUBMITTED_DATE_FIELD, ACCOUNT_CALL_FIELD, SUBTYPE_CALL_FIELD] })
    wiredRecord({ error, data }) {
        if(data) {
            this.callRecord = data;
            this.subTypeValue = getFieldValue(this.callRecord, SUBTYPE_CALL_FIELD);
        }
        else {
            this.callRecord = {};
        }
    }
 
    @wire(getCall, {callIdString: '$callRecordId'})
    getCall({error, data}) {
        if (data) {
            this.wiredCallResults = data;
            const parsedSalesCallWrapper = JSON.parse(data);
                this.salesCall.callId = this.callRecordId; 
            this.initialAttendees = parsedSalesCallWrapper.attendees;
            this.initialDiscussions.push(...parsedSalesCallWrapper.discussionItems);
            this.initialDiscussions.push(...parsedSalesCallWrapper.campaigns);
            this.initialDiscussions.push(...parsedSalesCallWrapper.products);
            this.initialColleagues = parsedSalesCallWrapper.colleagues;
            this.opportunities = parsedSalesCallWrapper.opportunities;
            this.initialSampleDrops = parsedSalesCallWrapper.sampleDropsINTL;
            //alert('Attendees--'+this.initialAttendees);
            //alert('Colleagues--'+this.initialColleagues);
            //alert('Sample Drops --'+ this.initialSampleDrops);
            this.followUpActivities = parsedSalesCallWrapper.followUpActivities || [];
            //alert(this.followUpActivities.length);
            this.followUpActivities.forEach((task,index) => {
                   task.taskLookupIndex = this.TASK_INDEX_START + (2*index);
                   task.taskItemLookupIndex = this.TASK_ITEM_INDEX_START + (2*index);
           });
            this.gifts = parsedSalesCallWrapper.gifts || [];
            this.gifts.forEach((gift,index) => {    
                   gift.giftLookupIndex = this.TASK_INDEX_START + (2* this.followUpActivities.length) + (2*index);
                   gift.giftcontactLookupIndex = this.TASK_ITEM_INDEX_START + (2* this.followUpActivities.length) + (2*index);
   
       });

        } else if (error) {
            this.notifyUser(
                'Load Call Error',
                'An error occured on load: ' + JSON.stringify(error.body.message),
                'error'
            );
        }
 
   }

   @wire(getObjectInfo,{ objectApiName: GIFT_OBJECT})
   giftObjectInfo;

   get ProductLabel() {
       return this.giftObjectInfo?.data?.fields?.ZTS_EU_Product_Hierarchy__c?.label ?? 'Product';
   }
   get QuantityLabel() {
      return this.giftObjectInfo?.data?.fields?.ZTS_EU_Quantity__c?.label ?? 'Quantity';
   }
   get DescriptionLabel() {
      return this.giftObjectInfo?.data?.fields?.ZTS_EU_Description__c?.label ?? 'Description';
   }
   get ContactLabel() {
      return this.giftObjectInfo?.data?.fields?.ZTS_EU_Contact__c?.label ?? 'Contact';
   }

   
 
   get modalHeader() {
        const recordName = getFieldValue(this.callRecord, NAME_FIELD);
        return (this.callRecordId ? this.label.CallHeadingPrefixEdit+ ' ' + recordName : this.label.CallHeadingPrefixCreate + ' ' + this.CREATE_TITLE_SUFFIX);
   }
   get buttonLabel() {
        return this.recordId ? this.editLabel : this.createLabel;
   }
 
   get buttonTitle() {
        return this.recordId ? this.editTitle : this.createTitle;
   }
 
   get renderSave() {
        // ( Call.ZTS_EU_Status__c != COMPLETED_STATUS||
        // (Call.ZTS_EU_Status__c == COMPLETED_STATUS&&call.ZTS_EU_Submitted_Date__c<>null&&NOW()-call.ZTS_EU_Submitted_Date__c<=10))
        let callStatus = getFieldValue(this.callRecord, STATUS_CALL_FIELD);

        const isCompleted = callStatus == this.COMPLETED_STATUS;
        
        let submittedDateValue = new Date(getFieldValue(this.callRecord, SUBMITTED_DATE_FIELD));
        const hasSubmittedDate = submittedDateValue != null;

        let secondsSinceSubmitted = new Date() - submittedDateValue;
        let daysSinceSubmitted = this.calculateTimeInDays(secondsSinceSubmitted);
        
        const isLessThanTenDays = daysSinceSubmitted < this.ALLOWED_DAYS;
        // const hasSubmittedDate = submittedDate != null;
        return !isCompleted || (isCompleted && hasSubmittedDate && isLessThanTenDays);
   }
 
   get renderSubmit() {
        // let call = this.callRecord;
        // const isCompleted = call.ZTS_EU_Status__c == this.COMPLETED_STATUS;  
        let callStatus = getFieldValue(this.callRecord, STATUS_CALL_FIELD);
 
        return this.COMPLETED_STATUS !== callStatus;
   }
 
   get isViewOnly() {
        return !this.renderSave;
   }
     
   get isViewOnlyMessage() {
        return this.VIEW_ONLY_MESSAGE;
   }
 
   calculateTimeInDays (secondsPassed) {
        return secondsPassed / (1000 * 3600 * 24);
   }
     
    // handleCreateContactLoad(event) {
    //         JSON.parse(
    //             JSON.stringify(
    //                 event.detail.objectInfos.Contact.fields["ZTS_US_Profession__c"].required
    //     )));
    //     let fieldsJson = JSON.stringify(event.detail.objectInfos.Contact.fields); 
    //     let parsedFieldsJson = JSON.parse(fieldsJson);
    //     parsedFieldsJson["ZTS_US_Profession__c"].required = true;


        
    //     event.detail.objectInfos.Contact.fields = parsedFieldsJson;
    // }
 
    handleFormLoad(event) 
    {
        const accountField = this.template.querySelector('.account-field');
        if (accountField) {
            if(!this.callRecordId) {
                if(this.recordId) {
                     accountField.value = this.recordId;
                }
                else {
                    const searchString = window.location.search;
                    if(searchString) {
 
                        const base64EncodedString = searchString.split('?')[1].split('=')[1].substring(2).split('&')[0];
                         console.log(' base64EncodedString ::: '+base64EncodedString);
                        const decodedString = decodeURIComponent(base64EncodedString);
                         console.log('decodedString ::: '+decodedString );
                        //Checking for not Aloha URL
                        //168  is when creating Call from the List View 
                        //180 when creating a Call from Related List on Account Record 
                        if (decodedString.length > 160){
                            const accObj = JSON.parse(atob(decodedString));
                            accountField.value = accObj.attributes.recordId; 
                        }
                    }
                }
            }
        }
        getSubPortalType({callId: this.callRecordId})
            .then(results =>
            {
                this.subTypeOptions = results;
            })
            .catch(error => {
                this.notifyUser(
                'Subtype field error',
                'An error occured' + JSON.stringify(error.body.message),
                'error'
            )});
        //Added the below method to hide the contact creation section for Russia
        isRestrictedFromCreatingContact()
              .then(result =>
               {   
                   this.isContactCreationRestricted = result;
               })
               .catch(error => {
                   this.notifyUser(
                       'Contact Creation Permission Check error',
                       'An error occured' + JSON.stringify(error.body.message),
                       'error'    
                   )
               });


    }
 
    handleSubTypeChange(event)
    {
        this.subTypeValue = event.detail.value;
    }
     
 
    handleSearch(event) {
        let accountId = '';
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName == 'ZTS_EU_Account__c') {
                    accountId = field.value;
                }
            });
        }
        event.detail.accountId = accountId;
        lookupSearch(event.detail)
            .then(results => {
                let lookResult = JSON.parse(results);
                const lookupIndex = event.detail.index;
                //alert('lookupIndex>>'+lookupIndex);
                if(this.ATTENDEE_INDEX == 0) { 
                    lookResult = this.filterResultsByTitle(lookResult, this.initialAttendees);
                }
                else if(this.COLLEAGUE_INDEX == 2) { 
                    lookResult = this.filterResultsByTitle(lookResult, this.initialColleagues);
                }
                else if(this.OPPORTUNITY_INDEX == 3) { 
                   lookResult = this.filterResultsByTitle(lookResult, this.opportunities);
               }
                this.template
                    .querySelectorAll('c-lookup')[lookupIndex]
                    .setSearchResults(lookResult);
            })
            .catch(error => {
                this.notifyUser(
                    'Lookup Error',
                    // 'An error occured while searching: ' + JSON.stringify(error.body.message),
                    'An error occured while searching: ' + JSON.stringify(error.body.message),
                    'error'
                );
                // eslint-disable-next-line no-console
                this.errors = [error];
            });
    } 
 
    handleSelectionChange(event) {  
         
        const selectionDetail = event.detail;
        if(selectionDetail) {
            const selectedItem = selectionDetail.selectedItem; 
            const lookupIndex = selectionDetail.index;
            if(selectionDetail.isRemoved) {
                if(selectedItem) { // multi-entry deletion
                    this.processing = true;
                    const lookupIndex = event.detail.index; 
                    const filteredSelection = event.detail.filteredSelection;
                    this.deleteLookupResult(selectedItem, lookupIndex, filteredSelection);
                }
                else { // single-entry deletion
                    this.followUpActivities.forEach( (task) => { 
                        if(lookupIndex == task.taskLookupIndex) {
                            task.owner = [];
                        }
                    });
                    this.gifts.forEach( (gift) => { 
                       if(lookupIndex == gift.giftLookupIndex) {
                           gift.product = [];
                       }
                   });
                }
            }
            else {
                this.followUpActivities.forEach( (task) => { 
                    if(lookupIndex == task.taskLookupIndex) {
                        task.owner = [selectedItem];
                    }
                   else if (lookupIndex-task.taskLookupIndex===1){ //important to keep the difference to 1 for followup, for next column in future it should be 2
                       task.followup = [selectedItem];
                    }
                });
                this.gifts.forEach( (gift) => { 
                   if(lookupIndex == gift.giftLookupIndex) {
                       gift.product = [selectedItem];
                   }
                   else if (lookupIndex-gift.giftLookupIndex===1){ //important to keep the difference to 1 for followup, for next column in future it should be 2
                       gift.contact = [selectedItem];
                    }
               });
            }
        }
        // this.errors = [];
    }
    saveOnClick() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                if(!field.reportValidity()) {
                    field.scrollIntoView(false);
                    this.isSubmit = false;
                    return;
                }
            });
        }
    }

    cancelOnClick(event) {
 
        let accountId = '';
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                 if(field.fieldName == 'ZTS_EU_Account__c') {
                    accountId = field.value;
                }
            });
        }
 
        let redirectRecord = {};
        if(this.recordId) {
            this.processCloseOrRedirect("close",redirectRecord);
        }
        else {
            this.processCloseOrRedirect("close",redirectRecord);
            window.history.back();
        }
    }
 
    handleSubmit(event) {
       if(this.isConfirmed) {
           this.processing = true;

           event.preventDefault();
           const formFields = event.detail.fields;
            // formFields.Id = '';
           let canSaveAndSubmit = true;
           if(this.isSubmit) {
               formFields.ZTS_EU_Status__c = this.COMPLETED_STATUS;
               const newDate = new Date();
               formFields.ZTS_EU_Submitted_Date__c = newDate.toISOString(); // Date.now();
               canSaveAndSubmit = this.checkForErrors(formFields);
           }

           formFields.ZTS_EU_Sub_Type__c = this.subTypeValue;
           if(canSaveAndSubmit) {
                 this.template.querySelector('.sales-call-form').submit(formFields);
                }
                }
        return refreshApex(this.wiredCallResults);
           /*if(this.salesCall.callId !=='undefined')
            {
                window.location.reload();
            }*/
               
      
    }
    
    

     
     
       

    submitOnclick() {
         console.log('submitOnclick');
        this.isConfirmed = window.confirm(this.CONFIRMATION_MESSAGE);
        this.isSubmit = true;
    }
 
    toggleNewContactForm() {
        this.showNewContactform = !this.showNewContactform;
    }
 
    handleCreateContactSubmit(event) {
 
        this.isContactProcessing = true;
        event.preventDefault();
        let callAccountId = '';
        this.template.querySelectorAll('lightning-input-field')
            .forEach(field => {
                if(field.fieldName == 'ZTS_EU_Account__c') {
                    callAccountId = field.value;
                }
            });
        if(callAccountId) {  
     
            let fields = event.detail.fields; 
            fields.AccountId = callAccountId; 
            this.template.querySelector('.create-contact-form').submit(fields);
        }
        else {
            this.notifyUser(
                'Create Contact Error',
                'An error occured while searching: ' + this.ACCOUNT_ID_ERROR,
                'error'
            );
        }
    }
 
    handleCreateContactSuccess(event) { 
         
         // Create wrapper for contactId
 
        const contactId = event.detail.id;
 
        const createContactParam = {
             contactId : event.detail.id
        };
        createContactLookup(createContactParam)
            .then(results => {
                const contactLookupWrapper = JSON.parse(results);

                // Create lookup result wrapper
                // standard:contact icon
                // name title
                // Contact.Account_Name__c subtitle
                let currentSelection = this.template.querySelectorAll('c-lookup')[0].getSelection();

                currentSelection.push(contactLookupWrapper);
                
                this.template.querySelectorAll('c-lookup')[0].setSelection(currentSelection);
                this.toggleNewContactForm();
                this.isContactProcessing = false;
                // this.processing = false;
            })
            .catch(error => {
                this.notifyUser(
                    'Create Contact Error',
                    // 'An error occured while searching: ' + JSON.stringify(error.body.message),
                    'An error occured while searching: ' + JSON.stringify(error.body.message),
                    'error'
                );
                // eslint-disable-next-line no-console
                this.errors = [error];
                this.isContactProcessing = false;
                this.toggleNewContactForm();
            });  
 
 
         
    }
 
    handleCreateContactError(event) {
    }
 
    handleCreateContactCancel(event) {
        this.toggleNewContactForm();
    }
 
    handleTaskChange(event) {
        const value = event.detail.value;
        const fieldChanged = event.target.dataset.id;
        const lookupIndex = event.target.dataset.item;
        this.followUpActivities.forEach( (task) => { 
            if(lookupIndex == task.taskLookupIndex) {
                switch(fieldChanged) {
                    case "subject":
                        task.subject = value;
                        break;
                    case "activityDate":
                        task.activityDate = value;
                        break;
                    case "priority":
                        task.priority = value;
                        break;
                    case "status":
                        task.status = value;
                        break;
                }
            }
        });
    }

    handleGiftChange(event) {
       const value = event.detail.value;
       const fieldChanged = event.target.dataset.id;
       const lookupIndex = event.target.dataset.item;
       this.gifts.forEach( (gift) => { 
           if(lookupIndex == gift.giftLookupIndex) {
               switch(fieldChanged) {
                   case "quantity":
                       gift.quantity = value;
                       break;
                   case "description":
                       gift.description = value;
                       break;
               }
           }
       });
   }
 
   addFollowUpActivity() {
       const activitiesLastIndex = this.followUpActivities.length-1;
       const followuprowcount = this.followUpActivities.length;
       const giftrowcount = this.gifts.length;
       let emptyTask = {
           taskId: '',
           owner: [],
           subject: '',
           activityDate: '',
           priority: this.DEFAULT_PRIORITY_TASK,
           status: this.DEFAULT_STATUS_TASK,
           followup:[]
       };
       if(activitiesLastIndex == -1) {
           emptyTask.taskLookupIndex = this.TASK_INDEX_START ;
           emptyTask.taskItemLookupIndex = this.TASK_ITEM_INDEX_START ;
           this.followUpActivities.push(emptyTask);
       }
       else {
           const lastActivityEntry = this.followUpActivities[activitiesLastIndex];
           //alert(lastActivityEntry.taskLookupIndex);
           //alert(lastActivityEntry.taskItemLookupIndex);
           if(lastActivityEntry.owner.length !== 0) {
               
               emptyTask.taskLookupIndex = lastActivityEntry.taskLookupIndex + 2;
               emptyTask.taskItemLookupIndex = emptyTask.taskLookupIndex + 1;
               this.followUpActivities.push(emptyTask);
           }
           
       }
       if(this.gifts.length > 0)
       {
           for(var i=0;i<this.gifts.length;i++)
           {
               this.gifts[i].giftLookupIndex = this.gifts[i].giftLookupIndex+2;
               this.gifts[i].giftcontactLookupIndex = this.gifts[i].giftcontactLookupIndex+2;
           }
       }
       // this.showActivityForm = !this.showActivityForm;
       /*if(activitiesLastIndex == -1) {
           alert('I am here');
           if(giftrowcount > 0)
           {
               alert('aa');
               emptyTask.taskLookupIndex = this.TASK_INDEX_START + (this.gifts.length*2);
               emptyTask.taskItemLookupIndex = this.TASK_ITEM_INDEX_START + (this.gifts.length*2);
               this.followUpActivities.push(emptyTask);
           }
           else
           {
               alert('bb');
               emptyTask.taskLookupIndex = this.TASK_INDEX_START;
               emptyTask.taskItemLookupIndex = this.TASK_ITEM_INDEX_START;
               this.followUpActivities.push(emptyTask);

           }
       }
       else {
           const lastActivityEntry = this.followUpActivities[activitiesLastIndex];
           alert('I am here 2');
           if(lastActivityEntry.owner.length !== 0) {
               if(giftrowcount >0)
               {
                   emptyTask.taskLookupIndex = this.TASK_INDEX_START + (followuprowcount+giftrowcount)*2;
                   emptyTask.taskItemLookupIndex = emptyTask.taskLookupIndex + 1;
                   this.followUpActivities.push(emptyTask);
               }
               else{
                   emptyTask.taskLookupIndex = lastActivityEntry.taskLookupIndex + 2;
                   emptyTask.taskItemLookupIndex = emptyTask.taskLookupIndex + 1;
                   this.followUpActivities.push(emptyTask);
               }
           }
       }*/

   }

    addGifts() {
       const giftsLastIndex = this.gifts.length-1;
       const followuprowcount = this.followUpActivities.length;
       const giftrowcount = this.gifts.length;
       let emptyGift = {
           giftId: '',
           contact: [],
           quantity: '',
           product: [],
           description: ''
       };
       if(giftsLastIndex == -1) {
           //alert(this.followUpActivities.length);
           if(followuprowcount > 0)
           {
               emptyGift.giftLookupIndex = this.TASK_INDEX_START + (this.followUpActivities.length*2);
               emptyGift.giftcontactLookupIndex = this.TASK_ITEM_INDEX_START + (this.followUpActivities.length*2);
               this.gifts.push(emptyGift);
           }
           else
           {
               emptyGift.giftLookupIndex = this.TASK_INDEX_START;
               emptyGift.giftcontactLookupIndex = this.TASK_ITEM_INDEX_START;
               this.gifts.push(emptyGift);

           }
       }
       else {
           const lastGiftEntry = this.gifts[giftsLastIndex];
           //alert('i am here');
           //alert(lastGiftEntry.giftLookupIndex);
           //alert(lastGiftEntry.giftcontactLookupIndex);
           if(lastGiftEntry.contact.length !== 0) {
               emptyGift.giftLookupIndex = lastGiftEntry.giftLookupIndex + 2;
               emptyGift.giftcontactLookupIndex = lastGiftEntry.giftLookupIndex + 3;
               this.gifts.push(emptyGift);
           }
           //alert(JSON.stringify(emptyGift));
       }
       
   }
    addSampleDropINTL()
    {

    }
    handleActivitySuccess(event) {
 
    }
 
    handleActivitySubmit(event) {
 
    }

    handleSuccess(event) {
         console.log('handleSuccess');
        if(event.detail.apiName == "Call__c" && this.isConfirmed) { // may need to switch to != 'Contact' 
            let closeOrRedirect = '';
            if(this.recordId) {
                closeOrRedirect = 'close';
            }
            else {
                closeOrRedirect = 'redirect';
            }

             // this.template.querySelector('div').scrollIntoView()
             
             // this.notifyUser('Success', 'The form was submitted.', 'success');
            const fields = event.detail.fields; 

            const recordId = this.callRecordId ? this.callRecordId : event.detail.id;
            this.saveLookupRelationships(fields, closeOrRedirect, recordId); 
        }
       
    }
 
    handleError(event) {
         console.log(JSON.stringify(event.detail));
         //alert(JSON.stringify(event.detail));
        
           let error = JSON.parse(JSON.stringify(event.detail.output.fieldErrors.ZTS_EU_Account__c));
         //let error = JSON.stringify(event.detail.output.fieldErrors);
         //console.log('Error -> '+ error);
         console.log('Error -> '+ error[0].errorCode);
         if(error){
           this.processing = false;
           this.isSubmit = false;
           this.notifyUser(
               'Error Submitting',
               /*'An error occured while submitting the call ',*/
               'An error occured while submitting the call: ' + "Error Field: " +   error[0].field+  ", Error Code: " + error[0].errorCode + ", Error Message: " +
               error[0].message , 
               'error'
           );
        }
        else{
           this.processing = false;
           this.isSubmit = false;
           this.notifyUser(
               'Error Submitting',
               'An error occured while submitting the call: ' + event.detail.message,
               'error'
           );
        }
    }
 
    handleDelete(event) {
        // event.preventDefault();
        this.processing = true;
        const taskId = event.target.value;
        if(taskId) {
            const removeItemParams = {
                recordId: taskId,
                sObjectTypeLabel: "Task",
                callId: this.salesCall.callId
            };
             console.log('removeItemParams>>>',removeItemParams);
            removeItem(removeItemParams)
                .then(result => {
                    this.followUpActivities = this.followUpActivities.filter(item => item.taskId !== taskId);
                    this.processing = false;
                })
                .catch(error => {
                    this.processing = false;
                    this.notifyUser(
                        'Deletion Error',
                        'An error occured while removing item: ' + JSON.stringify(error.body.message),
                        'error'
                    );
                });
        }
        else {
            const lookupIndex = event.target.dataset.item;
            this.followUpActivities = this.followUpActivities.filter(item => item.taskLookupIndex != lookupIndex);
            this.processing = false;
        }  
         
    }

    handleGiftsDelete(event) {
       // event.preventDefault();
       this.processing = true;
       const giftId = event.target.value;
       if(giftId) {
           const removeItemParams = {
               recordId: giftId,
               sObjectTypeLabel: "Gift",
               callId: this.salesCall.callId
           };
            console.log('removeItemParams>>>',removeItemParams);
           removeItem(removeItemParams)
               .then(result => {
                   this.gifts = this.gifts.filter(item => item.giftId !== giftId);
                   this.processing = false;
               })
               .catch(error => {
                   this.processing = false;
                   this.notifyUser(
                       'Deletion Error',
                       'An error occured while removing item: ' + JSON.stringify(error.body.message),
                       'error'
                   );
               });
       }
       else {
           const lookupIndex = event.target.dataset.item;
           this.gifts = this.gifts.filter(item => item.giftLookupIndex != lookupIndex);
           this.processing = false;
       }
        
   }
 
    deleteLookupResult(selectedItem, lookupIndex, filteredSelection) {
        const removeItemParams = {
            recordId: selectedItem.id,
            sObjectTypeLabel: selectedItem.sObjectType,
            callId: this.callRecordId
        };
         console.log('removeItemParams>>>',removeItemParams);
        removeItem(removeItemParams)
            .then(result => {
                this.template
                    .querySelectorAll('c-lookup')[lookupIndex]
                    .setSelection(filteredSelection);
                    this.processing = false;
                // const filteredSelection = this.selection.filter(item => item.id !== recordId);
            })
            .catch(error => {
                this.processing = false;
                this.notifyUser(
                    'Deletion Error',
                    'An error occured while removing item: ' + JSON.stringify(error.body.message),
                    'error'
                );
                // // eslint-disable-next-line no-console
                // console.error('Lookup error', JSON.stringify(error.body.message));
                // this.errors = [error];
            });
 
    }
 
    saveLookupRelationships(formFields, closeOrRedirect, recordId) {
 
        //JSON.stringify(lookupValues);
 
        let lookupValues = [];
        let lookupIndex = 0;
        this.template
            .querySelectorAll('c-lookup')
            .forEach((element) => {
                if(lookupIndex < this.TASK_INDEX_START) {
                    lookupValues.push(...element.getSelection());
                }
                lookupIndex++;
            });
        //alert(JSON.stringify(lookupValues));
        this.salesCall.callId = recordId;
        if(lookupValues.length > 0) {
            
            this.updateSalesCallBeforeSubmit(lookupValues);
        }

         //alert('after update salescall '+ JSON.stringify(this.salesCall));
        const initialDiscussionIds = this.initialDiscussions.map(disc => disc.id);
        this.salesCall.initialDiscussionIds = initialDiscussionIds;
        this.salesCall.followUpActivities = this.filterEmptyTask();
        this.salesCall.gifts = this.filterEmptyGift();

        let nextStep = ''; 
        let nextCallDate = '';
        let accountId = '';
        this.template.querySelectorAll('lightning-input-field')
            .forEach(field => {
                if(field.fieldName == 'ZTS_EU_Next_Step__c') {
                    nextStep = field.value;
                }
                if(field.fieldName == 'ZTS_EU_Next_Call_Date__c') {
                    nextCallDate = field.value;
                }
                if(field.fieldName == 'ZTS_EU_Account__c') {
                    accountId = field.value;
                }
            });
        if(this.isSubmit) {
            if(nextCallDate && nextCallDate) {
                let nextCallFields = {
                    ZTS_EU_Sub_Type__c: formFields.ZTS_EU_Sub_Type__c.value,
                    ZTS_EU_Next_Step__c: nextStep,
                    ZTS_EU_Next_Call_Date__c: nextCallDate,
                    ZTS_EU_Duration__c: formFields.ZTS_EU_Duration__c.value,
                    ZTS_EU_Account__c: accountId
                };
                this.salesCall.nextCallFieldsJson = JSON.stringify(nextCallFields);
            }
        }
        const saveResultsParams = {
            salesCallJson : JSON.stringify(this.salesCall)
        };
         //alert(JSON.stringify(this.salesCall));
        saveResults(saveResultsParams)
            .then(result => {
                this.salesCall = {};
                if(result) {
                    const redirectObject = {
                        type: 'standard__recordPage',
                        recordId: recordId,
                        sObjectApiName: 'Call__c',
                        actionName: 'view'
                    };
                    this.processCloseOrRedirect(closeOrRedirect, redirectObject);
                    // TODO:reset form on save
                    this.salesCall = {
                        callId : recordId,
                        attendees: [],
                        discussionItems: [],
                        campaigns: [],
                        products: [],
                        colleagues: [],
                        samples: [],
                        sampleDrops: [],
                        contacts: [], 
                        affiliations: [], //added by Aritra(SC-008075)
                        SamplesINTL: [],//Added by Aritra (SC-004726)
                        sampleDropsINTL: [], //Aded by Aritra (SC-004726)
                        users: [],
                        initialIds: [],
                        gifts: [],
                        opportunities: []
                    };
                    // this.navigateToRecord("0013K000003bWqSQAU","Account");
                    // this.navigateToRecord(this.salesCall.callId, "Call__c");
                }
                this.processing = false;
            })
            .catch(error => {
                this.processing = false;
                this.notifyUser(
                    'Save Error',
                    'An error occured while saving: ' + JSON.stringify(error.body.message),
                    'error'
                );
                // eslint-disable-next-line no-console
                 console.error('Lookup error', JSON.stringify(error.body.message));
                this.errors = [error];
            });
            
            this.isSubmit = false;
    }
 
    filterEmptyTask() {
        let filteredTasks = [];
        this.followUpActivities.forEach( (task) => {
            if(task.activityDate && task.subject && task.owner.length !== 0) {
                filteredTasks.push(task);
            }
        });
        return filteredTasks; 
    }

    filterEmptyGift() {
       let filteredGifts = [];
       this.gifts.forEach( (gift) => {
           if((gift.product.length !== 0) && (gift.contact.length !==0) && (gift.quantity!== 0)) {
               filteredGifts.push(gift);
           }
       });
       return filteredGifts;

    }
 
    updateSalesCallBeforeSubmit(lookupValues) {
        lookupValues.forEach((el)=>{
            //alert(el);
           /* switch(el.sObjectType) {
                case "Product Hierarchy":
                    this.salesCall.products.push(el);
                    break;
                case "Campaign":
                    this.salesCall.campaigns.push(el);
                    break;
                case "Discussion Item":
                    this.salesCall.discussionItems.push(el);
                    break;
                case "Contact":
                    this.salesCall.contacts.push(el);
                    break;
                case "Account Contact Affiliation": //added by Aritra(SC-008075)
                    this.salesCall.affiliations.push(el);
                    break;
                case "Sample Drop":
                    this.salesCall.sampleDrops.push(el);
                    break;
                case "Sample":
                    el.record.ZTS_EU_On_Hand_Balance__c = el.ZTS_EU_Quantity__c; // storing on field to sample drop 
                    this.salesCall.samples.push(el);
                    break;
                case "Colleague":
                    this.salesCall.colleagues.push(el);
                    break;
                case "User":
                    this.salesCall.users.push(el);
                    break;
                case "Attendee":
                    this.salesCall.attendees.push(el);
                    break;
                case "Opportunity":
                   this.salesCall.opportunities.push(el);
                   break;
                case "Oportunidade":
                       this.salesCall.opportunities.push(el);
                       break;
            }*/
            //Aritra converted it based on sObject API Name as Sobject label differs based on user's language
            switch(el.sObjectAPIName) {
               case "ZTS_EU_Species_Product__c":
                   this.salesCall.products.push(el);
                   break;
               case "Campaign":
                   this.salesCall.campaigns.push(el);
                   break;
               case "ZTS_EU_Discussion_Item__c":
                   this.salesCall.discussionItems.push(el);
                   break;
               case "Contact":
                   this.salesCall.contacts.push(el);
                   break;
               case "ZTS_EU_Affiliations__c": //added by Aritra(SC-008075)
                   this.salesCall.affiliations.push(el);
                   break;
               case "Sample_Drop__c":
                   this.salesCall.sampleDrops.push(el);
                   break;
               case "ZTS_EU_Sample__c":
                   el.record.ZTS_EU_On_Hand_Balance__c = el.ZTS_EU_Quantity__c; // storing on field to sample drop 
                   this.salesCall.samples.push(el);
                   break;
               case "ZTS_EU_Colleague__c":
                   this.salesCall.colleagues.push(el);
                   break;
               case "User":
                   this.salesCall.users.push(el);
                   break;
               case "Attendee__c":
                   this.salesCall.attendees.push(el);
                   break;
               case "Opportunity":
                  this.salesCall.opportunities.push(el);
                  break;
            }
        });
    }
 
    filterResultsByTitle(listToFilter, arrayToFilterAgainst) {
        const filteredTitles = arrayToFilterAgainst.map(obj => obj.title);
        return listToFilter.filter( ({title}) => !filteredTitles.includes(title));
    }
 
    checkForErrors(fields) {
        let noErrors = false;
        const validAttendeesAndDiscussions = this.checkForAttendeesAndDiscussionOnSubmit();
        const submittedDateAfterActivityDate = this.checkForSubmittedDateAfterActivityDate(fields.ZTS_EU_Start_Date_Time__c, fields.ZTS_EU_Submitted_Date__c);
        if(validAttendeesAndDiscussions) {
            if(submittedDateAfterActivityDate) {
                noErrors = true;
            }
        }
        return noErrors;
    }
 
    checkForSubmittedDateAfterActivityDate(activityDate, submittedDate) {
        let isValid = false;
        if(submittedDate > activityDate) {
            isValid = true;
        }
        else {
            this.notifyUser(
                'Submit Error',
                'An error occured while submitting: '+this.SUBMITTED_DATE_ERROR,
                'error'
            );
            this.isSubmit = false;
            this.processing = false;
        }
        return isValid;
    }
 
    checkForAttendeesAndDiscussionOnSubmit() {
        let isValid = false;
        const numAttendees = this.template.querySelectorAll('c-lookup')[this.ATTENDEE_INDEX].getSelection().length;
        const numDiscussions = this.template.querySelectorAll('c-lookup')[this.DISCUSSION_INDEX].getSelection().length;
        if(numAttendees > 0 && numDiscussions > 0) {
            isValid = true;
        }
        else {
            this.notifyUser(
                'Submit Error',
                'An error occured while submitting: '+this.NUM_ATTENDEE_DISCUSSION_ERROR,
                'error'
            );
            this.isSubmit = false;
            this.processing = false;
        }
        return isValid;
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
 
    processCloseOrRedirect(closeOrRedirect, redirectRecord) {
        if(closeOrRedirect == 'close') {
            this.closeQuickAction();
        }
        else if(closeOrRedirect == 'redirect') {
            this.navigateToRecord(redirectRecord);
        }
    } 
    closeQuickAction() { 
       const closeQA = new CustomEvent('close');
       this.dispatchEvent(closeQA);
    }
 
    navigateToRecord(redirectRecord) {
        this[NavigationMixin.Navigate]({
            type: redirectRecord.type,
            attributes: {
                recordId: redirectRecord.recordId,
                actionName: redirectRecord.actionName,
                objectApiName: redirectRecord.sObjectApiName
            },
        });
    }   
 
     
}