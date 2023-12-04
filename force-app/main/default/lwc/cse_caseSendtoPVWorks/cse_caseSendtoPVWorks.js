import { LightningElement, api, wire,track } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import SUCCESS_TEXT from '@salesforce/label/c.CSE_SendtoPVWorksText';
import ERROR_TEXT from '@salesforce/label/c.CSE_CaseType_Send_To_PVW';
import ID_FIELD from '@salesforce/schema/Case.Id';
import PV_WORKS_FIELD from '@salesforce/schema/Case.Send_to_PV_Works__c';
import APPROVED_FIELD from '@salesforce/schema/Case.ZTS_US_Approved__c';
import SYNC_STATUS_FIELD from '@salesforce/schema/Case.Sync_Status__c';
import FIRST_DATE_APPROVED_FIELD from '@salesforce/schema/Case.ZTS_US_DateFirstApproved__c'
import DATE_REAPPROVED_FIELD from '@salesforce/schema/Case.ZTS_US_DateReapproved__c'
import REVALIDATED_CASES from '@salesforce/schema/Case.Revalidated_Cases__c'
import RECORDTYPE from '@salesforce/schema/Case.RecordTypeId'
import TYPE from '@salesforce/schema/Case.Type'
import { loadStyle } from 'lightning/platformResourceLoader';
import CUSTOMCSS from '@salesforce/resourceUrl/cse_multiLineToast';
const fields = [ID_FIELD, SYNC_STATUS_FIELD,FIRST_DATE_APPROVED_FIELD, DATE_REAPPROVED_FIELD,RECORDTYPE,TYPE];
const today = new Date().toISOString();
const typeValue = 'Animal Complaint, Human Exposure, Product Defect Only'
const readySync = 'Ready to Sync with PV Works'
// importing to get the object info 
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// importing Case shcema
import CASE_Object from '@salesforce/schema/Case';
export default class CSE_SendtoPVWorks extends LightningElement {
    //the page sets the property to the ID of the current record.
    @api recordId;
    isExecuting = false;
    isCssLoaded = false;
    Animal_Support_RecordtypeId;

    //neeraj
    renderedCallback(){
        if(this.isCssLoaded) return
        this.isCssLoaded = true;
        loadStyle(this,CUSTOMCSS).then(()=>{
        console.log('loaded');
        })
        .catch(error=>{
        console.log('error to load');
        });
    }
    //neeraj end

    
    // object info using wire service
    @wire(getObjectInfo, { objectApiName: CASE_Object })
    caseObjectInfo({data, error}) {
        if(data) {
            const rtInfos = data.recordTypeInfos;
            // getting map values
            let rtValues = Object.values(rtInfos);
            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name == 'VMIPS') {
                  this.Animal_Support_RecordtypeId =rtValues[i].recordTypeId;
                }
            }
        }
        else if(error) {
            window.console.log('Error ===> '+JSON.stringify(error));
        }
    }

    //this uses the standard getRecord function to retrieve the record and it's relevant fields
    @wire(getRecord, { recordId: '$recordId', fields })
    case;

    buildMessageList(errors) {
    let messageList = '';
    errors.forEach(element => {
        messageList += element.message + '\n';
    });
    return messageList;
}   

    //invoke() is required for headless actions rest of the code is a normal handleclick()
    //made the function async so that it cannot be running more than once at a given moment
    @api async invoke() {
        let tempType = this.case.data.fields.Type.value;
        console.log("Inside this method = "+ tempType);


        if(typeValue.includes(tempType) && this.Animal_Support_RecordtypeId == this.case.data.fields.RecordTypeId.value){

            if (this.isExecuting) {
                return;
            }
            this.isExecuting = true;
            //check whether or not dates have been populated to see whether or not this is the first time the button has been pressed
            if(this.case.data.fields.ZTS_US_DateFirstApproved__c.value==null){
                console.log("Inside check date first approved method = ");

            //preparing fields so that they can be used by Salesforce's standard update method
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[SYNC_STATUS_FIELD.fieldApiName] = readySync;
                fields[FIRST_DATE_APPROVED_FIELD.fieldApiName] = today;
                const recordInput = { fields };
            //using the updateRecord method from the uiRecordApi and then using toastevents to display them
                updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            //custom label potentially
                            message: SUCCESS_TEXT,
                            variant: 'success'
                            //mode: 'sticky'    
                        })
                    );
                })
                .catch(error => {
                    console.log('in error catch'+ error.body.message);
                    console.log('OUTPUT error.body: ',error.body);

                    let messageList = this.buildMessageList(error.body.output.errors);
                    //messageList = messageList.replace('\n', '\n'); 
                    console.log('OUTPUT messageList: ',messageList);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: messageList,
                            // message: error.body.output.errors[0].message,
                            variant: 'error',
                            mode: 'sticky'    
                        })
                    );
                });
            //end of first button press update and beginning of functionality for subsequent button presses
            } else if(this.case.data.fields.Sync_Status__c.value != readySync){
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[SYNC_STATUS_FIELD.fieldApiName] = readySync;
                fields[DATE_REAPPROVED_FIELD.fieldApiName] = today;
                const recordInput = { fields };
                updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: SUCCESS_TEXT,
                            variant: 'success'
                            //mode: 'sticky'  
                        })
                    );
                })
                .catch(error => {
                    console.log('error.body.message'+error.body.message);
                    console.log('OUTPUT error.body: ',error.body);
                    let messageList = this.buildMessageList(error.body.output.errors);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: messageList,
                            // message: error.body.output.errors[0].message,
                            variant: 'error',
                            mode: 'sticky'    
                        })
                    );
                });
            }
        
        }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: ERROR_TEXT,
                        variant: 'error'
                        //mode: 'sticky'    
                    })
                );
        }
        this.isExecuting = false;
    }
}