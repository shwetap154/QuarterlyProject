/****************************************************************************************************************************************** 
* Class Name   : USZTS_EU_ColleagueTriggerService
* Description  : Logic for all US ZTS_EU_Colleague__c triggers housed here.
* Created By   : Slalom/David Stern 
* Created Date : 11 February 2020
*
* Modification Log:  
* ---------------------------------------------------------------------------------------------------------------------------------------
* Developer                Date               Description 
* ---------------------------------------------------------------------------------------------------------------------------------------
* David Stern(Slalom)     02/11/2020          Created, Logic from all triggers moved to this class.
*****************************************************************************************************************************************/
public class USZTS_EU_ColleagueTriggerService 
{
    public static void beforeDelete(List<ZTS_EU_Colleague__c> triggerOld, Map<Id, ZTS_EU_Colleague__c> triggerOldMap)
    {
        USAttendeeService.deleteAccShareForColleagues(triggerOld);
        
    }
    
    public static void afterInsert(List<ZTS_EU_Colleague__c> triggerNew, Map<Id, ZTS_EU_Colleague__c> triggerNewMap) 
    {
        USAttendeeService.createEventRelationsForColleagues(triggerNew);
        USAttendeeService.createAccShareForColleagues(triggerNew);
    }

    public static void afterDelete(List<ZTS_EU_Colleague__c> triggerOld, Map<Id, ZTS_EU_Colleague__c> triggerOldMap) 
    {
        USAttendeeService.deleteEventRelationsForColleague(triggerOldMap);
    }
}