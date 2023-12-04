/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_BrickToTerritoryTrigger
 * Description  : This trigger will handle all ZTS_GL_BrickToTerr__c Trigger Logic
 * Created By   : Slalom Consulting/Allister McKenzie
 * Created Date : 03 December 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                    Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Allister McKenzie(Slalom)    12/03/2020         Created
*****************************************************************************************************************************************/
trigger ZTS_EU_BrickToTerritoryTrigger on ZTS_GL_BrickToTerr__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTSEUBrickToTerritoryTriggerHandler(), Bypass_Triggers__mdt.ZTS_GL_BrickToTerr_Bypass__c);
}