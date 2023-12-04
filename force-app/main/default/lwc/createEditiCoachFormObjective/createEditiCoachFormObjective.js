import { LightningElement, api, track, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCompetencyModels from '@salesforce/apex/createEditiCoachFormObjectiveController.getCompetencyModels';
import saveiCoachFormObjectiveRecord from '@salesforce/apex/createEditiCoachFormObjectiveController.saveiCoachFormObjectiveRecord';
import getRelatedObjectives from '@salesforce/apex/createEditiCoachFormObjectiveController.getRelatedObjectives';
import { refreshApex } from '@salesforce/apex';


export default class CreateEditiCoachFormObjective extends NavigationMixin(LightningElement) {
  @api recordId;
  @track data = [];

  @track competencyModel = [];
  @track payload = {};

  @api iFormCoachId;
  @track loading = false;
  @track isEditMode = true;
  showValidationError = false;
  @api formId;

  get defaultValues() {
    return {
      'competencyModel': this.competencyModel
    };
  }

  connectedCallback() {
    this.data = [];
    this.refresh();
  } 

  wiredData_getRelatedObjectives_result;
  @wire(getRelatedObjectives, { recorId: '$recordId' })
  wiredData_getRelatedObjectives(result) {
    this.wiredData_getRelatedObjectives_result = result;
    if (result.data) {
      var defaultDataRow = { 'iCoach_Form__c': this.recordId };
      var defaultData = [defaultDataRow, defaultDataRow];
      var resultList = JSON.parse(JSON.stringify(result.data));
      resultList.forEach(function (currentItem, index) {
        defaultData[index] = currentItem;
      });
      this.data = JSON.parse(JSON.stringify(defaultData));
    } else if (result.error) {
      var defaultDataRow = { 'iCoach_Form__c': this.recordId };
      var defaultData = [defaultDataRow, defaultDataRow];
      this.data = JSON.parse(JSON.stringify(defaultData));
      console.error(result.error);
    }
  }
  
  wiredData_getCompetencyModels_result;
  @wire(getCompetencyModels, { iCoachFormId: '$recordId' })
  wiredData_getCompetencyModels(result) {
    this.wiredData_getCompetencyModels_result = result;
    if (result.data) {
      this.competencyModel = result.data.map(item => ({
          label: item.competencyModelName,
          value: item.Id
        }))
    } else if (result.error) {
       console.error('Error getCompetencyModels :', result.error);
    }
  }

  refresh(){
     refreshApex(this.wiredData_getRelatedObjectives_result);
     refreshApex(this.wiredData_getCompetencyModels_result);
  }

  // Save button for create 
  handleSave() {

    var items = this.template.querySelectorAll('c-create-editi-coach-form-objective-item');
    if (items != null) {
      var isAllValid = true;
      var isDupFound = false;
      var upsertItemList = [];
      var deleteItemList = [];
      var keys = [];
      items.forEach(itemAtt => {
        var isValid = itemAtt.checkValidation();
        isAllValid = !isAllValid || !isValid ? false : true;
        var item = itemAtt.fetchItem();
        if (item.Competency_Model__c != null) {
          upsertItemList.push(item);
          var key = item.Competency_Model__c + '~' + item.Competency__c + '~' + item.Skill__c;
          if (!keys.includes(key)) {
            keys.push(key);
          } else {
            isDupFound = true;
          }
        } else if (item.Id != null) {
          deleteItemList.push(item);
        }
      });

      if (isDupFound) {
        this.showToast('warning', '', 'Please add all unique skills.');
      } else if (isAllValid) {
        this.loading = true;
        saveiCoachFormObjectiveRecord({ 'upsertPayload': JSON.stringify(upsertItemList), 'deletePayload': JSON.stringify(deleteItemList) })
          .then(result => {
            this.refresh();
            this.loading = false;
            this.showToast('success', '', 'iCoach Form Objectives record successfully updated');
            this.redirectToRecord();
          })
          .catch(error => {
            this.loading = false;
            var messages = [];
            if (error != null && error.body != null && error.body.pageErrors != null) {
              error.body.pageErrors.forEach(er => {
                messages.push(er.message);
              });
            } else {
              messages.push('Something went wrong.');
            }
            this.showToast('error', '', messages.join(' '));
            console.error('Error:', error);
          });
      } else {
        this.showToast('warning', '', 'Please fill all required fields.');
      }
    }
  }

  handleCancel() {
    this.redirectToRecord();
  }

  redirectToRecord() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordPage',
      attributes: {
        recordId: this.recordId,
        actionName: 'view'
      },
    });
  }


  showToast(variant, title, message) {
    const showtoast = new ShowToastEvent({
      tite: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(showtoast);
  }

}