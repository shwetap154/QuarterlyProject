import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getQuestionRecord from '@salesforce/apex/GetPreInstallCheckListController.getQuestionRecord';

// Clinic Electric Labels
import ClinicElectic_Q1 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Electrical_Q1';
import ClinicElectic_Q2 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Electrical_Q2';
import ClinicElectic_Q3 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Electrical_Q3';
import ClinicElectic_Q4 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Electrical_Q4';

// Clinic Delivery Labels
import ClinicDelivery_Q1 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q1';
import ClinicDelivery_Q2 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q2';
import ClinicDelivery_Q3 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q3';
import ClinicDelivery_Q4 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q4';
import ClinicDelivery_Q5 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q5';
import ClinicDelivery_Q6 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q6';
import ClinicDelivery_Q7 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q7';
import ClinicDelivery_Q8 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q8';
import ClinicDelivery_Q9 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q9';
import ClinicDelivery_Q10 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Delivery_Q10';

// Clinic Communication Labels
import ClinicCommunic_Q1 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q1';
import ClinicCommunic_Q2 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q2';
import ClinicCommunic_Q3 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q3';
import ClinicCommunic_Q4 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q4';
import ClinicCommunic_Q5 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q5';
import ClinicCommunic_Q6 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q6';
import ClinicCommunic_Q7 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q7';
import ClinicCommunic_Q8 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q8';
import ClinicCommunic_Q9 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q9';
import ClinicCommunic_Q10 from '@salesforce/label/c.PreInstall_Check_List_Clinic_Communications_Q10';

// Cloud Internet Labels
import CloudInternet_Q1 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q1';
import CloudInternet_Q2 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q2';
import CloudInternet_Q3 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q3';
import CloudInternet_Q4 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q4';
import CloudInternet_Q5 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q5';
import CloudInternet_Q6 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q6';
import CloudInternet_Q7 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q7';
import CloudInternet_Q8 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q8';
import CloudInternet_Q9 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q9';
import CloudInternet_Q10 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q10';
import CloudInternet_Q11 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q11';
import CloudInternet_Q12 from '@salesforce/label/c.PreInstall_Check_List_Cloud_Internet_Q12';

// Installation and Training Labels
import InstallationAndTrain_Q1 from '@salesforce/label/c.PreInstall_Check_List_Installation_Training_Q1';
import InstallationAndTrain_Q2 from '@salesforce/label/c.PreInstall_Check_List_Installation_Training_Q2';
import InstallationAndTrain_Q3 from '@salesforce/label/c.PreInstall_Check_List_Installation_Training_Q3';

// Additional Comments Label
import addCommentsLabel from '@salesforce/label/c.PreInstall_Check_List_Additional_Comments';

// VETSCAN VS2 label
import vetscanVS2Label_Q1 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VS2_Q1';

// VETSCAN HM5 Label
import vetscanHM5Label_Q1 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_HM5_Q1';

// i-STAT Alinity v Labels
import istatAliLabel_Q1 from '@salesforce/label/c.PreInstall_Check_List_i_STAT_Alinity_v_Q1';
import istatAliLabel_Q2 from '@salesforce/label/c.PreInstall_Check_List_i_STAT_Alinity_v_Q2';

// VETSCAN Vspro Label
import vetscanVsProLabel_Q1 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_Vspro_Q1';

// VETSCAN FUSE Labels
import vetscanFuseLabel_Q1 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q1';
import vetscanFuseLabel_Q2 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q2';
import vetscanFuseLabel_Q3 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q3';
import vetscanFuseLabel_Q4 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q4';
import vetscanFuseLabel_Q5 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q5';
import vetscanFuseLabel_Q6 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q6';
import vetscanFuseLabel_Q7 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q7';
import vetscanFuseLabel_Q8 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q8';
import vetscanFuseLabel_Q9 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q9';
import vetscanFuseLabel_Q10 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q10';
import vetscanFuseLabel_Q11 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q11';
import vetscanFuseLabel_Q12 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_FUSE_Q12';

// VETSCAN IMAGYST Labels
import vetscanImagyst_Q1 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q1';
import vetscanImagyst_Q2 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q2';
import vetscanImagyst_Q3 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q3';
import vetscanImagyst_Q4 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q4';
import vetscanImagyst_Q5 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q5';
import vetscanImagyst_Q6 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q6';
import vetscanImagyst_Q7 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q7';
import vetscanImagyst_Q8 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q8';
import vetscanImagyst_Q9 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q9';
import vetscanImagyst_Q10 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q10';
import vetscanImagyst_Q11 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q11';
import vetscanImagyst_Q12 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_IMAGYST_Q12';

