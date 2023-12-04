import { LightningElement,track,api} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import getForecastResult from '@salesforce/apex/alphaDistReadOnlyController.loadForecastView';
import getStockResult from '@salesforce/apex/alphaDistReadOnlyController.loadStockView';
import getColumns from '@salesforce/apex/alphaDistReadOnlyController.getColumns';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const monthValues = ['January','February','March','April','May','June','July','August','September','October','November','December']

export default class AlphaDistReadOnlyForecast extends LightningElement {
    
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
    columns;
    @track showBreadCrumb = true;
    @track finalresult = [];
    @track monthLabel = '';
    @track yearLabel = '';
    @api objName = '';
    @api accRecord = '';
    @api mode = '';

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

    connectedCallback(){
        this.monthLabel = (this.objName == 'Stock') ? 'Stock Month' : 'Forecast Month';
        this.yearLabel = (this.objName == 'Stock') ? 'Stock Year' : 'Forecast Year';
        this.showBreadCrumb = (this.mode == 'CSCL')? false : true;
        
        getColumns({type:this.objName})
       
        .then((result)=>
            {
                        let finalset;
                        let objfilter;
                        let temp = result.map((item)=>{
                             return {
                                        label: item.label__c, 
                                        fieldName: item.fieldName__c,
                                        type: 'text', 
                                        wrapText: true
                                    }
                        })

                        console.log('Within child -->' + this.objName + this.mode)
                        
                        objfilter = temp.filter((item)=>{
                                return item.fieldName != 'forecastNumber'
                                        && item.fieldName != 'stockNumber'
                        })

                        if(this.objName == 'Stock')
                        {

                            objfilter = objfilter.filter((item)=>{
                                return item.fieldName != 'oldValue'
                                        && item.fieldName != 'newValue'
                                        && item.fieldName != 'price'
                                        && item.fieldName != 'currencyCode'
                                       
                            })
                        }
                        else if(this.objName == 'Forecast')
                        {
                            //    console.log('Entered Forecast')
                            objfilter = objfilter.filter((item)=>{
                                return item.fieldName != 'quantity'
                                        && item.fieldName != 'batchNo'
                                        && item.fieldName != 'expiryDate'
                                        && item.fieldName != 'distProdCode'
                            })
                        }

                        if(this.mode != 'CSCL')
                        {
                            finalset = objfilter.filter((item)=>{
                                return item.fieldName != 'accountName'
                                
                            })
                            if(this.objName == 'Stock')
                             {
                                 finalset = finalset.filter((item)=>{
                                     return item.fieldName != 'uom'
                                      && item.fieldName != 'expiryDate'
                                })
                            }
                             console.log(finalset);
                        }
                        else{
                            finalset = objfilter.filter((item)=>{
                                return  item.fieldName != 'distProdCode'
                                    && item.fieldName != 'distProdName'
                                    
                            })
                        }

                        this.columns = finalset;

                        console.log(this.columns);

            }).catch((err)=>{
                    console.log(err);
            })
    }

     
           
    handleClick(){
            console.log(this.objName);
            if(this.objName == 'Forecast'){
                getForecastResult({month:this.monthValue,year:this.yearValue,accountId:this.accRecord}).then(result =>{
                    console.log('Result==>',result)

                    // Adjust price so that it displays correctly
                    let modifiedResult = JSON.parse(JSON.stringify(result));
                    for (let i = 0; i < modifiedResult.length; i++) {
                        let index = modifiedResult[i].price.indexOf('.');
                        if (index >= 0) {
                            modifiedResult[i].price = modifiedResult[i].price.substring(0, index + 3);
                            modifiedResult[i].sapProductCode= parseInt(modifiedResult[i].sapProductCode,10).toString();
                        }
                    }

                    this.finalresult = modifiedResult;
                }).catch(error =>{
                    console.log('Error--> ' + error.body.message)
                         const evt = new ShowToastEvent({
                            title: "Error",
                            message: "This account does not belong to your market",
                            variant: 'error',
                        });
                         this.dispatchEvent(evt);
                })
            }
            else if(this.objName == 'Stock'){
                getStockResult({month:this.monthValue,year:this.yearValue,accountId:this.accRecord}).then(result =>{
                    console.log('Result==>',result)
                    let temp = JSON.parse(JSON.stringify(result));;
                    temp.forEach((item)=>{
                            item.sapProductCode= parseInt(item.sapProductCode,10).toString();
                    })
                    this.finalresult = temp;

                }).catch(error =>{
                    console.log('Error--> ' + error.body.message)
                         const evt = new ShowToastEvent({
                            title: "Error",
                            message: "This account does not belong to your market",
                            variant: 'error',
                        });
                         this.dispatchEvent(evt);
                })
            }

    }

    handleChange(event) {
        switch(event.currentTarget.dataset.name) {            
             case 'forecastMonth':
                this.monthValue = event.detail.value;
                break;
            case 'forecastYear':
                this.yearValue = event.detail.value;
                break;
        }
    }
}