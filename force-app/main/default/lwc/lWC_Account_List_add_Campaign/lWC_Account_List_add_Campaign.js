import { LightningElement, wire } from 'lwc';
import { getListUi } from 'lightning/uiListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LWC_Account_List_add_Campaign extends LightningElement {
    @wire(getListUi, { listViewId: '00BF0000007GlWFMA0'})
    showToast() {
        const event = new ShowToastEvent({
            title: 'Get Help',
            message: 'Salesforce documentation is available in the app. Click ? in the upper-right corner.',
        });
        this.dispatchEvent(event);
    }
    
}