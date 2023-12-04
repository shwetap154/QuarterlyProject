/****************************************************************************************************************************************** 
* Class Name   : INTLZTS_EU_Campaign_AcctTriggerService
* Description  : Logic for all INTL ZTS_EU_Campaign_Account triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 11 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/11/2020          Created, Logic from all triggers moved to this class.
* Aritra (Cognizant)      03/03/2021          Commeneted after insert action (SC-008159)        
*****************************************************************************************************************************************/
public class INTLZTS_EU_Campaign_AcctTriggerService 
{
    public static void afterInsert(List<ZTS_EU_Campaign_Account__c> triggerNew, Map<Id, ZTS_EU_Campaign_Account__c> triggerNewMap) 
    {
        //ZTS_EU_PopulateCampMemFromTargetedAccnt.insertCampMem(triggerNew);  --commented by Aritra (SC-008159)                                                                
    }
    public static void afterUpdate(List<ZTS_EU_Campaign_Account__c> triggerOld, Map<Id, ZTS_EU_Campaign_Account__c> triggerOldMap, List<ZTS_EU_Campaign_Account__c> triggerNew, Map<Id, ZTS_EU_Campaign_Account__c> triggerNewMap) 
    {
        ZTS_EU_PopulateCampMemFromTargetedAccnt.delCampMem(triggerNew, triggerOldMap);  
    }
}