import { LightningElement , api, wire, track} from 'lwc';
import getAccountAlerts from '@salesforce/apex/AccountAlertController.getLatestAccountAlerts';
import { NavigationMixin } from 'lightning/navigation';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import ACCOUNT_ALERT_OBJECT from '@salesforce/schema/Account_Alert__c';
import ALERT_FIELD from '@salesforce/schema/Account_Alert__c.Alert__c';

export default class AccounNotesDisplay extends NavigationMixin(LightningElement) {
    mapData = [];
     error;
     @api recordId;
     @api alertsMap;
     @api alertFirstwoRec;
     accountAlertsMap;
     showViewAllLink = false;
     showNewAccountAlertPopup = false;
     objectApiName = ACCOUNT_ALERT_OBJECT;
     alertField = ALERT_FIELD;

    @wire(getAccountAlerts, { recordId: '$recordId'})
    wireMapData({error, data}) {
        if (data) {
            var alerts = data;
            for(var key in alerts){
               this.mapData.push({key:key, value:alerts[key]});    
            }
            let obj = JSON.parse(JSON.stringify(this.mapData));
            this.alertsMap = obj;
            this.alertFirstwoRec =this.alertsMap.slice(2);
            if (this.alertsMap && this.alertsMap.length > 2) {
                console.log('inside'+this.alertsMap.length);
                this.showViewAllLink = true;
            }
        } else if (error) {
            this.error = error;
        }
    }

    handleViewAllClick() {
        window.open(window.location.origin+'/lightning/r/Account/'+this.recordId+'/related/Account_Alerts__r/view','_self');
    }

   
    handleAddAccountAlertClick(){
        this.showNewAccountAlertPopup = true;
    }

    hideModalBox(){
        this.showNewAccountAlertPopup = false;
    }
    
}