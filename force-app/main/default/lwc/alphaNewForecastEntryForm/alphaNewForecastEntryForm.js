import { LightningElement,track,wire,api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import getProductForecast from '@salesforce/apex/alphaDistReadOnlyController.getProductForecast';
import getMonthlyForecast from '@salesforce/apex/alphaDistReadOnlyController.getMonthlyForecast';
import saveForecast from '@salesforce/apex/alphaDistReadOnlyController.saveForecastRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const monthValues = ['January','February','March','April','May','June','July','August','September','October','November','December'];

export default class AlphaNewForecastEntryForm extends LightningElement {

    connectedCallback() {
        // Calculate current month plus two to prevent editing.
        let today = new Date();
        let month = today.getMonth();
        let year = today.getFullYear();
        this.lockedMonths.push(monthValues[month] + ' ' + year);
        for (let i = 0; i < 2; i++) {
            month += 1;
            if (month >= 12) {
                month = 0;
                year += 1;
            }
            this.lockedMonths.push(monthValues[month] + ' ' + year);
        }
        for (let i = 0; i < 24; i++) {
            month += 1;
            if (month >= 12) {
                month = 0;
                year += 1;
            }
            this.validMonths.push(monthValues[month] + ' ' + year);
        }
    }

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
    lockedMonths = [];
    validMonths = [];
    lockButtons = false;
    @track isDataPresent = false;
    @track initList = []; 
    @track index = 0;
    @track prodForecast = {
        prod:'',
        forecast:''
    }

    monthOptions = monthValues.map((item) => {
        return {label: item,value:item};
    });

    get yearOptions() {
        /*
        let currYear = new Date().getFullYear();
        let tempOptions = []
        tempOptions.push({label: currYear - 1,value:(currYear - 1).toString()});
        for(let i=0;i<10;i++) {
            tempOptions.push({label: currYear + i,value:(currYear + i).toString()});
        }
        return tempOptions;
        */
        
        let currYear = new Date().getFullYear();
        let tempOptions = [];
        for(let i = 0; i < 4; i++) {
            tempOptions.push({label: currYear + i, value: (currYear + i).toString()});
        }
        return tempOptions;
    }

    handleProdChange(event){
        debugger
        // let key = event.currentTarget.dataset.id;
        let rec = JSON.parse(JSON.stringify(event.detail.selectedRecordId));
        console.log("REC",rec);
        getProductForecast({productId: rec.Id}).then((result)=>{
            // Check if the product is already in the table
            console.log('initList:' + JSON.stringify(this.initList));
            let productIdList = [];
            for (let i = 0; i < this.initList.length; i++) {
                productIdList.push(this.initList[i].prod.Id);
            }
            if (productIdList.includes(result.prod.Id)){
                this.prodForecast = {prod:'', forecast:''};
                this.template.querySelector('c-alpha-custom-lookup').handleRemove();
                const evt = new ShowToastEvent({
                    title: "Product Already Selected",
                    message: "Product is already in the table. Please edit or delete existing entry.",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }
            else {
                let modifiedResult = JSON.parse(JSON.stringify(result));
                modifiedResult.forecast.Short_SAP_Product_Code__c = parseInt(modifiedResult.forecast.SAP_Product_Code__c, 10).toString();
                this.prodForecast = modifiedResult;
                console.log(this.prodForecast);
            }
        }).catch((error)=>{
            console.log(error.body.message);
        })
    }

    addToGrid = () => {
        if(this.validateFields())
        {
            if (this.prodForecast.prod != '' && this.prodForecast.forecast != '')
            {
                console.log(this.prodForecast);
                console.log('Key=>',this.prodForecast.key)
                if (this.prodForecast.key == undefined) {
                    this.initList.push(this.prodForecast);
                } 
                else {
                    // console.log('Key=>',this.initList[this.prodForecast.key])
                    this.initList[this.prodForecast.key] = this.prodForecast;
                }   
                this.prodForecast = { prod:'',forecast:''};
                this.template.querySelector('c-alpha-custom-lookup').handleRemove();
                this.isDataPresent = true;
            }
            else{
                alert('Fill the data first')
                const evt = new ShowToastEvent({
                    title: "Error",
                    message: "Please fill up Forecast record details",
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            }    
        }
    }

    editRow = (event)=>{
        let key = event.currentTarget.dataset.id;
        // this.index++;
        this.prodForecast.key = event.currentTarget.dataset.id;
        this.prodForecast.prod = JSON.parse(JSON.stringify(this.initList[key].prod));
        this.prodForecast.forecast = JSON.parse(JSON.stringify(this.initList[key].forecast));
        // this.initList.push(this.prodForecast);       
        console.log('Enter ',this.prodForecast);
    }

    removeRow=(event)=>{
        let key = event.currentTarget.dataset.id;
        if(this.initList.length>1){
            this.initList.splice(key, 1);
            this.index--;
        }
        else if(this.initList.length == 1){
            this.initList = [];
            this.index = 0;    
            this.isDataPresent = false;        
        }       
    } 

    handleValueChange(event) {
        let ctrlName = event.currentTarget.dataset.name;
        // let key = event.currentTarget.dataset.id;
        switch(ctrlName){
            case 'DistCode':
                this.prodForecast.forecast.Distributor_Product_Code__c = event.target.value;
                break;
            case 'DistName':
                this.prodForecast.forecast.Distributor_Product_Name__c = event.target.value;
                break;
            case 'Quantity':
                this.prodForecast.forecast.Quantity__c = event.target.value;
                break;
            case 'forecastMonth':
                this.monthValue = event.target.value;
                this.retrieveForecast();
                break;
            case 'forecastYear':
                this.yearValue = event.target.value;
                this.retrieveForecast();
                break;
        }
    }

    retrieveForecast() {
        this.lockButtons = false;
        if (!this.monthValue || !this.yearValue) {
            return;
        }
        else if (this.lockedMonths.includes(this.monthValue + ' ' + this.yearValue)) {
            const evt = new ShowToastEvent({
                title: "Locked Forecast",
                message: "Forecasts cannot be entered for the current month or the two following months. Please select a different month and year combination.",
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            this.lockButtons = true;
            return;
        }
        else if (!this.validMonths.includes(this.monthValue + ' ' + this.yearValue)) {
            const evt = new ShowToastEvent({
                title: "Locked Forecast",
                message: "Forecasts can only be entered for the next 3 to 27 months. Please select a different month and year combination.",
                variant: 'warning',
            });
            this.dispatchEvent(evt);
            this.lockButtons = true;
            return;
        }
        console.log('getMonthlyForecast');

        getMonthlyForecast({month: this.monthValue, year: this.yearValue})
        .then(data => {
            console.log(data);
            let parsedData = JSON.parse(JSON.stringify(data));
            // if (parsedData.length > 0) {
                this.initList = parsedData;
                for (let i = 0; i < this.initList.length; i++) {
                    this.initList[i].forecast.Short_SAP_Product_Code__c = parseInt(this.initList[i].forecast.SAP_Product_Code__c, 10).toString();
                }
                // this.isDataPresent = true;
                this.isDataPresent = parsedData.length > 0;
            // }
            // Potential improvement: Check if there is unsaved data, and confirm with the user that they want to get rid of it if they change to a month that already has data.
        })
        .catch(err => {
            console.log("Error Occured: " , err);
        });
    }

    validateFields() {
        let errorStatus = true;

        errorStatus = this.template.querySelector('[data-name=\'forecastMonth\']').reportValidity();
        console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\'forecastYear\']').reportValidity() && errorStatus;
        console.log(errorStatus);
        errorStatus = this.template.querySelector('[data-name=\"Quantity\"]').reportValidity() && errorStatus
        console.log(errorStatus);

        return errorStatus;
    }

    saveRecord = ()=>
    {
        let hack = { pfOfList: this.initList};
        console.log('Final Result-->', JSON.stringify(hack))
        saveForecast({payload:JSON.stringify(hack), year:this.yearValue, month:this.monthValue})
        .then((result)=>{ 
            console.log('Success-->' ,result)
            const evt = new ShowToastEvent({
                title: "Success",   
                message: "Forecast record created successfully",
                variant: 'success',
            });
            this.dispatchEvent(evt);
        })
        .catch((error)=>{                      
            console.log('Error--> ' + error.body.message)
            const evt = new ShowToastEvent({
                title: "Error",
                // message: "Forecast record already created for this month and year",
                // message: 'Forecast was not saved.',
                message: error.body.message,
                variant: 'error',
            });
            this.dispatchEvent(evt);
        })
    }
}