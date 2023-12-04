/****************************************************************************************************************************************** 
 * Class Name   : AccountSpeciesPotentialTrigger
 * Description  : This trigger will handle all ZTS_EU_Account_Species_Potential__c Trigger Logic
 * Created By   : Slalom Consulting/Allister McKenzie
 * Created Date : 19 November 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                        Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie(Slalom)        11/19/2020          Created
*****************************************************************************************************************************************/
trigger AccountSpeciesPotentialTrigger on ZTS_EU_Account_Species_Potential__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new AccountSpeciesPotentialTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Account_Species_Potential_Bypass__c);
}