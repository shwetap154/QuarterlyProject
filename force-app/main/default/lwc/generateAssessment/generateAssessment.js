import { LightningElement, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import LOCAL_ASSESSMENT_METHOD from '@salesforce/apex/CaseAssessmentController.createLocalAssessment';
import PRODUCT_ASSESSMENT_METHOD from '@salesforce/apex/CaseAssessmentController.createProductAssessment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GenerateAssessment extends LightningElement 
{
    // using @wire to get the Case record ID
    @api recordId;
    loadSpinner = false;

    // When "Create Local Assessment" button is clicked
    handleClick_LA()
    {
        this.loadSpinner = true;
        LOCAL_ASSESSMENT_METHOD({caseIdVal: this.recordId})
        .then(result =>
            {
            if(result){
                eval("$A.get('e.force:refreshView').fire();");
                const event = new ShowToastEvent({
                    "variant": 'Success',
                    "title": "Success!",
                    "message": "Local Assessment record created.",
                });
                this.dispatchEvent(event);
            }
            else if(result === false)
			{
				//Displaying error message
				const event = new ShowToastEvent({
					"variant": 'error',
					"title": "Error!",
					"message": "Local Assessment are only created for Suspect Products. Please check if it already exists.",
				});
				this.dispatchEvent(event);
			}
            this.loadSpinner = false;
        })
        .catch(error =>
        {
            console.log('Error: ', error);
            this.loadSpinner = false;
        })
    }

    // When "Create Product Assessment" button is clicked
    handleClick_PA()
    {
        this.loadSpinner = true;
         PRODUCT_ASSESSMENT_METHOD({caseIdVal: this.recordId})
         .then(result =>
            {
                if(result)
                {
                    eval("$A.get('e.force:refreshView').fire();");
                    //Success message to display once the assessment record is created
                    const event = new ShowToastEvent({
                        "variant": 'Success',
                        "title": "Success!",
                        "message": "Product Assessment record created.",
                    });
                    this.dispatchEvent(event);
                }
                else if( result === null )
                {
                    //Displaying error message
                    const event = new ShowToastEvent({
                        "variant": 'error',
                        "title": "Error!",
                        "message": "Product Assesments are only created for Suspect Products. Please check if it already exists.",
                    });
                    this.dispatchEvent(event);
                }
                this.loadSpinner = false;
            })
         .catch(error =>
            {
             console.log('Error: ', error);
             this.loadSpinner = false;
         })
    }
}