/*
  @File Name          : configurableRelatedList.js
  @Description        : This file contains all the front end logic for the component, uses the information from the
                        getRelatedList apex class to populate the data table, and the values from the lightning app builder 
                        to customize the related list display (icon, name). This file also contains the logic for the pagination 
                        on the component and the logic for the row actions.
  @Author             : Slalom run:CRM
  @Group              : run:CRM
  @Last Modified By   : miguel.torres@slalom.com
  @Last Modified On   : 6/17/2020, 10:00:00 AM
*/

import { LightningElement, api, track ,wire} from 'lwc';
import getRelatedList from '@salesforce/apex/ConfigurableRelatedListController.getRelatedList';
import { helper } from './configurableRelatedListhelper.js';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
 
export default class ConfigurableRelatedList extends LightningElement {

    // app builder variables
    @api customMetadataName;
    @api recordId;
    @api relatedListObject;
    @api maxNumberRecords;
    @api listIcon;
    @api displayedName;
    @api showsNameColumn;
    @api showCreateButton;
    @api showDeleteButton;
    @api showsEditButton;

    // set up variables 
    @track makeUrl;
    @track makePercent;
    @track makeTime;
    @track columns;
    @track objectName;
    @track objectLabel;
    @track numberOfObjects;
    @track canCreate;
    @track parentRecordField;
    @track createFields;
    @track hasRecordType = false;
    @track RecordTypeId;
    
    // pagination variables
    @track page;
    @track perpage;
    @track set_size;
    @track pages;
    @track data;
    @track needsPagination;

    // tracking record marked for edit or delete
    @track currentRecord;

    //delete or edit record modals
    @track deleteModal = false;
    @track updateModal = false;
    @track createModal = false;

    //Sorting variables
    sortDirection = 'asc';
    sortedBy;
   
    // used for refreshApex when data changes
    wireData;

    // String customMetadataName, String id, String recordType
    @wire(getRelatedList, { customMetadataName: '$customMetadataName',  id: '$recordId', baseCreate: false})
    wiredCallBack(results) {
       this.makeUrl = [];
       this.makeTime = [];
       this.makePercent=[];
       this.pages = [];
       this.data = [];
       this.needsPagination = false;
       this.page = 1;
       this.wireData = results

        if (results.data){

            const { recordList, labelNames, objectName, objectLabel, canCreate, canDelete, parentRecordField, RecordTypeId, createFields } = results.data;
            
            if (RecordTypeId) {
                this.hasRecordType = true;
                this.RecordTypeId = RecordTypeId;
            }

            this.objectLabel = objectLabel;
            this.createFields = createFields;
            this.objectName = objectName;

            // if admin wants to show create button and current user has create permission on object.
            if (canCreate && this.showCreateButton) this.canCreate = true;

            // used for auto populating id of the page your on in the create form
            this.parentRecordField = parentRecordField;

            // used for the link to the record based on id for later
            let keyList
            if (recordList.length > 0) {
                keyList = helper.findKeyList(recordList);  
            } else {
                keyList = []
            }

            if (keyList.length > 0) {
                const idIndex = keyList.indexOf('Id');
                const id = keyList.splice(idIndex, 1);
                keyList.unshift(id[0]);
    
                // makes the columns for datatable
                const result = helper.makeColumns(labelNames, keyList);
    
                this.makeUrl = result.makeUrl;
                this.makeTime  = result.timeList;
                this.makePercent = result.percentList;

                // had permissions issues with Id and got around with parse and stringify
                const formattedValues = JSON.parse(JSON.stringify(recordList));
                
                //iterate all the records from the apex class to make all the references urls
                formattedValues.forEach(value => {
                    let fields = Object.keys(value)
                    fields.forEach(field => {
                        if (this.makeUrl.includes(field)){
                            value[field] = '/' + value[field];    
                        }
                        else if (this.makePercent.includes(field)){
                            value[field] = value[field]/100;    
                        }

                        else if (this.makeTime.includes(field)){
                            var date = new Date();
                            date.setHours(0,0,0,0);
                            var miliDate = date.getTime() + value[field]
                            value[field] = new Date(miliDate)
                            
                        }

                        else if(typeof value[field] === 'object'){
                            value[field + 'IdLabel'] = value[field].Name;       
                        }

                    })
                })

                const actions = [];

                // if admin wants edit button to show on page. Edit button respects current user permissions.
                if (this.showsEditButton === true) actions.push({label: 'Edit', name: 'edit' });

                // if admin wants delete button to show on page and current user has delete permission on object.
                if (canDelete && this.showDeleteButton) actions.push({ label: 'Delete', name: 'delete' })

                const actionColumn = {
                    type: 'action',
                    typeAttributes: { rowActions: actions },
                };

                // only add if there is action columns
                if (actions.length > 0) result.columnList.push(actionColumn);

                // if admin does not want to show name column such as when name column is an auto number
                if (this.showsNameColumn === false) result.columnList.shift();

                this.columns = result.columnList;

                this.list = formattedValues;
                this.numberOfObjects = formattedValues.length;

                if (this.maxNumberRecords < this.numberOfObjects) {
                    this.needsPagination = true
                }

                //this line is to select all the records from the beginning
                this.data = this.list;
                this.setPages(this.data);
            } else {
                this.columns = [];
                this.numberOfObjects = 0;
            }

        } else if (results.error) {
            console.log(results.error);
        }
    }

