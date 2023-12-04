/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_Account_AffiliationsTrigger
 * Description  : All Trigger Logic for ZTS_EU_Account_Affiliations object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 13th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/13/2020          Created 
*****************************************************************************************************************************************/

trigger ZTS_EU_Account_AffiliationsTrigger on ZTS_EU_Account_Affiliations__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_Account_AffiliatTriggerHandler(),Bypass_Triggers__mdt.ZTS_EU_Account_Affiliations_Bypass__c);
}