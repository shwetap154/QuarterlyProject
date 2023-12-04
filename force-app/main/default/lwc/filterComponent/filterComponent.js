import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountData from '@salesforce/apex/CustomDataTableController.getAccountData';

export default class filterComponent extends LightningElement {
    @track accounts = [];
    @track theraupeuticgroupFilter = '';
    @track productFilter = '';
    @track productSalesFilter = '';
    @track GrandTotalFilter = '';
    @track APRFilter = '';
    @track AUGFilter = '';
    @track FEBFilter = '';
    @track MAYFilter = '';
    
    @track theraupeuticgroupOptions = [];
    @track productFilterOptions = [];
    @track productSalesFilterOptions = [];
    @track GrandTotalFilterOptions = [];
    @track APRFilterOptions = [];
    @track AUGFilterOptions = [];
    @track FEBFilterOptions = [];
    @track MAYFilterOptions = [];

    @track showTheraupeuticGroupDropdown = false;
    @track showProductDropdown = false;
    @track showProductSalesDropdown = false;
    @track showGrandTotalDropdown = false;
    @track showAPRDropdown = false;
    @track showAUGDropdown = false;
    @track showFEBDropdown = false;
    @track showMAYDropdown = false;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this.loadData();
    }

    loadData() {
        if (this._recordId) {
            getAccountData({ recordId: this._recordId })
                .then(result => {
                    this.accounts = result;
                    this.initializeFilters(result);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'An error occurred while fetching data.',
                            variant: 'error',
                        })
                    );
                });
        }
    }

    initializeFilters(data) {
        // Create filter options for Account Name and Industry columns
        this.theraupeuticgroupOptions = Array.from(new Set(data.map(account => account.Theraupeutic_Group__c))).map(Theraupeutic_Group__c => ({ label: Theraupeutic_Group__c , value: Theraupeutic_Group__c }));
        this.productFilterOptions = Array.from(new Set(data.map(account => account.Applicable_Product_Lines__c))).map(Applicable_Product_Lines__c => ({ label: Applicable_Product_Lines__c, value: Applicable_Product_Lines__c }));
        this.productSalesFilterOptions = Array.from(new Set(data.map(account => account.Product_Sales__c))).map(Product_Sales__c => ({ label: Product_Sales__c, value: Product_Sales__c }));
        this.GrandTotalFilterOptions = Array.from(new Set(data.map(account => account.Grand_Total__c))).map(Grand_Total__c => ({ label: Grand_Total__c, value: Grand_Total__c }));
        this.APRFilterOptions = Array.from(new Set(data.map(account => account.APR__c))).map(APR__c => ({ label: APR__c, value: APR__c }));
        this.AUGFilterOptions = Array.from(new Set(data.map(account => account.AUG__c))).map(AUG__c => ({ label: AUG__c, value: AUG__c }));
        this.FEBFilterOptions = Array.from(new Set(data.map(account => account.FEB__c))).map(FEB__c => ({ label: FEB__c, value: FEB__c }));
        this.MAYFilterOptions = Array.from(new Set(data.map(account => account.MAY__c))).map(MAY__c => ({ label: MAY__c, value: MAY__c }));
    }

    get filteredAccounts() {
        // Apply filters to the accounts based on nameFilter and industryFilter
        return this.accounts.filter(account => 
            (this.theraupeuticgroupFilter === '' || account.Theraupeutic_Group__c.includes(this.theraupeuticgroupFilter)) &&
            (this.productFilter === '' || account.Applicable_Product_Lines__c === this.productFilter) &&
            (this.productSalesFilter === '' || account.Product_Sales__c === this.productSalesFilter) &&
            (this.GrandTotalFilter === '' || account.GrandTotalFilter === this.GrandTotalFilter)&&
            (this.APRFilter === '' || account.APRFilter === this.APRFilter)&&
            (this.AUGFilter === '' || account.AUGFilter === this.AUGFilter)&&
            (this.FEBFilter === '' || account.FEBFilter === this.FEBFilter)&& 
            (this.MAYFilter === '' || account.MAYFilter === this.MAYFilter)
        );
    }

    toggleTheraupeuticGroupDropdown() {
        this.showTheraupeuticGroupDropdown = !this.showTheraupeuticGroupDropdown;
        this.showProductDropdown = false;
        this.showProductSalesDropdown =false;
        this.showGrandTotalDropdown = false;
        this.showAPRDropdown = false;
        this.showAUGDropdown = false;
        this.showFEBDropdown = false;
        this.showMAYDropdown = false;
    }

    toggleProductDropdown() {
        this.showProductDropdown = !this.showProductDropdown;
        this.showTheraupeuticGroupDropdown = false;
        this.showProductSalesDropdown =false;
        this.showGrandTotalDropdown = false;
        this.showAPRDropdown = false;
        this.showAUGDropdown = false;
        this.showFEBDropdown = false;
        this.showMAYDropdown = false;
    }
    toggleProductSalesDropdown() {
        this.showProductSalesDropdown = !this.showProductSalesDropdown;
        this.showTheraupeuticGroupDropdown = false;
        this.showProductDropdown = false;
        this.showGrandTotalDropdown = false;
        this.showAPRDropdown = false;
        this.showAUGDropdown = false;
        this.showFEBDropdown = false;
        this.showMAYDropdown = false;
    }
    toggleGrandTotalDropdown(){
        this.showGrandTotalDropdown = !this.showGrandTotalDropdown;
        this.showTheraupeuticGroupDropdown = false;
        this.showProductDropdown = false;
        this.showProductSalesDropdown = false;
        this.showAPRDropdown = false;
        this.showAUGDropdown = false;
        this.showFEBDropdown = false;
        this.showMAYDropdown = false;
    }
    toggleAPRDropdown(){
        this.showAPRDropdown = !this.showAPRDropdown;
        this.showTheraupeuticGroupDropdown = false;
        this.showProductDropdown = false;
        this.showProductSalesDropdown =false;
        this.showGrandTotalDropdown = false;
        this.showAUGDropdown = false;
        this.showFEBDropdown = false;
        this.showMAYDropdown = false;
    }
    toggleAUGDropdown(){
        this.showAUGDropdown = !this.showAUGDropdown;
        this.showTheraupeuticGroupDropdown = false;
        this.showProductDropdown = false;
        this.showProductSalesDropdown =false;
        this.showGrandTotalDropdown = false;
        this.showAPRDropdown = false;  
        this.showFEBDropdown = false;
        this.showMAYDropdown = false;
    }
    toggleFEBDropdown(){
        this.showFEBDropdown = !this.showFEBDropdown;
        this.showTheraupeuticGroupDropdown = false;
        this.showProductDropdown = false;
        this.showProductSalesDropdown =false;
        this.showGrandTotalDropdown = false;
        this.showAPRDropdown = false;  
        this.showAUGDropdown = false;
        this.showMAYDropdown = false;
    }
    toggleMAYDropdown(){
        this.showMAYDropdown = !this.showMAYDropdown;
        this.showTheraupeuticGroupDropdown = false;
        this.showProductDropdown = false;
        this.showProductSalesDropdown =false;
        this.showGrandTotalDropdown = false;
        this.showAPRDropdown = false;  
        this.showAUGDropdown = false;
        this.showFEBDropdown = false;
    }


    handleFilterChange(event) {
        const fieldName = event.target.name;
        const filterValue = event.detail.value;
        this[fieldName] = filterValue;
    }
   
     
}