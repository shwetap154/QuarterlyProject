/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_Species_ProductTrigger
 * Description  : This trigger will handle all ZTS_EU_Species_Product__c Trigger Logic
 * Created By   : Slalom Consulting/Allister McKenzie
 * Created Date : 25 November 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date                Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie(Slalom)    11/25/2020          Created
*****************************************************************************************************************************************/
trigger ZTS_EU_Species_ProductTrigger on ZTS_EU_Species_Product__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new EUSpeciesProductTriggerHandler(), Bypass_Triggers__mdt.Species_Product_Bypass__c);
}