    connectedCallback(){
        this.perpage = this.maxNumberRecords;
        this.set_size = this.maxNumberRecords;
    }

    handleRowAction(event) {
        let id = event.detail.row.Id
        id = id.substring(1);
        this.currentRecord = id ;
        const actionName = event.detail.action.name;
        
        switch (actionName) {
            case 'delete':
                this.openDeleteModal();
                break;
            case 'edit':
                this.openEditModal();
                break;
            default:
        }
    }

    // modal functions 

    deleteRowRecord() {
        
        deleteRecord(this.currentRecord)
            .then(() => {
                this.closeModalDelete();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Deleted',
                        variant: 'success',
                    }),
                );
                return refreshApex(this.wireData);
            })
            .catch(error => {
                this.closeModalDelete();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error While Deleting Record',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });
    }

    openDeleteModal() {
        this.deleteModal = true;
    }

    openEditModal() {
        this.updateModal = true;
    }
    
    openCreateModal() {
        this.createModal = true;
    }


    closeCreateModal(){
        this.createModal = false;
    }

    closeModalDelete() {    
        this.deleteModal = false;
    }

    closeModalUpdate(){
        this.updateModal = false;
        return refreshApex(this.wireData);
    }

    handleNewRecord(){
        this.createModal = false;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'New Record Created',
                variant: 'success',
            }),
        );
        return refreshApex(this.wireData);
    }

    // The functions below correspond to the Pagination Logic 

    renderedCallback() {
        this.renderButtons();
    }

    renderButtons = () => {
        this.template.querySelectorAll('button').forEach((but) => {
            but.style.backgroundColor = this.page === parseInt(but.dataset.id, 10) ? 'dodgerblue' : 'white';
            but.style.color = this.page === parseInt(but.dataset.id, 10) ? 'white' : 'black';
        });
    }
    get pagesList() {
        let mid = Math.floor(this.set_size / 2) + 1;
        var list;
        if (this.page > mid) {
                list = this.pages.slice(this.page - mid, this.page + mid - 1);
        } else {
            list = this.pages.slice(0, this.set_size);
        }
        return list;
    }

    pageData = () => {
        let page = this.page;
        let perpage = this.set_size;
        let startIndex = (page * perpage) - perpage;
        let endIndex = (page * perpage);
        let result = this.data.slice(startIndex, endIndex);
        return result;
    }

    setPages = (data) => {
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }

    get hasPrev() {
        return this.page > 1;
    }

    get hasNext() {
        return this.page < this.pages.length
    }

    //Increase this.page value to advance on the pagination 
    onNext = () => {
        ++this.page;
    }
    //Decrease this.page value to advance on the pagination 
    onPrev = () => {
        --this.page;
    }
    onPageClick = (e) => {
        this.page = parseInt(e.target.dataset.id, 10);
    }

    get currentPageData() {
        return this.pageData();
    }

    // The next two function make the sorting functionality work

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                    return primer(x[field]);
                }
            : function(x) {
                    return x[field];
                };
        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        var { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.data];

        if (sortedBy == 'Id' && this.object !== 'Case'){
            sortedBy = 'Name'
        } else if (sortedBy == 'Id' && this.object == 'Case'){
            sortedBy = 'CaseNumber'
        }

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
    
        if (sortedBy == 'Name' || sortedBy == 'CaseNumber'){
            sortedBy = 'Id'
        }

        this.data = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

}