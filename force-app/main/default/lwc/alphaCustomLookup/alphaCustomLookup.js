import { LightningElement,api,track } from 'lwc';
import findRecords from '@salesforce/apex/UtilityController.findRecords';
import findProducts from '@salesforce/apex/UtilityController.returnProdList';


export default class AlphaCustomLookup extends LightningElement {
       // public property with default value 
      
    @api objectName = 'Account';
    @api fieldName  = 'Name';
    @api iconname   = 'standard:record';
    @api label      = 'Account';
    

    // private property 
    @track records;
    @api selectedRecord = '';
    @api disabled = false;
    prodRecords;
    @api excludeRecordIds;
    

    connectedCallback()
    { 
       
        if(this.objectName == 'Product2')
        {
            this.doProdSearch();
        }
    }
    //this method calls apex method and gets the data..
    handleSearch(event) {

        let searchVal = event.detail.value;

        if(this.objectName == 'Product2')
        {
            this.records = [];
            for(let i=0; i < this.prodRecords.length; i++)
                {       
                          if(this.prodRecords[i].Name.startsWith(searchVal.toUpperCase()))
                    {
                        this.records.push({ Id: this.prodRecords[i].Id,Name:this.prodRecords[i].Name});
                   
                    }                    
                }
        }
        else{
                this.doSearch (searchVal);
        }        
    }

    doProdSearch =(searchVal)=>
    {
         console.log("this.excludeRecordIds --> " , this.excludeRecordIds);
            findProducts()
            
            .then(result => {
                this.prodRecords = result;
               // this.excludeRecordIds = result;
                console.log("Record length Product--> " ,this.excludeRecordIds);
                console.log("Record length --> " , this.prodRecords.length);
                this.error = undefined;
            })
            .catch(error =>{
                console.log("Error:",error);
                this.error = error;
                this.records = undefined;
            })
    }

    doSearch = (searchVal)=>
    {
        findRecords({
            searchKey : searchVal, 
            objectName : this.objectName, 
            searchField : this.fieldName
        })
        .then(result => {
            this.records = result;
            console.log("prodResult",this.records);
            console.log("Record length --> " + this.records);
            for(let i=0; i < this.records.length; i++){
                const rec = this.records[i];
                this.records[i].Name = rec[this.fieldName];
            }
            this.error = undefined;
        })
        .catch(error => {
            console.log("Error:",error);
            this.error = error;
            this.records = undefined;
        });

    }

    // selection of the record from dropdown..
    handleSelect(event) {
        let selectedVal = event.detail.selRec;
        this.selectedRecord =  selectedVal;
        let finalrecevent = new CustomEvent('recselect',{
            detail : { selectedRecordId : this.selectedRecord }
        });
        this.dispatchEvent(finalrecevent); // hook for the component which will consume..
    } 

    @api
    //removal of the record from the dropdown..
    handleRemove() {
        if (this.disabled) {
            // Because there's no way to disable a pill, we just reassign this.selectedRecords to cancel out a pill being removed
            this.selectedRecord = this.selectedRecord;
        }
        else {
            this.selectedRecord =  '';
            this.records = undefined;
            let finalremevent = new CustomEvent('recselect',{
                detail : { selectedRecordId : ''}
            });
            this.dispatchEvent(finalremevent); // hook for the component which will consume..
            console.log()
        }
    }
}