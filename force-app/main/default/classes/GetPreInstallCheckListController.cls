/*
* File Name     :  GetPreInstallCheckListController
* @description  :  Controller Class for LWC GetPreInstallChecklist
* @author       :  
* Modification Log
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0	  06/09/2023    Rahul Kumar	@DEL		Modified the controller to handle preInstallCheclist feature for Non CPQ User
*/
public with sharing class GetPreInstallCheckListController {
    
    public class NotPrimaryQuoteException extends Exception {}    
    private static final String OPP_PREFIX = '006';
    
    
    @AuraEnabled(cacheable=true)
    public static PreInstallCheckList__c getQuestionRecord(String quoteId) {

        String primaryQuote ;
        List<PreInstallCheckList__c> preInstallCheckList = new List <PreInstallCheckList__c>();
        try{
            // If recordId is from Oppty, then get the primary Quote
            if (quoteId != null && quoteId.startsWith(OPP_PREFIX)) {
                // Get Primary Quote
                List<Opportunity> opp = [SELECT Id, SBQQ__PrimaryQuote__c,Market__r.Is_PreInstallCheckList_Enable__c
                                         FROM Opportunity
                                         WHERE Id = :quoteId];
               
                
                if (!opp.isEmpty() && !opp[0].Market__r.Is_PreInstallCheckList_Enable__c) {  
                    throw new NotPrimaryQuoteException(System.Label.PreInstall_Check_List_Warning_No_Market_Available);
                }
                if (!opp.isEmpty() && opp[0].SBQQ__PrimaryQuote__c == null) {               
                    throw new NotPrimaryQuoteException(System.Label.PreInstall_Check_List_Warning_No_Quote);
                }
                primaryQuote = opp[0].SBQQ__PrimaryQuote__c;
                
            }
            
			if(!(checkCPQ_PermissionSet(userinfo.getUserId())) && quoteId != null && quoteId.startsWith(OPP_PREFIX)) 
            {
                 preInstallCheckList.add([SELECT Id,Opportunity__c, Is_Clinic_Electical_Relevant_for_Quote__c,
                                         Opportunity__r.AccountId, Opportunity__r.Purchasing_Contact__c, Opportunity__r.Account.ZTS_EU_Primary_Address__c,
                                         Is_Clinic_Delivery_Relevant_for_Quote__c,Is_Clinic_Communic_Relevant_for_Quote__c,Is_Cloud_Internet_Relevant_for_Quote__c,
                                         Is_InstallationTrain_Relevant_for_Quote__c,Is_VETSCAN_VS2_Relevant_for_Quote__c,Is_Is_VETSCAN_HM5_Relevant_for_Quote__c,
                                         Is_iSTAT_Alinity_Relevant_for_Quote__c,Is_VETSCAN_Vspro_Relevant_for_Quote__c,Is_VETSCAN_SA_Relevant_for_Quote__c,
                                         Is_VETSCAN_FUSE_Relevant_for_Quote__c,Is_VETSCAN_IMAGYST_Relevant_for_Quote__c,Is_VETSCAN_VUE_Relevant_for_Quote__c,
                                         Status__c,Opportunity__r.Market__r.Name,Opportunity__r.Market__r.Is_PreInstallCheckList_Enable__c FROM PreInstallCheckList__c
                                         WHERE Opportunity__c = :quoteId ORDER BY CreatedDate DESC
                                         LIMIT 1]);
            }
            else
            {	
                primaryQuote = (primaryQuote != null)||(String.isNotBlank(primaryQuote)) ? primaryQuote: quoteId ;
                preInstallCheckList.add([SELECT Id, Is_Clinic_Electical_Relevant_for_Quote__c,
                                         Quote__r.SBQQ__Account__c, Quote__r.SBQQ__Opportunity2__r.Purchasing_Contact__c, Quote__r.Address__c,
                                         Is_Clinic_Delivery_Relevant_for_Quote__c,Is_Clinic_Communic_Relevant_for_Quote__c,Is_Cloud_Internet_Relevant_for_Quote__c,
                                         Is_InstallationTrain_Relevant_for_Quote__c,Is_VETSCAN_VS2_Relevant_for_Quote__c,Is_Is_VETSCAN_HM5_Relevant_for_Quote__c,
                                         Is_iSTAT_Alinity_Relevant_for_Quote__c,Is_VETSCAN_Vspro_Relevant_for_Quote__c,Is_VETSCAN_SA_Relevant_for_Quote__c,
                                         Is_VETSCAN_FUSE_Relevant_for_Quote__c,Is_VETSCAN_IMAGYST_Relevant_for_Quote__c,Is_VETSCAN_VUE_Relevant_for_Quote__c,
                                         Quote__c,Quote__r.SBQQ__Opportunity2__c, Status__c,Quote__r.SBQQ__Primary__c,Quote__r.Sales_Org_Market__r.Name,
                                         Quote__r.Sales_Org_Market__r.Is_PreInstallCheckList_Enable__c
                                         FROM PreInstallCheckList__c
                                         WHERE Quote__c = :primaryQuote
                                         LIMIT 1]);
                
                if (preInstallCheckList.isEmpty() || !preInstallCheckList[0].Quote__r.Sales_Org_Market__r.Is_PreInstallCheckList_Enable__c) {
                  
                    throw new NotPrimaryQuoteException(System.Label.PreInstall_Check_List_Warning_No_Market_Available);
                    
                }
                if (!preInstallCheckList[0].Quote__r.SBQQ__Primary__c) {
                    throw new NotPrimaryQuoteException(System.Label.PreInstall_Check_List_Warning_No_Primary);
                }
            }
                       
            
        }
        catch (QueryException ex)
        {	
            System.debug('User does not have access to Object__c Exception : - ' + ex.getMessage());
            System.debug(ex.getStackTraceString());
            throw new NotPrimaryQuoteException('User does not have access to Pre Install Checklist Object');
            
        }
    
        return preInstallCheckList[0];
    } 
    
    //Method to check if user have CPQ License
    
    public static Boolean checkCPQ_PermissionSet(String userName) 
    {	
        List<PermissionSetLicenseAssign> assignedLicenseList = [SELECT PermissionSetLicense.MasterLabel FROM PermissionSetLicenseAssign where PermissionSetLicenseAssign.AssigneeId =: userName AND PermissionSetLicense.MasterLabel IN ('Salesforce CPQ License','Salesforce CPQ AA License')];
        return assignedLicenseList.size() > 0;
    }
}