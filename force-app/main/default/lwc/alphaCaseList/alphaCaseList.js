import { LightningElement,track,api} from 'lwc';
import getCaseList from '@salesforce/apex/alphaCaseHandler.getCaseList';

const columnsWithHeaders = [
    { label: 'Account Name', fieldName: 'AccountName'},
    { label: 'Case Type', fieldName: 'Case_Type__c'},
    { label: 'Subject', fieldName: 'Subject'},
    { label: 'Description', fieldName: 'Description' },
    { label: 'Submitted By', fieldName: 'Created_By__c' },
    { label: 'Submission Date', fieldName: 'createddate' }
   
];

export default class AlphaCaseList extends LightningElement {

    columns = columnsWithHeaders;
    @track finalresult = [];
    @api objName;
    @api accRecord = '';
    @track selAccRecord = '';
    @track selAccRecordId = '';

    handleAccChange(event){
       this.selAccRecord  = JSON.parse(JSON.stringify(event.detail.selectedRecordId));
       this.selAccRecordId = this.selAccRecord.Id
        this.loadData()
    }

    connectedCallback(){
         this.loadData()
    }

    loadData(){
        getCaseList({accountId:this.selAccRecordId})
        .then((result)=>{
            console.log('Result>>>',result)
            this.finalresult = result.map((item)=>{
                  return {
                      AccountName :item.Account.Name,
                      Case_Type__c :item.Case_Type__c,
                      Subject :item.Subject,
                      Description:item.Description,
                      createddate:item.CreatedDate,
                      Created_By__c:item.Created_By__c
                  }
            });
            console.log(this.finalresult)
        })
        .catch((err)=>{
            console.log(err);
        })
    }

}