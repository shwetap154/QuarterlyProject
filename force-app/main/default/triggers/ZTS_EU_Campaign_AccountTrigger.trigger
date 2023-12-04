/****************************************************************************************************************************************** 
 * Trigger Name : ZTS_EU_Campaign_AccountTrigger
 * Description  : This is trigger on ZTS_EU_Campaign_Account__c for all events.
 *      
 * Created By   : Slalom/David Stern 
 * Created Date : 11 February 2020
 *
 * Modification Log:  
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Developer                Date               Description 
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Slalom(David)		   02/11/2020		   All logic moved to INTLZTS_EU_Campaign_AccountService Class.
*****************************************************************************************************************************************/
trigger ZTS_EU_Campaign_AccountTrigger on ZTS_EU_Campaign_Account__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) 
{
	ZTS_EU_Campaign_AccountTriggerHandler campAccountTriggerHandler = new ZTS_EU_Campaign_AccountTriggerHandler();
    // DispatchTriggerHandler.setRecursionContexts(campAccountTriggerHandler);
	DispatchTriggerHandler.dispatchHandlerToFire(new ZTS_EU_Campaign_AccountTriggerHandler(), Bypass_Triggers__mdt.ZTS_EU_Campaign_Account_Bypass__c);
}