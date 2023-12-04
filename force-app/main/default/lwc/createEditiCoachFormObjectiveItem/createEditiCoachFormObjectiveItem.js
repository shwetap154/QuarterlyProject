import { LightningElement, api, track, wire} from 'lwc';
import iDevelop_Learning from '@salesforce/label/c.iDevelop_Learning';
import iDevelop_Applying from '@salesforce/label/c.iDevelop_Applying';
import iDevelop_Mastery from '@salesforce/label/c.iDevelop_Mastery';
import Learning_Description from '@salesforce/label/c.Learning_Description';
import Applying_Description from '@salesforce/label/c.Applying_Description';
import Mastery_Description from '@salesforce/label/c.Mastery_Description';
import getCompetencies from '@salesforce/apex/createEditiCoachFormObjectiveController.getCompetencies';
import getSkills from '@salesforce/apex/createEditiCoachFormObjectiveController.getSkills';
import getPreviousScore from '@salesforce/apex/createEditiCoachFormObjectiveController.getPreviousScore';

export default class CreateEditiCoachFormObjectiveItem extends LightningElement {
    @api recordId;
    @api defaultValues;
    @api item;
    @api index;

    @api fetchItem() {
        var item = JSON.parse(JSON.stringify(this.item));
        item["iDevelop_Last_Benchmark_Rating__c"] = this.previousBenchMarkRating;
        item["Previous_iCoach_Form_Rating__c"] = this.previousiCoachFormRating;
        return item;
    }

    @api checkValidation() {
        const All_Compobox_Valid = [...this.template.querySelectorAll('lightning-combobox')]
            .reduce((validSoFar, input_Field_Reference) => {
                input_Field_Reference.reportValidity();
                return validSoFar && input_Field_Reference.checkValidity();
            }, true);

        return All_Compobox_Valid;
    }


    get competencyModel() { return this.defaultValues == null ? [] : [{ 'label': '-- NONE --', value: null }].concat(this.defaultValues.competencyModel); }
    get disableCompetencyDropdown() { return this.checkEmpty(this.item) || this.checkEmpty(this.item.Competency_Model__c); }
    get disableSkillDropdown() { return this.disableCompetencyDropdown || this.checkEmpty(this.item.Competency__c) || this.SkillArr == null || this.SkillArr.length === 0; }

    get requiredCompetencyDropdown() { return !this.disableCompetencyDropdown; }
    get requiredSkillDropdown() { return !this.disableCompetencyDropdown; }

    @track competencies = [];
    @track skills = [];
    Learningval = iDevelop_Learning;
    Applyingval = iDevelop_Applying;
    Masteryval = iDevelop_Mastery;
    Learning_Descriptionval = Learning_Description;
    Applying_Descriptionval = Applying_Description;
    Mastery_Descriptionval = Mastery_Description;
    @track SkillArr = [];

    previousiCoachFormRating;
    previousBenchMarkRating;
    previousiCoachandBenchRating;
    previousiCoachFormRatingClass;
    previousBenchMarkRatingClass;
    previousiCoachandBenchRatingClass;
    previousiCoachFormIndicatorClass;
    previousBenchMarkIndicatorClass;
    previousiCoachandBenchIndicatorClass;
    hideIcons = false;

    connectedCallback() {
        if (this.item != null) {
            this.item = JSON.parse(JSON.stringify(this.item));
            if (this.item.Competency__c) {
                this.loadCompetencies();
            }
            if (this.item.Skill__c) {
                this.loadSkills();
            }
        } else {
            this.item = {};
        }
    }

    get competencyModalId(){return this.item == null || this.item.Competency_Model__c == undefined ? null : this.item.Competency_Model__c;}
    get competencyId(){return this.item == null || this.item.Competency__c == undefined ? null : this.item.Competency__c;}
    get skillId(){return this.item == null || this.item.Skill__c == undefined ? null : this.item.Skill__c;}

