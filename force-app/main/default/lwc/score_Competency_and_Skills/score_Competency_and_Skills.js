/**
Name	        : ScoreCompetencyandSkills.js
Description	    : JS file created as part of  Score_Competency_and_Skills LWC for TPDEV-59. 
Created By		: Sibin Kuriakose
Created Date	: 03-13-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-13-2023	 Created methods to retrive values to Create Observed Competencies and Score them
02   Sweta Kumari               08-11-2023   If I go back and I am not brought to my ratings but to the initial screen with the explanatory text and all my ratings have gone for TPDEV-1634. 
*/

import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Score_Skill_Competency_validation from '@salesforce/label/c.Score_Skill_Competency_validation';
import score_competency_Accordion_error from '@salesforce/label/c.score_competency_Accordion_error';
import iDevelop_Learning from '@salesforce/label/c.iDevelop_Learning';
import iDevelop_Applying from '@salesforce/label/c.iDevelop_Applying';
import iDevelop_Mastery from '@salesforce/label/c.iDevelop_Mastery';
import Learning_Description from '@salesforce/label/c.Learning_Description';
import Applying_Description from '@salesforce/label/c.Applying_Description';
import Mastery_Description from '@salesforce/label/c.Mastery_Description';
import Next from '@salesforce/label/c.Next';
import Previous from '@salesforce/label/c.Previous';
import getCompetencySkills from '@salesforce/apex/ScoreCompetencyandSkillsController.getCompetencySkills';
import getObservedRecords from '@salesforce/apex/ScoreCompetencyandSkillsController.getObservedRecords';

export default class Score_Competency_and_Skills extends LightningElement {

    @api records = [];
    @api lstObserCompSkill;
    recordid = [];
    display = [];
    lstFnlCompSkill;
    lstCompSkill = [];
    temp = [];
    @track activeSections = '';
    previousopensection;
    compskillbyName = {};
    @api counter;
    show_next = false;
    Learningval = iDevelop_Learning;
    Applyingval = iDevelop_Applying;
    Masteryval = iDevelop_Mastery;
    Learning_Descriptionval = Learning_Description;
    Applying_Descriptionval = Applying_Description;
    Mastery_Descriptionval = Mastery_Description;
    next = Next;
    previous = Previous;
    tempscore = 0;
    comSkillScore = {};

    //Created contructor   
    constructor() {
        super();
    }

    connectedCallback() {
        debugger;
        // To get the previous scored values on clicking previous button in the flow
        if(this.lstObserCompSkill){
            this.lstObserCompSkill.forEach((currentValue)=> {this.comSkillScore[currentValue.Skill__c ? currentValue.Skill__c : currentValue.Competency__c]=currentValue.Score__c});
        }
        getCompetencySkills({ records: this.records })
            .then((result) => {
                this.lstCompSkill = result.map(v => ({ ...v, Score__c: 1 }))  //mapping the Score__c in lstCompSkill with value 1
                this.lstFnlCompSkill = this.lstCompSkill;
                this.error = undefined;
                for (let i = 0; i < result.length; i++) {
                    this.recordid.push({ id: result[i].Id, score: this.tempscore });
                }
                for (let i = 0; i < this.lstCompSkill.length; i++) {
                    for (let j = 0; j < this.lstFnlCompSkill.length; j++) {
                        if (this.lstCompSkill[i].Id === this.lstFnlCompSkill[j].Id) {
                            let col = this.lstFnlCompSkill[j].Name;
                            if (this.lstFnlCompSkill[j].Competency__c.length > 0) {
                                col = this.lstFnlCompSkill[j].Competency__c + ' : ' + this.lstFnlCompSkill[j].Name__c;
                            }
                            this.lstCompSkill = this.lstCompSkill.map(row => ({
                                ...row,
                                Name: col,
                                cssClass: i === 0 ? 'accordion' : 'ui-state-disabled',
                                Score__c: this.comSkillScore[row.Id] || row.Score__c
                            }));
                            this.display[i] = this.lstCompSkill[i];
                        }
                    }
                }
                this.lstCompSkill = this.display;
                this.activeSections = this.lstCompSkill[0].Name;
                this.previousopensection = this.lstCompSkill[0].Name;
                this.lstCompSkill.forEach(currentItem => {
                this.compskillbyName[currentItem.Name] = currentItem;
                });
            })
            .catch((error) => {
                this.error = error;
                this.lstCompSkill = undefined;
            });
    }

