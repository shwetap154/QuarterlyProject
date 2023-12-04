import { LightningElement, api, wire, track} from 'lwc';
import { getRecord,getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import getRebateRecs from '@salesforce/apex/RebateCalculatorController.getRebateProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import { NavigationMixin} from 'lightning/navigation';

import ID_FIELD from "@salesforce/schema/SBQQ__Quote__c.Id";
//import MAT_DX_FIELD from "@salesforce/schema/SBQQ__Quote__c.MAT_Purchase_Dollars_Dx__c";
//import MAT_RX_FIELD from "@salesforce/schema/SBQQ__Quote__c.MAT_Purchase_Dollars_Rx__c";
import ESTFINANCEAMT_FIELD from "@salesforce/schema/SBQQ__Quote__c.EST_Rebate_For_Qualifying_Products__c"; // EST_Rebate_For_Qualifying_Products__c
import MAXAMT_FIELD from "@salesforce/schema/SBQQ__Quote__c.Maximum_Rx_Vx_Quarterly_Rebate__c";
import CONTRIBUTIONAMT_FIELD from "@salesforce/schema/SBQQ__Quote__c.Est_quarterly_contribution_rebate__c";
import QUARTSUBTOTAL_FIELD from "@salesforce/schema/SBQQ__Quote__c.Quarterly_Total_Rebate_Amount__c";
import SUBTOTBYMONTHLY_FIELD from "@salesforce/schema/SBQQ__Quote__c.Quarterly_Rebate_amnt_Products_By_Units__c";
import PERCENTAGE_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.Market__r.Percentage__c';
import NO_OF_MONTHS_FIELD from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.Market__r.No_Of_Months__c';
import MARKET_NAME from '@salesforce/schema/SBQQ__Quote__c.SBQQ__Opportunity2__r.Market__r.Name';

import labelRX from '@salesforce/label/c.RebateCalculator_Section_Summary_RX';
import labelLAB from '@salesforce/label/c.RebateCalculator_Section_Summary_LAB';
import labelVRLAB from '@salesforce/label/c.RebateCalculator_Section_Summary_VRTLAB';
import labelCalAmnt from '@salesforce/label/c.RebateCalculator_Section_Summary_Cal_Amnt';
import labelQauterCalAmnt from '@salesforce/label/c.RebateCalculator_Section_Sum_Quaterly_Amt';


const FIELDS = [
    'SBQQ__Quote__c.Name', 
    'SBQQ__Quote__c.Est_quarterly_contribution_rebate__c',
    'SBQQ__Quote__c.EST_Rebate_For_Qualifying_Products__c',
    'SBQQ__Quote__c.Maximum_Rx_Vx_Quarterly_Rebate__c',
    'SBQQ__Quote__c.Quarterly_Lease_Amount__c',
    'SBQQ__Quote__c.Quarterly_Total_Rebate_Amount__c',
    'SBQQ__Quote__c.Quarterly_Rebate_amnt_Products_By_Units__c',
    'SBQQ__Quote__c.MAT_Purchase_Dollars_Rx__c',
    'SBQQ__Quote__c.MAT_Purchase_Dollars_Dx__c',
    'SBQQ__Quote__c.SBQQ__Opportunity2__r.Market__r.Percentage__c',
    'SBQQ__Quote__c.SBQQ__Opportunity2__r.Market__r.No_Of_Months__c',
    'SBQQ__Quote__c.SBQQ__Opportunity2__r.Market__r.Name'
];
//alert("FIELDS: " + FIELDS); 
 
export default class RebateCalculator extends LightningElement {
    customlabel = {
        labelRX,
        labelLAB,
        labelVRLAB,
        labelCalAmnt,
        labelQauterCalAmnt
    };
    @track columns = [
        { label: 'Product Name', fieldName: 'Name'},
        { label: 'Product sku#', fieldName: 'ProductCode'},
        { label: 'Rebate Amount', fieldName: 'RebateAmt' , type: 'currency'},
        { label: 'Qty', fieldName: 'Qty',editable:true}   
    ];
    @track quoteObject
    @api recordId;
    @api wiredata;
    @track rebateProductstList;
    @track error;
    numberOfMonths;
    percentage;
    marketName = 'United States';
    displayPercentage;
    dataById = {};

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    SBQQ__Quote__c({error, data})
    {
        if(data)
        {   this.wiredata = data;
            console.log('Data',data);
            this.quoteObject = JSON.parse(JSON.stringify(data));
            console.log('CPQ: opp ' + JSON.stringify(data));
            console.log('this.quoteObject ' + this.quoteObject);
            this.numberOfMonths =  getFieldValue(data, NO_OF_MONTHS_FIELD);
            this.percentage =  getFieldValue(data, PERCENTAGE_FIELD)/100;
            this.displayPercentage = '('+ getFieldValue(data, PERCENTAGE_FIELD) + '%)';
            this.marketName = getFieldValue(data,MARKET_NAME) !== undefined ? getFieldValue(data,MARKET_NAME) : 'United States' ;
           /* console.log('numberOfMonths with method >>> ' + this.numberOfMonths);
            console.log('percentage with method >>> ' + this.percentage);    
            console.log('market id >> ' + getFieldValue(data,MARKET_NAME)) ;*/

        }
        else if(error)
        {
            console.log('CPQ: error ' + JSON.stringify(error));
        }
    }

    @api
    get monthlyRXVXCAP() {
        if (!this.calcAmnt && this.calcAmnt !== 0) {
        return this.quoteObject.fields.Maximum_Rx_Vx_Quarterly_Rebate__c.value;
        } else {return   this.calcAmnt;  }
        
    }

    @api
    get quarterlyLeaseAmount() {
        return this.quoteObject.fields.Quarterly_Lease_Amount__c.value;
        //return this.quoteObject.fields.Quarterly_Lease_Amount__c.value ? this.quoteObject.fields.Quarterly_Lease_Amount__c.value : 0;

    }
    @api
    get matDxAmount() {
        return this.quoteObject.fields.MAT_Purchase_Dollars_Dx__c.value;
    }
    @api
    get matRxAmount() {
        return this.quoteObject.fields.MAT_Purchase_Dollars_Rx__c.value;
    }

    get estRebateForQualifyProducts() {
        return this.quoteObject.fields.EST_Rebate_For_Qualifying_Products__c.value;
    }
    
    get estQuarContribuationRebate() {
        return this.quoteObject.fields.Est_quarterly_contribution_rebate__c.value;
    }

    @api
    get quartTotalRebateAmt() {
        return this.quoteObject.fields.Quarterly_Total_Rebate_Amount__c.value;
    }
    @api
    get quartByUnitsAmt() {
        return this.quoteObject.fields.Quarterly_Rebate_amnt_Products_By_Units__c.value;
    }
    userAmount;

    @api
    get fields() {
        return this.userAmount;
    }


    @wire(getRebateRecs ,{marketNameStr: '$marketName'}) 
    rebatesHandler({data,error}){
        if (data ) {
            let i = 0;
            let self = this;

            data.forEach(function (element) {
                self.dataById[element.Id] = element;
            });
            this.rebateProductstList = data
            console.log(data);
            this.error = undefined; 
        } else if (error) {
           this.error = error;
           this.rebateProductstList = undefined;
        }
    }
    @track draftValues = [];
    /*updateColumnSorting(event) {
        var fieldName = event.detail.fieldName;
        var sortDirection = event.detail.sortDirection;
        // assign the latest attribute with the sorted column fieldName and sorted direction
        this.sortedBy = fieldName;
        this.sortedDirection = sortDirection;
        this.data = this.sortData(fieldName, sortDirection);
   } */

    @api calRebateRXAmt=0;
    @api calRebateLABAmt=0;
    @api calRebateVRLABAmt=0;

    @api calQuatRebateRXAmt=0;
    @api calQuatRebateLABAmt =0;
    @api calQuatRebateVRLABAmt=0;
    @api calcAmnt;  

    handleRXAmntChange() {
       /* let calQuatRebateRXAmt=0
        let calRebateRXAmt = 0;
        let calcAmnt=0;*/
      console.log('this.quarterlyLeaseAmount',this.quarterlyLeaseAmount);
        if (this.quarterlyLeaseAmount > 0){
            //this.calcAmnt = ((this.quarterlyLeaseAmount/3) /3)*3 ;
            this.calcAmnt = (this.quarterlyLeaseAmount)/(this.numberOfMonths) ;
        } else {this.calcAmnt=0; }   
       
        if (this.calcAmnt == 0){
            this.calQuatRebateRXAmt = this.calcAmnt;
            this.calRebateRXAmt = this.calcAmnt;
        } else {
            this.calRebateRXAmt = ((this.template.querySelector('[data-target-id="EnterAmountRX"]').value) * (this.percentage)); 
           this.calQuatRebateRXAmt= ((this.template.querySelector('[data-target-id="EnterAmountRX"]').value) * (this.percentage) * (this.numberOfMonths)); 
            //this.calQuatRebateRXAmt = (this.calRebateRXAmt*(this.numberOfMonths)); 
        }
        

        if (this.calcAmnt < this.calQuatRebateRXAmt ) {
                this.calQuatRebateRXAmt = this.calcAmnt;
        }
        //alert("monthlyRXVXCAP: " + this.calcAmnt);
        //alert("calQuatRebateRXAmt: " + this.calQuatRebateRXAmt);
    }

    handleLABAmntChange() {
        this.calRebateLABAmt = (this.template.querySelector('[data-target-id="EnterAmountLAB"]').value) * (this.percentage);
        this.calQuatRebateLABAmt = ((this.template.querySelector('[data-target-id="EnterAmountLAB"]').value) * (this.percentage)) * (this.numberOfMonths);
       //this.calQuatRebateLABAmt = this.calRebateLABAmt * (this.numberOfMonths) ;
    }
    handleVRLABAmntChange() {
        this.calRebateVRLABAmt = (this.template.querySelector('[data-target-id="EnterAmountVRLAB"]').value) * (this.percentage);
        this.calQuatRebateVRLABAmt = ((this.template.querySelector('[data-target-id="EnterAmountVRLAB"]').value) * (this.percentage)) * (this.numberOfMonths);
       //this.calQuatRebateVRLABAmt = this.calRebateVRLABAmt  * (this.numberOfMonths) ;
    }

    handleCalculate(e) {
        //alert("monthlyRXVXCAP: " + this.monthlyRXVXCAP);  
        let QuarFinanceRebateAmt = 0;
        let sumAmt = 0;
        let totAmt = 0;
        let  selected = this.template.querySelector('lightning-datatable').draftValues;
        let self = this;
        selected.forEach(element => {
          totAmt = element.Qty * self.dataById[element.Id].RebateAmt;
          sumAmt +=  totAmt;

        });
        //console.log('sumAmt ' , sumAmt);
        console.log('maxAmount ' , this.monthlyRXVXCAP);
        let qTotalRebateAmt = this.calQuatRebateRXAmt + this.calQuatRebateLABAmt + this.calQuatRebateVRLABAmt;
        let qByUnitsAmt = (sumAmt * (this.numberOfMonths));
        //alert("qByUnitsAmt: " + qByUnitsAmt);  
        QuarFinanceRebateAmt = qTotalRebateAmt + qByUnitsAmt;
        let contributeAmount = QuarFinanceRebateAmt - this.quarterlyLeaseAmount;
   
        const fields = {};

        fields[ID_FIELD.fieldApiName] = this.recordId;
        fields[ESTFINANCEAMT_FIELD.fieldApiName]  =  QuarFinanceRebateAmt;
        fields[MAXAMT_FIELD.fieldApiName] =this.monthlyRXVXCAP;
        fields[CONTRIBUTIONAMT_FIELD.fieldApiName] =contributeAmount;
        fields[QUARTSUBTOTAL_FIELD.fieldApiName] =qTotalRebateAmt;
        fields[SUBTOTBYMONTHLY_FIELD.fieldApiName] =qByUnitsAmt;
         
        const recordInput = { fields: fields };
          updateRecord(recordInput)
          .then(() => {
              this.dispatchEvent(
                  new ShowToastEvent({
                      title: 'Success',
                      message: 'Quote updated',
                      variant: 'success'
                  })
              );
          })

    }
    closeQuickAction() {
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    
    
}