// VETSCAN VUE Labels
import vetscanVUE_Q1 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VUE_Q1';
import vetscanVUE_Q2 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VUE_Q2';
import vetscanVUE_Q3 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VUE_Q3';
import vetscanVUE_Q4 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VUE_Q4';
import vetscanVUE_Q5 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VUE_Q5';
import vetscanVUE_Q6 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VUE_Q6';

// VETSCAN SA Labels
import vetscanSA_Q1 from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_SA_Q1';

//Notes Label
import Notes from '@salesforce/label/c.PreInstall_Check_List_Notes';

// Analizer Labels
import analizer_1 from '@salesforce/label/c.PreInstall_Check_List_Analyzer_to_be_Removed';
import analizer_2 from '@salesforce/label/c.PreInstall_Check_List_Analyzer_to_be_Removed_Serial';
import analizer_3 from '@salesforce/label/c.PreInstall_Check_List_Analyzer_to_be_Removed_SAP';

// Header Labels
import header_clinic_name from '@salesforce/label/c.PreInstall_Check_List_Header_Clinic_Name';
import header_city from '@salesforce/label/c.PreInstall_Check_List_Header_City';
import header_address from '@salesforce/label/c.PreInstall_Check_List_Header_Address';
import header_fax from '@salesforce/label/c.PreInstall_Check_List_Header_Fax';
import header_phone from '@salesforce/label/c.PreInstall_Check_List_Header_Phone';
import header_purchaser from '@salesforce/label/c.PreInstall_Check_List_Header_Purchaser';
import header_SAPContract from '@salesforce/label/c.PreInstall_Check_List_Header_SAP_Contract';
import header_state from '@salesforce/label/c.PreInstall_Check_List_Header_State';
import header_zip from '@salesforce/label/c.PreInstall_Check_List_Header_Zip';
import header_today from '@salesforce/label/c.PreInstall_Check_List_Header_Today';
import header_email from '@salesforce/label/c.PreInstall_Check_List_Header_Email';

//Section labels
import section_clinicElectric from '@salesforce/label/c.PreInstall_Check_List_Section_Clinic_Electric';
import section_clinicDelivery from '@salesforce/label/c.PreInstall_Check_List_Section_Clinic_Delivery';
import section_clinicComm from '@salesforce/label/c.PreInstall_Check_List_Section_Clinic_Comm';
import section_clinicCloud from '@salesforce/label/c.PreInstall_Check_List_Section_Clinic_Cloud';
import section_Analyzer from '@salesforce/label/c.PreInstall_Check_List_Section_Analyzer';
import section_installTrain from '@salesforce/label/c.PreInstall_Check_List_Section_Install_Train';

//South Africa labels
import ClinicElectic_Q1_SA from '@salesforce/label/c.PreInstall_Check_List_Clinic_Electrical_Q1_SA';
import vetscanVS2Label_Q1_SA from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_VS2_Q1_SA';
import vetscanHM5Label_Q1_SA from '@salesforce/label/c.PreInstall_Check_List_VETSCAN_HM5_Q1_SA';


export default class GetPreInstallCheckList extends NavigationMixin(LightningElement) {

    @track activeSections = ['Analyzer'];
    activeSectionsMessage = '';
    marketIsSouthAfrica = false; 
    cloudInternet_Q3_Value = "N/A";

