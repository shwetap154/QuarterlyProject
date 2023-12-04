import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFlexibleGroups from '@salesforce/apex/GetConsumablesForLargeOfferController.getFlexibleGroups';
import createQuoteLines from '@salesforce/apex/GetConsumablesForLargeOfferController.createQuoteLines';
import getFlexGroupItems from '@salesforce/apex/GetConsumablesForLargeOfferController.getFlexGroupItems';
import getSelectedMaterialsByFlexibleGroup from '@salesforce/apex/GetConsumablesForLargeOfferController.getSelectedMaterialsByFlexibleGroup';

const columns = [
    {
        label: 'SAP Material Number',
        fieldName: 'SAPNumber',
        sortable: true,
        hideDefaultActions: true,
        initialWidth: 180
    },
    {
        label: 'Product Name',
        fieldName: 'ProductName',
        sortable: true,
        hideDefaultActions: true
    }
];


export default class SelectConsumablesForLargeOffer extends NavigationMixin(LightningElement) {

    @api quoteId;
    @api error;

    /** Values & Labels for the combobox */
    @track aggregateCommitmentsArray = []; //this holds the array for records with value & label
    @track selectedAggregateCommitmentKey = '';
    @track selectedFlexGroup;
    @track selectedSuffix;

    /** Filtering and pagination */
    @track searchKey = '';
    @track pageSize = 10;
    @track currentPage = 1; 
    @track totalPages = 1;

    /**
     * Selected Flexbible Group Items.
     * Object structure: {"FlexGroupNumber:Suffix": ["Array of Selected Material Numbers"]}
     */
    @track selectedFlexItems = {};
    @track currentSelectedItems = [];
    @track numberOfSelectedFlexItems = 0;

    /**
     * Cache object to store the flexible group items and avoid calling Apex multiple times.
     * Object structure: {"FlexGroupNumber": ["Array of Selected Material Numbers"]}
     */
    @track flexGroupItemsCache = {}


    /**
     * Disable flags for Add and Remove buttons
     */
    @track disableAddButton = true;
    @track disableRemoveButton = true;

    /**
     * Array of current list items.
     * This list is filtered and ordered.
     */
    @track data;

    /**
     * The 'Loading' indicator.
     */
    @track loading = true;
    @track loadingMessage = 'Loading data...';

    async connectedCallback() {

        this.columns = columns;

        // Load Aggregate commitments included in the Quote.
        await this.getAggregateCommitmentInQuote();

        // Get Flexible Group Items by Flexible Group.
        await this.getFlexibleGroupItems();

        // Get the selected items included in the quote per Aggregate Commitment
        await this.getSelectedMaterialsByAggregateCommitment();
    }

    /**
     * Handles the 'Add' button click.
     * Moves the selected items in the 'Available Consumables' list
     * to the 'Selected Consumables' list.
     */
    handleAddClick() {

        if (!this.selectedFlexGroup) {
            return;
        }

        // Get seleted rows from left side table
        const availableConsumablesSelected = this.template.querySelector("lightning-datatable[data-id=availableConsumablesTbl]").getSelectedRows();

        console.log('handleAddClick > availableConsumablesSelected', JSON.stringify(availableConsumablesSelected));

        const itemsToAdd = [];

        if (availableConsumablesSelected && availableConsumablesSelected.length > 0) {

            // Add to selected products only if they're not already there
            availableConsumablesSelected.forEach(item => {
                if (!this.currentSelectedItems.some(x => x.Id == item.Id)) {
                    console.log('handleAddClick > Item to add', JSON.stringify(item));
                    itemsToAdd.push(item);
                }
            });

            this.currentSelectedItems = this.currentSelectedItems.concat(itemsToAdd);
            this.selectedFlexItems[this.selectedAggregateCommitmentKey] = this.currentSelectedItems;

            this.disableAddButton = true;
        }
    }

    /**
     * Handles the 'Remove' button click.
     * Remove the selected items from the 'Selected Consumables' list.
     */
    handleRemoveClick() {

        if (!this.selectedFlexGroup) {
            return;
        }

        // Get seleted rows from left side table
        const selectedConsumablesToRemove = this.template.querySelector("lightning-datatable[data-id=selectedConsumablesTbl]").getSelectedRows();

        console.log('handleRemoveClick > selectedConsumablesToRemove', JSON.stringify(selectedConsumablesToRemove));

        if (selectedConsumablesToRemove && selectedConsumablesToRemove.length > 0) {

            const newSelectedItems = [];

            // Add to selected products only if they're not already there
            for(let selectedItem of this.currentSelectedItems) {
                if (!selectedConsumablesToRemove.some(x => x.ProductNumber === selectedItem.ProductNumber)) {
                    newSelectedItems.push(selectedItem);
                }
            }

            this.currentSelectedItems = newSelectedItems;
            this.selectedFlexItems[this.selectedAggregateCommitmentKey] = this.currentSelectedItems;
        }
    }