    //Event handler to Assign Scores and Pass Value back to Flow
    handleChange(event) {
        var divId = event.target.id;
        this.myValue = event.target.value;
        var tempval = this.myValue;
        var upd_obj = 0;
        if (divId != 0) {
            upd_obj = this.recordid.findIndex((obj => obj.id === divId.substr(0, 18)));
            this.recordid[upd_obj].score = tempval;
        }
        this.counter = 0;
        for (var i = 0; i < this.recordid.length; i++) {
            if (this.recordid[i].score > 0) {
                this.counter = this.counter + 1;
            }
        }
        if (this.counter === this.lstFnlCompSkill.length) {
            getObservedRecords({ lstFnlCompSkill: this.lstFnlCompSkill, records: this.records })
                .then((result) => {
                    this.lstObserCompSkill = [];
                    for (var i = 0; i < result.length; i++) {
                        this.temp[i] = result[i];
                        for (var j = 0; j < this.recordid.length; j++) {
                            if (this.recordid[j].id === this.temp[i].Id) {
                                this.temp = this.temp.map(row => ({
                                    ...row,
                                    Score__c: this.recordid[j].score
                                }));
                            }
                        }
                        this.lstObserCompSkill[i] = this.temp[i];
                    }
                    //Navigating to Next Page if the last Competency/Skill is scored and clicked Next
                    if (this.show_next === true && this.show_next !== false) {
                        this.handleNextMethod();
                    }
                    })
        }
    }

    //method to hadle click of button and activate accordion
    handleclick(event) {
        var check = false;
        var divId = event.target.id;
        divId = divId.substr(0, 18);
        for (var i = 0; i < this.recordid.length; i++) {
            if (this.recordid[i].id === divId) {
                if (!this.recordid[i].score) {
                    event.target.value = this.comSkillScore[this.recordid[i].id] || 1;
                    this.handleChange(event);
                }
                
                if (i + 1 < this.lstCompSkill.length) {
                    this.activeSections = this.lstCompSkill[i + 1].Name;
                    this.lstCompSkill[i + 1].cssClass = 'accordion';
                }
                check = true;
            }
        }
        if (check === true && this.counter === this.lstCompSkill.length) {
            this.show_next = true;
            event.target.id = 0;
            this.handleChange(event); 
        }
    }

    //Method called after scoring last Competency/Skill and clicking Next button
    handleNextMethod() {
        const attributeChangeEvent = new FlowAttributeChangeEvent('lstObserCompSkill', this.lstObserCompSkill);
        this.dispatchEvent(attributeChangeEvent);
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    //Method to handle toggle Action on Accordion
    handleSectionToggle(event) {
        const self = this;
        const opensection = event.detail.openSections;
        const compskill = this.compskillbyName[opensection];
        if (compskill.cssClass.indexOf('ui-state-disabled') !== -1) {
            this.activeSections = this.previousopensection;
            self.template.querySelector('.competency-accordion').activeSectionName = this.previousopensection;
            this.handleToast();
        }
        else {
            this.previousopensection = this.activeSections;
        }
    }

    //method to navigate to Previous page
    handlePrevious() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    //method to show Toast Warning
    handleToast() {
        const event = new ShowToastEvent({
            title: "Error",
            message: score_competency_Accordion_error,
            variant: "error"
        });
        this.dispatchEvent(event);
    }

    //method to validate if all Observed Competencies are Scored
    @api
    validate() {
        var counter = 0;
        for (var i = 0; i < this.recordid.length; i++) {
            if (this.recordid[i].score > 0) {
                counter = counter + 1;
            }
        }
        if (counter === this.recordid.length) {
            return { isValid: true };
        }
        else {
            return {
                isValid: false,
                errorMessage: Score_Skill_Competency_validation
            };
        }
    }
}