    label = {
        ClinicElectic_Q1,
        ClinicElectic_Q1_SA,
        ClinicElectic_Q2,
        ClinicElectic_Q3,
        ClinicElectic_Q4,
        ClinicDelivery_Q1,
        ClinicDelivery_Q2,
        ClinicDelivery_Q3,
        ClinicDelivery_Q4,
        ClinicDelivery_Q5,
        ClinicDelivery_Q6,
        ClinicDelivery_Q7,
        ClinicDelivery_Q8,
        ClinicDelivery_Q9,
        ClinicDelivery_Q10,
        ClinicCommunic_Q1,
        ClinicCommunic_Q2,
        ClinicCommunic_Q3,
        ClinicCommunic_Q4,
        ClinicCommunic_Q5,
        ClinicCommunic_Q6,
        ClinicCommunic_Q7,
        ClinicCommunic_Q8,
        ClinicCommunic_Q9,
        ClinicCommunic_Q10,
        CloudInternet_Q1,
        CloudInternet_Q2,
        CloudInternet_Q3,
        CloudInternet_Q4,
        CloudInternet_Q5,
        CloudInternet_Q6,
        CloudInternet_Q7,
        CloudInternet_Q8,
        CloudInternet_Q9,
        CloudInternet_Q10,
        CloudInternet_Q11,
        CloudInternet_Q12,
        InstallationAndTrain_Q1,
        InstallationAndTrain_Q2,
        InstallationAndTrain_Q3,
        addCommentsLabel,
        vetscanVS2Label_Q1,
        vetscanVS2Label_Q1_SA,
        vetscanHM5Label_Q1,
        vetscanHM5Label_Q1_SA,
        istatAliLabel_Q1,
        istatAliLabel_Q2,
        vetscanVsProLabel_Q1,
        vetscanFuseLabel_Q1,
        vetscanFuseLabel_Q2,
        vetscanFuseLabel_Q3,
        vetscanFuseLabel_Q4,
        vetscanFuseLabel_Q5,
        vetscanFuseLabel_Q6,
        vetscanFuseLabel_Q7,
        vetscanFuseLabel_Q8,
        vetscanFuseLabel_Q9,
        vetscanFuseLabel_Q10,
        vetscanFuseLabel_Q11,
        vetscanFuseLabel_Q12,
        vetscanImagyst_Q1,
        vetscanImagyst_Q2,
        vetscanImagyst_Q3,
        vetscanImagyst_Q4,
        vetscanImagyst_Q5,
        vetscanImagyst_Q6,
        vetscanImagyst_Q7,
        vetscanImagyst_Q8,
        vetscanImagyst_Q9,
        vetscanImagyst_Q10,
        vetscanImagyst_Q11,
        vetscanImagyst_Q12,        
        vetscanVUE_Q1,
        vetscanVUE_Q2,
        vetscanVUE_Q3,
        vetscanVUE_Q4,
        vetscanVUE_Q5,
        vetscanVUE_Q6,
        vetscanSA_Q1,
        Notes,
        analizer_1,
        analizer_2,
        analizer_3,
        header_clinic_name,
        header_city,
        header_address,
        header_fax,
        header_phone,
        header_purchaser,
        header_SAPContract,
        header_state,
        header_zip,
        header_today,
        header_email,
        section_clinicElectric,
        section_clinicDelivery,
        section_clinicComm,
        section_clinicCloud,
        section_Analyzer,
        section_installTrain
    };
    
    @api quoteId;
    @track questionRecord = {};
    @track data;    