    /**
     * Handler method for the search filter change.
     * @param {*} event 
     */
    onSearchFilterChange(event) {

        this.searchKey = event.target.value;

        // Reset paging
        this.currentPage = 1;
        this.applyFilters();
    }

    /**
     * Apply current filtering and paginates the array.
     */
    applyFilters() {

        if (!this.selectedFlexGroup) {
            return;
        }

        let flexGroupItems = (this.flexGroupItemsCache && this.flexGroupItemsCache[this.selectedFlexGroup]) ? this.flexGroupItemsCache[this.selectedFlexGroup] : [];

        if (this.searchKey) {
            flexGroupItems = [...flexGroupItems].filter(fgi => (fgi.SAPNumber.indexOf(this.searchKey) >= 0 || fgi.ProductName.toUpperCase().indexOf(this.searchKey.toUpperCase()) >= 0));
        }
        else {
            flexGroupItems = [...flexGroupItems];
        }

        // Calculate total pages based on filtered data
        this.totalPages = Math.ceil(flexGroupItems.length / this.pageSize);

        // Show the selected page
        this.data = this.paginate(flexGroupItems, this.pageSize, this.currentPage);
    }   

    /** 
     * Change event for the Flexible Group combobox
     */
    handleFlexGroupChange(event) {

        // Value format: "0000001234-02" (flex group - suffix)
        this.selectedAggregateCommitmentKey = event.detail.value;
        if (this.selectedAggregateCommitmentKey && this.selectedAggregateCommitmentKey.indexOf("-") >= 0) {
            this.selectedFlexGroup = this.selectedAggregateCommitmentKey.split("-")[0];
            this.selectedSuffix = this.selectedAggregateCommitmentKey.split("-")[1];
        }
        else {
            console.error("handleFlexGroupChange > Malformed value: " + event.detail.value);
        }

        if (!this.selectedFlexGroup) {
            return;
        }

        // Reset filtering and page
        this.searchKey = '';
        this.pageSize = 20;
        this.currentPage = 1;

        this.applyFilters();

        if (this.selectedFlexItems[this.selectedAggregateCommitmentKey]) {
            this.currentSelectedItems = this.selectedFlexItems[this.selectedAggregateCommitmentKey];
        }
        else {
            this.selectedFlexItems[this.selectedAggregateCommitmentKey] = [];
            this.currentSelectedItems = [];
        }
    }

