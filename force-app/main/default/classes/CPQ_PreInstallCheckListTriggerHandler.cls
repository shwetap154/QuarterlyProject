/**
* File Name     :  CPQ_PreInstallCheckListTriggerHandler
* @description  :  Handler class for PreInstallCheckList__c.                    
* @author       :  Ramiro Alvarez @ ATG - Advanced Technology Group
* Modification Log
===================================================================================================
* Ver.    Date          Author              	Modification
---------------------------------------------------------------------------------------------------
* 1.0     4/20/2021		Ramiro Alvarez @ ATG    Created the Class.
* 2.0	  08/18/2023	Rahul Kumar @Deloitte   commented out the 'preInstallCheckListCompletion' method due to its inclusion of redundant code.
*/
public with sharing class CPQ_PreInstallCheckListTriggerHandler {  
    
    /**
     * @description Handles the Before Insert event.
     * @param triggerNewList List of new version of the orders, provided by the trigger.   
     */
    public static void handleBeforeUpdate(List<PreInstallCheckList__c> triggerNewList, Map<Id, PreInstallCheckList__c> triggerOldMap) {
      
      //CPQATG-1288
      //preInstallCheckListCompletion(triggerNewList);
      
      preInstallCheckListStatusUpdate(triggerNewList);
    }  


   /**
   * @description Set Is_CheckList_Complete__c checkbox to true if checklist is complete
   * @param newList List of new version of the orders, provided by the trigger.   
   */
/*  private static void preInstallCheckListCompletion(List<PreInstallCheckList__c> newList) {
      
    for (PreInstallCheckList__c preInstall : newList) {

        if (preInstall.Analizer_to_be_Removed_Complete__c &&
            preInstall.Clinic_Communications_Complete__c &&
            preInstall.Clinic_Delivery_Complete__c &&
            preInstall.Clinic_Electrical_Complete__c &&
            preInstall.Cloud_Internet_Complete__c &&	
            preInstall.i_STAT_Alinity_Complete__c &&	
            preInstall.Installation_Training_Complete__c &&
            preInstall.VETSCAN_FUSE_Complete__c &&
            preInstall.VETSCAN_HM5_Complete__c &&
            preInstall.VETSCAN_IMAGYST_Complete__c &&
            preInstall.VETSCAN_SA_Complete__c &&
            preInstall.VETSCAN_VS2_Complete__c &&
            preInstall.VETSCAN_Vspro_Complete__c &&
            preInstall.VETSCAN_VUE_Complete__c) {
                
                preInstall.Is_CheckList_Complete__c = true;                
            }
            else {
                preInstall.Is_CheckList_Complete__c = false;
            }
    }

  }*/


  /**
   * @description Update status with Not Started, In progress or Complete values.
   * @param newList List of new version of the orders, provided by the trigger.   
   */
  private static void preInstallCheckListStatusUpdate(List<PreInstallCheckList__c> newList) {
      
    for (PreInstallCheckList__c preInstall : newList) {

        if (preInstall.Analizer_to_be_Removed_Complete__c &&
            preInstall.Clinic_Communications_Complete__c &&
            preInstall.Clinic_Delivery_Complete__c &&
            preInstall.Clinic_Electrical_Complete__c &&
            preInstall.Cloud_Internet_Complete__c &&	
            preInstall.i_STAT_Alinity_Complete__c &&	
            preInstall.Installation_Training_Complete__c &&
            preInstall.VETSCAN_FUSE_Complete__c &&
            preInstall.VETSCAN_HM5_Complete__c &&
            preInstall.VETSCAN_IMAGYST_Complete__c &&
            preInstall.VETSCAN_SA_Complete__c &&
            preInstall.VETSCAN_VS2_Complete__c &&
            preInstall.VETSCAN_Vspro_Complete__c &&
            preInstall.VETSCAN_VUE_Complete__c) {
                
                preInstall.Is_CheckList_Complete__c = true;  
                preInstall.Status__c = 'Complete';                
            }
            else if(!preInstall.Analizer_to_be_Removed_Complete__c &&
            (!preInstall.Clinic_Communications_Complete__c || (preInstall.Clinic_Communications_Complete__c && !preInstall.Is_Clinic_Communic_Relevant_for_Quote__c)) &&
            (!preInstall.Clinic_Delivery_Complete__c || (preInstall.Clinic_Delivery_Complete__c && !preInstall.Is_Clinic_Delivery_Relevant_for_Quote__c)) &&
            (!preInstall.Clinic_Electrical_Complete__c || (preInstall.Clinic_Electrical_Complete__c && !preInstall.Is_Clinic_Electical_Relevant_for_Quote__c)) &&
            (!preInstall.Cloud_Internet_Complete__c || (preInstall.Cloud_Internet_Complete__c && !preInstall.Is_Cloud_Internet_Relevant_for_Quote__c)) &&
            (!preInstall.i_STAT_Alinity_Complete__c || (preInstall.i_STAT_Alinity_Complete__c && !preInstall.Is_iSTAT_Alinity_Relevant_for_Quote__c)) &&
            (!preInstall.Installation_Training_Complete__c || (preInstall.Installation_Training_Complete__c && !preInstall.Is_InstallationTrain_Relevant_for_Quote__c)) &&
            (!preInstall.VETSCAN_FUSE_Complete__c || (preInstall.VETSCAN_FUSE_Complete__c && !preInstall.Is_VETSCAN_FUSE_Relevant_for_Quote__c)) &&
            (!preInstall.VETSCAN_HM5_Complete__c || (preInstall.VETSCAN_HM5_Complete__c && !preInstall.Is_Is_VETSCAN_HM5_Relevant_for_Quote__c)) &&
            (!preInstall.VETSCAN_IMAGYST_Complete__c || (preInstall.VETSCAN_IMAGYST_Complete__c && !preInstall.Is_VETSCAN_IMAGYST_Relevant_for_Quote__c)) &&
            (!preInstall.VETSCAN_SA_Complete__c || (preInstall.VETSCAN_SA_Complete__c && !preinstall.Is_VETSCAN_SA_Relevant_for_Quote__c)) &&
            (!preInstall.VETSCAN_VS2_Complete__c || (preInstall.VETSCAN_VS2_Complete__c && !preinstall.Is_VETSCAN_VS2_Relevant_for_Quote__c)) &&
            (!preInstall.VETSCAN_Vspro_Complete__c || (preInstall.VETSCAN_Vspro_Complete__c && !preInstall.Is_VETSCAN_Vspro_Relevant_for_Quote__c)) &&
            (!preInstall.VETSCAN_VUE_Complete__c || (preInstall.VETSCAN_VUE_Complete__c && !preInstall.Is_VETSCAN_VUE_Relevant_for_Quote__c))) {
                
				preInstall.Is_CheckList_Complete__c = false;
                preInstall.Status__c = 'Not Started';
                
            }
            else {
                preInstall.Is_CheckList_Complete__c = false;
                preInstall.Status__c = 'In Progress';
            }
    }

  }

}