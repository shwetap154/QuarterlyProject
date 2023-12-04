/**
Name	        : IDevelop_select_Lessons.js
Description	    : JS file created as part of  IDevelop_select_Lessons LWC for TPDEV-59. 
Created By		: Sibin Kuriakose
Created Date	: 04-24-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				04-24-2023	 Created methods to retrive values for showing Recommended Learnings
*/

import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';
import getRecommendedLessons from '@salesforce/apex/IDevelop_select_Lessons_controller.getRecommendedLessons';
import Lesson_Selection from '@salesforce/label/c.Lesson_Selection';
import Lesson_Name from '@salesforce/label/c.Lesson_Name';
import Lesson_Description from '@salesforce/label/c.Lesson_Description';
import Lesson_URL from '@salesforce/label/c.Lesson_URL';
import iDevelop_Recommended_e_learnings from '@salesforce/label/c.iDevelop_Recommended_e_learnings';

export default class IDevelop_select_Lessons extends LightningElement {
    
    @api lstObscomprecords = [];
    @api lstBenchmark = [];
    @api lstUser = [];
    @api lstdelLessons;
    @api lstinsLessons;    
    @api recomLessons = [];
    @api lsttempdelLessons;
    @api lsttempinsLessons;
    lstdelete = [];
    Recommended_learnings = iDevelop_Recommended_e_learnings;
    records = [];
    LessonSelection = Lesson_Selection;
    LessonName = Lesson_Name;
    LessonDescription = Lesson_Description;
    LessonURL = Lesson_URL;

    connectedCallback(){
       
        //calling Method to get List of Records to be Displayed in Flow
        getRecommendedLessons({ lstObscomprecords: this.lstObscomprecords, lstBenchmark: this.lstBenchmark, lstUser: this.lstUser })
        .then((result) => {
            this.recomLessons = result;
            if(result.length == 0){
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }
            this.error = undefined;
            var tempbool = '';
            for (let i = 0; i < result.length; i++) {
                for (let j = 0; j < result[i].lstcompLesson.length; j++) {
                    this.records.push({id: result[i].lstcompLesson[j].recordId, check: tempbool});
                }
            }
        })
        .catch((error) => {
            this.error = error;
            this.recomLessons = undefined;
        }); 
    }

    //Event handler to Assign Scores and Pass Value back to Flow
    handleChange(event) {
        var divId = event.target.id;
        this.myValue = event.target.checked;
        var tempval = this.myValue;
        divId = divId.substr(0,18);
        var upd_obj=0;
        
        upd_obj = this.records.findIndex((obj => obj.id == divId));
        this.records[upd_obj].check = tempval;
    }

    
    //method to validate the selections
    @api
    validate() {
        this.lstinsLessons = [];
        this.lstdelLessons = [];

        for(var i=0; i < this.recomLessons.length; i++){
            for(var j=0; j < this.recomLessons[i].lstcompLesson.length; j++){
                var upd_obj = this.records.findIndex((obj => obj.id == this.recomLessons[i].lstcompLesson[j].recordId));
                if(this.records[upd_obj].check == false && this.records[upd_obj].check !== '' && this.recomLessons[i].lstcompLesson[j].checked == true){
                    this.lstdelLessons.push({Id : this.records[upd_obj].id});
                }
                else if(this.records[upd_obj].check == true){
                    this.lstinsLessons.push({Lesson_Template__c : this.recomLessons[i].lstcompLesson[j].recordId, Name : this.recomLessons[i].lstcompLesson[j].name, Observed_Competency__c : this.recomLessons[i].lstcompLesson[j].ObsCompId});
                }
            }
        }
        const attributeChangeEvent2 = new FlowAttributeChangeEvent('lstdelLessons', this.lstdelLessons);
        this.dispatchEvent(attributeChangeEvent2);

        const attributeChangeEvent1 = new FlowAttributeChangeEvent('lstinsLessons', this.lstinsLessons);
        this.dispatchEvent(attributeChangeEvent1);
    }
}