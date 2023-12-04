import { LightningElement,track,api,wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import {getRecord,updateRecord,generateRecordInputForUpdate,getFieldValue} from 'lightning/uiRecordApi';


export default class CoachingGuideRedirectLWC extends NavigationMixin(LightningElement) {

    @track loading;
    @api recordId;

    @wire(CurrentPageReference)
    wiredPageRef() {
        var retURL;
        var baseURL = 'https://zero.pitcher.com/coachingForm.php';
        if (typeof this.recordId !== 'undefined') {
            this.loading = true;
            retURL = baseURL.concat('?ID=',this.recordId);
        }
        else {
            this.loading = false;
            retURL = baseURL;
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: retURL
            },
        });
        this.closeQuickAction();
    }

    closeQuickAction() {
        if (this.loading){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.recordId,
                    objectApiName: 'PIT_Coaching_Guide__c',
                    actionName: 'view'
                }
            });
        }
        else {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'PIT_Coaching_Guide__c',
                    actionName: 'list'
                },
                state: {
                    filterName: 'Recent'
                }
            });
        }
        
    }

}