import { LightningElement, api } from 'lwc';
import getAccountList from '@salesforce/apex/AccountHelper.getAccountList';
export default class LightningDatatableLWCExample extends LightningElement {
    columns = [
    {
            label: 'Theraupeutic Group',
            fieldName: 'Theraupeutic_Group__c',
            type: 'Picklist',
            sortable: true,
            wrapText: true
        },
        {
            label: 'Product',
            fieldName: 'Applicable_Product_Lines__c',
            type: 'Picklist',
            sortable: true,
            wrapText: true
        },
        {
            label: 'Product Sales',
            fieldName: 'Product_Sales__c',
            type: 'Picklist',
            sortable: true,
            wrapText: true
        },
        {
            label: 'Grand total',
            fieldName: 'Grand_Total__c',
            type: 'currency',
            sortable: true,
            wrapText: true,
            typeAttributes: { maximumFractionDigits: '2' },
    cellAttributes: { alignment: 'left' } },
        
        {
            label: 'APR',
            fieldName: 'APR__c',
            type: 'currency',
            sortable: true,
            wrapText: true,
            typeAttributes: { maximumFractionDigits: '2' },
    cellAttributes: { alignment: 'left' }
        },
        {
            label: 'AUG',
            fieldName: 'AUG__c',
            type: 'currency',
            sortable: true,
            wrapText: true,
            typeAttributes: { maximumFractionDigits: '2' },
    cellAttributes: { alignment: 'left' }
        },
        {
            label: 'FEB',
            fieldName: 'FEB__c',
            type: 'currency',
            sortable: true,
            wrapText: true,
            typeAttributes: { maximumFractionDigits: '2' },
    cellAttributes: { alignment: 'left' }
        },
        {
            label: 'MAY',
            fieldName: 'MAY__c',
            type: 'currency',
            sortable: true,
            wrapText: true,
            typeAttributes: { maximumFractionDigits: '2' },
    cellAttributes: { alignment: 'left' }
        },
 
    ];
    @api accList;
}