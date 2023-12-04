/****************************************************************************************************************************************** 
 * Class Name   : AccountProductPotentialTrigger
 * Description  : This trigger will handle all ZTS_EU_Account_Product_Potential__c Trigger Logic
 * Created By   : Slalom Consulting/Allister McKenzie
 * Created Date : 24 November 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie(Slalom)    11/24/2020          Created
*****************************************************************************************************************************************/
trigger AccountProductPotentialTrigger on ZTS_EU_Account_Product_Potential__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new AccountProductPotentialTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Account_Product_Potential_Bypass__c);       
}