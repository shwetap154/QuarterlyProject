/**
 * @description       : 
 * @author            : Ethan Hirsch @ Zoetis Inc
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : Ethan Hirsch @ Zoetis Inc
 * Modifications Log
 * Ver   Date         Author                      Modification
 * 1.0   03-18-2022   Ethan Hirsch @ Zoetis Inc   Initial Version
**/
import { LightningElement,track,api,wire } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getColumns from '@salesforce/apex/alphaCreateOrder.getColumns';
import getOrderList from '@salesforce/apex/alphaCreateOrder.getOrderList';
import deleteOrder from '@salesforce/apex/alphaCreateOrder.deleteOrder';
import {refreshApex} from '@salesforce/apex';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Edit', name: 'edit' },
];

const columnsWithHeaders = [
    { label: 'Purchase Order Number', fieldName: 'PoNumber'},
    { label: 'SAP Order No', fieldName: 'OrderReferenceNumber'},
    { label: 'Purchase Order Date', fieldName: 'PoDate' },
    { label: 'Status', fieldName: 'Status' },
    {
        label: 'Actions',
        type: 'action',
        typeAttributes: { rowActions: actions },
    },
];

export default class AlphaDistReadOnlyOrder extends LightningElement {

    @track finalresult = [];
    @track orderId = '';
    @track mode = '';
    columns = columnsWithHeaders;
    intialData = '';
    @track showSpinner = true;
    @track showOrderform = false;
    @track showCreateOrder = false;
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
    connectedCallback(){
            this.loadData();
    }

    createOrder = ()=>{
        this.showCreateOrder = true;
        this.mode = 'Create';
    }

    postUpdate = () =>{
             this.loadData();
             this.showOrderform = false;       
    }

    postSave= () =>{
            this.loadData();
            this.showCreateOrder = false;              
    }

    modalClosed = ()=>{
            this.loadData();
            this.showCreateOrder = false;
    }

    loadData =()=>{
         getOrderList().then((data)=>{
                     this.finalresult = data.map((item)=>{
                            let ce = (item.Status == 'Draft')? true: false;
                            return {
                                Id: item.Id,
                                PoNumber: item.PoNumber,
                                OrderReferenceNumber:item.OrderReferenceNumber,
                                PoDate : item.PoDate,
                                Status:item.Status,
                                canEdit:ce
                            }
                     });
                     this.intialData = this.finalresult;
                     this.showSpinner = false;
                });
    }

    handleValueChange(event){       
        this.finalresult = this.intialData;
        let ctrlName = event.currentTarget.dataset.name;
        // console.log('changed value:',event.detail.value)
       
        if(event.detail.value)
        {
            switch(ctrlName)
            {
                case 'poDate':
                    this.finalresult = this.finalresult.filter((item)=>{                
                    return item.PoDate ==  event.detail.value;
                })
                    break;
                case 'poNo':
                    this.finalresult = this.finalresult.filter((item)=>{                
                    return item.PoNumber ==  event.detail.value;
                })
                    break;
                case 'sapNo':
                    this.finalresult = this.finalresult.filter((item)=>{                
                    return item.OrderReferenceNumber ==  event.detail.value;
                })
                    break;
            }
        }
     
    }

    deleteRow = (event)=>{
        console.log('Delete invoked!!');
        this.orderId = event.currentTarget.dataset.id;
        let choice = confirm("You are about to delete this Order. Are you sure?")
        if(choice == true)
        {
             deleteOrder({ orderId: this.orderId })
            .then((result)=>{ 
                    if (result.success) {
                        console.log('Delete Success-->' ,result)
                        const evt = new ShowToastEvent({
                            title: "Success",
                            message: "Order record deleted successfully",
                            variant: 'success',
                        });
                        this.dispatchEvent(evt); 
                        this.intialData = this.intialData.filter((item)=>{
                                return item.Id != this.orderId;
                        })
                        this.finalresult = this.intialData;        
                    }
                    else {
                        const evt = new ShowToastEvent({
                            title: "Error",
                            message: result.errorMessage,
                            variant: 'error',
                        });
                        this.dispatchEvent(evt); 
                    }  
                }).catch((error)=>{                      
                    console.log('Error--> ' + error)
                        const evt = new ShowToastEvent({
                            title: "Error",
                            message: "Error Occured deleting Order record",
                            variant: 'error',
                        });
                        this.dispatchEvent(evt);
                })  
               
        }
       
    }

    editRow = (event)=>{
        this.orderId = event.currentTarget.dataset.id;
        this.mode = 'Edit';
        console.log('Edit',  this.orderId);
        this.showOrderform =true;
    }

    showRow = (event)=>{
        this.orderId = event.currentTarget.dataset.id;
        this.mode = 'Show';
        this.showOrderform =true;
        console.log('Show');
    }

    back = () =>{
        this.loadData();
        this.showOrderform =false;
    }
}