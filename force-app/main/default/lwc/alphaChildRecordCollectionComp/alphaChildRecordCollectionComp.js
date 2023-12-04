import { LightningElement,api } from 'lwc';

export default class AlphaChildRecordCollectionComp extends LightningElement {
    @api rec;
    @api iconname = 'standard:account';

    //identifies the selected record from the list..
    handleSelect() {
        let selectEvent = new CustomEvent('select',{
            detail : { selRec : this.rec }
        });
        this.dispatchEvent( selectEvent );
    }
}