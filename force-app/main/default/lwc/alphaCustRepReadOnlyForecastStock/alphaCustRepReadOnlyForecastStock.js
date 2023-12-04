import { LightningElement,track,api } from 'lwc';


export default class AlphaCustRepReadOnlyForecastStock extends LightningElement
{
    @api objName = '';
    @track selAccRecord = '';
    @track selAccRecordId = '';

    handleAccChange(event){
       this.selAccRecord  = JSON.parse(JSON.stringify(event.detail.selectedRecordId));
       this.selAccRecordId = this.selAccRecord.Id
    }
}