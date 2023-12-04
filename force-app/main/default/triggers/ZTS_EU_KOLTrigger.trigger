/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_KOLTrigger
 * Description  : All Trigger Logic for ZTS_EU_KOL object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 11th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/11/2020          Created 
*****************************************************************************************************************************************/
trigger ZTS_EU_KOLTrigger on ZTS_EU_KOL__c (before insert, before update, before delete, after insert, after update, after delete, after undelete)
{
	DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_KOLTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_KOL_Bypass__c);
}