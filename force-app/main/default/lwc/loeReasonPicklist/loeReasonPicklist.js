import { LightningElement, track, api } from 'lwc';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import getLOEReasons from "@salesforce/apex/ZTS_CSESplitLOEReasons.getLoeReasons";
import saveLOEReason from "@salesforce/apex/ZTS_CSESplitLOEReasons.updateRelatedCaseProduct";

export default class LoeReasonPicklist extends LightningElement 
{
    @api recordId;

    @track options;
    value = '';

    connectedCallback()
    {
        this.getLOEReasonOptions();
    }

    getLOEReasonOptions()
    {
        let theRecId = this.recordId;
        
        console.log( 'record id: ' + theRecId );

        getLOEReasons( { caseProductId: theRecId } )
            .then( ( result ) =>
            {
                console.log( 'result: ', result );
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
                }
                this.options = picklistOptions;
            } )
            .catch( ( error ) => 
            {
                console.error( 'error name: ' + error.name );
                console.error( 'error message: ' + error.message );
                console.error( 'error stack trace: ' + error.stack );
            });
    
    }

    handleSave()
    {
        let theRecId = this.recordId;
        console.log( 'selected value: ' + this.value );
        saveLOEReason( { caseProductId: theRecId, loeReason: this.value, reasonForUse: null })
            .then( ( result ) => 
            {
                const evt = new ShowToastEvent( {
                    title: 'Success',
                    message: 'LOE Reason updated successfully',
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
                    message: 'Error updating LOE Reason',
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
        console.log( 'handle the change: ', event.detail.value );
        this.value = event.detail.value;
    }

}