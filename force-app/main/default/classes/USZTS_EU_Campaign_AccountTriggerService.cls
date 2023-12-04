/****************************************************************************************************************************************** 
* Class Name   : USZTS_EU_Campaign_AccountTriggerService
* Description  : Logic for all US ZTS_EU_Campaign_Account triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 11 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/11/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class USZTS_EU_Campaign_AccountTriggerService 
{   
    public static void afterInsert(List<ZTS_EU_Campaign_Account__c> triggerNew, Map<Id, ZTS_EU_Campaign_Account__c> triggerNewMap) 
    {
        if(controlTriggers.execute_ZTS_US_Campaign_Account_Trigger)
        {
            controlTriggers.execute_CampaignMember_Trigger = false;
            ZTS_US_PopulateCampMemFromTargetedAccnt.insertCampMem(triggerNew);
        }
    }
    public static void afterUpdate(List<ZTS_EU_Campaign_Account__c> triggerOld, Map<Id, ZTS_EU_Campaign_Account__c> triggerOldMap, List<ZTS_EU_Campaign_Account__c> triggerNew, Map<Id, ZTS_EU_Campaign_Account__c> triggerNewMap) 
    {
        if(controlTriggers.execute_ZTS_US_Campaign_Account_Trigger)
        {
            controlTriggers.execute_CampaignMember_Trigger = false;
            ZTS_US_PopulateCampMemFromTargetedAccnt.updCampMem(triggerNew, triggerOldMap); 
        }
    }
    public static void afterDelete(List<ZTS_EU_Campaign_Account__c> triggerOld, Map<Id, ZTS_EU_Campaign_Account__c> triggerOldMap) 
    {
        if(controlTriggers.execute_ZTS_US_Campaign_Account_Trigger)
        {
            controlTriggers.execute_CampaignMember_Trigger = false;
            ZTS_US_PopulateCampMemFromTargetedAccnt.delCampMem(triggerOld);
        }
    }
}