    @wire(getQuestionRecord, { quoteId: '$quoteId'})
    wiredQuestionRecord(value) {
        if (value.error) {
            console.log('value: ', value);            
            this.data = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Pre-Install Checklist',
                    message: value.error.body.message, 
                    variant: 'warning'
                }),
            );
            let link = '/' + this.quoteId;
            this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link
            }});

        } 
        else if (value.data && value.data.Quote__c != null) 
        {
            console.log("Quote id is >> " , this.quoteId);
            var questionObj = {
                recordId : value.data.Id,
                addressId : value.data.Quote__r.Address__c,
                accountId : value.data.Quote__r.SBQQ__Account__c,
                opportunityId : value.data.Quote__r.SBQQ__Opportunity2__c,
                contactId : value.data.Quote__r.SBQQ__Opportunity2__r.Purchasing_Contact__c,
                IsClinicElectricalRelevant : value.data.Is_Clinic_Electical_Relevant_for_Quote__c,
                IsClinicDeliveryRelevant : value.data.Is_Clinic_Delivery_Relevant_for_Quote__c,
                IsClinicCommunicDeliveryRelevant : value.data.Is_Clinic_Communic_Relevant_for_Quote__c,
                IsCloudInternetRelevant : value.data.Is_Cloud_Internet_Relevant_for_Quote__c,
                IsInstallationAndTrainRelevant : value.data.Is_InstallationTrain_Relevant_for_Quote__c,
                IsVETSCANvs2Relevant: value.data.Is_VETSCAN_VS2_Relevant_for_Quote__c,
                IsVETSCANhm5Relevant: value.data.Is_Is_VETSCAN_HM5_Relevant_for_Quote__c,
                IsISTATRelevant: value.data.Is_iSTAT_Alinity_Relevant_for_Quote__c,
                isVETSCANvSProRelevant: value.data.Is_VETSCAN_Vspro_Relevant_for_Quote__c,
                isVETSCANSARelevant: value.data.Is_VETSCAN_SA_Relevant_for_Quote__c,
                isVETSCANFUSERelevant: value.data.Is_VETSCAN_FUSE_Relevant_for_Quote__c,
                isVETSCANImagystRelevant: value.data.Is_VETSCAN_IMAGYST_Relevant_for_Quote__c,
                isVETSCANIvueRelevant: value.data.Is_VETSCAN_VUE_Relevant_for_Quote__c,
                quoteId: value.data.Quote__c,
                status: value.data.Status__c,
                market: value.data.Quote__r.Sales_Org_Market__r.Name
            }
            this.questionRecord = questionObj;            
            console.log('questionRecord: ', this.questionRecord);
            console.log('questionRecord account : ', this.questionRecord.accountId);    
            this.data = true;    
            this.QuoteData = true;
            console.log('this.questionRecord.market>'+this.questionRecord.market);
            if(this.questionRecord.market === 'South Africa'){
                this.marketIsSouthAfrica = true;
                this.cloudInternet_Q3_Value = "N/A";
            }    
        }
        else if (value.data && value.data.Quote__c == null) 
        {
            console.log("Opportunity block for non cpq users ");
            var questionObj = {
                recordId : value.data.Id,
                addressId : value.data.Opportunity__r.Account.ZTS_EU_Primary_Address__c,
                accountId : value.data.Opportunity__r.AccountId,
                opportunityId : value.data.Opportunity__c,
                contactId : value.data.Opportunity__r.Purchasing_Contact__c,
                IsClinicElectricalRelevant : value.data.Is_Clinic_Electical_Relevant_for_Quote__c,
                IsClinicDeliveryRelevant : value.data.Is_Clinic_Delivery_Relevant_for_Quote__c,
                IsClinicCommunicDeliveryRelevant : value.data.Is_Clinic_Communic_Relevant_for_Quote__c,
                IsCloudInternetRelevant : value.data.Is_Cloud_Internet_Relevant_for_Quote__c,
                IsInstallationAndTrainRelevant : value.data.Is_InstallationTrain_Relevant_for_Quote__c,
                IsVETSCANvs2Relevant: value.data.Is_VETSCAN_VS2_Relevant_for_Quote__c,
                IsVETSCANhm5Relevant: value.data.Is_Is_VETSCAN_HM5_Relevant_for_Quote__c,
                IsISTATRelevant: value.data.Is_iSTAT_Alinity_Relevant_for_Quote__c,
                isVETSCANvSProRelevant: value.data.Is_VETSCAN_Vspro_Relevant_for_Quote__c,
                isVETSCANSARelevant: value.data.Is_VETSCAN_SA_Relevant_for_Quote__c,
                isVETSCANFUSERelevant: value.data.Is_VETSCAN_FUSE_Relevant_for_Quote__c,
                isVETSCANImagystRelevant: value.data.Is_VETSCAN_IMAGYST_Relevant_for_Quote__c,
                isVETSCANIvueRelevant: value.data.Is_VETSCAN_VUE_Relevant_for_Quote__c,
               // quoteId: value.data.Quote__c,
                status: value.data.Status__c,
                market: value.data.Opportunity__r.Market__r.Name
            }
            this.questionRecord = questionObj;    
            console.log('whole data ' , value.data);        
            console.log('questionRecord: ', this.questionRecord);
            console.log('questionRecord account : ', this.questionRecord.accountId);    
            console.log('questionRecord address ' , this.questionRecord.addressId);
            this.data = true;
            this.OpportunityData = true; 
            console.log('this.questionRecord.market>'+this.questionRecord.market);
            if(this.questionRecord.market === 'South Africa'){
                this.marketIsSouthAfrica = true;
                this.cloudInternet_Q3_Value = "N/A";
            }       
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;

        if (openSections.length === 0) {
            this.activeSectionsMessage = 'All sections are closed';
        } else {
            this.activeSectionsMessage =
                'Open sections: ' + openSections.join(', ');
        }
    }
    handleCancel() {

        let link = '/' + this.quoteId;

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link
            }});

    }

    handleSuccess() {
        console.log('handleSuccess, dispatch toast');
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Pre-installation checklist was saved successfully',
                variant: 'Success',
            })
        );
        this.handleCancel();
            
    }

    handleError(event) {        
        //console.log('this is the error:', JSON.stringify(event.detail));

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Pre-installation checklist was not saved. Please provide additional required information.',
                variant: 'Error',
            })
        );
        
    }
}