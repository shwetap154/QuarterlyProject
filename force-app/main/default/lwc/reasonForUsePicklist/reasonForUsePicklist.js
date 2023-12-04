import { LightningElement, track, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getReasonsForUse from "@salesforce/apex/ZTS_CSESplitLOEReasons.getReasonsForUse";
import saveReasonForUse from "@salesforce/apex/ZTS_CSESplitLOEReasons.updateRelatedCaseProduct";

export default class ReasonForUsePicklist extends LightningElement 
{
    @api recordId;

    @track options;
    value = '';

    connectedCallback()
    {
        this.getReasonsForUseOptions();
    }

    getReasonsForUseOptions()
    {
        let theRecId = this.recordId;

        getReasonsForUse( { caseProductId: theRecId } )
            .then ( ( result ) => 
            {
                let picklistOptions = [];
                if ( result )
                {
                    result.forEach( aResult =>
                    {
                        picklistOptions.push( 
                            {
                                label: aResult, 
                                value: aResult
                            }
                        );
                    });

                    this.options = picklistOptions;
                }
            } )
            .catch( ( error ) => {
                console.error( 'error name: ' + error.name );
                console.error( 'error message: ' + error.message );
                console.error( 'error stack trace: ' + error.stack );
            });
    }

    handleSave()
    {
        let theRecId = this.recordId;

        saveReasonForUse( { caseProductId: theRecId, loeReason: null, reasonForUse: this.value } )
            .then( ( result ) => 
            {
                const evt = new ShowToastEvent( {
                    title: 'Success',
                    message: 'Reason for Use updated successfully',
                    variant: 'success'
                });

                this.dispatchEvent( evt );

                getRecordNotifyChange( [ { recordId: theRecId } ] );
            })
            .catch( error => 
            {
                console.error( 'error name: ' + error.name );
                console.error( 'error message: ' + error.message );
                console.error( 'error stack trace: ' + error.stack );

                const evt = new ShowToastEvent( {
                    title: 'Error',
                    message: 'Error updating Reason for Use',
                    variant: 'error' 
                });

                this.dispatchEvent( evt );
            });
    }

    @api
    get selectedValue()
    {
        return this.value;
    }

    set selectedValue( selectedVal )
    {
        this.value = selectedVal;
    }

    handleChange( event )
    {
        this.value = event.detail.value;
    }
}