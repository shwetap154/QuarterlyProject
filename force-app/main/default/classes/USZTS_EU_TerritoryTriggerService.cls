/****************************************************************************************************************************************** 
* Class Name   : USZTS_EU_TerritoryTriggerService
* Description  : Logic for all US ZTS_EU_Territory__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 12 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/12/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class USZTS_EU_TerritoryTriggerService 
{
    public static void beforeDelete(List<ZTS_EU_Territory__c> triggerOld, Map<Id, ZTS_EU_Territory__c> triggerOldMap)
    {
        	SL_ZTS_TerritoryTriggerHandler objHandler = new SL_ZTS_TerritoryTriggerHandler();
            objHandler.onBeforeDelete(triggerOld);
    }    
}