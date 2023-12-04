import { LightningElement,track,api } from 'lwc';

export default class AlphaChildSearchBarComp extends LightningElement {
        // properties...
    searchKeyword;
    @api isrequired = 'false';
    @api searchLabel = 'Look up Fieldname';

    @api reset() {
        this.template.querySelector('lightning-input').value = '';
    }

    // Check the to make lookup mandatory...
    renderedCallback() {
        if ( this.isrequired === "false" )
            return;
        if ( this.isrequired === "true") {
            let picklistInfo = this.template.querySelector('lightning-input');
            picklistInfo.required = true;
            //this.isrequired = "false";
        }
    }

    // This event will bubble up the search keyword into the parent comp...
    handleChange(event) {
        var keyword = event.target.value;
        
        if (keyword.length > 0) {
            let searchEvent = new CustomEvent('search',{
                detail : { value : keyword }
            });
            this.dispatchEvent(searchEvent);
        }
        else {
            let clearFieldEvent = new CustomEvent('clearfield');
            this.dispatchEvent(clearFieldEvent);
        }
    }
}