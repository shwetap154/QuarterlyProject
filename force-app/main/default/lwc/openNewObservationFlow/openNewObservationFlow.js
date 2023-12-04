import { LightningElement,api,wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import {CurrentPageReference} from 'lightning/navigation';

export default class OpenNewObservationFlow extends NavigationMixin(LightningElement) {
  @api recordId;
  @api type;
  
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
        this.type = 'iDevelop_New_Observation';
        this[NavigationMixin.Navigate]({
          type: "standard__component",
          attributes: {
            componentName: "c__displayFlowAuraComponent"
          },
          state: {
          c__inputVariable: this.recordId,
          c__type: this.type
        }
        }); 
    }
  }
}