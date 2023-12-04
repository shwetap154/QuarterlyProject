import { LightningElement,api,track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getCompetencySkills from '@salesforce/apex/ScoreCompetencyandSkillsController.getCompetencySkills';
import getObservedRecords from '@salesforce/apex/ScoreCompetencyandSkillsController.getObservedRecords';

export default class LwcToFlowDemo extends LightningElement {
    @api records = [];
    @api testString;
    @api lstObserCompSkill = [];
    lstCompSkill = [];

    connectedCallback() {
        getCompetencySkills({ records: this.records })
            .then((result) => {
                this.lstCompSkill = result;
                this.error = undefined;
                console.log('Competencies/Skills: ' + result);
            })
            .catch((error) => {
                this.error = error;
                this.lstCompSkill = undefined;
            });     
    }
    
    @api
    validate() {
        console.log('<--- Begin Validate Function --->')
        this.testString = 'Hello World';
        console.log('testString --> ' + this.testString);

        getObservedRecords({lstFnlCompSkill: this.lstCompSkill, records: this.records})
            .then((result) => {
                this.lstObserCompSkill = result;
                console.log('getObservedRecords result---> ' + this.lstObserCompSkill);
            })
            .then(() => {
                const flowChangeEvent = new FlowAttributeChangeEvent('testString', this.testString);
                this.dispatchEvent(flowChangeEvent);

                const flowChangeEvent2 = new FlowAttributeChangeEvent('lstObserCompSkill', this.lstObserCompSkill);
                this.dispatchEvent(flowChangeEvent2);
            })

        return { isValid: true };
    }
}