    /**
     * Handles the 'Save' button click.
     */
    handleSave() {

        this.loading = true;
        this.loadingMessage = 'Saving configuration...';

        // Convert the selectedFlexItem object to a flat array with the format flexiblegroup:suffix-materialnumber
        const flatSelectedItemsArr = [];
        if (this.selectedFlexItems) {
            Object.keys(this.selectedFlexItems).forEach(key => {
                this.selectedFlexItems[key].forEach(material => {
                    flatSelectedItemsArr.push(`${key}:${material.SAPNumber}`)
                });
            });
        }

        console.log('handleFlexGroupChange > handleSave > flatSelectedItemsArr', flatSelectedItemsArr);

        createQuoteLines({
            quoteId: this.quoteId,
            keyList: flatSelectedItemsArr
        })
        .then((result) => {
            console.log('handleFlexGroupChange > handleSave > createQuoteLines: OK');
            
            let link = '/apex/sbqq__sb?scontrolCaching=1&id=' + this.quoteId 
                + '#quote/le?qId=' + this.quoteId;

            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: link
            }});
            this.loading = false;
            this.loadingMessage = '';
        })
        .catch((error) => {
            console.error('handleFlexGroupChange > handleSave > createQuoteLines: ERROR', error);
            let errorMsg = 'An error has occurred when saving.';
            
            if(error.body && error.body.message) {
                errorMsg = error.body.message;
                console.log('error: ', error.body.message);
            }
            
            console.log(error.message);
            const evt = new ShowToastEvent({
                title: 'Incorrect value',
                message: errorMsg,
                variant: 'error',
                mode: 'dismissable'
            });
            
            this.dispatchEvent(evt);
        });
    }

    /**
     * Handles the 'Cancel' button click.
     * Navigates back to the Quote Line Editor without saving.
     */
    handleCancel() {
        let link = '/apex/sbqq__sb?scontrolCaching=1&id=' + this.quoteId 
            + '#quote/le?qId=' + this.quoteId;

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link
            }});
    }

    /**
     * Handles the navigation to the previous page.
     */
    previousHandler() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.applyFilters();
        }
    }

    /**
     * Handles the navigation to the next page.
     */
    nextHandler() {
        if(this.currentPage < this.totalPages){
            this.currentPage++;
            this.applyFilters();          
        }             
    }

    /**
     * Indicates if current page is the first page.
     */
    get isFirstPage() {
        return this.currentPage === 1;
    }

    /**
     * Indicates if current page is the last page.
     */
    get isLastPage() {
        return this.currentPage >= this.totalPages;
    }

    /**
     * Event fired when an item is selected in the 'Available Consumables' table.
     * This is only for activating or deactivating the 'Add' button.
     */
    onTableRowSelected(event) {

        if (!this.selectedFlexGroup) {
            return;
        }

        if (event && event.detail && event.detail.selectedRows) {
            this.disableAddButton = event.detail.selectedRows.length <= 0;
        }
        else {
            this.disableAddButton = true;
        }
    }

    /**
     * Event fired when an item is selected in the 'Selected Consumables' table.
     * This is only for activating or deactivating the 'Remove' button.
     */
    onSelectedConsumablesRowSelected(event) {
        if (!this.selectedFlexGroup) {
            return;
        }

        if (event && event.detail && event.detail.selectedRows) {
            this.disableRemoveButton = event.detail.selectedRows.length <= 0;
        }
        else {
            this.disableRemoveButton = true;
        }
    }

    /**
     * Gets the List of flexible groups associated to the line items included in the Quote.
     */
    async getAggregateCommitmentInQuote() {

        this.loading = true;
        this.loadingMessage = 'Loading Offer definition...';
        
        try {
            const result = await getFlexibleGroups({ quoteId: this.quoteId });

            if (result) {

                const tempArr = [];

                result.forEach(x => {
                    tempArr.push(
                        {
                            value: this.getFlexibleGroupSuffixKey(x.Flexible_Group__c, x.Deal_Line_Group__c),
                            label: this.getAggregateCommitmentName(x.SBQQ__RequiredBy__r.SBQQ__ProductName__c, x.Aggregate_Commitment_Type__c) // TODO: Add Dx / Rx
                        }
                    );
                });

                this.aggregateCommitmentsArray = tempArr;
            }
        }
        catch(error) {
            console.log('getAggregateCommitmentInQuote ERROR: ' + error);
        }
        finally {
            this.loading = false;
            this.loadingMessage = '';
        }
    }

    /**
     * 
     */
    async getSelectedMaterialsByAggregateCommitment() {

        this.loading = true;
        this.loadingMessage = 'Loading current Quote configuration...';

        try {
            const result = await getSelectedMaterialsByFlexibleGroup({ quoteId: this.quoteId });
            if (result) {
                console.log('getSelectedMaterialsByFlexibleGroup > Result', result);
                this.selectedFlexItems = {...result};
            }
            else {
                this.selectedFlexItems = {};
            }
        }
        catch(error) {
            console.log('getSelectedMaterialsByFlexibleGroup ERROR: ' + error);
            // TODO: Add error message to display. Set this.error variable.
        }
        finally {
            this.loading = false;
            this.loadingMessage = '';
        }
    }

    /**
     * Gets the list of Materials associated with a flexible group using the Cache object if it was already
     * queried or from the Apex controller if it's the first time.
     * @returns Array of FlexibleGroupItems (see the internal class structure in GetConsumablesForLargeOfferController apex class).
     */
     async getFlexibleGroupItems() {

        this.loading = true;
        this.loadingMessage = 'Loading available Products...';

        try {
            console.log('getFlexibleGroupItems > Getting from Apex');
            const result = await getFlexGroupItems({ quoteId: this.quoteId });

            if (result) {
                console.log('getFlexibleGroupItems > Result', result);
                this.flexGroupItemsCache = {...result};
            }
            else {
                console.error('getFlexibleGroupItems > Apex resuls undefined.');
                this.flexGroupItemsCache = {};
            }                
        }
        catch(err) {
            console.error('getFlexibleGroupItems ERROR', err);
            this.error = err;
            this.flexGroupItemsCache = {};
        } finally {
            this.loading = false;
        }
    }

    /**
     * 
     * @param {String} flexGroup 
     * @param {String} suffix 
     * @returns 
     */
    getFlexibleGroupSuffixKey(flexGroup, suffix) {
        const suffixText = suffix ?? 'noSuffix';
        return `${flexGroup}-${suffixText}`;
    }

    /**
     * Return the name of the Aggregate Commitment based on the parent name and the type (Rx/Dx).
     * @param {String} parentName 
     * @param {String} type 
     * @returns 
     */
    getAggregateCommitmentName(parentName, type) {
        const typeText = type ? ` (${type})` : '';
        return `${parentName}-${typeText}`;
    }

    /**
     * T
     * @param {Array} array 
     * @param {Number} pageSize 
     * @param {Number} pageNumber 
     * @returns 
     */
    paginate(array, pageSize, pageNumber) {
        return array.slice((pageNumber - 1) * pageSize, pageNumber * pageSize);
    }
}