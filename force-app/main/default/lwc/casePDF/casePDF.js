import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class CasePDF extends NavigationMixin(LightningElement) {
    @api recordId;
    constructor() {
        super();
       
      }
      @wire(getRecord, { recordId: '$recordId' })
    connectedCallback(){
        
            console.log('recordId:', this.recordId); // prints 'recordId: undefined'
          
        this.navigateToVFPage();

    }
  /*  navigateToVFPage(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: "customTabName",
            },
            // query string parameters
            state: {
                c__showPanel: 'true' // Value must be a string
                
            }
        }).then(url => {
            window.open(url)
        });
    }*/
    //Navigate to visualforce page
    navigateToVFPage(event) {console.log('id ------'+this.recordId);
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/CasePDF?id=' + this.recordId
            }
            /*state :{
                RecordId : this.recordId
            }*/
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
      //  this.closeQuickAction();
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
   /*openVisualForcePage(event) 
    {

    const urlWithParameters = '/apex/YourVisualPageName?prop1=propval';
    console.log('urlWithParameters...'+urlWithParameters);
    this[NavigationMixin.Navigate]({
    type: 'standard__webPage',
    attributes: {
    url: urlWithParameters
    }
    }, false); //if you set true this will opens the new url in same window
    }*/
}