    @wire(getPreviousScore, { recordId: '$recordId', 'competencyModalId': '$competencyModalId', 'competencyId': '$competencyId', 'skillId': '$skillId' })
    wiredData({ error, data }) {
        if (data) {
            this.previousBenchMarkRating = data.previousBenchMarkRating;
            this.previousiCoachFormRating = data.previousiCoachFormRating;  
            console.log('This is value benchmark', this.previousBenchMarkRating); 
            console.log('This is value icoach', this.previousiCoachFormRating); 
            this.previousBenchMarkRatingClass = this.determinePreviousScoreClass(data.previousBenchMarkRating) + ' previousiDevelopBenchmarkIndicator';
            this.previousiCoachFormRatingClass = this.determinePreviousScoreClass(data.previousiCoachFormRating) + ' previousIcoachFormIndicator';
            this.previousiCoachFormIndicatorClass = 'previousIcoachFormIndicator';
            this.previousBenchMarkIndicatorClass = 'previousiDevelopBenchmarkIndicator';
            // Check if previousBenchMarkRating and previousiCoachFormRating are the same
        if (this.previousBenchMarkRating === this.previousiCoachFormRating){
            this.previousiCoachandBenchRating = this.previousBenchMarkRating;
            this.previousiCoachandBenchRatingClass = this.determinePreviousScoreClass(this.previousiCoachandBenchRating) + ' previousiCoachAndiDevelopIndicator';
            this.previousiCoachandBenchIndicatorClass = 'previousiCoachAndiDevelopIndicator';
            this.previousiCoachFormIndicatorClass = 'previousIcoachFormIndicator' + ' hideAllIcons';
            this.previousBenchMarkIndicatorClass = 'previousiDevelopBenchmarkIndicator' + ' hideAllIcons';

        }
        else if(this.previousBenchMarkRating === undefined ) {
            // If they are not the same, hide the combined icon
            //this.previousiCoachandBenchRating = null;
            this.previousBenchMarkRatingClass = this.determinePreviousScoreClass(data.previousBenchMarkRating) + ' previousiDevelopBenchmarkIndicator' + ' hideAllIcons';
            this.previousiCoachandBenchRatingClass = this.determinePreviousScoreClass(this.previousiCoachandBenchRating) + ' previousiCoachAndiDevelopIndicator' + ' hideAllIcons';
            this.previousBenchMarkIndicatorClass = 'previousiDevelopBenchmarkIndicator' + ' hideAllIcons';
            this.previousiCoachandBenchIndicatorClass = 'previousiCoachAndiDevelopIndicator' + ' hideAllIcons';
        }
        else if(this.previousiCoachFormRating === undefined){
            this.previousiCoachFormRatingClass = this.determinePreviousScoreClass(data.previousiCoachFormRating) + ' previousIcoachFormIndicator' + ' hideAllIcons';
            this.previousiCoachandBenchRatingClass = this.determinePreviousScoreClass(this.previousiCoachandBenchRating) + ' previousiCoachAndiDevelopIndicator' + ' hideAllIcons';
            this.previousiCoachFormIndicatorClass = 'previousIcoachFormIndicator' + ' hideAllIcons';
            this.previousiCoachandBenchIndicatorClass = 'previousiCoachAndiDevelopIndicator' + ' hideAllIcons';

        }
        // Check if there are no previous scores
        if (this.previousBenchMarkRating === undefined && this.previousiCoachFormRating === undefined) {
            //this.hideIcons = true;
            this.previousBenchMarkRatingClass = this.determinePreviousScoreClass(data.previousBenchMarkRating) + ' previousiDevelopBenchmarkIndicator' + ' hideAllIcons';
            this.previousiCoachFormRatingClass = this.determinePreviousScoreClass(data.previousiCoachFormRating) + ' previousIcoachFormIndicator' + ' hideAllIcons';
            this.previousiCoachandBenchRatingClass = this.determinePreviousScoreClass(this.previousiCoachandBenchRating) + ' previousiCoachAndiDevelopIndicator' + ' hideAllIcons';
            this.previousiCoachFormIndicatorClass = 'previousIcoachFormIndicator' + ' hideAllIcons';
            this.previousiCoachandBenchIndicatorClass = 'previousiCoachAndiDevelopIndicator' + ' hideAllIcons';
            this.previousBenchMarkIndicatorClass = 'previousiDevelopBenchmarkIndicator' + ' hideAllIcons';
        } 

        } else if (error) {
            console.error('Error:', error);
        }
    }

    determinePreviousScoreClass(score){
        switch(score){
            case '1': 
            return 'learning-meter1padding';
            case '2':
            return 'learning-meter2padding';
            case '3':
            return 'learning-meter3padding';
            case '4':
            return 'applying-meter4padding';
            case '5':
            return 'applying-meter5padding';
            case '6':
            return 'applying-meter6padding';
            case '7':
            return 'mastery-meter7padding';
            case '8':
            return 'mastery-meter8padding';
            case '9':
            return 'mastery-meter9padding';

        }
    }


    handleDataChange(event) {
        var fieldName = event.currentTarget.dataset.id;
        var fieldValue = event.detail?.value;
        if (fieldName == 'Rating__c') {
            fieldValue = this.template.querySelector(`[data-id="Rating__c"]`).value;
            console.log('fieldValue :: ' + fieldValue);
        }
        var item = JSON.parse(JSON.stringify(this.item));
        item[fieldName] = fieldValue;
        this.item = item;
        if (fieldName == 'Competency_Model__c') {
            this.item.Competency__c = null;
            this.item.Skill__c = null;
            this.loadCompetencies();
            this.setSkills();
        } else if (fieldName == 'Competency__c') {
            this.item.Skill__c = null;
            this.loadSkills();
        } else if (fieldName == 'Skill__c') {
            this.setSkills();
        }
    }

    loadCompetencies() {
        getCompetencies({ competencyModelId: this.item.Competency_Model__c })
            .then(result => {
                this.competencies = [...result.map(item => ({
                    label: item.Name,
                    value: item.Id
                }))];
            })
            .catch(error => {
                console.error('Error fetching Competencies:', error);
            });
    }

    loadSkills() {
        getSkills({ competencyId: this.item.Competency__c })
            .then(result => {
                console.log('Skills result:', JSON.stringify(result));
                this.SkillArr = result.map(skill => ({
                    label: skill.Name__c,
                    value: skill.Id,
                    learningDescription: skill.Learning_Description__c,
                    masteryDescription: skill.Mastery_Description__c,
                    applyingDescription: skill.Applying_Description__c
                }));
                this.setSkills();
            })
            .catch(error => {
                console.error('Error fetching Skills:', error);
            });
    }

    setSkills() {
        if (this.SkillArr.length === 0) {
            this.skills = [
                {
                    learningDescription: this.item.Competency__r?.Learning_Description__c,
                    masteryDescription: this.item.Competency__r?.Mastery_Description__c,
                    applyingDescription: this.item.Competency__r?.Applying_Description__c
                }
            ];
        }
        else {
            this.skills = this.SkillArr.filter(skill => skill.value === this.item.Skill__c);

        }
    }

    checkEmpty(payload) {
        return payload == null || payload == '';
    }
}