import { LightningElement,track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import Zoetis_Static_Resources from '@salesforce/resourceUrl/Zoetis_Static_Resources';
import getCaseType from '@salesforce/apex/alphaCaseHandler.getCaseType';
import createCase from '@salesforce/apex/alphaCaseHandler.createCase';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class AlphaCreateCase extends LightningElement {
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
   
    @track  options;
    @track showMessage =  false;
    @track showPharmaMessage = false;
    @track displaymessage = '';
    case = {
            Subject:"",
            Description : "",
            Case_Type__c : ""
    };
    @track baseURL = '';

    dataloggermesg = 'For all Data Logger Inquiries, please contact to "zoetis@liberomanager.com" , if you received products from Novidia, please directly contact to Novidia for any inquiries'
    pharmamesg = 'All pharmacovigilance reports must be sent to the email address for your region:' 
                  
    connectedCallback(){
        getCaseType().then(data =>{
            this.options = data.map((item)=>{                       
                        return { label: item, value: item};
                    });
            //  console.log("Received==>",  this.options)
        }).catch(err => {
            console.log("Error Occured: " , err);
        })
        this.baseURL = window.location.origin + "/ZoetisDistributorCommunity/s/legal-and-regulatory";
        // console.log('URL==>',this.baseURL);
    }

    handleValueChange(event){
          
            let ctrlName = event.currentTarget.dataset.name;
            switch(ctrlName){
                case 'caseType':
                    this.case.Case_Type__c = event.detail.value;
                    if(this.case.Case_Type__c == 'Data Logger Inquiries')
                    {
                         this.displaymessage = this.dataloggermesg;
                         this.showMessage = true;
                          this.showPharmaMessage = false;
                    }
                    else if(this.case.Case_Type__c == 'Pharmacovigilance')
                    {
                        this.displaymessage = this.pharmamesg;
                        this.showPharmaMessage = true;
                        this.showMessage = true;
                    }
                    else{
                        this.showMessage = false;
                        this.showPharmaMessage = false;
                    }
                    break;
                case 'caseSub':
                    this.case.Subject = event.detail.value;
                    break;
                case 'caseDesc':
                    this.case.Description = event.detail.value;
                    break;
            }
    }

    handleClick(){

        if(this.validateFields())
        {
            console.log(JSON.stringify(this.case));
            let objson = JSON.stringify(this.case);
            createCase({payload:objson}).then((result)=>{ 
                    console.log('Success-->' ,result)
                        const evt = new ShowToastEvent({
                            title: "Success",
                            message: "Case logged successfully",
                            variant: 'success',
                        });
                        this.dispatchEvent(evt);
                        this.reload();
                })
                .catch((error)=>{                      
                        console.log('Error--> ' + error.body.message)
                         const evt = new ShowToastEvent({
                            title: "Error",
                            message: "Error Occured",
                            variant: 'error',
                        });
                         this.dispatchEvent(evt);
                         
                    });
        }
    }

    validateFields(){

        let errorStatus = true;
        errorStatus = this.template.querySelector('[data-name=\'caseType\']').reportValidity() && errorStatus;
        errorStatus = this.template.querySelector('[data-name=\'caseSub\']').reportValidity() && errorStatus;
        errorStatus = this.template.querySelector('[data-name=\'caseDesc\']').reportValidity() && errorStatus;

        return errorStatus;
    }

    reload = ()=>{
        this.template.querySelector('[data-name=\'caseSub\']').value = '';
        this.template.querySelector('[data-name=\'caseDesc\']').value = '';
        this.template.querySelector('[data-name=\'caseType\']').value = '';
    }



}