import { LightningElement,track,wire,api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import getProductStock from '@salesforce/apex/alphaDistReadOnlyController.getProductStock';
import saveStock from '@salesforce/apex/alphaDistReadOnlyController.saveStockRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const monthValues = ['January','February','March','April','May','June','July','August','September','October','November','December'];

export default class AlphaNewStockEntryForm extends LightningElement {

    renderedCallback() {

        Promise.all([
            loadScript(this, Zoetis_Static_Resources + '/js/jquery.min.js'),
            loadScript(this, Zoetis_Static_Resources + '/js/zoetis_global_scripts.js'),
            loadStyle(this, Zoetis_Static_Resources + '/css/zoetis_global_styles.css'),
        ])
            .then(() => {
                //alert('Files loaded.');
            })
            .catch(error => {
                alert(error.body.message);
            });
    }

    yearValue;
    monthValue;
    @track isSaved = false;
    @track isDataPresent = false;
    @track initList = []; 
    @track index = 0;
    @track prodStock = {
        prod:'',
        stock:''
    }


    monthOptions = monthValues.map((item) => {
                return {label: item,value:item};
        });

    get yearOptions()
    {
         let currYear = new Date().getFullYear();
         let tempOptions = []
            tempOptions.push({label: currYear - 1,value:(currYear - 1).toString()});
            for(let i=0;i<10;i++)
            {
                tempOptions.push({label: currYear + i,value:(currYear + i).toString()});
            }
        return tempOptions;
    }

handleProdChange(event){
        // let key = event.currentTarget.dataset.id;
        let rec = JSON.parse(JSON.stringify(event.detail.selectedRecordId));
        console.log('selected prod',rec);
        if(rec == '')
        {
            this.prodStock = { prod:'',stock:''};
        }
        else
        {
            getProductStock({productId:rec.Id}).then((result)=>{
                this.prodStock.prod = JSON.parse(JSON.stringify(result.prod));
                this.prodStock.stock = JSON.parse(JSON.stringify(result.stock));
                this.prodStock.stock.SAP_Product_Code__c = parseInt(this.prodStock.stock.SAP_Product_Code__c, 10).toString();
                console.log(this.prodStock);
            }).catch((error)=>{
                    console.log(error.body.message);
            })

        }
        
    }

    doCleanUp = ()=>{
            this.initList = [];
            this.index = 0;    
            this.isDataPresent = false;    
    }

    addToGrid = ()=>{
        
        if(this.validateFields())
        {
            if (this.prodStock.prod != '' && this.prodStock.stock != '')
            {
                
                if(this.prodStock.key == undefined){
                    this.initList.push(this.prodStock);
                } 
                else{
                        //  console.log('Key=>',this.initList[this.prodStock.key])
                          this.initList[this.prodStock.key] = this.prodStock;
                    }              
                this.prodStock = { prod:'',stock:''};
                this.template.querySelector('c-alpha-custom-lookup').handleRemove();
                this.isDataPresent = true;
            }
        else{
                alert('Fill the data first')
                const evt = new ShowToastEvent({
                                title: "Error",
                                message: "Please fill up Stock record details",
                                variant: 'error',
                            });
                            this.dispatchEvent(evt);
            }    
        }
        
    }

    editRow = (event)=>{
        let key = event.currentTarget.dataset.id;
        // this.index++;
        this.prodStock.key = event.currentTarget.dataset.id;
        this.prodStock.prod = JSON.parse(JSON.stringify(this.initList[key].prod));
        this.prodStock.stock = JSON.parse(JSON.stringify(this.initList[key].stock));
        // this.initList.push(this.prodStock);       
         console.log('Enter ',this.prodStock);
    }
    
    removeRow=(event)=>{

        let key = event.currentTarget.dataset.id;
        if(this.initList.length>1){
                this.initList.splice(key, 1);
                this.index--;
                
        }
        else if(this.initList.length == 1){
               this.doCleanUp();
        }       
    } 

    handleValueChange(event){
        let ctrlName = event.currentTarget.dataset.name;
     
        switch(ctrlName){
            case 'DistCode':
                this.prodStock.stock.Distributor_Product_Code__c = event.target.value;
                break;
            case 'DistName':
                this.prodStock.stock.Distributor_Product_Name__c = event.target.value;
                break;
            case 'BatchLot':
                this.prodStock.stock.Batch_Lot_Number__c = event.target.value;
                break;
            case 'ExpDate':
                this.prodStock.stock.Expiration_Date__c = event.target.value;
                break;
            case 'Quantity':
                this.prodStock.stock.Quantity__c = event.target.value;
                break;
            case 'forecastMonth':
                this.monthValue = event.target.value;
                 this.doCleanUp();
                break;
            case 'forecastYear':
                this.yearValue = event.target.value;
                 this.doCleanUp();
                break;
        }
    }

    validateFields(){

        let errorStatus = true;

        errorStatus = this.template.querySelector('[data-name=\'forecastMonth\']').reportValidity();
        console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\'forecastYear\']').reportValidity() && errorStatus;
        console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\"BatchLot\"]').reportValidity() && errorStatus
        console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\"ExpDate\"]').reportValidity() && errorStatus
        console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\"Quantity\"]').reportValidity() && errorStatus
        console.log(errorStatus);

        return errorStatus;

    }

    saveRecord = ()=>
    {
        let hack = { psOfList: this.initList};
        //  console.log('Final Result-->', JSON.stringify(hack))
         saveStock({payload:JSON.stringify(hack),
                year:this.yearValue,month:this.monthValue})
                .then((result)=>{ 
                    console.log('Success-->' ,result)
                        this.isSaved = true;
                        const evt = new ShowToastEvent({
                            title: "Success",
                            message: "Stock record created successfully",
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                })
                .catch((error)=>{                      
                        console.log('Error--> ' + error.body.message)
                        const evt = new ShowToastEvent({
                            title: "Error",
                            message: error.body.message,
                            variant: 'error',
                        });
                         this.dispatchEvent(evt);
                    })
           
    }
    
}