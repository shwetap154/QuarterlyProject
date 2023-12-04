import { LightningElement,api, wire,track } from 'lwc';
import searchActionplan from '@salesforce/apex/CreateEditActionPlanController.getActionPlanById';
import getRelatedFilesMap from '@salesforce/apex/CreateEditActionPlanController.getRelatedFilesByRecordId';
import updateAccountPlanRecords from '@salesforce/apex/CreateEditActionPlanController.updateActionPlanRecords'
import I_COACH_FORM_STATUS_FIELD from '@salesforce/schema/Action_Plan__c.iCoach_Form__r.Status__c';
import I_COACH_FORM_FIELD from '@salesforce/schema/Action_Plan__c.iCoach_Form__c';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import {NavigationMixin} from 'lightning/navigation'
import { getObjectInfos } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ACTIONPLANOBJECT from '@salesforce/schema/Action_Plan__c';
import iCoachFormOBJECT from '@salesforce/schema/iCoach_Form__c';
import CreateActionPlanError from '@salesforce/label/c.iCoachActionPlanCreateError';
import CreatActionPlanOnlyOniCoachForm from '@salesforce/label/c.iCoachActionPlanCreatesOnlyOniCoachForm';

const fields = [I_COACH_FORM_STATUS_FIELD,I_COACH_FORM_FIELD];
const richTextMap=new Map();
const dateFieldMap=new Map();
export default class CreateEditActionPlan extends NavigationMixin  (LightningElement) {
    @api recordId;
    @api isCreated;
    @track isFileUploaded=false;
    @track listrecordId = null;
    filesList = {};
    @track filesListNew;
    @track searchData=[];
    actionPlanByIds={};
    errorMsg = '';
    relatedFiles;
    objectApiName = 'Action_Plan__c';
    competencyLabel= 'DefaultCompetency';
    competencyModelLabel='DefaultCompetencyModel';
    skillLabel = 'DefaultSkill';
    ratingLabel = 'DefaultRating';
    actionLabel ='DefaultAction';
    toBeCompletedDateFieldLabel = 'DefaultToBeCompleted';
    label ={CreateActionPlanError};
    icoachformId;
    dateFieldValue;
    richTextValue;

    @wire(getRecord, { recordId: '$recordId', fields }) record({ error, data }){
        if (data) {
            this.icoachformId = getFieldValue(data,I_COACH_FORM_FIELD);
            console.log('>>> I_COACH_FORM_STATUS_FIELD... ' + getFieldValue(data, I_COACH_FORM_STATUS_FIELD));
            if((getFieldValue(data, I_COACH_FORM_STATUS_FIELD) ==='Submitted') ||(getFieldValue(data, I_COACH_FORM_STATUS_FIELD)==='Completed'&& this.isCreated===true )){
                this.ShowToast('Error',CreateActionPlanError,'error','dismissable');
                this.dispatchEvent(event);
                this.navigateToiCoachForm(this.icoachformId);
                return;
            } 
        }
        
    }
    connectedCallback() {
        console.log('Connected Callback is called')
        console.log('this.iscreated :'+ this.isCreated)
        console.log('this.recordId.Status__c :'+ this.recordId)
        if (this.isCreated) {
            //this.isCreated=true;
            this.ShowToast('Error',CreateActionPlanError,'error','dismissable');
            window.history.back();
            return;

        }
    }



     @wire(getObjectInfos, {
            objectApiNames: [ACTIONPLANOBJECT,iCoachFormOBJECT]
        })
        wireObjInfos({
            data,
            error
        }){
            if (data && data.results) {
                let objectInfo = data.results.reduce((map, obj) => (map[obj.result.apiName] = obj, map), {});
                const actionPlanFields = objectInfo['Action_Plan__c'].result.fields;
                const iCoachformKeyPreFix = objectInfo['iCoach_Form__c'].result.keyPrefix;
                if (this.isCreated && this.recordId && !this.recordId.startsWith(iCoachformKeyPreFix)) {
                        const error = new ShowToastEvent({
                            title: 'Error',
                            message:CreatActionPlanOnlyOniCoachForm,
                            variant: 'Error',
                        });
                    this.dispatchEvent(error);
                    window.history.back();
                }
                for (const field in actionPlanFields) {
                    console.log('field API Name = ' + field + ' ,label = ' , actionPlanFields[field].label);
                    if(field==='Competency__c'){
                        this.competencyLabel=actionPlanFields[field].label;
                    }
                    if(field==='Competency_Model__c'){
                        this.competencyModelLabel=actionPlanFields[field].label;
                    }
                    if(field==='Skill__c'){
                        this.skillLabel=actionPlanFields[field].label;
                    }
                    if(field==='Rating__c'){
                        this.ratingLabel=actionPlanFields[field].label;
                    }
                    if(field==='Action__c'){
                        this.actionLabel=actionPlanFields[field].label;
                    }
                    if(field==='To_Be_Completed__c'){
                        this.toBeCompletedDateFieldLabel=actionPlanFields[field].label;
                    }
                }

            }else if(error){
                //handleError
            }
        }

