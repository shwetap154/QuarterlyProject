/******************************************************************************************************************************************
 * Class Name   : salesCall
 * Description  : Lightning web component for SalesCall page
 * Created By   : Slalom/Alex Carstairs
 * Created Date : 23 March 2020
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Alex Carstairs(Slalom)     03/23/2020          Created.
 *****************************************************************************************************************************************
 * Mahendra Kumar(TouchPoint)   08/17/2021          Modified
 * (Added checkForAttendeesAndDiscussionOnSave() this function to display alert message when discussion item is selected without adding attendee)
 * Aritra (Cognizant)           12/21/2021          Modified. Added functions and vars for call duplicate prompt (SC-008846)
 * 
 ***********************************************************************************************************************************************
 * Sayan (Cognizant)            01/20/2023          Modified. Added some changes to prevent duplicate call creation in case if there is an exception (SC-009780)
 **********************************************************************************************************************************************/


 import { LightningElement, track, api, wire } from 'lwc';
 import { ShowToastEvent } from 'lightning/platformShowToastEvent';
 import { NavigationMixin } from 'lightning/navigation';
 import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
 import { getUserPreferenceInfo, getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
 import PROF_NAME_FIELD from '@salesforce/schema/User.Profile.Name';//Added for SC-009405
 import curr_user_id from '@salesforce/user/Id';//Added for SC-009405
 
 import NAME_FIELD from '@salesforce/schema/Call__c.Name';
 import SUBTYPE_CALL_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Sub_Type__c';
 import STATUS_CALL_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Status__c';
 import SUBMITTED_DATE_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Submitted_Date__c';
 import CREATED_DATE_FIELD from '@salesforce/schema/Call__c.CreatedDate';//created for SC-009405
 import ACCOUNT_CALL_FIELD from '@salesforce/schema/Call__c.ZTS_EU_Account__c';
 import STATUS_TASK_FIELD from '@salesforce/schema/Task.Status';
 import PRIORITY_TASK_FIELD from '@salesforce/schema/Task.Priority';
 import TASK_OBJECT from '@salesforce/schema/Task';
 
 import lookupSearch from '@salesforce/apex/SalesCallLWCController.search';
 import saveResults from '@salesforce/apex/SalesCallLWCController.saveLookupResults';
 import getCall from '@salesforce/apex/SalesCallLWCController.getCallRecordAndRelatedRecords';
 import removeItem from '@salesforce/apex/SalesCallLWCController.removeItem';
 
 import createContactLookup from '@salesforce/apex/SalesCallLWCController.createContactLookup';
 
 import getFieldsByFieldSetName from '@salesforce/apex/FieldSetRecordFormController.getFieldsByFieldSetName';
 import createCallRecord from '@salesforce/apex/SalesCallLWCController.createCallRecord'; /*Added for SC-008846*/
 import lookForDuplicateCalls from '@salesforce/apex/SalesCallLWCController.lookForDuplicate';/*Added for SC-008846*/
 // commented because the related system change will go live in future
 import createContact from '@salesforce/apex/CreateDuplicateRecordUtil.createDuplicateRecord'; //Added for SC-008149
 import getDupContactList from '@salesforce/apex/CreateDuplicateRecordUtil.getDupContactDetails'; //Added for SC-008149 
 import getSubPortalType from '@salesforce/apex/SalesCallLWCController.getSubTypes';
 import Discount_0_Sales_Manager_Rule from '@salesforce/label/c.Discount_0_Sales_Manager_Rule';
 //Added below import for Competitor module on Call page (SC-009358)
 import updateCompetitor from '@salesforce/apex/SalesCallLWCController.updateCompetitor';
 import removeCompetitor from '@salesforce/apex/SalesCallLWCController.deleteCompetitor';
 import createCompetitorRow from '@salesforce/apex/SalesCallLWCController.createCompetitorLookup';
 // Changes done for SC-009936
 import getCompetitors from '@salesforce/apex/SalesCallLWCController.getCompetitorOnAccount';
 import Json2 from '@salesforce/resourceUrl/Json2';
 
 
 // import USER_PREF_OBJECT from '@salesforce/schema/UserPreference';
 
 export default class SalesCall extends NavigationMixin(LightningElement) {
     // Use alerts instead of toast to notify user
     @api notifyViaAlerts = false;
     @api recordId;
     @api objectApiName;
 
     @track initialDiscussions = [];
     @track initialAttendees = [];
     @track initialColleagues = [];
     @track initialSampleDrops = [];
     @track followUpActivities = [];
     @track competitors = [];//Added by Aritra for (SC-009358)
 
     @track discussionErrors = [];
     @track attendeeErrors = [];
     @track colleagueErrors = [];
     @track sampleDropErrors = [];
     @track taskErrors = [];
     @track competitorErrors = [];//Added by Aritra for (SC-009358)
 
     @track processing = false;
     @track showNewContactform = false;
     @track showNewCompetitorform = false;//Added by Aritra for (SC-009358)
     @track isContactProcessing = false;
     // @track showActivityForm = false;
     //below vars are created for SC-008846
     @track callRecords;
     @track selectedConRecordId;
     @track showDupCallModal = false;
     @track callDuplicateMessage;
     @track formFieldsforFurtherSave;
     @track dupecallprocessing = false;
     @track fields = [];
     @track callRecord = {};
     //below vars are created for SC-008149
     @track conRecords;
     @track isDialogVisible = false;
     @track originalMessage;
     @track showDupContactModal = false;
     @track duplicateContactMessage;
     @track showDupContactTable = false;
     @track matchingIdJSON;
     //below var is created for SC-009405
     @track profileName;
 
     DEFAULT_SUBTYPE_CALL = 'Account Call';
     @track subTypeValue = this.DEFAULT_SUBTYPE_CALL;
     @track subTypeOptions = [];
     @track callCreatedDateVal;
     @track callIdToPreventDuplicate;//Sayan Added a new variable to track if a new call is inserted in the system SC-009780
     @track activityDate;
 
 
     isSubmit = false;
     isConfirmed = true;
     isContactSaveMethodisbeingcalled = false;//Sayan added a new variable to prevent callIdToPreventDuplicate insertion whenever new Contact insertion is successful
 
     ATTENDEE_INDEX = 0;
     DISCUSSION_INDEX = 1;
     COLLEAGUE_INDEX = 2;
     SAMPLE_DROP_INDEX = 3;
     TASK_INDEX_START = 4; // Number of c-lookup components on page before follow up activity section
     TASK_ITEM_INDEX_START = 5; // Number of the first c-lookup component for follow up items (Added by Morgan Marchese)
 
     salesCall = {
         callId: this.callRecord.id,
         attendees: [],
         discussionItems: [],
         campaigns: [],
         products: [],
         colleagues: [],
         samples: [],
         sampleDrops: [],
         contacts: [],
         affiliations: [], //added by Aritra(SC-008075)
         users: [],
         followUpActivities: [],
         competitors: [], //Added by Aritra for (SC-009358)
         initialIds: []
     };
     //below var is created for contact duplicate (SC-008149)
     contact = {
         FirstName: "",
         LastName: "",
         Interface_Email__c: "",
         ZTS_US_Account_influence__c: "",
         ZTS_US_Profession__c: "",
         ZTS_US_Job_Function__c: "",
         Phone: "",
         AccountId: "",
         ZTS_EU_Market__c: "",
         Title: "",
         ZTS_US_Primary_Species__c: ""
     };
 
     //below var is created for call duplicate (SC-008846)
     call = {
         Id: "",
         ZTS_EU_Start_Date_Time__c: "",
         ZTS_EU_Duration__c: "",
         ZTS_EU_Account__c: "",
         ZTS_EU_Sub_Type__c: "",
         ZTS_EU_Status__c: "",
         ZTS_EU_Submitted_Date__c: "",
         ZTS_EU_Additional_Notes__c: "",
         ZTS_EU_Next_Step__c: "",
         ZTS_EU_Next_Call_Date__c: ""
     };
     //below var is created for call duplicate (SC-008846)
     callforDupe = {
         callId: this.callRecord.id || "",
         activityDate: "",
         accountId: "",
         subtype: "",
         ownerId: "",
         attendees: [],
         affiliations: [],
         contacts: [],
         discussionNames: []
     };
 
 
     firstTime = true;
     errors = [];
 
     editLabel = 'Save';
     createLabel = 'Save';
 
     editTitle = 'Saves changes to call and closes modal';
     createTitle = 'Creates call record and closes modal';
 
     CREATE_TITLE_SUFFIX = 'Sales Call';
 
     COMPLETED_STATUS = 'Submitted';
     ALLOWED_DAYS = 10;
     TASK_CREATION_ALLOWED_DAYS = 15;
 
     CONTACT_FIELDSET = 'New_Contact';
 
 
     DEFAULT_PRIORITY_TASK = 'Normal';
     DFLT_PRIORITY_TASK_FOR_INSIDE_SMALLANIMAL_USERS = 'High';
     DEFAULT_STATUS_TASK = 'Not Started';
 
     SUBMITTED_DATE_ERROR = 'Call cannot be submitted prior to the activity date';
     NUM_ATTENDEE_DISCUSSION_ERROR = 'Each call needs to have at least one attendee and discussion for it to be submitted.';
     SELECT_ATTENDEE_WARNING = 'An Attendee is required if you want to add Discussion Items';//Added by Mahendra SC-008860
     ACCOUNT_ID_ERROR = 'Account missing on Call.';
     VIEW_ONLY_MESSAGE = 'You cannot edit a submitted call after ' + this.ALLOWED_DAYS + ' days has elapsed.';
     TASK_DUE_DATE_ERROR_MESSAGE = 'You cannot add a task which is dated more than ' + this.TASK_CREATION_ALLOWED_DAYS + ' days after the call created date';
     TASK_SUBJECT_LEN_EXCEEDED_MESSAGE = 'You are exceeding the recommended 50 character max for this field.';
     CONFIRMATION_MESSAGE = 'You would not be able to make any more changes ' + this.ALLOWED_DAYS + ' days after a call is submitted. Are you sure you want to Submit?';
     
     CATEGORIES_RQEUIRES_RX_PRODUCTS = ["Chemistry","Fecal","Hematology","Rapids","Reference Labs","Urine"]; // TPDEV-732
     @track isProductVisible = false; // TPDEV-732
     // @wire(getUserPreferenceInfo, { objectApiName: USER_PREF_OBJECT })
     //     getUserPref({error, data}) {
     //         if(data) {
     //         }
     //     }
 
     get callRecordId() {
         let recId = this.recordId;
         if (this.recordId) {
             if (this.recordId.substring(0, 3) == '001') { // Can be called from Account page as quick action
                 recId = '';
             }
         }
         return recId;
     }
 
     // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: STATUS_TASK_FIELD })
     get priorityOptions() {
         return [
             { label: 'High', value: 'High' },
             { label: 'Normal', value: 'Normal' },
             { label: 'Low', value: 'Low' },
         ];
     };
 
     // @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PRIORITY_TASK_FIELD })
     get statusOptions() {
         return [
             { label: 'Acknowledged, No Action', value: 'Acknowledged, No Action' },
             { label: 'Closed Due to Age', value: 'Closed Due to Age' },
             { label: 'Completed', value: 'Completed' },
             { label: 'Deferred', value: 'Deferred' },
             { label: 'In Progress', value: 'In Progress' },
             { label: 'Not Started', value: 'Not Started' },
             { label: 'Open', value: 'Open' },
             { label: 'Waiting on customer', value: 'Waiting on customer' },
             { label: 'Waiting on someone else', value: 'Waiting on someone else' },
         ];
     };
 
     get headerClass() {
         let cssClasses = '';
         if (this.recordId) {
             cssClasses = 'slds-modal__header sticky-top';
         }
         else {
             cssClasses = 'slds-modal__header';
         }
         return cssClasses;
     }
 
     get titleClass() {
         let cssClasses = '';
         if (this.recordId) {
             cssClasses = 'slds-modal__title slds-hyphenate';
         }
         else {
             cssClasses = 'slds-hyphenate large-font-size';
         }
         return cssClasses;
     }
 
     get footerClass() {
         let cssClasses = '';
         if (this.recordId) {
             cssClasses = 'slds-modal__footer sticky-bottom';
         }
         else {
             cssClasses = 'slds-modal__footer';//added extra style 
             //to show blank space below footer to show Next Call Date Time Picker fully (SC-008846)
         }
         return cssClasses;
     }
 
     get contentClass() {
         let cssClasses = '';
         if (this.recordId) {
             cssClasses = 'slds-modal__content modal-content-override';
         }
         else {
             cssClasses = 'slds-modal__content slds-p-horizontal_large';
         }
         return cssClasses;
     }
 
     /*
     Commented by SC-010116
     get formContainer() {
         let cssClasses = '';
         if (this.recordId) {
             cssClasses = '';
         }
         else {
             cssClasses = 'form-container';
         }
         return cssClasses;
     } */
 
     get spinnerClass() {
         let cssClasses = '';
         if (this.recordId) {
             cssClasses = 'medium-height';
         }
         else {
             cssClasses = 'medium-height';
             // cssClasses = 'medium-height slds-is-relative';
         }
     }
     //below function is created for contact duplicate (SC-008149)
     // commented because the related system change will go live in future
     @wire(getDupContactList, { selectedIdsJson: '$matchingIdJSON' })
     getCon({ error, data }) {
         if (data) {//jgm
             //alert('data-->'+data);
             this.conRecords = data;
             this.error = undefined;
         } else if (error) {
             this.notifyUser(
                 'Contact Retrieval Error',
                 'An error occured while retrieving duplicate contacts: ' + JSON.stringify(error.body.message),
                 'error'
             );
             this.error = error;
         }
     }
     //below function is created for contact duplicate (SC-008149)
     get conColumns() {
         return [
             { label: 'Contact Name', fieldName: 'Full_Contact_Name__c' },
             { label: 'Account Name', fieldName: 'Account_Name__c' },
             { label: 'Status', fieldName: 'ZTS_EU_Contact_Status__c' },
             { label: 'Email', fieldName: 'Interface_Email__c' },
             { label: 'Phone', fieldName: 'Phone' },
             { label: 'Profession', fieldName: 'ZTS_US_Profession__c' },
             { label: 'Job Function', fieldName: 'ZTS_US_Job_Function__c' },
 
         ];
     };
     //below function is created for call duplicate (SC-008846)
     get callColumns() {
         return [
             { label: 'Call Type', fieldName: 'Name' },
             {
                 label: 'Activity Date', fieldName: 'ZTS_EU_Start_Date_Time__c', type: 'date',
                 typeAttributes: {
                     day: 'numeric',
                     month: 'numeric',
                     year: 'numeric',
                     hour: '2-digit',
                     minute: '2-digit',
                     second: '2-digit',
                     hour12: true
                 }
             },
             { label: 'Account Name', fieldName: 'Account_name__c' },
             { label: 'Call Objective', fieldName: 'ZTS_EU_Call_Objectives__c' },
             {
                 type: "button",
                 fixedWidth: 100,
                 typeAttributes: { label: 'View', name: 'View', value: 'view', iconPosition: 'center' },
                 cellAttributes: { style: 'transform: scale(0.75)' }
             }
         ];
     };
 
     // Changes done for SC-009936
     connectedCallback()
       {
        //Changes done by SC - 010311
        if(this.recordId == null || this.recordId == undefined || (this.recordId != null && this.recordId.startsWith('001'))) { 
            let todayDate = new Date();
            this.activityDate = todayDate.toISOString();

        }

       }
 
     //Added for SC-009405
     @wire(getRecord, {
         recordId: curr_user_id,
         fields: [PROF_NAME_FIELD]
     }) wireuser({
         error,
         data
     }) {
         if (error) {
             this.error = error;
         } else if (data) {
             this.profileName = data.fields.Profile.value.fields.Name.value;
         }
     }
 
     @wire(getFieldsByFieldSetName, { objectApiName: 'Contact', fieldSetName: '$CONTACT_FIELDSET' })
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
 
     @wire(getRecord, { recordId: '$callRecordId', fields: [NAME_FIELD, CREATED_DATE_FIELD, STATUS_CALL_FIELD, SUBMITTED_DATE_FIELD, ACCOUNT_CALL_FIELD, SUBTYPE_CALL_FIELD] })
     wiredRecord({ error, data }) {
         if (data) {
             this.callRecord = data;
             this.subTypeValue = getFieldValue(this.callRecord, SUBTYPE_CALL_FIELD);
         }
         else {
             this.callRecord = {};
         }
     }
 
     @wire(getCall, { callIdString: '$callRecordId' })
     getCall({ error, data }) {
         if (data) {//jgm
             const parsedSalesCallWrapper = JSON.parse(data);
             //this.salesCall.callId = this.callRecordId;

             //Sayan added to check and add the correct record id (SC-009780)
             if(this.callRecordId){
             this.salesCall.callId = this.callRecordId;
             }else if(this.callIdToPreventDuplicate){
                this.salesCall.callId = this.callIdToPreventDuplicate;
             }//Sayan end
             this.initialAttendees = parsedSalesCallWrapper.attendees;
             this.initialDiscussions.push(...parsedSalesCallWrapper.discussionItems);
             this.initialDiscussions.push(...parsedSalesCallWrapper.campaigns);
             this.initialDiscussions.push(...parsedSalesCallWrapper.products);
             this.initialColleagues = parsedSalesCallWrapper.colleagues;
             this.initialSampleDrops = parsedSalesCallWrapper.sampleDrops;
             this.followUpActivities = parsedSalesCallWrapper.followUpActivities;
             this.competitors = parsedSalesCallWrapper.competitors;//Added by Aritra for (SC-009358)
             //alert("competitors-->" + JSON.stringify(this.competitors));
             //TASK_ITEM_INDEX_START
             this.followUpActivities.forEach((task, index) => {
                 if (index == 0) {
                     task.taskLookupIndex = 4;
                 } else if (index == 1) {
                     task.taskLookupIndex = 6;
                 } else {
                     task.taskLookupIndex = 4 + (2 * index);
                 }
                 task.taskItemLookupIndex = task.taskLookupIndex + 1; //Aritra added this line
             });
         } else if (error) {
             this.notifyUser(
                 'Load Call Error',
                 'An error occured on load: ' + JSON.stringify(error.body.message),
                 'error'
             );
         }
 
     }
 
     get modalHeader() {
         const recordName = getFieldValue(this.callRecord, NAME_FIELD);
         return (this.callRecordId ? 'Edit ' + recordName : 'Create ' + this.CREATE_TITLE_SUFFIX);
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
 
     calculateTimeInDays(secondsPassed) {
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
 
     //below function is created for contact duplicate (SC-008149)
     handleRowSelection = event => {
         var selectedRows = event.detail.selectedRows;
         this.selectedConRecordId = selectedRows[0].Id;
     }
 
     //below function is created for contact duplicate (SC-008846) 
     handleCallRowAction(event) {
         const actionName = event.detail.action.name;
         const row = event.detail.row;
         switch (actionName) {
             case 'View':
                 this[NavigationMixin.GenerateUrl]({
                     type: 'standard__recordPage',
                     attributes: {
                         recordId: row.Id,
                         objectApiName: 'Call__c',
                         actionName: 'view'
                     }
                 })
                     .then(url => {
                         /*
                         console.log( 'URL is ' + url );
                         let completeURL = window.location.origin + url;
                         let windowFeatures = "menubar=no,resizable=yes,scrollbars=yes";
                         windowFeatures  = "width=" + screen.width;
                         windowFeatures += ",height=" + screen.height;
                         console.log( 'Complete URL is ' + completeURL );
                         window.open( completeURL, "_blank", windowFeatures );*/
                         window.open(url);
 
                     });
         }
     }
 
     handleFormLoad(event) {
         const accountField = this.template.querySelector('.account-field');
         if (accountField) {
             if (!this.callRecordId) {
                 if (this.recordId) {
                     accountField.value = this.recordId;
                 }
                 else {
                     const searchString = window.location.search;
                     if (searchString) {
 
                         const base64EncodedString = searchString.split('?')[1].split('=')[1].substring(2).split('&')[0];
                         console.log(' base64EncodedString ::: ' + base64EncodedString);
                         const decodedString = decodeURIComponent(base64EncodedString);
                         console.log('decodedString ::: ' + decodedString);
                         //Checking for not Aloha URL
                         //168  is when creating Call from the List View 
                         //180 when creating a Call from Related List on Account Record 
                         if (decodedString.length > 160) {
                             const accObj = JSON.parse(atob(decodedString));
                             accountField.value = accObj.attributes.recordId;
                         }
                     }
                 }
             }
 
             // Changes done for SC-009936
             if (accountField.value && this.competitors.length < 1) {
                 const competitorParam = {
                     accountId: accountField.value
                 };
                 getCompetitors(competitorParam).then(results =>{
                     if(results){
                         var competitorResult = JSON.parse(results);
                         this.competitors.push(...competitorResult);
                         this.salesCall.competitors.push(...competitorResult);    
                     }
                 });
             }
         }
         getSubPortalType({ callId: this.callRecordId })
             .then(results => {
                 this.subTypeOptions = results;
             })
             .catch(error => {
                 this.notifyUser(
                     'Subtype field error',
                     'An error occured' + JSON.stringify(error.body.message),
                     'error'
                 )
             });
 
     }
 
     handleSubTypeChange(event) {
         this.subTypeValue = event.detail.value;
     }
 
     //below function is created for contact duplicate (SC-008149)
     handleContactValueChange(event) {
         let ctrlName = event.currentTarget.dataset.name;
         switch (ctrlName) {
             case 'FirstName':
                 //alert('I am in contact change');
                 this.contact.FirstName = event.detail.value;
                 break;
             case 'ZTS_US_Account_influence__c':
                 this.contact.ZTS_US_Account_influence__c = event.detail.value;
                 break;
             case 'LastName':
                 this.contact.LastName = event.detail.value;
                 break;
             case 'ZTS_US_Profession__c':
                 this.contact.ZTS_US_Profession__c = event.detail.value;
                 break;
             case 'Interface_Email__c':
                 this.contact.Interface_Email__c = event.detail.value;
                 break;
             case 'ZTS_US_Job_Function__c':
                 this.contact.ZTS_US_Job_Function__c = event.detail.value;
                 break;
             case 'Phone':
                 this.contact.Phone = event.detail.value;
                 break;
             case 'Title':
                 this.contact.Title = event.detail.value;
                 break;
             case 'ZTS_US_Primary_Species__c':
                 this.contact.ZTS_US_Primary_Species__c = event.detail.value;
                 break;
         }
     }
     //Added by Aritra for (SC-009358)
     get hascompetitors() {
         if (this.competitors.length > 0)
             return true;
         else
             return false;
     }
     // added by Aritra (SC-009358)
     handleExsCompSaveSubmit(event) {
 
     }
     // added by Aritra (SC-009358)
     handleExsCompSaveSuccess(event) {
 
     }
     // added by Aritra (SC-009358)
     handleExsCompSaveError(event) {
 
     }
     // added by Aritra (SC-009358)
     handleCompChange(event) {
         const fieldChanged = event.target.fieldName;
         const competitorId = event.target.dataset.item;
         const newFieldValue = event.target.value;//fetching the updated value here and sending to competitor update
         const inputFields = this.template.querySelectorAll('lightning-input-field');
         if (inputFields) {
             inputFields.forEach(field => {
                 if (field.fieldName === fieldChanged) {
                     if (field.reportValidity()) {
                         if (this.searchThrottlingTimeout) {
                             clearTimeout(this.searchThrottlingTimeout);
                         }
 
                         this.searchThrottlingTimeout = setTimeout(() => {
                             this.isProcessing = true;
                             // this.template.querySelectorAll('lightning-record-edit-form')[formIndex].submit(fields);
 
                             const updateCompetitorParam = {
                                 compId: competitorId,
                                 fieldToUpdate: fieldChanged,
                                 newValue: newFieldValue
                             };
                             //alert(JSON.stringify(updateContactParam));
                             updateCompetitor(updateCompetitorParam)
                                 .then(results => {
                                     console.log('results: ', JSON.parse(JSON.stringify(results)));
                                     this.isProcessing = false;
                                 })
                                 .catch(error => {
                                     this.isProcessing = false;
                                     this.notifyUser(
                                         'Update Competitor Error',
                                         // 'An error occured while searching: ' + JSON.stringify(error.body.message),
                                         'An error occured while searching: ' + JSON.stringify(error.body.message),
                                         'error'
                                     );
                                 });
 
                             this.searchThrottlingTimeout = null;
 
                         }, 1);
                     }
                 }
             });
         }
     }
 
     handleSearch(event) {
         let accountId = '';
         const inputFields = this.template.querySelectorAll(
             'lightning-input-field'
         );
         if (inputFields) {
             inputFields.forEach(field => {
                 if (field.fieldName == 'ZTS_EU_Account__c') {
                     accountId = field.value;
                 }
             });
         }
         event.detail.accountId = accountId;
         lookupSearch(event.detail)
             .then(results => {
                 let lookResult = JSON.parse(results);
                 const lookupIndex = event.detail.index;
                 if (this.ATTENDEE_INDEX == 0) {
                     lookResult = this.filterResultsByTitle(lookResult, this.initialAttendees);
                 }
                 else if (this.COLLEAGUE_INDEX == 2) {
                     lookResult = this.filterResultsByTitle(lookResult, this.initialColleagues);
                 }
                 this.template
                     .querySelectorAll('c-lookup')[lookupIndex]
                     .setSearchResults(lookResult);
             })
             .catch(error => {
                 this.notifyUser(
                     'Lookup Error',
                     'An error occured while searching: ' + JSON.stringify(error.body.message),
                     'error'
                 );
                 // eslint-disable-next-line no-console
                 this.errors = [error];
             });
     }
 
 
 
     handleSelectionChange(event) {
         const selectionDetail = event.detail;
         if (selectionDetail) {
             const selectedItem = selectionDetail.selectedItem;
             const lookupIndex = selectionDetail.index;
             
             if (selectionDetail.isRemoved) {
                 if (selectedItem) { // multi-entry deletion
                     this.processing = true;
                     const lookupIndex = event.detail.index;
                     const filteredSelection = event.detail.filteredSelection;
                     this.deleteLookupResult(selectedItem, lookupIndex, filteredSelection);
                 }
                 else { // single-entry deletion
                     this.followUpActivities.forEach((task) => {
                         if (lookupIndex == task.taskLookupIndex) {
                             task.owner = [];
                         }
 
                         else if (lookupIndex - task.taskLookupIndex === 1) {
                             task.followup = []; //Added for task follow up item 
                         }
                     });
                 }
             }
             else {
                 this.followUpActivities.forEach((task) => {
                     if (lookupIndex == task.taskLookupIndex) {
                         task.owner = [selectedItem];
                     } else if (lookupIndex - task.taskLookupIndex === 1) { //important to keep the difference to 1 for followup, for next column in future it should be 2
                         task.followup = [selectedItem];
                     }
                 });
             }
         }
         // this.errors = [];
     }
     // added by Aritra (SC-009358)
     deleteCompetitorSelection(event) {
         this.isContactProcessing = true;
         const recordId = event.target.value;
         //alert('current comp list ---' + JSON.stringify(this.competitors));
         this.competitors = this.competitors.filter(item => item.Competitor__c !== recordId);//to delete the competitor from existing competitor call records associated to this call
         this.competitors = this.competitors.filter(item => item.Id !== recordId);//to delete the new competitor created in call form, waiting to create competitor call. 
         this.salesCall.competitors = this.salesCall.competitors.filter(item => item.Id !== recordId);
         //alert('recordId-->' + JSON.stringify(event.target.value));
         const removeItemParams = {
             recordId: recordId,
             sObjectTypeLabel: 'ZTS_Competitor__c'
         };
         //console.log('removeItemParams>>>', removeItemParams);
         removeCompetitor(removeItemParams)
             .then(result => {
                 this.notifyUser(
                     'Deletion Success',
                     'Competitor has been removed successfully',
                     'success'
                 );
                 this.isContactProcessing = false;
             })
             .catch(error => {
                 this.isContactProcessing = false;
                 this.notifyUser(
                     'Deletion Error',
                     'An error occured while removing competitor: ' + JSON.stringify(error.body.message),
                     'error'
                 );
             });
     }
     saveOnClick() {
         //this.isConfirmed = true;
         const inputFields = this.template.querySelectorAll('lightning-input-field');
         if (inputFields) {
             inputFields.forEach(field => {
                 if (!field.reportValidity()) {
                     field.scrollIntoView(false);
                     this.isSubmit = false;
                     return;
                 }
             });
         }
         //alert(this.checkForTaskDueDate());
         if (!this.checkForTaskDueDate()) {
             this.isConfirmed = false;
 
         }
         else {
             this.isConfirmed = true;
         }
 
         //SC-008860 Added by Mahendra, to Dispaly Alert if the Discussion Item is selected without adding Attendee
         this.checkForAttendeesAndDiscussionOnSave();
 
     }
 
     cancelOnClick(event) {

        let accountId = '';
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName == 'ZTS_EU_Account__c') {
                    accountId = field.value;
                }
            });
        }

        let redirectRecord = {};
        if (this.recordId) {
            this.processCloseOrRedirect("close", redirectRecord);
        }
        else {
            this.processCloseOrRedirect("close", redirectRecord);
            window.history.back();
        }
    }
 
     //updated below function to check for call duplicate and show prompt modal(SC-008846)
     handleSubmit(event) {
         //alert("111");
         event.preventDefault();
         if (this.isConfirmed) {
             this.processing = true;
             //alert("222");
             //Stops the event propagation
 
             const formFields = event.detail.fields;
             this.formFieldsforFurtherSave = event.detail.fields;//This is used to hold the call fields for post call actions
             // formFields.Id = '';
             if (this.callRecordId) {
                 this.call.Id = this.callRecordId;
                 this.callforDupe.callId = this.callRecordId;
             }//Sayan added else-if (SC-009780)
             else if(this.callIdToPreventDuplicate){
                this.call.Id = this.callIdToPreventDuplicate;
                this.callforDupe.callId = this.callIdToPreventDuplicate;
             }
            //Sayan
             else {
                 this.call.Id = null;
                 //this.callforDupe.callId = null;
             }
             let canSaveAndSubmit = true;
             this.template.querySelectorAll('lightning-input-field')
                 .forEach(field => {
                     if (field.fieldName == 'ZTS_EU_Start_Date_Time__c') {
                         this.call.ZTS_EU_Start_Date_Time__c = field.value;
                         this.callforDupe.activityDate = field.value;
                     }
                     if (field.fieldName == 'ZTS_EU_Duration__c') {
                         this.call.ZTS_EU_Duration__c = field.value;
                     }
                     if (field.fieldName == 'ZTS_EU_Account__c') {
                         this.call.ZTS_EU_Account__c = field.value;
                         this.callforDupe.accountId = field.value;
                     }
 
                     if (field.fieldName == 'ZTS_EU_Call_Objectives__c') {
                         this.call.ZTS_EU_Call_Objectives__c = field.value;
                     }
                     if (field.fieldName == 'ZTS_EU_Additional_Notes__c') {
                         this.call.ZTS_EU_Additional_Notes__c = field.value;
                     }
                     if (field.fieldName == 'ZTS_EU_Next_Step__c') {
                         this.call.ZTS_EU_Next_Step__c = field.value;
                     }
                     if (field.fieldName == 'ZTS_EU_Next_Call_Date__c') {
                         this.call.ZTS_EU_Next_Call_Date__c = field.value;
                     }
 
                 });
 
             this.template.querySelectorAll('lightning-output-field')
                 .forEach(field => {
                     if (field.fieldName == 'ZTS_EU_Status__c') {
                         this.call.ZTS_EU_Status__c = field.value;
                     }
                     if (field.fieldName == 'ZTS_EU_Submitted_Date__c') {
                         this.call.ZTS_EU_Submitted_Date__c = field.value;
                     }
                 });
 
             let subtype = this.template.querySelector("lightning-combobox[data-id='subtype']").value;
             //alert ('subtype->'+ subtype);
             formFields.ZTS_EU_Sub_Type__c = subtype;
             this.call.ZTS_EU_Sub_Type__c = subtype;
             this.callforDupe.subtype = subtype;
             let lookupValues = [];
             let lookupIndex = 0;
             this.template
                 .querySelectorAll('c-lookup')
                 .forEach((element) => {
                     if (lookupIndex < this.COLLEAGUE_INDEX) {
                         lookupValues.push(...element.getSelection());
                     }
                     lookupIndex++;
                 });
             if (lookupValues.length > 0) {
                 lookupValues.forEach((el) => {
                     switch (el.sObjectType) {
                         case "Product Hierarchy":
                             this.callforDupe.discussionNames.push(el);
                             break;
                         case "Campaign":
                             this.callforDupe.discussionNames.push(el);
                             break;
                         case "Discussion Item":
                             this.callforDupe.discussionNames.push(el);
                             break;
                         case "Contact":
                             this.callforDupe.contacts.push(el);
                             break;
                         case "Account Contact Affiliation":
                             this.callforDupe.affiliations.push(el);
                             break;
                         case "Attendee":
                             this.callforDupe.attendees.push(el);
                             break;
                     }
                 });
             }
             if (this.isSubmit) {
                 //alert ('I am here');
                 formFields.ZTS_EU_Status__c = 'Submitted';
                 this.call.ZTS_EU_Status__c = 'Submitted';
                 //this.formFieldsforFurtherSave.ZTS_EU_Status__c = 'Submitted';
                 formFields.ZTS_EU_Submitted_Date__c = new Date().toISOString(); // Date.now();
                 this.call.ZTS_EU_Submitted_Date__c = new Date().toISOString(); // Date.now();
                 //this.formFieldsforFurtherSave.ZTS_EU_Submitted_Date__c = new Date().toISOString();
                 canSaveAndSubmit = this.checkForErrors(formFields);
             }
             //formFields.ZTS_EU_Sub_Type__c = this.subTypeValue;
             if (canSaveAndSubmit) {
                 //alert('Before checking for duplicate ->'+ JSON.stringify(this.callforDupe));
                 let objson = JSON.stringify(this.callforDupe);
                 const param = {
                     dupeCheckDetails: objson
                 };
                 lookForDuplicateCalls(param).
                     then((result) => {
                         if (!result.length) {
                             //alert ("33333");
                             //If no duplicates found then submit the form
                             //this.template.querySelector('.sales-call-form').submit(formFields);


                             //Sayan added check before submitting the form only if a Call record is not yet inserted in the system, otherwise just save the lookup values (SC-009780)
                             if(!this.callIdToPreventDuplicate){
                                this.template.querySelector('.sales-call-form').submit(formFields);//This is the line which creates a Call record
                            }else{
                                if (this.isConfirmed) { // may need to switch to != 'Contact' 
                                    let closeOrRedirect = '';
                                    if (this.recordId) {
                                        closeOrRedirect = 'close';
                                    }
                                    else {
                                        closeOrRedirect = 'redirect';
                                    }

                                    // this.template.querySelector('div').scrollIntoView()
                                    // this.notifyUser('Success', 'The form was submitted.', 'success');
                                    const fields = event.detail.fields;
                                    const recordId = this.callRecordId ? this.callRecordId : (this.callIdToPreventDuplicate ? this.callIdToPreventDuplicate : event.detail.id);
                                    this.saveLookupRelationships(fields, closeOrRedirect, recordId);
                                }
                            }
                            //Sayan added
                         }
                         else {
                             //Else show duplicate call modal
                             this.showDupCallModal = true;
                             this.callRecords = result;
                             this.callDuplicateMessage = 'We found a probable duplicate call on the same Account. ';
                             this.callDuplicateMessage = this.callDuplicateMessage + 'Do you still want to create the call?'
                         }
                     })
                     .catch((error) => {
                         this.notifyUser(
                             'Error while checking for call duplicate',
                             'An error occured while checking for call duplicate: ' + JSON.stringify(error.body.message),
                             'error'
                         );
                         // eslint-disable-next-line no-console
                         this.errors = [error];
                         this.processing = false;
                     });
             }
         }
     }
 
     //This method is called when user confirms to create duplicate call in duplicate prompt modal (SC-008846)
     saveDuplicateCall(event) {
         this.dupecallprocessing = true;
         let recordId;
         let callObjJSON = JSON.stringify(this.call);
         //alert('callObjJSON before duplicate save 123s -->'+ callObjJSON);
         const param = {
             callRecord: callObjJSON,
             forceSave: false
         };
         createCallRecord(param).then((result) => {
             if (result !== "ERROR") {
                 //alert(result);
                 recordId = result;
                 this.notifyUser(
                     'Success!!',
                     'Call Record created successfully',
                     'success'
                 );
                 this.showDupCallModal = false;
                 //Post call submit tasks
                 if (recordId) {
                     let closeOrRedirect = '';
                     if (this.recordId) {
                         closeOrRedirect = 'close';
                     }
                     else {
                         closeOrRedirect = 'redirect';
                     }
 
                     //const callId = this.callRecordId ? this.callRecordId : recordId;
                     const callId = this.callRecordId ? this.callRecordId : (this.callIdToPreventDuplicate ? this.callIdToPreventDuplicate : recordId);//Sayan added SC-009780

                     //alert('Before additional records creation ->'+ callId);
                     this.saveLookupRelationships(this.formFieldsforFurtherSave, closeOrRedirect, callId);
                 }
             }
             else {
                 //alert('Error!');
                 this.notifyUser(
                     'Error!!',
                     'Error while saving the call.',
                     'error'
                 );
 
             }
             this.dupecallprocessing = false;
         })
             .catch((error) => {
                 //alert('Error!');
                 this.notifyUser(
                     'Error while saving the call',
                     'An error occurred while saving the call: ' + JSON.stringify(error.body.message),
                     'error'
                 );
                 this.errors = [error];
                 this.dupecallprocessing = false;
             });
 
     }
 
     submitOnclick() {
         this.isConfirmed = window.confirm(this.CONFIRMATION_MESSAGE);
         this.isSubmit = true;
     }
 
     toggleNewContactForm() {
         this.showNewContactform = !this.showNewContactform;
     }
     // added by Aritra (SC-009358)
     toggleNewCompForm() {
         this.showNewCompetitorform = !this.showNewCompetitorform;
         this.isProductVisible = false;
     }
     // added by Aritra (SC-009358) 
     // Called from Competitor creation lightning record edit form 
     handleCreateCompSubmit(event) {
         this.isContactProcessing = true;
         event.preventDefault();
         let callAccountId = '';
         this.template.querySelectorAll('lightning-input-field')
             .forEach(field => {
                 if (field.fieldName == 'ZTS_EU_Account__c') {
                     callAccountId = field.value;
                 }
             });
         if (callAccountId) {
             //alert("I am here");
             let fields = event.detail.fields;
             fields.Account__c = callAccountId;
             this.template.querySelector('.create-competitor-form').submit(fields);
         }
         else {
             this.notifyUser(
                 'Create Competitor Error',
                 'An error occured while searching: ' + this.ACCOUNT_ID_ERROR,
                 'error'
             );
         }
     }
     // added by Aritra (SC-009358)
     // invoked on Competitor creation lightning record edit form onsuccess event
     handleCreateCompSuccess(event) {
        this.isContactSaveMethodisbeingcalled = true;//Sayan added - SC-009780
         this.notifyUser(
             'Success',
             'Competitor Record has been created: ' + event.detail.id,
             'success'
         );
         const compSelectionParam = {
             compId: event.detail.id
         };
         createCompetitorRow(compSelectionParam)
             .then(results => {
                 const competitorResult = JSON.parse(results);
                 this.competitors.push(competitorResult);
                 this.salesCall.competitors.push(competitorResult);
                 this.toggleNewCompForm();
                 this.isContactProcessing = false;
             })
             .catch(error => {
                 this.notifyUser(
                     'Create Competitor Error',
                     'An error occured while creation: ' + JSON.stringify(error.body.message),
                     'error'
                 );
                 // eslint-disable-next-line no-console
                 this.errors = [error];
                 this.isContactProcessing = false;
                 this.toggleNewCompForm();
             });
     }
 
     // added by Aritra (SC-009358)
     handleCreateCompCancel(event) {
         this.toggleNewCompForm();
     }
     handleCreateContactSubmit(event) {
 
        this.isContactProcessing = true;
        event.preventDefault();
        let callAccountId = '';
        this.template.querySelectorAll('lightning-input-field')
            .forEach(field => {
                if (field.fieldName == 'ZTS_EU_Account__c') {
                    callAccountId = field.value;
                }
            });
        if (callAccountId) {

            let fields = event.detail.fields;
            fields.AccountId = callAccountId;
            this.template.querySelector('.create-contact-form').submit(fields);
            this.isContactSaveMethodisbeingcalled = true;//Sayan added - SC-009780
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
        this.isContactSaveMethodisbeingcalled = true;//Sayan added - SC-009780
         // Create wrapper for contactId
         
         const accountField = this.template.querySelector('.account-field');   // Added as a part of TPDEV-320     
         const contactId = event.detail.id;
 
         const createContactParam = {
             contactId: event.detail.id,
             accountId: accountField.value // Added as a part of TPDEV-320
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
 
     //below function will show the matching record modal duplicate error recieved while saving contact(SC-008149) 
     handleCreateContactError(event) {
         //console.log('error');
         this.isContactProcessing = false;
         // commented because the related system change will go live in future
         let confMsg;
         let matchingids = [];
         let matchingcontacts = [];
         this.isSubmit = false;
         let selection;
         if (JSON.stringify(event.detail.output.errors[0]).includes('duplicateRecordError')) {
             this.showDupContactModal = true;
             confMsg = "This record looks like an existing contact. ";
             confMsg = confMsg + "Please make sure to check any potential duplicate records before creating this contact. Use radio button to select an existing Contact if applicable.";
             confMsg = confMsg + " If the contact you select is showing a different account name, it will create a new affiliation to the account you are entering the Call for."; //TPDEV-320 Updated duplicate message
             this.duplicateContactMessage = confMsg;
             let dupContactCount;
             dupContactCount = event.detail.output.errors[0].duplicateRecordError.matchResults[0].matchRecordIds.length;
             //alert('error-> '+ dupContactCount);
             if (dupContactCount >= 1) {
                 this.showDupContactTable = true;
                 for (let i = 0; i < dupContactCount; i++) {
                     matchingids.push(event.detail.output.errors[0].duplicateRecordError.matchResults[0].matchRecordIds[i]);
                 }
                 this.matchingIdJSON = JSON.stringify(matchingids);
             }
 
 
         }
 
         else {
             this.notifyUser(
                 'Error Submitting',
                 'An error occured while submitting the call: ' + JSON.stringify(event.detail.message),
                 'error'
             );
         }
     }
     //this function is called when user selects to continue creating duplicate contact (SC-008149)
     // commented because the related system change will go live in future
     saveDuplicateContact(event) {
         this.isContactProcessing = true;
         let accountId; // Added as a part of TPDEV-320     
         this.template.querySelectorAll('lightning-input-field')
             .forEach(field => {
                 if (field.fieldName == 'ZTS_EU_Account__c') {
                     this.contact.AccountId = field.value;
                     accountId = field.value; // Added as a part of TPDEV-320  
                 }
             });
         this.contact.ZTS_EU_Market__c = 'United States';
         let objson = JSON.stringify(this.contact);
         const param = {
             sObjectRecord: objson,
             objectName: 'Contact'
         };
         let conId;
         createContact(param).then((result) => {
             if (result !== 'ERROR') {
                 this.notifyUser(
                     'Success',
                     'The duplicate contact has been created',
                     'success'
                 );
                 conId = result;
             }
             else {
                 conId = null;
             }
             //this will add the created contact in the attendee list
             const createContactParam = {
                 contactId: conId,
                 accountId: accountId // Added as a part of TPDEV-320  
             };
             createContactLookup(createContactParam)
                 .then(results => {
                     const contactLookupWrapper = JSON.parse(results);
                     let currentSelection = this.template.querySelectorAll('c-lookup')[0].getSelection();
                     currentSelection.push(contactLookupWrapper);
                     this.template.querySelectorAll('c-lookup')[0].setSelection(currentSelection);
                     this.toggleNewContactForm();
                     this.isContactProcessing = false;
                     this.showDupContactModal = false;
                     // this.processing = false;
                 })
                 .catch(error => {
                     this.notifyUser(
                         'Create Contact Error',
                         // 'An error occured while searching: ' + JSON.stringify(error.body.message),
                         'An error occured while adding contact in attendee list: ' + JSON.stringify(error.body.message),
                         'error'
                     );
                     // eslint-disable-next-line no-console
                     this.errors = [error];
                     this.isContactProcessing = false;
                     this.toggleNewContactForm();
                 });
         })
             .catch((error) => {
                 let errmesg = JSON.stringify(error.body.message);
                 const evt = new ShowToastEvent({
                     title: "Error",
                     message: "Error Occured while creating contact:" + errmesg,
                     variant: 'error',
                 });
                 this.dispatchEvent(evt);
 
             });
     }
     //this function is called when user selects exisiting matching contact to call from dupe modal (SC-008149)
     // commented because the related system change will go live in future
     addContactToCall(event) {
         // Added as a part of TPDEV-320
         const accountField = this.template.querySelector('.account-field');

         if (this.selectedConRecordId !== undefined) {
             const createContactParam = {
                 contactId: this.selectedConRecordId,
                 accountId: accountField.value  // Added as a part of TPDEV-320
             };
             createContactLookup(createContactParam)
                 .then(results => {
                     const contactLookupWrapper = JSON.parse(results);
                     let currentSelection = this.template.querySelectorAll('c-lookup')[0].getSelection();
                     currentSelection.push(contactLookupWrapper);
                     this.template.querySelectorAll('c-lookup')[0].setSelection(currentSelection);
                     this.toggleNewContactForm();
                     //this.isContactProcessing = false;
                     this.showDupContactModal = false;
                     // this.processing = false;
                 })
                 .catch(error => {
                     this.notifyUser(
                         'Error while adding contact to Call',
                         // 'An error occured while searching: ' + JSON.stringify(error.body.message),
                         'An error occured while adding contact in attendee list: ' + JSON.stringify(error.body.message),
                         'error'
                     );
                     // eslint-disable-next-line no-console
                     this.errors = [error];
                     this.isContactProcessing = false;
                     this.toggleNewContactForm();
                 });
         }
         else {
             const event = new ShowToastEvent({
                 title: 'Error',
                 message: 'Please select a contact from the list',
                 variant: 'warning',
                 mode: 'pester'
             });
             this.dispatchEvent(event);
         }
     }
     //this function will be called when user clicks cancel on the cancel button on matching contact modal(SC-008149)
     // commented because the related system change will go live in future
     cancelDuplicateContact(event) {
         this.showDupContactModal = false;
     }
 
     handleCreateContactCancel(event) {
         this.toggleNewContactForm();
     }
 
     handleTaskChange(event) {
         const value = event.detail.value;
         const fieldChanged = event.target.dataset.id;
         const lookupIndex = event.target.dataset.item;
         this.followUpActivities.forEach((task) => {
             if (lookupIndex == task.taskLookupIndex) {
                 switch (fieldChanged) {
                     case "subject":
                         task.subject = value;
                         if ((this.profileName == "US Inside Sales Manager") || (this.profileName == "US Inside Sales Rep")
                             || (this.profileName == "US Small Animal Manager") || (this.profileName == "US Small Animal Rep")) {
                             if (task.subject.length > 50) {
                                 this.notifyUser(
                                     'Warning',
                                     'Warning : ' + this.TASK_SUBJECT_LEN_EXCEEDED_MESSAGE,
                                     'warning'
                                 );
                             }
                         }
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
 
     addFollowUpActivity() {
         const activitiesLastIndex = this.followUpActivities.length - 1;
         let emptyTask = {
             taskId: '',
             owner: [],
             subject: '',
             activityDate: '',
             priority: '',
             status: this.DEFAULT_STATUS_TASK,
             followup: []
         };
         if ((this.profileName == "US Inside Sales Manager") || (this.profileName == "US Inside Sales Rep")
             || (this.profileName == "US Small Animal Manager") || (this.profileName == "US Small Animal Rep")) {
             emptyTask.priority = this.DFLT_PRIORITY_TASK_FOR_INSIDE_SMALLANIMAL_USERS;
         }
         else {
             emptyTask.priority = this.DEFAULT_PRIORITY_TASK;
         }
         if (activitiesLastIndex == -1) {
             emptyTask.taskLookupIndex = this.TASK_INDEX_START;
             emptyTask.taskItemLookupIndex = this.TASK_ITEM_INDEX_START;
             this.followUpActivities.push(emptyTask);
         }
         else {
             const lastActivityEntry = this.followUpActivities[activitiesLastIndex];
             if (lastActivityEntry.owner.length !== 0) {
                 // To support a second lookup field on each line, 
                 // we need to start the next line with an index that is +1 from the 
                 // last lookup index of the previous line.
                 // The last lookup on the previous line as of 3/19/2021 is taskItemLookupIndex
                 // - Added by Morgan Marchese
                 /*
                 const nextLookupIndex = lastActivityEntry.taskItemLookupIndex + 1;
                 const nextItemLookupIndex = nextLookupIndex + 1;
                 emptyTask.taskLookupIndex = nextLookupIndex;
                 emptyTask.taskItemLookupIndex = nextItemLookupIndex;
                 console.log('empty task called-->'+JSON.stringify(emptyTask));
                 */
                 emptyTask.taskLookupIndex = lastActivityEntry.taskLookupIndex + 2;
                 emptyTask.taskItemLookupIndex = emptyTask.taskLookupIndex + 1;
                 this.followUpActivities.push(emptyTask);
             }
         }
         // this.showActivityForm = !this.showActivityForm;
     }
 
     handleActivitySuccess(event) {
 
     }
 
     handleActivitySubmit(event) {
 
     }
 
     handleSuccess(event) {
        //handleSuccess is called every time a form is submitted successfully
        //Sayan added - SC-009780
        if((this.callIdToPreventDuplicate == undefined || this.callIdToPreventDuplicate == null) && !this.isContactSaveMethodisbeingcalled){
            this.callIdToPreventDuplicate = event.detail.id;
        }
        //Sayan


         if (event.detail.apiName == "Call__c" && this.isConfirmed) { // may need to switch to != 'Contact' 
             let closeOrRedirect = '';
             if (this.recordId) {
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
         console.log('error');
         this.processing = false;
         this.isSubmit = false;
         this.notifyUser(
             'Error Submitting',
             'An error occured while submitting the call: ' + JSON.stringify(event.detail.message),
             'error'
         );
     }
 
     handleDelete(event) {
         // event.preventDefault();
         this.processing = true;
         const taskId = event.target.value;
         if (taskId) {
             const removeItemParams = {
                 recordId: taskId,
                 sObjectTypeLabel: "Task",
                 callId: this.salesCall.callId
             };
             console.log('removeItemParams>>>', removeItemParams);
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
 
     deleteLookupResult(selectedItem, lookupIndex, filteredSelection) {
         const removeItemParams = {
             recordId: selectedItem.id,
             sObjectTypeLabel: selectedItem.sObjectType,
             callId: this.callRecordId
         };
         console.log('removeItemParams>>>', removeItemParams);
                  
         removeItem(removeItemParams)
             .then(result => {
                 this.template
                     .querySelectorAll('c-lookup')[lookupIndex]
                     .setSelection(filteredSelection);
                 this.processing = false;
                 // const filteredSelection = this.selection.filter(item => item.id !== recordId);


                 //this.initialDiscussions = this.initialDiscussions.filter(item => item.record.Id !== selectedItem.id);//Sayan added
                 //purpose of the line is: when a discussion is removed from at the 'Edit Call' screen, that must be removed from initialdiscussionids as well
                 //so that SaveLookupResults can be called with the updated SalesCallJSON
                 
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
         let lookupValues = [];
         let lookupIndex = 0;
         this.template
             .querySelectorAll('c-lookup')
             .forEach((element) => {
                 if (lookupIndex < this.TASK_INDEX_START) {
                     lookupValues.push(...element.getSelection());
                 }
                 lookupIndex++;
             });
 
         this.salesCall.callId = recordId;
         if (lookupValues.length > 0) {
             this.updateSalesCallBeforeSubmit(lookupValues);
         }
         const initialDiscussionIds = this.initialDiscussions.map(disc => disc.id);

         this.salesCall.initialDiscussionIds = initialDiscussionIds;
         this.salesCall.followUpActivities = this.filterEmptyTask();
         let nextStep = '';
         let nextCallDate = '';
         let accountId = '';
         this.template.querySelectorAll('lightning-input-field')
             .forEach(field => {
                 if (field.fieldName == 'ZTS_EU_Next_Step__c') {
                     nextStep = field.value;
                 }
                 if (field.fieldName == 'ZTS_EU_Next_Call_Date__c') {
                     nextCallDate = field.value;
                 }
                 if (field.fieldName == 'ZTS_EU_Account__c') {
                     accountId = field.value;
                 }
             });
         if (this.isSubmit) {
             if (nextCallDate && nextCallDate) {
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
             salesCallJson: JSON.stringify(this.salesCall)
         };
         saveResults(saveResultsParams)
             .then(result => {
                 this.salesCall = {};
                 if (result) {
                     const redirectObject = {
                         type: 'standard__recordPage',
                         recordId: recordId,
                         sObjectApiName: 'Call__c',
                         actionName: 'view'
                     };
                     this.processCloseOrRedirect(closeOrRedirect, redirectObject);
                     // TODO:reset form on save
                     this.salesCall = {
                         callId: recordId,
                         attendees: [],
                         discussionItems: [],
                         campaigns: [],
                         products: [],
                         colleagues: [],
                         samples: [],
                         sampleDrops: [],
                         contacts: [],
                         affiliations: [], //added by Aritra(SC-008075)
                         users: [],
                         initialIds: [],
                         followUpActivities: [], //added by James
                         competitors: [] // added by Aritra (SC-009358)
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


                 //Sayan added to nullify the variables in case of an exception (SC-009780)
                 this.salesCall = {
                    callId: recordId,
                    attendees: [],
                    discussionItems: [],
                    campaigns: [],
                    products: [],
                    colleagues: [],
                    samples: [],
                    sampleDrops: [],
                    contacts: [],
                    affiliations: [],
                    users: [],
                    initialIds: [],
                    followUpActivities: [],
                    competitors: []
                };
                //Sayan added
             });
 
         this.isSubmit = false;
     }
 
     filterEmptyTask() {
         let filteredTasks = [];
         this.followUpActivities.forEach((task) => {
             if (task.activityDate && task.subject && task.owner.length !== 0) {
                 filteredTasks.push(task);
             }
         });
         return filteredTasks;
     }
     // added by Aritra (SC-009358)
     filterEmptycompetitors() {
         let filteredComps = [];
         this.competitors.forEach((comp) => {
             if (comp.species && comp.manufacturer) {
                 filteredComps.push(comp);
             }
         });
         return filteredComps;
     }
     updateSalesCallBeforeSubmit(lookupValues) {
         lookupValues.forEach((el) => {
             switch (el.sObjectType) {
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
                     el.record.ZTS_US_On_Hand_Balance__c = el.ZTS_US_Quantity__c; // storing on field to sample drop 
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
             }
         });
     }
 
     filterResultsByTitle(listToFilter, arrayToFilterAgainst) {
         const filteredTitles = arrayToFilterAgainst.map(obj => obj.title);
         return listToFilter.filter(({ title }) => !filteredTitles.includes(title));
     }
 
     checkForErrors(fields) {
         let noErrors = false;
         const validAttendeesAndDiscussions = this.checkForAttendeesAndDiscussionOnSubmit();
         const submittedDateAfterActivityDate = this.checkForSubmittedDateAfterActivityDate(fields.ZTS_EU_Start_Date_Time__c, fields.ZTS_EU_Submitted_Date__c);
         const taskDueDateSatisfied = this.checkForTaskDueDate();
 
         if (validAttendeesAndDiscussions) {
             if (submittedDateAfterActivityDate) {
                 if (taskDueDateSatisfied) {
                     noErrors = true;
                 }
             }
         }
         return noErrors;
     }
 
     checkForSubmittedDateAfterActivityDate(activityDate, submittedDate) {
         let isValid = false;
         if (submittedDate > activityDate) {
             isValid = true;
         }
         else {
             this.notifyUser(
                 'Submit Error',
                 'An error occured while submitting: ' + this.SUBMITTED_DATE_ERROR,
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
         if (numAttendees > 0 && numDiscussions > 0) {
             isValid = true;
         }
         else {
             this.notifyUser(
                 'Submit Error',
                 'An error occured while submitting: ' + this.NUM_ATTENDEE_DISCUSSION_ERROR,
                 'error'
             );
             this.isSubmit = false;
             this.processing = false;
         }
         return isValid;
     }
 
     //Added by Mahendra SC-008860
     //display alert if the discussion item is selected without Adding Attendee while Saving the call
     checkForAttendeesAndDiscussionOnSave() {
 
         const numAttendees = this.template.querySelectorAll('c-lookup')[this.ATTENDEE_INDEX].getSelection().length;
         const numDiscussions = this.template.querySelectorAll('c-lookup')[this.DISCUSSION_INDEX].getSelection().length;
         if (numAttendees == 0 && numDiscussions > 0) {
             this.notifyUser(
                 'Warning',
                 'Alert: ' + this.SELECT_ATTENDEE_WARNING,
                 'warning'
             )
             this.isSubmit = false;
             //this.isConfirmed = false;
         }
 
     }
 
     //Added for SC-009405
     checkForTaskDueDate() {
         let isValid = true;
         //alert(this.profileName);
         if ((this.profileName == "US Inside Sales Manager") || (this.profileName == "US Inside Sales Rep")
             || (this.profileName == "US Small Animal Manager") || (this.profileName == "US Small Animal Rep")) {
             this.followUpActivities.forEach((task) => {
 
                 var callCreatedDate = new Date(getFieldValue(this.callRecord, CREATED_DATE_FIELD));
                 //alert ('callCreatedDate  udijnnf' + callCreatedDate);
                 if (callCreatedDate == 'Invalid Date') {
                     callCreatedDate = new Date();
                 }
                 var taskDueDate = new Date(task.activityDate);
                 //alert("fff taskDueDate->"+ taskDueDate);
                 //alert("ggg callCreatedDate->"+ callCreatedDate);
                 let milisecondsUntilTaskDueDate = taskDueDate - callCreatedDate;
                 let daysUntilTaskDueDate = this.calculateTimeInDays(milisecondsUntilTaskDueDate);
                 //alert ("milisecondsUntilTaskDueDate-->"+ milisecondsUntilTaskDueDate);
                 //alert ("daysUntilTaskDueDate-->"+ daysUntilTaskDueDate);

                 //Commented by Kishore -- TPDEV-1030

                 /* if (daysUntilTaskDueDate > this.TASK_CREATION_ALLOWED_DAYS) {
 
                     this.notifyUser(
                         'Submit Error',
                         'An error occured while submitting: ' + this.TASK_DUE_DATE_ERROR_MESSAGE,
                         'error'
                     );
                     this.isSubmit = false;
                     this.processing = false;
                     isValid = false;
 
                 } */
 
             });
 
         }
 
         return isValid;
 
     }
 
     //Added for SC-009405
     /*ValidateTaskSubjectLength(){
        if((this.profileName == "US Inside Sales Manager") || (this.profileName == "US Inside Sales Rep")
        ||(this.profileName == "US Small Animal Manager") || (this.profileName == "US Small Animal Rep"))
           {   
                this.followUpActivities.forEach( (task) => {
 
                    if(task.subject.length > 50)
                    {
                        this.notifyUser(
                            'Warning',
                            'Warning:'+ this.TASK_SUBJECT_LEN_EXCEEDED_MESSAGE,
                            'warning'
                        );
                    }
                });
            }  
        
        
     }*/
 
 
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
         if (closeOrRedirect == 'close') {
             this.closeQuickAction();
         }
         else if (closeOrRedirect == 'redirect') {
             this.navigateToRecord(redirectRecord);
         }
     }
     closeQuickAction() {
        if(this.profileName != "US Inside Sales Manager" && this.profileName != "US Inside Sales Rep"){ //TPDEV-722 stop refresh
           window.location.reload(); //This will refresh the page after update is made   TPDEV-722 Change by Pooja
        }else{
           eval("$A.get('e.force:refreshView').fire();");
        }
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
         },true);
     }
 
     // Changes done for SC-009936
     getCompetitor(event){
         const accountField = this.template.querySelector('.account-field');
         if (accountField.value) {
             this.isContactProcessing = true;
             const competitorParam = {
                 accountId: accountField.value
             };
             getCompetitors(competitorParam).then(results =>{
                 if(results){
                     var competitorResult = JSON.parse(results);
                     this.competitors.push(...competitorResult);
                     this.salesCall.competitors.push(...competitorResult);    
                 }
                 this.isContactProcessing = false;
             }).catch(error => {
                 this.isContactProcessing = false;
             });
         }
     }

     // Added as a part of TPDEV-732
     checkRxProduct(event){
         var selectedVal = event.target.value;
         
         if(selectedVal != null && selectedVal != undefined && selectedVal != ""
                            && !this.CATEGORIES_RQEUIRES_RX_PRODUCTS.includes(selectedVal)){
                                this.isProductVisible = true;
                            }else{
                                this.isProductVisible = false;
                            }
     }
 }