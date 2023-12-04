/**
Name	        : KnowledgeCategoryNotice.js
Description	    : JS file created as part of  KnowledgeCategoryNotice LWC for TPDEV-431. 
Created By		: Sibin Kuriakose
Created Date	: 03-28-2023
Modification Log:
-------------------------------------------------------------------------------------------------------------------------
Ver  Developer					Date		 Description
-------------------------------------------------------------------------------------------------------------------------
01  Sibin Kuriakose				03-30-2023	 Created methods to check if Data category is populated and to thrown Toast message accordingly
02  Sibin Kuriakose				05-31-2023	 Modified methos to be called in 2000ms
*/

import { LightningElement,api } from 'lwc';
import checkDataCategory from '@salesforce/apex/KnowledgeCategoryNoticeController.checkDataCategory'
import DataCategoryMismatchError from '@salesforce/label/c.DataCategoryMismatchError';

export default class KnowledgeCategoryNotice extends LightningElement {

    @api recordId;
    @api checker;
    @api categories_mismatch;
    @api dcategory;

    connectedCallback() {
        setInterval(() =>{  
                checkDataCategory({ recordId: this.recordId })
                    .then((result) =>{ 
                        this.checker = result;
                        this.error = undefined;
                        if(this.checker == true){
                            this.categories_mismatch = true;
                            this.dcategory = DataCategoryMismatchError;
                        }
                        else{
                           this.categories_mismatch = false;
                        }           
                    })
                    .catch((error) =>{                 
                        this.checker = error;             
                    });          
        }, 2000)
    }
}