   @wire(searchActionplan, { actionplanId: '$recordId' })
    actionPlanData({ error, data}) {
        console.log('actionPlanData is called');
        if (data) {
            console.log('this.searchData'+JSON.stringify(data));
            this.searchData=[];
            data.forEach((record)=>{
                let parsedRecord = {};
                Reflect.ownKeys(record).forEach((key)=>{
                    parsedRecord[key]= record[key];
                });

                this.searchData.push(parsedRecord);
            });
            console.log('this.searchData'+JSON.stringify(this.searchData));
            this.searchData.forEach((record)=>this.actionPlanByIds[record.Id]=record);
            this.listrecordId = []
            for (var i=0; i<data.length; i++){
                this.listrecordId.push(data[i].Id);
            }
            console.log('this.listrecordId'+this.listrecordId);
            if(this.listrecordId.length > 0)
                this.getRelatedFiles();
        } else if (error) {
            this.errorMsg = error.message
        } 
    }
    //removed the wired property function and make it as imparative function because we need to refresh particular section data so we can call it whenever require to calling.
    getRelatedFiles(){
        getRelatedFilesMap({recordIds: this.listrecordId}).then(data=>{
            console.log('relatedFilesResult is called'+this.listrecordId);
            if (data) {
                this.actiondata = data;
                const self=this;
                Object.keys(this.actiondata).forEach((recordId) => {
                    self.actionPlanByIds[recordId].filesList = self.actiondata[recordId].map(file=> ({
                        "label":file.Title,
                        "value": file.Id,
                        "url":file.LatestPublishedVersion
                    }));
                })
                this.isFileUploaded=false; 
            }
        })
    }

    navigateToiCoachForm(recordId)
    {
        this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId:recordId,
                        objectApiName: 'iCoach_Form__c',
                        actionName: 'view'
                    }
                });
                console.log('recordId '+ this.recordId);
    }
    handleRichTextChange(event) {
        if(event.target.name == 'action'){
            this.richTextValue = event.target.value;
            richTextMap.set(event.target.dataset.id,event.target.value);
        }
        if(event.target.name == 'date'){
            dateFieldMap.set(event.target.dataset.id,event.target.value);
        }

    }

    handleUploadFinished(event) {// Get the list of uploaded files
        this.isFileUploaded=true;
        this.recordId = this.recordId;
        this.getRelatedFiles();
        console.log('this.recordId in upload'+this.recordId);
    } 


    handleClickSubmit(event){
        
        var outputArray = [];
        // Iterate through keys in richTextMap
        richTextMap.forEach((value1, key) => {
            // Check if the key is present in oldmap
            if (dateFieldMap.has(key)) {
                // If present in both maps, add an object to the output array
                outputArray.push({ id: key, value: value1, dateValue: dateFieldMap.get(key) });
            } else {
                // If key is only present in richTextMap, add an object with an empty string for 'dateValue'
                outputArray.push({ id: key, value: value1, dateValue: '' });
            }
        });

        // Iterate through keys in oldmap
        dateFieldMap.forEach((value1, key) => {
            // Check if the key is missing in newmap
            if (!richTextMap.has(key)) {
                // If key is only present in dateFieldMap, add an object with an empty string for 'actionvalue'
                outputArray.push({ id: key, value: '', dateValue: value1 });
            }
        });

        console.log(outputArray)

        updateAccountPlanRecords({jsonString : JSON.stringify(outputArray)}).then(result=>{
            this.ShowToast('Success','Records Updated Successfully', 'success','dismissable');
            this.navigateToiCoachForm(this.icoachformId);
        }).catch(error=>{
            console.log('line253>>'+JSON.stringify(error));
        })
    }
    handleRefresh(event){
        this.isFileUploaded=true;
        this.getRelatedFiles();
    }

    ShowToast(title,msg,variant,mode){
        const evt=new ShowToastEvent({
            title : title,
            message : msg,
            variant : variant,
            mode : mode
        })
        this.dispatchEvent(evt);
    }
}