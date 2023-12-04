/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_US_ExpensesTrigger
 * Description  : All Trigger Logic for ZTS_US_Expenses object.
 * Created By   : Slalom(Art Smorodin) 
 * Created Date : 14th February, 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Art Smorodin           02/14/2020          Created 
*****************************************************************************************************************************************/

trigger ZTS_US_ExpensesTrigger on ZTS_US_Expenses__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_US_ExpensesTriggerHandler(),Bypass_Triggers__mdt.ZTS_EU_Account_Affiliations_Bypass__c);
}