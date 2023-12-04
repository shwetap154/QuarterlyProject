import { LightningElement , api, wire} from 'lwc';
import getAccountAlerts from '@salesforce/apex/AccountAlertController.getLatestAccountAlerts';

export default class AccounNotesDisplay extends LightningElement {
    @api accountId;
    accountAlt;

    @wire(getAccountAlerts)
    wiredAccounts({ error, data }) {
        if (data) {
            this.accountAlt = data;
        } else if (error) {
            console.error('Error fetching account records:', error);
        }
    }
}