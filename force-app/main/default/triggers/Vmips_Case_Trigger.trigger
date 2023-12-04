/****************************************************************************************************************************************** 
 * Trigger Name   : Vmips_Case_Trigger
 * Description  : This is trigger on Vmips_Case_Trigger for After Update events.
 *                
 *                  After Update
 *                  -------------
 *                  1)Assign the tasks to TBM users on Account teams
 *      
 * Created By   : Cloudsense/Laxmikanth 
 * Created Date : 07 April 2015
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Laxmikanth             01/17/2014          Created 
*****************************************************************************************************************************************/
trigger Vmips_Case_Trigger on ZTS_US_VMIPS_Case__c (after update) {

    if(!(CustomSettingService.checkIfTriggerActive('Vmips_Case_Trigger'))) return; // by pass trigger logic according to isActive checkbox in custom setting  
    if(Trigger.isUpdate){
        VmipsCaseTriggerHandler.sendEmail(Trigger.new,Trigger.oldMap);
    }
}