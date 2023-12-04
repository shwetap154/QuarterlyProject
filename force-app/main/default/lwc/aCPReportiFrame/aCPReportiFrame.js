/******************************************************************************************************************************************
 * Class Name   : ACPReportiFrame
 * Description  : Lightning web component for ACPReportiFrame
 * Created By   : Yadagiri Avula
 * Created Date : 11 May 2023
 *
 * Modification Log:
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                       Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Yadagiri Avula(Cognizant)     05/11/2023             Created.
 *****************************************************************************************************************************************/
 

import { api,track, LightningElement,wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import AccountNARCID from "@salesforce/schema/Account.ZTS_US_NARC_ID__c";

export default class ACPReportiFrame extends LightningElement {
  @api height = '500px';
  @api width = '100%';
  @api recordId;
  @api baseurl;
  @track url;
  @track narcId;

  get isURLGenerated(){

      this.url = this.baseurl+ this.narcId;
  
    return (this.narcId != undefined || this.narcId != '') ;
  }
@wire(getRecord, { recordId: '$recordId',fields: AccountNARCID })
  accountData({error,data}){
      if(error){
      }else if(data){
          this.narcId = data.fields.ZTS_US_NARC_ID__c.value;
      }
  }

}