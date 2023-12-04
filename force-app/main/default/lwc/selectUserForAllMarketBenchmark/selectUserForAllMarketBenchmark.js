/**
Name	        : SelectUserForAllMarketBenchmark.js
Description	    : JS file created as part of  SelectUserForAllMarketBenchmark LWC for TPDEV-158. 
Created By		: Sibin Kuriakose
Created Date	: 04-24-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				05-24-2023	 Created methods to retrive user records 
*/
import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

import search from '@salesforce/apex/SelectUserForAllMarketBenchmarkCntrl.search';
import MarketUsersBenchmarkError from '@salesforce/label/c.MarketUsersBenchmarkError';
import User_s_Name from '@salesforce/label/c.User_s_Name';
import MarketUsersBenchmarkLabel from '@salesforce/label/c.MarketUsersBenchmarkLabel';

export default class SelectUserForAllMarketBenchmark extends LightningElement {

    @api lstUser = " ";
    @api initialUser = [];
    @api userErrors = [];
    @api inpulValue;   
    username = User_s_Name;
    label = MarketUsersBenchmarkLabel;

    handleSearch(event) {
        const lookupElement = event.target;
        // Call Apex endpoint to search for records and pass results to the lookup
        search({searchTerm : event.detail.searchTerm , inpulValue:this.inpulValue})              
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.errors = error;
            });
    }

    handleSelectionChange(event){
        this.lstUser = " ";
        if(event.detail.selectedItem !== null){  
            const lookupElement = event.detail.selectedItem.id;
            this.lstUser = lookupElement;
            const attributeChangeEvent = new FlowAttributeChangeEvent('lstUser', this.lstUser);
            this.dispatchEvent(attributeChangeEvent);
        }
    }
    //method to validate if all Observed Competencies are Scored
    @api
    validate() {
        if(this.lstUser.length == 18) { 
            return { isValid: true };
        } 
        else { 
            return { 
                isValid: false, 
                errorMessage: MarketUsersBenchmarkError
            }; 
        }
    }
}