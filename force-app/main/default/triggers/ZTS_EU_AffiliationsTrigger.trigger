/****************************************************************************************************************************************** 
 * Class Name   : ZTS_EU_AffiliationsTrigger
 * Description  : This trigger will handle all ZTS_EU_Affiliations__c Trigger Logic
 * Created By   : Slalom Consulting/David Stern
 * Created Date : 07 May 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * David Stern(Slalom)     05/07/2020          Created
*****************************************************************************************************************************************/
trigger ZTS_EU_AffiliationsTrigger on ZTS_EU_Affiliations__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_AffiliationsTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Affiliations_Bypass__c);
}